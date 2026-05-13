# Black Hole Simulation — R/Shiny

Real-time interactive simulation of a rotating Kerr black hole, built entirely in R/Shiny with embedded JavaScript. No WebGL. No external rendering engine. No physics library. Just `library(shiny)`, HTML5 Canvas 2D, and physics math.

---

## Quick Start

Requires R and the `shiny` package — nothing else.

```r
shiny::runGitHub("black-hole-simulation", "AhmetDuyar")
```

Or clone manually:

```r
git clone https://github.com/AhmetDuyar/black-hole-simulation
cd black-hole-simulation
Rscript -e "shiny::runApp('app.R')"
```

---

## Architecture

The entire application is a single `app.R` file. The `server` function is intentionally empty — R/Shiny only handles the UI scaffold. All physics, rendering, and interactivity run client-side in an embedded JavaScript block via `tags$script(HTML(...))`.

```
app.R
├── ui (fluidPage)
│   ├── CSS — layout, sidebar, sliders, toggles
│   ├── HTML — canvas element, sidebar controls
│   └── <script> — full JS engine (physics + rendering)
└── server (empty)
```

No reactive expressions. No `render*` functions. No `observe`. The browser does everything at ~60 fps via `requestAnimationFrame`.

---

## Physics

### Schwarzschild Radius

The Schwarzschild radius is computed from physical constants in SI units and displayed live:

```
Rs = 2GM / c²
```

With `G = 6.674×10⁻¹¹ m³kg⁻¹s⁻²`, `c = 3×10⁸ m/s`, mass in solar masses scaled by 10⁶.

### Kerr Metric

The simulation models a rotating (Kerr) black hole. The spin parameter `a/M` is adjustable from 0 (Schwarzschild) to 0.998 (near-extremal Kerr). The Kerr line element in Boyer–Lindquist coordinates introduces the off-diagonal `dt dφ` term responsible for frame-dragging.

### ISCO — Innermost Stable Circular Orbit

The exact Bardeen et al. (1972) formula is implemented:

```
r_ISCO = Rs · (3 + Z₂ − √((3−Z₁)(3+Z₁+2Z₂)))

Z₁ = 1 + (1−a*²)^(1/3) · [(1+a*)^(1/3) + (1−a*)^(1/3)]
Z₂ = √(3a*² + Z₁²)
```

where `a* = a/M` is the dimensionless spin. For `a* = 0` this gives `r_ISCO = 6 GM/c²` (Schwarzschild), and for `a* → 1` it approaches `GM/c²` (prograde extremal). The ISCO defines the inner boundary of the accretion disk and governs spiral infall behavior.

### Accretion Disk

The disk is particle-based: `density × 1000` particles, distributed radially between ISCO and the outer radius using a power-law concentration `r ~ U^1.6` to produce a realistic density gradient. Each particle carries:

- **Keplerian angular velocity** (Kerr approximation): `ω_K = 1 / (r^1.5 + a)`
- **Relativistic Doppler factor** (Luminet 1979): `δ = (1 − β·cos α) / √(1−β²)` with `β = ω_K · r · 0.32`
- **Color temperature** mapped to 6 radial bands from white-hot (inner) to deep red (outer)

The Doppler factor `δ^2.8` is applied per-particle to all RGB channels and opacity. The approaching side appears blue-shifted and brighter; the receding side red-shifted and dimmer — consistent with EHT imaging of M87*.

The disk is rendered in two passes (back → event horizon → front) to correctly handle depth ordering.

### Gravitational Lensing

Background stars are deflected using a screen-space approximation of the Einstein deflection angle:

```
δ ∝ Rs² / r   (in screen units)
```

Stars near the Einstein ring radius `r_E ≈ 1.5 · sr_px` receive a brightness boost of up to 3.5×. Secondary images appear on the opposite side of the lens, approximating the double-image effect predicted by the Schwarzschild geometry.

### Frame-Dragging (Lense–Thirring)

For the slingshot mode, frame-dragging is applied when `r < 8 Rs`:

```
Ω_LT = 2GJ / (c² r³)
```

Implemented as a velocity rotation in the equatorial plane, proportional to the spin parameter and inversely proportional to distance.

### Post-Newtonian GR Correction

Slingshot trajectories use a post-Newtonian correction to the Newtonian gravitational acceleration:

```
a = −(GM/r³) · (1 + 1.5·GM/(r·c²)) · r⃗
```

This produces measurably tighter periapsis deflection compared to the Newtonian case.

### Tidal Spaghettification

The star's elongation grows as:

```
stretch = 1 + max(0, (r_ISCO + 6 − r) / (r_ISCO + 5)) · 14
```

The rendered ellipse aspect ratio scales with `stretch`. Corona spikes animate for `stretch < 4`; above this threshold thermal fragments are spawned with individual volumetric glow gradients. A shockwave ring appears for `stretch > 0.4 · 14`.

### Photon Trajectory

Photons (null geodesics) are launched near the critical impact parameter `b_crit ≈ 2.6 Rs`. The photon sphere at `r_ph = 1.5 Rs` is modelled by a damping term `dr *= 0.98` for orbits satisfying `2.3 ≤ r ≤ 2.6`. Trail color shifts from yellow-white to blue-white (gravitational blueshift) as the photon approaches.

---

## Rendering

### Volumetric Glow

All test objects use a 3-layer radial gradient system:

| Layer | Radius | Purpose |
|-------|--------|---------|
| Outer halo | `8 × r` | Diffuse nebula-like falloff |
| Corona | `3.5 × r` | Mid-range colored glow |
| Core | `1 × r` | Hard bright center |

### Trail System

Trails are rendered in 3 passes per frame:

| Pass | Line width | Alpha | Purpose |
|------|-----------|-------|---------|
| 1 | `f × maxW × 5` | `f² × 0.22` | Wide soft outer glow |
| 2 | `f × maxW × 2` | `f² × 0.55` | Medium colored glow |
| 3 | `f × maxW × 0.45` | `f × 0.9` | Bright white spine |

All passes use `lineCap: round` and `globalCompositeOperation: screen` for additive blending.

### Camera

Orthographic projection with spherical coordinates `(θ, φ, zoom)`. 3D world coordinates are rotated by `camPhi` (azimuth) then projected with `camTheta` (elevation):

```
x' = x·cos(φ) − z·sin(φ)
z' = x·sin(φ) + z·cos(φ)

sx = cx + x'·sc
sy = cy + z'·cos(θ)·sc − y·sin(θ)·sc
```

Mouse controls: left-drag orbits, right-drag pans, scroll zooms (`camZoom ∈ [0.04, 6.0]`).

---

## Controls

| Input | Action |
|-------|--------|
| Left drag | Orbit camera |
| Right drag | Pan |
| Scroll | Zoom in/out |

Camera presets: **Top-down** (`θ = 0.18`), **Edge-on** (`θ = π/2 − 0.04`), **Oblique** (`θ = 1.05`)

---

## Parameters

| Parameter | Range | Effect |
|-----------|-------|--------|
| Mass (M☉ ×10⁶) | 1 – 20 | Scales Rs, tidal force classification |
| Spin (a/M) | 0 – 0.998 | ISCO radius, frame-dragging strength |
| Luminosity | 0.1 – 4 | Disk and photon sphere brightness |
| Disk outer radius | 8 – 35 Rs | Accretion disk extent |
| Particle density | 10 – 50k | Number of disk particles |
| Lensing strength | 0 – 2 | Star deflection amplitude |

---

## Test Object Modes

| Mode | Description |
|------|-------------|
| Spiral infall | Eccentric decay orbit, color temperature gradient, volumetric glow |
| Gravitational slingshot | Hyperbolic trajectory with post-Newtonian correction and frame-dragging |
| Star (spaghettification) | Tidal disruption event with fragment spawning and shockwave ring |
| Debris field | 18-particle ensemble on randomised orbits with proximity heating |
| Photon trajectory | Null geodesic near photon sphere with gravitational blueshift trail |

---

## References

- Bardeen, J.M., Press, W.H. & Teukolsky, S.A. (1972). *Rotating Black Holes: Locally Nonrotating Frames, Energy Extraction, and Scalar Synchrotron Radiation*. ApJ, 178, 347.
- Luminet, J.-P. (1979). *Image of a Spherical Black Hole with Thin Accretion Disk*. A&A, 75, 228.
- Kerr, R.P. (1963). *Gravitational Field of a Spinning Mass as an Example of Algebraically Special Metrics*. PRL, 11(5), 237.
- Lense, J. & Thirring, H. (1918). *Über den Einfluss der Eigenrotation der Zentralkörper*. Phys. Z., 19, 156.
- Event Horizon Telescope Collaboration (2019). *First M87 EHT Results I*. ApJL, 875, L1.

---

## Author

**Ahmet Duyar** — Energy Data Analyst, illwerke vkw AG, Vorarlberg, Austria  
[LinkedIn](https://www.linkedin.com/in/ahmetduyar)

---

## License

MIT — free to use, modify, and share.
