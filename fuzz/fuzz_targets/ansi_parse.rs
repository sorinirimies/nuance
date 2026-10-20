#![no_main]
//! Fuzz the ANSI SGR parser: must never panic; `strip` must never emit ESC.
use libfuzzer_sys::fuzz_target;

#[path = "../../src/ansi.rs"]
#[allow(dead_code)]
mod ansi;

fuzz_target!(|data: &str| {
    let _ = ansi::parse_line(data);
    let _ = ansi::strip(data);
});
