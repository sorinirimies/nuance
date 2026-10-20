#![no_main]
//! Fuzz Nushell arg quoting: output must be a well-formed sequence of
//! double-quoted literals (no unescaped quote/backslash inside).
use libfuzzer_sys::fuzz_target;

fn quote(args: &[String]) -> String {
    args.iter()
        .map(|a| format!("\"{}\"", a.replace('\\', "\\\\").replace('"', "\\\"")))
        .collect::<Vec<_>>()
        .join(" ")
}

fuzz_target!(|args: Vec<String>| {
    let out = quote(&args);
    // Tokenize like nu: walk literals, honoring backslash escapes.
    let mut chars = out.chars().peekable();
    let mut n = 0;
    while let Some(c) = chars.next() {
        assert_eq!(c, '"');
        loop {
            match chars.next().expect("unterminated literal") {
                '\\' => assert!(chars.next().is_some()),
                '"' => break,
                _ => {}
            }
        }
        n += 1;
        if let Some(sp) = chars.next() {
            assert_eq!(sp, ' ');
        }
    }
    assert_eq!(n, args.len());
});
