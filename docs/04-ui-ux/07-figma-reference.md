# Figma Reference

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: repository-wide search of `docs/` and `vithey_app/` (no Figma URL found); `docs/Prompt Frontend/Screen prompt/**`, `docs/Prompt Frontend/screen image/**`, `docs/Prompt Frontend/run-genz-complete/DESIGN_SYSTEM.md`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [UI/UX overview](01-ui-ux-overview.md) · [Design system](04-design-system.md)

## 1. Figma source of truth

**Figma link: TBD — Requires confirmation.**

An exhaustive search of the repository (all `docs/` folders and `vithey_app/`) found **no Figma file link, no Figma embed, and no Figma node IDs**. The only occurrences of the word "Figma" are unrelated (a fixture skill label, a test tool name, a color-picker comment and a generic skill in an example site). [VERIFIED — repository search]

Therefore this design documentation cannot trace to a design tool file. Provide the Figma file URL and page/frame IDs to complete this section — TBD — Requires confirmation.

## 2. What design reference material does exist

The repository does contain **prompt-based screen specifications and exported screen images**, which are the de-facto design references:

| Artefact | Path | Nature |
|---|---|---|
| Screen specifications | `docs/Prompt Frontend/Screen prompt/**` (`auth`, `chat`, `chatbot`, `finance`, `global_widget`, `job_apply`, `map`, `media`, `notification`, `profile`, `search`, `setting`, `upload_cv`) | Markdown specs (layout, states, API notes) |
| Screen images | `docs/Prompt Frontend/screen image/**` | Exported reference images by feature |
| Design system | `docs/Prompt Frontend/run-genz-complete/DESIGN_SYSTEM.md` | Written visual contract (brand, radii, GenZ principles) |
| Component kit | `docs/Prompt Frontend/COMPONENT_KIT.md` | Shared widget contract |
| Foundation | `docs/Prompt Frontend/Screen prompt/00-foundation-prompt.md` | Theme/token foundation spec |

[VERIFIED — directory listings]

## 3. Traceability approach

Because there is no Figma file, requirement-to-design traceability is maintained through:

1. `DESIGN_SYSTEM.md` → implemented token files (`AppColors`, `VitheyType`, `VitheyRadii`, `AppSemanticColors`). [VERIFIED]
2. Screen prompt specs → implemented screens under `lib/modules/**` (see [Screen Inventory](03-screen-inventory.md)). [VERIFIED]
3. `COMPONENT_KIT.md` → widgets under `lib/core/widgets/` (see [Design System §6](04-design-system.md)). [VERIFIED]

## 4. Gaps and requests

- Figma file URL and ownership — TBD — Requires confirmation.
- Whether exported images under `screen image/` are the authoritative visuals or just references — TBD — Requires confirmation.
- Design revision history / versioning policy — TBD — Requires confirmation.
- Sign-off that the implemented theme matches the intended design — **Not yet formally assessed**.

> Note: design tokens in Dart are the current source of truth. Any future Figma file must be reconciled against `app_colors.dart`, `vithey_type.dart` and `vithey_radii.dart`.
