# hydro-cores3-mount

Parametric OpenSCAD pipe-clamp + TS35 DIN-rail section for the
M5Stack CoreS3 on a vertical 1-1/2" Schedule-40 PVC pipe. Sibling
to [`hydro-tapco-mount`](../hydro-tapco-mount) — same pipe, same
clamp pattern, designed to share the rig with the camera mount.

The CoreS3 has a female TS35 clip on its back (35 mm × 7.5 mm
per IEC 60715). This part presents a printed male TS35 rail
section that the device clips onto. The rail runs **horizontally**
— perpendicular to the pipe, the standard DIN-rail orientation —
so gravity seats the device's spring-clip on the lower flange.
Slide the device on from either end of the rail. Reposition height
by loosening the clamp bolts and sliding the whole assembly up or
down the pipe.

## Files

| File | Re-render with | Notes |
|------|----------------|-------|
| [`cores3-mount.scad`](cores3-mount.scad) | — | Source. Set `mode` at the top. |
| `cores3-mount_rail.stl` | `mode = "half_a"` (the rail half) | Print **one** |
| `cores3-mount_clamp.stl` | `mode = "half_b"` (the plain half) | Print **one** |

## BOM (per mount)

- 2 × M4 socket-cap bolts, 16 mm long (clamp bolts — one per side)
- 2 × M4 hex nuts (captive, one in each of Half A's bolt ears,
  hidden behind the rail once installed)
- A piece of 1-1/2" Schedule-40 PVC pipe (nominal OD 48.26 mm)
- An M5Stack CoreS3

## Render

| Mode | Renders |
|------|---------|
| `"half_a"` | Rail half — print one; rail-flange side down, supports around the screw-hole area. |
| `"half_b"` | Plain half — print one. |
| `"assembly"` | Both halves on a transparent dummy pipe. |
| `"exploded"` | Both halves separated with dummy bolts and nuts. |

Render (F6), export STL.

## Print orientation

**Half A (rail half):** prints **rail-flange side down** — the
flat rail face on the bed. The flange overhangs land directly on
the build plate, so they need no support, but the bolt-ear /
screw-hole area now overhangs the bed: **add supports around the
screw holes.**

**Half B (plain half):** prints with the bore axis vertical — it
stands as a half-tube on the bed, body and ears extruding as a
constant cross-section per layer, **no supports needed.**

## Print settings

- **Material:** PETG. Better fatigue tolerance for the
  captive-nut clamp force, and humidity-tolerant.
- **Layer height:** 0.2 mm.
- **Infill:** 20 % gyroid or grid.
- **Perimeters:** 3.
- **Supports:** around Half A's screw-hole area only; none for
  Half B.

## Rail-clip clearance — why the plate is narrower than the rail

In a real DIN-rail install, the rail's flanges sit on a
backpanel and the device's clip hooks reach in past the flange
edges from outside the rail. To reproduce that here, the
printed support plate is exactly the width of the rail's HAT
TOP (27 mm) along the pipe axis — not the width of the flanges
(35 mm). The flanges overhang the plate by ~4 mm above and
below, leaving open air for the hooks to wrap around. If you
change `RAIL_HAT_W` or `PLATE_W` in the SCAD, keep them equal.

## Fit-test before final print

Run a fit-test of both halves at 0.3 mm layer / 0 % infill
/ 2 perimeters first. Wrap them around an actual offcut of the
pipe and dry-fit the CoreS3 onto the rail:

- **Device clip won't engage / binds going on** → increase
  `RAIL_GAP` (try 0.3 mm, then 0.4 mm).
- **Device wobbles or slides off when bumped** → reduce
  `RAIL_GAP` (try 0.1 mm).
- **Pipe still spins under modest hand torque** → reduce
  `PIPE_OD` by 0.3 mm.
- **Pipe-clamp halves bottom out before gripping** → increase
  `CLAMP_GAP`.
- **Captive nut spins in its hex pocket** → reduce `NUT_FLATS`
  by 0.1 mm.

## Assembly

1. Drop one M4 hex nut into each of the two pockets on the
   outer faces of **Half A's** bolt ears (the rail side). They
   tuck behind the rail and stay captive.
2. Stand the pipe vertical. Hold Half A against one side of the
   pipe (with the rail facing the direction you want the device
   to point) and Half B against the opposite side so their bolt
   ears line up.
3. Drop an M4 bolt through each of **Half B's** counterbores
   (the back side, away from the device), across the gap, and
   into the captive nuts on Half A.
4. Tighten both bolts evenly with a hex key — alternate sides a
   few turns at a time so the halves close on the pipe square.
5. Slide the CoreS3 onto the rail from either end; gravity seats
   its clip on the lower flange.

## Re-aiming or relocating

- **Up / down the pipe:** loosen both clamp bolts 1–2 turns,
  slide the assembly up or down, retighten. The CoreS3 can stay
  clipped on the rail through this — or lift it off first.
- **Aim direction:** loosen, rotate the clamp around the pipe
  axis, retighten. The CoreS3 rotates with the clamp.
- **Remove the device:** slide it off either end of the rail.
- **Remove the clamp:** fully remove both bolts, separate the
  two halves, lift off the pipe.

## Pairing with the camera mount

Both `hydro-tapco-mount` and `hydro-cores3-mount` clamp to the
same 1.5" pipe, so they can sit on the same vertical run a few
inches apart. With both clamps rotated to the same direction,
the camera and the dashboard face the same way and you can see
both from one viewpoint.
