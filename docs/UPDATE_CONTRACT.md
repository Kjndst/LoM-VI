# LoM-VI Update Contract

This file defines which release component owns each kind of LoM-VI change. The launcher consumes the channel manifest and updates only the components whose versions changed, while resolving declared dependencies automatically.

## Component ownership

### Translation
Use a new Translation version when the change is data/content only, for example:
- new or corrected Vietnamese strings;
- terminology/wording changes;
- updated sparse translation tables;
- no runtime/hook behavior change is required.

Translation depends on Core. The launcher must ensure the required Core is present before applying Translation.

### Core
Use a new Core version when runtime behavior changes, for example:
- new or expanded hooks;
- NativeScan/runtime discovery changes;
- new setter/getter/lifecycle interception;
- fixes for source strings that already exist in the translation database but are not yet reached/displayed in game;
- loader/bootstrap/runtime repair.

Core is an internal dependency. It is managed automatically by the launcher and does not need to be exposed as a user-selectable component in the main UI.

### Font
Use a new Font version when the game font payload or its integration changes. Font remains independent from Translation.

## Combined changes

If one release needs both new translation data and new runtime coverage, publish new versions of both Translation and Core. If Font also changes, bump Font as well. Never hide a changed component behind an unchanged version.

## Launcher releases

A new launcher EXE is not required for ordinary Translation, Core/hook, or Font updates. Publish a new launcher only when the launcher/updater itself changes, such as:
- manifest/update protocol changes;
- install/uninstall/state behavior changes;
- launcher UI/UX changes;
- new security/integrity behavior that cannot be delivered through an existing component.

### No minimum-launcher component gate

The stable `lomvi.release.v2` channel does not use `min_launcher` to mark Translation, Core or Font incompatible. Launcher age must never turn otherwise valid localization components into `Chưa tương thích`.

If a future launcher introduces a genuinely incompatible update protocol, publish a new manifest schema/channel contract and handle that explicitly at launcher level. Do not reuse component compatibility as a launcher-version gate.

## Release invariants

1. Every changed component gets a new version.
2. Manifest URL, size and SHA-256 must describe the exact published payload.
3. Dependencies must be resolved before apply.
4. Do not silently replace a published payload while keeping the same version.
5. Translation remains sparse/permissive; missing UI coverage is repaired by Core rather than falsely marking valid Translation data incompatible.
6. User-facing actions stay simple: Install / Update / Uninstall. Component dependency planning is automatic.
7. Never report install/update success until the launcher verifies the final managed state on disk/runtime. An operation returning without an error is not sufficient proof of success.
