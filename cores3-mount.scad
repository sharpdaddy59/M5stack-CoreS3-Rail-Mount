// cores3-mount.scad — parametric pipe clamp with TS35 DIN-rail
// section, for 1.5" Sch 40 PVC. Sibling of hydro-tapco-mount.
//
// Use case: the M5Stack CoreS3 has a female TS35 DIN-rail clip
// on its back (35 mm wide × 7.5 mm depth, IEC 60715). This part
// clamps to a vertical 1-1/2" PVC pipe and presents a printed
// male TS35 rail section that the device clips onto. Rail runs
// HORIZONTALLY (perpendicular to the pipe), so gravity seats the
// device's spring-clip onto the lower flange — the standard
// DIN-rail orientation. Slide the device on from either end of
// the rail. Loosen the clamp bolts to reposition up/down the pipe.
//
// Coordinate convention (design space):
//   Y = pipe axis (vertical in use).
//   Z = horizontal axis perpendicular to pipe, in the radial
//       direction the plate + rail extend. Plate face is at +Z.
//   X = the other horizontal axis. The rail length runs along X
//       (so device slides left/right). Bolts are along Z, with
//       the two bolt ears extending out in ±X.
//   Mating plane between the two halves: XY plane (Z = 0).
//   Half A (the half with the plate + rail): Z >= +G.
//   Half B (the half without): Z <= -G.
//
// Rail-clip clearance trick: in a real DIN-rail install, the
// rail's flanges sit on a backpanel and the device's clip hooks
// reach in past the flange edges from outside the rail. To
// reproduce that here, the printed support plate is exactly the
// width of the rail's HAT TOP (27 mm) along the pipe axis (Y),
// not the width of the flanges (35 mm). The flanges then overhang
// the plate by ~4 mm above and below in Y, leaving open air for
// the device's clip hooks to wrap around.
//
// Print orientation (recommended):
//   Half A (plate + rail): lay it RAIL-FLANGE SIDE DOWN — the flat
//   rail face on the bed. The flange overhangs then rest directly
//   on the build plate (no support needed there), but the bolt
//   ears / screw-hole area overhang the bed, so add supports
//   around the screw holes.
//   Half B (no rail): print with the bore axis VERTICAL — it sits
//   as a half-annulus tube on the bed; body and ears extrude as a
//   constant cross-section per layer, no supports needed.
//   The half_*_print() wrappers below just give a canonical export
//   placement; re-orient Half A in your slicer as above.
//
// Top-of-file `mode` selects what to render:
//   "half_a" / "half_b" / "assembly" / "exploded"

mode = "exploded";

// =============================================================
// PARAMETERS
// =============================================================

// ----- Pipe / clamp body -------------------------------------
PIPE_OD       = 48.5;   // 1.5" Sch 40 PVC nominal OD = 48.26 mm.
                        // CPVC and DWV pipe differ — measure first.
CLAMP_LEN     = 27.0;   // length of the clamp along the pipe axis.
                        // Matches the rail length so the rail sits
                        // on the body without cantilever along Y.
CLAMP_GAP     = 1.5;    // mating-plane gap when un-tightened.
                        // Bolts close this gap to grip. If halves
                        // bottom out before grip, increase.
WALL          = 4.0;    // shell wall thickness

// ----- Fasteners (M4 socket cap + hex nut, BOTH sides) -------
// Bolt heads recess into Half B (the no-rail half) so a hex key
// can reach them from the back of the assembly. Captive nuts
// drop into pockets on Half A — once installed they sit tucked
// behind the rail and never need to be touched again.
BOLT_DIA      = 4.4;    // through-hole, M4 clearance fit
HEAD_DIA      = 7.5;    // socket-cap head counterbore
HEAD_DEPTH    = 4.0;
NUT_FLATS     = 7.2;    // M4 hex nut across-flats
NUT_DEPTH     = 3.5;
EAR_LEN       = 12.0;   // bolt-ear extension past the shell
EAR_THK       = 6.0;    // bolt-ear thickness (perpendicular to
                        // mating plane)

// ----- DHT20 sensor mounting pad (Half B only) ---------------
// Extends ONE bolt ear into a flat pad. The Grove DHT20 breakout
// bolts down FLAT against the ear's outer face, mounted VERTICAL:
// its long axis runs along Y (the pipe axis) so it stands up
// alongside the pipe instead of cantilevering radially.
//
// 3 mounting holes (Seeed Grove DHT20): a PAIR on the Grove-
// connector edge, SENSOR_PAIR_DX apart along X, and a SINGLE hole
// SENSOR_PAIR_TO_SINGLE away along Y.
//
// The holes sit OUTBOARD of the ear tip (SENSOR_HOLE_INSET_X), so
// the board clears the central M4 clamp bolt purely in X -- the
// bolt-head counterbore stays open through the pad for hex-key
// access beside the board. Because the board (~40 mm) is longer
// than the clamp, the pad hangs past ONE clamp end (the board's
// natural overhang) and sits FLUSH with the OTHER. That flush edge
// is what lets Half B print support-free: the pad's outboard strip
// is carried straight up from the bed. A centred pad would
// overhang both ends and need supports.
//
// M2 screws from the board side; M2 nuts are CAPTIVE in hex
// pockets on the pad's INNER face (same idea as Half A's
// nut_pocket) so you only turn the screw.
//   >>> SENSOR_* dims are "MEASURE YOUR BOARD" values <<<
//   >>> Keep the pad a plain rectangle (Y-constant, no fillets)
//       or the no-support vertical print of Half B breaks. <<<
SENSOR_ENABLE   = false;   // master on/off
SENSOR_EAR_SIDE = +1;     // which ear: +1 (+X) or -1 (-X)

// Hole pattern (measured off the board)
SENSOR_PAIR_DX        = 20.0; // pair spacing along X  (connector edge)
SENSOR_PAIR_TO_SINGLE = 30.0; // pair -> single hole, along Y
SENSOR_SINGLE_DX      = 0.0;  // single-hole X offset from pair centre
                              // (0 = centred between the pair)
SENSOR_HOLE_INSET_X   = 46.0; // X of the INNER pair hole. Pushed well
                              // past the M4 bolt head (outer edge at
                              // EAR_BOLT_X+HEAD_DIA/2 ~= 38) so the board
                              // sits fully clear of it with a margin.
                              // Lower = tucked in tighter (min ~40);
                              // raise it if your PCB edge still shadows
                              // the bolt.
SENSOR_HOLE_DIA       = 2.4;  // M2 clearance, through the pad

// Print alignment: the board hangs past one clamp end; the pad is
// flush with the OTHER end so it prints support-free.
SENSOR_EXTEND_DIR = -1;   // which end the board hangs past:
                          //  -1 = past the Y=0 end (pad flush at
                          //       Y=CLAMP_LEN, the default print-bed
                          //       face -> no part change needed)
                          //  +1 = past the Y=CLAMP_LEN end (flip the
                          //       part in the slicer to print)

// Pad
SENSOR_PAD_THK    = EAR_THK;  // thickness (Z); holds the captive nut,
                          // keep <= EAR_THK and > nut depth + ~1
SENSOR_PAD_MARGIN = 5.0;  // border around the hole bounding box

// Captive M2 hex-nut pockets on the pad's INNER (+Z) face
SENSOR_NUT_POCKET = true;
SENSOR_NUT_FLATS  = 4.0;   // M2 nut across-flats (MEASURE)
SENSOR_NUT_DEPTH  = 1.8;   // M2 nut thickness  (MEASURE)

// ----- Mount plate (Half A only) -----------------------------
// A short radial cantilever between the body and the rail.
// Y extent matches the rail HAT TOP width so the rail's flanges
// overhang the plate above and below, leaving room for the
// device's clip hooks. X extent matches RAIL_LEN.
PLATE_W       = 27.0;   // Y extent along pipe axis — = RAIL_HAT_W
PLATE_THK     = 5.0;    // radial thickness (Z direction)

// ----- Rail length (along X, perpendicular to pipe) ----------
// Total length of the printed rail section. Needs to be at
// least a bit longer than the device's clip width so the
// device can slide on from one end. CoreS3 clip is ~35 mm; a
// few mm of extra travel is comfortable.
RAIL_LEN      = 60.0;

// ----- TS35 DIN rail (IEC 60715, 7.5 mm depth) ---------------
// Outside dimensions per the standard. RAIL_GAP is a slip-fit
// allowance shaved off the OUTSIDE so the device's clip slides
// on without binding.
RAIL_HAT_W    = 27.0;   // hat top width (the upper, narrower part)
RAIL_FLANGE_W = 35.0;   // flange-to-flange total width
RAIL_DEPTH    = 1.0;    // hat depth above flange tops
RAIL_FLANGE_T = 1.0;    // flange thickness
RAIL_GAP      = 0.2;    // slip-fit allowance (subtracted from
                        // each face that contacts the device clip)

// ----- Exploded view -----------------------------------------
EXPLODE_GAP   = 35.0;

$fn = 64;

// =============================================================
// DERIVED
// =============================================================
R_BORE  = PIPE_OD / 2;
R_OUTER = R_BORE + WALL;
G       = CLAMP_GAP / 2;
X_MATE  = sqrt(R_OUTER*R_OUTER - G*G);

// Bolt ear's INNER X edge: pulled inward to where the body's
// outer wall passes at the TOP of the ear (Z = G + EAR_THK).
EAR_INNER_X  = sqrt(max(0.01,
                        R_OUTER*R_OUTER -
                        (G + EAR_THK)*(G + EAR_THK))) - 0.5;
EAR_OUTER_X  = X_MATE + EAR_LEN;
EAR_BOLT_X   = X_MATE + EAR_LEN/2;
EAR_Y        = CLAMP_LEN/2;

// ----- DHT20 pad derived -------------------------------------
SP_S       = SENSOR_EAR_SIDE;
SP_Z_OUTER = -(G + EAR_THK);                  // pad outer face = ear outer
SP_Z_INNER = SP_Z_OUTER + SENSOR_PAD_THK;     // pad inner face (nut side)

// Hole X magnitudes (un-signed; ear side applied in the modules)
H_XI = SENSOR_HOLE_INSET_X;                                // inner pair
H_XO = SENSOR_HOLE_INSET_X + SENSOR_PAIR_DX;               // outer pair
H_XS = SENSOR_HOLE_INSET_X + SENSOR_PAIR_DX/2 + SENSOR_SINGLE_DX; // single

// Hole Y. The board hangs past one clamp end; the near (pair) row
// sits one margin inside the flush end, the single row reaches out.
SP_FLUSH_Y = SENSOR_EXTEND_DIR < 0 ? CLAMP_LEN : 0;
H_YP = SP_FLUSH_Y + SENSOR_EXTEND_DIR * SENSOR_PAD_MARGIN;      // pair row
H_YS = H_YP + SENSOR_EXTEND_DIR * SENSOR_PAIR_TO_SINGLE;        // single row

// Pad: spans from the flush clamp end out over all three holes.
// Inner X edge reaches back into the ear for a solid weld.
PAD_X_LO = min(EAR_OUTER_X - 8, min(H_XI, H_XS) - SENSOR_PAD_MARGIN);
PAD_X_HI = max(H_XO, H_XS) + SENSOR_PAD_MARGIN;
PAD_Y_LO = min(SP_FLUSH_Y, min(H_YP, H_YS) - SENSOR_PAD_MARGIN);
PAD_Y_HI = max(SP_FLUSH_Y, max(H_YP, H_YS) + SENSOR_PAD_MARGIN);

assert(SENSOR_PAD_THK <= EAR_THK, "SENSOR_PAD_THK must be <= EAR_THK");
assert(SENSOR_PAD_THK >= SENSOR_NUT_DEPTH + 0.8,
       "SENSOR_PAD_THK too thin for the captive nut + wall");
assert(SENSOR_HOLE_INSET_X >= EAR_BOLT_X + HEAD_DIA/2,
       "inner hole over the M4 bolt head — increase SENSOR_HOLE_INSET_X");
assert(abs(SENSOR_EXTEND_DIR) == 1, "SENSOR_EXTEND_DIR must be +1 or -1");

// Plate footprint:
PLATE_Z_INNER = R_BORE;                 // sunk into body wall
PLATE_Z_OUTER = R_OUTER + PLATE_THK;    // outer face (rail mounts here)

// Effective rail dimensions after slip-fit allowance:
RAIL_HAT_W_EFF    = RAIL_HAT_W    - 2*RAIL_GAP;
RAIL_FLANGE_W_EFF = RAIL_FLANGE_W - 2*RAIL_GAP;
RAIL_DEPTH_EFF    = RAIL_DEPTH    - RAIL_GAP;

// Bolt mirror
EAR_SIDES = [+1, -1];

// =============================================================
// HELPERS
// =============================================================

module rounded_box(size, r) {
    minkowski() {
        cube([max(0.01, size[0] - 2*r),
              max(0.01, size[1] - 2*r),
              max(0.01, size[2] - 0.001)], center=true);
        cylinder(h=0.001, r=r, $fn=$fn);
    }
}

// =============================================================
// CROSS-SECTIONS (2D in XZ, extruded along Y for the body)
// =============================================================

module half_a_body_2d() {
    union() {
        // Outer shell minus bore, intersected with Z >= +G
        intersection() {
            difference() {
                circle(r = R_OUTER);
                circle(r = R_BORE);
            }
            translate([-2*R_OUTER, G]) square([4*R_OUTER, 2*R_OUTER]);
        }
        // Two bolt ears, with inner edge tucked inside the body's
        // outer curve so they fuse without a gap.
        for (s = EAR_SIDES)
            translate([s > 0 ? EAR_INNER_X
                             : -EAR_OUTER_X, G])
                square([EAR_OUTER_X - EAR_INNER_X, EAR_THK]);
    }
}

module half_b_body_2d() {
    mirror([0, 1]) half_a_body_2d();
}

module body_extrude() {
    rotate([90, 0, 0])
        translate([0, 0, -CLAMP_LEN])
            linear_extrude(height = CLAMP_LEN)
                children();
}

// =============================================================
// FASTENER NEGATIVES
// =============================================================

module bolt_through() {
    for (s = EAR_SIDES)
        translate([s * EAR_BOLT_X, EAR_Y, -2*EAR_THK])
            cylinder(h = 4*EAR_THK, d = BOLT_DIA);
}

// Bolt-head counterbores on Half B's outer face (back side,
// hex-key access away from the device).
module head_counterbore() {
    for (s = EAR_SIDES)
        translate([s * EAR_BOLT_X, EAR_Y,
                   -(G + EAR_THK) - 0.5])
            cylinder(h = HEAD_DEPTH + 0.5, d = HEAD_DIA);
}

// Captive-nut hex pockets on Half A's outer face (under the rail).
module nut_pocket() {
    for (s = EAR_SIDES)
        translate([s * EAR_BOLT_X, EAR_Y,
                   G + EAR_THK - NUT_DEPTH])
            cylinder(h = NUT_DEPTH + 0.5,
                     d = NUT_FLATS / cos(30), $fn = 6);
}

// =============================================================
// DHT20 SENSOR PAD (Half B only)
// =============================================================

// Flat rectangular pad on the chosen ear's OUTER face, sized to
// cover all three mounting holes. A plain cube (Y-constant, no
// fillets) so Half B still prints support-free with the bore axis
// vertical. Its inner X edge overlaps the ear for a clean weld.
module sensor_pad_solid() {
    x0 = SP_S > 0 ? PAD_X_LO : -PAD_X_HI;
    translate([x0, PAD_Y_LO, SP_Z_OUTER])
        cube([PAD_X_HI - PAD_X_LO, PAD_Y_HI - PAD_Y_LO, SENSOR_PAD_THK]);
}

// The three sensor mounting-hole centres (pair + single).
function sensor_hole_points() =
    [ [SP_S*H_XI, H_YP], [SP_S*H_XO, H_YP], [SP_S*H_XS, H_YS] ];

// Through-holes (along Z) for the M2 screws.
module sensor_holes() {
    for (p = sensor_hole_points())
        translate([p[0], p[1], SP_Z_OUTER - 1])
            cylinder(h = SENSOR_PAD_THK + 2, d = SENSOR_HOLE_DIA);
}

// Captive M2 hex-nut pockets opening on the pad's INNER (+Z) face
// (the side away from the board). Reuses the nut_pocket() hex
// idiom (d = FLATS/cos(30), $fn=6). Nuts drop in from the inner
// side; the screw threads into them from the board side.
module sensor_nut_pockets() {
    if (SENSOR_NUT_POCKET)
        for (p = sensor_hole_points())
            translate([p[0], p[1], SP_Z_INNER - SENSOR_NUT_DEPTH])
                cylinder(h = SENSOR_NUT_DEPTH + 0.5,
                         d = SENSOR_NUT_FLATS / cos(30), $fn = 6);
}

// =============================================================
// PLATE (Half A only)
// =============================================================

// Rectangular slab cantilevering radially in +Z. Inner edge
// extends down to R_BORE so the central portion overlaps the
// body wall and unions in cleanly along the body's outer
// cylindrical surface; the X-cantilevered "wings" past the
// body's curvature are thin shelves attached at the middle.
module plate_solid() {
    translate([-RAIL_LEN/2,
               CLAMP_LEN/2 - PLATE_W/2,
               PLATE_Z_INNER])
        cube([RAIL_LEN, PLATE_W, PLATE_Z_OUTER - PLATE_Z_INNER]);
}

// =============================================================
// TS35 DIN RAIL (Half A only)
// =============================================================

// Rail runs HORIZONTALLY: length along X, hat opens in +Z. The
// hat top and the flanges are both blocks built directly in 3D
// (no 2D extrude — the cross-section is in YZ but the extrude
// axis is X, perpendicular to the body's extrude axis Y, so a
// linear_extrude approach offers no advantage).
//
// Cross-section through the rail (looking down the +X axis):
//
//   flange                                 flange
//   ───────                              ───────
//   ──         ┌────────────────┐       ──            ↑
//              │                │                     │ RAIL_DEPTH
//              │   hat (solid)  │                     │
//              │                │                     ↓
//              └────────────────┘
//   ←────────── RAIL_FLANGE_W ──────────→
//                ←── HAT_W ──→
//
// All sat on top of the plate (Z = PLATE_Z_OUTER), centered on
// the body's mid-Y so the rail sits in the middle of the clamp.
module din_rail() {
    cy = CLAMP_LEN / 2;
    // Hat top (solid block)
    translate([-RAIL_LEN/2,
               cy - RAIL_HAT_W_EFF/2,
               PLATE_Z_OUTER])
        cube([RAIL_LEN, RAIL_HAT_W_EFF, RAIL_DEPTH_EFF]);
    // Flanges (thin strip wider than the hat, on the plate face)
    translate([-RAIL_LEN/2,
               cy - RAIL_FLANGE_W_EFF/2,
               PLATE_Z_OUTER])
        cube([RAIL_LEN, RAIL_FLANGE_W_EFF, RAIL_FLANGE_T]);
}

// =============================================================
// HALVES
// =============================================================

module half_a() {
    difference() {
        union() {
            body_extrude() half_a_body_2d();
            plate_solid();
            din_rail();
        }
        bolt_through();
        nut_pocket();
    }
}

module half_b() {
    difference() {
        union() {
            body_extrude() half_b_body_2d();
            if (SENSOR_ENABLE) sensor_pad_solid();
        }
        bolt_through();
        head_counterbore();
        if (SENSOR_ENABLE) { sensor_holes(); sensor_nut_pockets(); }
    }
}

// =============================================================
// PRINT-ORIENTATION WRAPPERS
// =============================================================

module half_a_print() {
    translate([0, 0, CLAMP_LEN])
        rotate([-90, 0, 0])
            half_a();
}

module half_b_print() {
    translate([0, 0, CLAMP_LEN])
        rotate([-90, 0, 0])
            half_b();
}

// =============================================================
// VIEWS
// =============================================================

module pipe_dummy() {
    %translate([0, -10, 0])
        rotate([-90, 0, 0])
            cylinder(h = CLAMP_LEN + 40, d = PIPE_OD - 0.5);
}

module assembly_view() {
    half_a();
    half_b();
    pipe_dummy();
}

module exploded_view() {
    translate([0, 0, EXPLODE_GAP]) half_a();
    translate([0, 0, -EXPLODE_GAP]) half_b();
    pipe_dummy();
    for (s = EAR_SIDES) {
        // Bolt: head at the bottom (Half B side), shaft up
        translate([s * EAR_BOLT_X, EAR_Y,
                   -EXPLODE_GAP - (G + EAR_THK) - HEAD_DEPTH - 8])
            color("silver") {
                cylinder(h = HEAD_DEPTH, d = HEAD_DIA - 0.2);
                translate([0, 0, HEAD_DEPTH])
                    cylinder(h = 16, d = BOLT_DIA - 0.2);
            }
        // Captive nut on Half A's outer face
        translate([s * EAR_BOLT_X, EAR_Y,
                   EXPLODE_GAP + G + EAR_THK + 4])
            color("silver")
                cylinder(h = NUT_DEPTH,
                         d = NUT_FLATS / cos(30), $fn = 6);
    }
}

// =============================================================
// MODE DISPATCH
// =============================================================

if (mode == "half_a")        half_a_print();
else if (mode == "half_b")   half_b_print();
else if (mode == "assembly") assembly_view();
else if (mode == "exploded") exploded_view();
else echo(str("Unknown mode: ", mode,
              " — use half_a / half_b / assembly / exploded"));
