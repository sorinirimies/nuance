//! Minimal ANSI SGR parser: turns the true-color escape sequences that
//! `nushell-prompt.nu` emits (24-bit `38;2;r;g;b` / `48;2;r;g;b` + bold/reset)
//! into a ratatui `Line`, so the picker can render the *exact* prompt output
//! nu would produce, without needing a general-purpose terminal emulator
//! crate as a dependency.

use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};

/// Parse one line of text containing ANSI SGR escape sequences into a
/// ratatui `Line` with per-span styling. Unsupported/unknown codes are
/// ignored rather than erroring — the goal is "looks right for what nu
/// actually emits", not a full terminal emulator.
pub fn parse_line(input: &str) -> Line<'static> {
    let mut spans: Vec<Span<'static>> = Vec::new();
    let mut style = Style::default();
    let mut current = String::new();
    let chars: Vec<char> = input.chars().collect();
    let mut i = 0;

    macro_rules! flush {
        () => {
            if !current.is_empty() {
                spans.push(Span::styled(std::mem::take(&mut current), style));
            }
        };
    }

    while i < chars.len() {
        if chars[i] == '\u{1b}' && chars.get(i + 1) == Some(&'[') {
            // find terminating 'm'
            let start = i + 2;
            let mut end = start;
            while end < chars.len() && chars[end] != 'm' {
                end += 1;
            }
            if end < chars.len() {
                let codes_str: String = chars[start..end].iter().collect();
                flush!();
                apply_codes(&codes_str, &mut style);
                i = end + 1;
                continue;
            }
        }
        current.push(chars[i]);
        i += 1;
    }
    flush!();

    if spans.is_empty() {
        spans.push(Span::raw(String::new()));
    }
    Line::from(spans)
}

/// Apply a `;`-separated list of SGR codes (e.g. `"1;38;2;137;180;250"`) to
/// `style` in place.
fn apply_codes(codes_str: &str, style: &mut Style) {
    let codes: Vec<i64> = codes_str
        .split(';')
        .filter_map(|c| c.parse().ok())
        .collect();
    let mut i = 0;
    while i < codes.len() {
        match codes[i] {
            0 => *style = Style::default(),
            1 => *style = style.add_modifier(Modifier::BOLD),
            22 => *style = style.remove_modifier(Modifier::BOLD),
            38 if codes.get(i + 1) == Some(&2) && i + 4 < codes.len() => {
                let (r, g, b) = (codes[i + 2] as u8, codes[i + 3] as u8, codes[i + 4] as u8);
                *style = style.fg(Color::Rgb(r, g, b));
                i += 4;
            }
            48 if codes.get(i + 1) == Some(&2) && i + 4 < codes.len() => {
                let (r, g, b) = (codes[i + 2] as u8, codes[i + 3] as u8, codes[i + 4] as u8);
                *style = style.bg(Color::Rgb(r, g, b));
                i += 4;
            }
            39 => *style = Style { fg: None, ..*style },
            49 => *style = Style { bg: None, ..*style },
            _ => {}
        }
        i += 1;
    }
}

/// Strip all ANSI SGR sequences, leaving plain text (used for fuzzy matching).
pub fn strip(input: &str) -> String {
    let mut out = String::with_capacity(input.len());
    let chars: Vec<char> = input.chars().collect();
    let mut i = 0;
    while i < chars.len() {
        if chars[i] == '\u{1b}' && chars.get(i + 1) == Some(&'[') {
            let mut j = i + 2;
            while j < chars.len() && chars[j] != 'm' {
                j += 1;
            }
            i = j + 1;
            continue;
        }
        out.push(chars[i]);
        i += 1;
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn strip_removes_escape_sequences() {
        assert_eq!(strip("\x1b[1;38;2;1;2;3mhello\x1b[0m"), "hello");
    }

    #[test]
    fn strip_passes_through_plain_text() {
        assert_eq!(strip("plain text"), "plain text");
    }

    #[test]
    fn parse_line_extracts_plain_text() {
        let line = parse_line("\x1b[1;38;2;255;0;0mred\x1b[0m plain");
        let rendered: String = line.spans.iter().map(|s| s.content.as_ref()).collect();
        assert_eq!(rendered, "red plain");
    }

    #[test]
    fn parse_line_applies_fg_color() {
        let line = parse_line("\x1b[38;2;10;20;30mtext\x1b[0m");
        assert_eq!(line.spans[0].style.fg, Some(Color::Rgb(10, 20, 30)));
    }

    #[test]
    fn parse_line_applies_bold() {
        let line = parse_line("\x1b[1mbold\x1b[0m");
        assert!(line.spans[0].style.add_modifier.contains(Modifier::BOLD));
    }

    #[test]
    fn parse_line_handles_no_escapes() {
        let line = parse_line("no escapes here");
        assert_eq!(line.spans.len(), 1);
        assert_eq!(line.spans[0].content.as_ref(), "no escapes here");
    }

    #[test]
    fn parse_line_resets_style_on_code_zero() {
        let line = parse_line("\x1b[38;2;1;2;3ma\x1b[0mb");
        assert_eq!(line.spans.len(), 2);
        assert_eq!(line.spans[0].style.fg, Some(Color::Rgb(1, 2, 3)));
        assert_eq!(line.spans[1].style.fg, None);
    }
}
