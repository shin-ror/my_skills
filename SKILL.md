---
name: cocos-creator-prefab-builder
description: Build and edit Cocos Creator prefab scaffolds for UI screens such as login panels, HUDs, dialogs, and menus. Use when Codex must convert interface requirements into prefab node hierarchies, output prefab JSON, or refine existing Cocos Creator prefab layouts for 2D UI workflows.
---

# Cocos Creator Prefab Builder

Use this skill to turn UI requirements into importable Cocos Creator prefab scaffolds.
English is the primary instruction language; Traditional Chinese docs are maintainer references.

## Follow this workflow

1. Capture requirements in a node spec JSON.
2. Generate a starter prefab from the node spec.
3. Apply manual component wiring in Cocos Creator (Sprite, Label, Button, Widget, project scripts).

## Create the node spec first

Write a spec that follows the schema in `references/prefab-spec-schema.md`.

- Keep node names unique.
- Set `root` to the top node.
- For every non-root node, set `parent` to an existing node.
- Provide width and height for every node.

## Generate prefab output

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate-prefab-json.ps1 `
  -SpecPath assets/examples/login-ui.spec.json `
  -OutputPath assets/examples/login-ui.prefab
```

The script outputs a prefab scaffold with project-style metadata fields, including:
- `cc.Prefab`
- `cc.Node`
- `cc.UITransform`
- `cc.CompPrefabInfo`
- `cc.PrefabInfo`

## Apply interface components after scaffold generation

Open the generated `.prefab` in Cocos Creator and then:

1. Add visual components (`cc.Sprite`, `cc.Label`) to target nodes.
2. Add interaction components (`cc.Button`) where needed.
3. Add layout helpers (`cc.Widget`, `cc.Layout`) for responsive behavior.
4. Add project scripts in the editor and let Cocos serialize internal metadata.

## If editing an existing prefab

- Keep existing node names whenever possible to avoid script binding breaks.
- Patch only required nodes and transforms.
- Preserve root path and stable hierarchy for runtime lookup code.
- For Project feature flows, read the module pattern references before editing:
  - `references/luckywheel-patterns.md`
  - `references/uijppayresult-patterns.md`
  - `references/uithreetopwin-patterns.md`
  - `references/spine-runtime-patterns.md`
  - `references/audiomanagerutil-patterns.md`
  - `references/audiopool-conventions.md`
  - `references/trackerutil-patterns.md`
  - `references/viberator-patterns.md`
  - `references/tweenextend-patterns.md`
  - `references/maingame-statusflow-patterns.md`
  - `references/network-packet-boundaries.md`
  - `references/error-ui-severity-patterns.md`
  - `references/customsetting-patterns.md`
  - `references/buybonus-patterns.md`
  - `references/betpanel-patterns.md`
  - `references/uibetcontroller-patterns.md`
  - `references/uibetpanel-patterns.md`
  - `references/uiroadmap-patterns.md`
  - `references/uiquicktip-patterns.md`
  - `references/uijackpot-patterns.md`
  - `references/uinewsticker-patterns.md`
  - `references/uibalance-patterns.md`
  - `references/uiautopanel-patterns.md`
  - `references/numberprecision-patterns.md`

## Resources

- References index (English): `references/README.md`
- References index (Traditional Chinese): `references/README-zh-tw.md`
- Node-spec format and defaults: `references/prefab-spec-schema.md`
- Project conventions: `references/project-conventions.md`
- Project copied reference pack: `assets/reference-pack/project/REFERENCE.md`
- LuckyWheel implementation patterns: `references/luckywheel-patterns.md`
- UiJpPayResult implementation patterns: `references/uijppayresult-patterns.md`
- UiThreeTopWin implementation patterns: `references/uithreetopwin-patterns.md`
- Spine runtime patterns (`setAnimation` / `setCompleteListener` / `setEventListener` / `setMix`): `references/spine-runtime-patterns.md`
- Audio manager utility patterns (`playEffect` / `playFadeMusic` / `playDealer`): `references/audiomanagerutil-patterns.md`
- Audio pool naming/usage conventions (`BGM_POOL` / `SOUND_POOL` / `VOICE_POOL`): `references/audiopool-conventions.md`
- Tracker utility patterns (`Init` / `SetUserID` / `TrackEvent` / `TrackScreen` / `TrackExcp`): `references/trackerutil-patterns.md`
- Viberator patterns (`Node.shake` / `navigator.vibrate`): `references/viberator-patterns.md`
- TweenExtend patterns (`pulse` / `fade` / `bezier` / `cubicBezier`): `references/tweenextend-patterns.md`
- MainGame status flow patterns (single-player baseline): `references/maingame-statusflow-patterns.md`
- Network & packet boundaries (`ProtoManager` / `GameController` / event-property drive): `references/network-packet-boundaries.md`
- Error severity UI handling (small=`toast`, medium/large=`popup`): `references/error-ui-severity-patterns.md`
- CustomSetting runtime tuning patterns: `references/customsetting-patterns.md`
- BuyBonus implementation patterns: `references/buybonus-patterns.md`
- BetPanel implementation patterns: `references/betpanel-patterns.md`
- UiBetController implementation patterns: `references/uibetcontroller-patterns.md`
- UiBetPanel implementation patterns: `references/uibetpanel-patterns.md`
- UiRoadMap implementation patterns: `references/uiroadmap-patterns.md`
- UiQuickTip implementation patterns: `references/uiquicktip-patterns.md`
- UiJackpot implementation patterns: `references/uijackpot-patterns.md`
- UiNewsTicker implementation patterns: `references/uinewsticker-patterns.md`
- UiBalance implementation patterns: `references/uibalance-patterns.md`
- UiAutoPanel implementation patterns: `references/uiautopanel-patterns.md`
- Number precision patterns: `references/numberprecision-patterns.md`
- Chinese developer notes (for maintainers): `references/developer-guide-zh-tw.md`
- Starter spec: `assets/examples/login-ui.spec.json`
- Prefab generator: `scripts/generate-prefab-json.ps1`
