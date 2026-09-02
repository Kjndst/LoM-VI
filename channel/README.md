# LoM-VI update channel

Machine-consumed update channel for the LoM-VI Thin Client.

- `manifest.json`: current channel manifest.
- `core-0.2.0.2.zip`: runtime integration layer.
- Translation payload remains versioned as a GitHub Release asset.
- The launcher verifies declared SHA-256 and size before installation.

Core 0.2.0.2 supports both an existing `LOMModLoader` underlay and migration from the historical LoM-VI sparse loader. It does not require or install the English Patch.
