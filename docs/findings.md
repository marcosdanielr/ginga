# Findings — where the block lives

How the Brazil camera/screen-share block works, and why the patch is what it is.

## Root cause

The gate is a **client-side experiment**, `2026-08-video-guard`, defined in Webpack
module **625075**:

```js
a = (0, i.mj)({
  name: "2026-08-video-guard",
  kind: "user",
  defaultConfig: { videoEnabled: true },
  variations: { 1: { videoEnabled: false }, 2: { videoEnabled: false } },
});
```

The module's export `k` is the experiment object, with
`getConfig({ location }) -> { videoEnabled }`. Users in Brazil are assigned to
variation 1 or 2, so `videoEnabled` resolves to `false`.

## How it disables video

`getConfig(...).videoEnabled` is read across the client:

- `222692` `handleCameraUnavailable` (modal)
- `702904` `handleScreenshareUnavailable` (modal)
- `300128` `VideoGuardBannerManager`
- `177141` notice `VIDEO_UNSUPPORTED_BROWSER`
- `453028` MediaEngineStore, `tc(e) = getConfig(e).videoEnabled`

The button itself (tooltip "Camera Unavailable") comes from module `151476`:

```js
cameraUnavailable = firstVideoDevice.disabled || !supports(O5.VIDEO)
```

Confirmed live in Brazil (no VPN):

```
getConfig().videoEnabled = false
supports(VIDEO)          = false
video device "default"   = { disabled: true }
```

None of these are hardware limits — the camera works fine over a VPN — so
`supports(VIDEO)` and the disabled device both trace back to the same guard. The
MediaEngine reads the guard at initialization, which is why a runtime override
arrives too late: the patch has to run at module load. A Vencord patch does exactly
that.

## The patch

Module `625075`, flip both variations from `videoEnabled:!1` to `videoEnabled:!0`.
Implemented in `../plugin/index.tsx` as a regex replacement scoped to the module
found by the `"2026-08-video-guard"` string.

## If it breaks

Discord may rotate the experiment name/shape. Re-find it with `../tools/README.md`.
