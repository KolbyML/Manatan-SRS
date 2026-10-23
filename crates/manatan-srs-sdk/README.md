# Manatan SRS extension SDK

Build Manatan SRS extensions as WebAssembly components in Rust. Implement
`Extension`, export it with `export_extension!`, and package the component
with a manifest declaring its requested permissions.

```rust,ignore
use manatan_srs_sdk::{collection, Extension};

#[derive(Default)]
struct DeckCounter;

impl Extension for DeckCounter {
    fn render(&mut self, surface: String, _context: String) -> String {
        if surface != "dashboard" { return String::new(); }
        format!("<p>You have {} decks.</p>", collection::list_decks().len())
    }
}

manatan_srs_sdk::export_extension!(DeckCounter);
```

The crate includes its WIT contract in `wit/world.wit`; no private Manatan
source tree is required. Extensions target `wasm32-unknown-unknown` and are
wrapped into components using `wasm-tools component new`.

Read the [authoring guide](https://github.com/KolbyML/Manatan-SRS/blob/master/docs/AUTHORING.md)
for the complete build, manifest, and installation workflow. Use only the
capabilities your extension needs, and test against the intended host version
and platform before distribution.

Licensed under MIT. See `LICENSE` in this package.
