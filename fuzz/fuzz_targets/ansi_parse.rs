#![no_main]
//! Fuzz the ANSI SGR parser: must never panic; `strip` must never emit ESC.
use libfuzzer_sys::fuzz_target;

#[path = "../../src/ansi.rs"]
#[allow(dead_code)]
mod ansi;

fuzz_target!(|data: &str| {
    let line = ansi::parse_line(data);
    let text: String = line.spans.iter().map(|s| s.content.as_ref()).collect();
    // both parsers must agree on the visible text
    assert_eq!(text, ansi::strip(data));
});
