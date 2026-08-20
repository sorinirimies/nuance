//! Interactive ratatui picker: an in-memory list + live preview pane.
//!
//! All picker items (name + rendered ANSI preview) are fetched once, up
//! front, via a single `nu` subprocess call (see `nu::fetch_picker_items`).
//! From then on, every keypress is served purely from memory — moving the
//! selection redraws the *actual* rendered prompt for the highlighted item
//! instantly, with no further calls to `nu` and no need to press Enter
//! first. This is the live-preview behavior Nushell's own `input list`
//! can't provide (it has no per-highlight callback).

use std::io;

use crossterm::event::{self, Event, KeyCode, KeyEventKind, KeyModifiers};
use crossterm::execute;
use crossterm::terminal::{
    disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen,
};
use ratatui::backend::CrosstermBackend;
use ratatui::layout::{Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, Borders, List, ListItem, ListState, Paragraph};
use ratatui::{Frame, Terminal};

use crate::ansi;
use crate::nu::PickerItem;

struct PickerState {
    items: Vec<PickerItem>,
    filter: String,
    filtered: Vec<usize>,
    selected: usize,
}

impl PickerState {
    fn new(items: Vec<PickerItem>) -> Self {
        let filtered = (0..items.len()).collect();
        Self {
            items,
            filter: String::new(),
            filtered,
            selected: 0,
        }
    }

    fn recompute_filter(&mut self) {
        let needle = self.filter.to_lowercase();
        self.filtered = self
            .items
            .iter()
            .enumerate()
            .filter(|(_, it)| {
                needle.is_empty()
                    || it.key.to_lowercase().contains(&needle)
                    || ansi::strip(&it.label).to_lowercase().contains(&needle)
            })
            .map(|(i, _)| i)
            .collect();
        self.selected = self.selected.min(self.filtered.len().saturating_sub(1));
    }

    fn current(&self) -> Option<&PickerItem> {
        self.filtered.get(self.selected).map(|&i| &self.items[i])
    }

    fn move_selection(&mut self, delta: i32) {
        if self.filtered.is_empty() {
            return;
        }
        let len = self.filtered.len() as i32;
        let next = (self.selected as i32 + delta).rem_euclid(len);
        self.selected = next as usize;
    }
}

/// Run the interactive picker. Returns `Ok(Some(key))` if the user picked an
/// item, `Ok(None)` if they cancelled (Esc/Ctrl-C).
pub fn pick(items: Vec<PickerItem>, title: &str) -> io::Result<Option<String>> {
    if items.is_empty() {
        return Ok(None);
    }

    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut state = PickerState::new(items);
    let result = run_loop(&mut terminal, &mut state, title);

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;

    result
}

fn run_loop(
    terminal: &mut Terminal<CrosstermBackend<io::Stdout>>,
    state: &mut PickerState,
    title: &str,
) -> io::Result<Option<String>> {
    loop {
        terminal.draw(|f| draw(f, state, title))?;

        if let Event::Key(key) = event::read()? {
            if key.kind != KeyEventKind::Press {
                continue;
            }
            match key.code {
                KeyCode::Esc => return Ok(None),
                KeyCode::Char('c') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                    return Ok(None)
                }
                KeyCode::Enter => return Ok(state.current().map(|it| it.key.clone())),
                KeyCode::Up => {
                    state.move_selection(-1);
                }
                KeyCode::Down => {
                    state.move_selection(1);
                }
                KeyCode::Backspace => {
                    state.filter.pop();
                    state.recompute_filter();
                }
                KeyCode::Char(c) => {
                    state.filter.push(c);
                    state.recompute_filter();
                }
                _ => {}
            }
        }
    }
}

fn draw(f: &mut Frame, state: &PickerState, title: &str) {
    let area = f.area();
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3), // filter box
            Constraint::Min(3),    // list
            Constraint::Length(5), // live preview
        ])
        .split(area);

    draw_filter(f, chunks[0], state, title);
    draw_list(f, chunks[1], state);
    draw_preview(f, chunks[2], state);
}

fn draw_filter(f: &mut Frame, area: Rect, state: &PickerState, title: &str) {
    let text = format!("/{}", state.filter);
    let p = Paragraph::new(text).block(
        Block::default()
            .borders(Borders::ALL)
            .title(format!(
                " {title} — type to filter, ↑↓ move, Enter pick, Esc cancel "
            ))
            .border_style(Style::default().fg(Color::DarkGray)),
    );
    f.render_widget(p, area);
}

fn draw_list(f: &mut Frame, area: Rect, state: &PickerState) {
    let items: Vec<ListItem> = state
        .filtered
        .iter()
        .map(|&i| {
            let it = &state.items[i];
            if it.key == "__sync__" {
                // Synthetic "sync with terminal" entry: it has no preview
                // arrow, just render its (already ANSI-colored) label
                // directly instead of the raw "__sync__" key.
                ListItem::new(ansi::parse_line(&it.label))
            } else {
                ListItem::new(Line::from(Span::raw(it.key.clone())))
            }
        })
        .collect();

    let mut list_state = ListState::default();
    if !state.filtered.is_empty() {
        list_state.select(Some(state.selected));
    }

    let list = List::new(items)
        .block(Block::default().borders(Borders::ALL).title(format!(
            " {} match{} ",
            state.filtered.len(),
            if state.filtered.len() == 1 { "" } else { "es" }
        )))
        .highlight_style(Style::default().add_modifier(Modifier::BOLD | Modifier::REVERSED))
        .highlight_symbol("\u{276f} ");

    f.render_stateful_widget(list, area, &mut list_state);
}

fn draw_preview(f: &mut Frame, area: Rect, state: &PickerState) {
    let block = Block::default()
        .borders(Borders::ALL)
        .title(" live preview ");
    let line = match state.current() {
        Some(it) => ansi::parse_line(&it.label),
        None => Line::from("(no matches)"),
    };
    let p = Paragraph::new(vec![Line::default(), line]).block(block);
    f.render_widget(p, area);
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::nu::PickerItem;

    fn item(key: &str, label: &str) -> PickerItem {
        PickerItem {
            key: key.to_string(),
            label: label.to_string(),
        }
    }

    #[test]
    fn filter_empty_matches_everything() {
        let mut s = PickerState::new(vec![item("full", "l1"), item("compact", "l2")]);
        s.recompute_filter();
        assert_eq!(s.filtered.len(), 2);
    }

    #[test]
    fn filter_narrows_by_substring_case_insensitive() {
        let mut s = PickerState::new(vec![item("full", "l1"), item("compact", "l2")]);
        s.filter = "COMP".to_string();
        s.recompute_filter();
        assert_eq!(s.filtered, vec![1]);
    }

    #[test]
    fn move_selection_wraps_around() {
        let mut s = PickerState::new(vec![item("a", "l"), item("b", "l"), item("c", "l")]);
        s.recompute_filter();
        assert_eq!(s.selected, 0);
        s.move_selection(-1);
        assert_eq!(s.selected, 2);
        s.move_selection(1);
        assert_eq!(s.selected, 0);
        s.move_selection(1);
        assert_eq!(s.selected, 1);
    }

    #[test]
    fn current_reflects_selection_after_filtering() {
        let mut s = PickerState::new(vec![
            item("full", "l1"),
            item("compact", "l2"),
            item("full2", "l3"),
        ]);
        s.filter = "full".to_string();
        s.recompute_filter();
        assert_eq!(s.filtered, vec![0, 2]);
        assert_eq!(s.current().unwrap().key, "full");
        s.move_selection(1);
        assert_eq!(s.current().unwrap().key, "full2");
    }

    #[test]
    fn move_selection_on_empty_filtered_is_noop() {
        let mut s = PickerState::new(vec![item("full", "l1")]);
        s.filter = "zzz".to_string();
        s.recompute_filter();
        assert!(s.filtered.is_empty());
        s.move_selection(1); // must not panic
        assert!(s.current().is_none());
    }

    #[test]
    fn pick_returns_none_for_empty_items() {
        // No terminal needed: the empty-items short-circuit returns before
        // touching the alternate screen.
        assert_eq!(pick(vec![], "test").unwrap(), None);
    }
}
