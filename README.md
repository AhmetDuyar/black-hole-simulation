# Black Hole Simulation — R/Shiny

Real-time interactive simulation of a rotating Kerr black hole, built entirely in R/Shiny with embedded JavaScript. No WebGL. No external rendering engine. No physics library. Just `library(shiny)`, HTML5 Canvas 2D, and physics math.

---

## Features

- **Kerr metric** — rotating black hole with adjustable spin parameter `a/M ∈ [0, 0.998]`
- **Schwarzschild radius** — computed live from `Rs = 2GM/c²`
- **ISCO** — exact Kerr formula (Bardeen et al. 1972), determines accretion disk inner edge
- **Accretion disk** — particle-based, Keplerian orbits with relativistic Doppler shift
- **Gravitational lensing** — background stars deflected and brightened near the Einstein ring
- **Frame-dragging** — Lense–Thirring effect applied to slingshot trajectories
- **Tidal spaghettification** — star stretches and fragments as it approaches the ISCO
- **5 test object modes** — spiral infall, gravitational slingshot, star disruption, debris field, photon trajectory

---

## Run Locally

Requires R and the `shiny` package — nothing else.

```r
shiny::runGitHub("black-hole-simulation", "AhmetDuyar")
```

Or clone and run manually:

```r
git clone https://github.com/AhmetDuyar/black-hole-simulation
cd black-hole-simulation
Rscript -e "shiny::runApp('app.R')"
```

---

## Controls

| Input | Action |
|-------|--------|
| Left drag | Orbit camera |
| Right drag | Pan |
| Scroll | Zoom |

Camera presets: Top-down / Edge-on / Oblique

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Application | R + Shiny |
| UI | `fluidPage()`, Shiny tags |
| Physics & rendering | Embedded JavaScript |
| Canvas | HTML5 Canvas 2D (`requestAnimationFrame`) |

The `server` function is intentionally empty — all computation runs client-side in the browser.

---

## Physics Reference

| Formula | Implementation |
|---------|---------------|
| `Rs = 2GM/c²` | Schwarzschild radius display |
| Kerr ISCO (Bardeen 1972) | `getISCO(a)`, disk inner boundary |
| `Ω_K ∝ (r^1.5 + a)⁻¹` | Keplerian frequency per disk particle |
| Relativistic Doppler | Color/brightness correction per particle |
| `δ ∝ Rs²/r` | Gravitational lensing of background stars |
| `Ω_LT ∝ J/r³` | Frame-dragging in slingshot mode |
| Post-Newtonian GR factor | Slingshot acceleration correction |

---

## Author

**Ahmet Duyar** — Energy Data Analyst, illwerke vkw AG, Vorarlberg, Austria  
[LinkedIn](https://www.linkedin.com/in/ahmetduyar)

---

## License

MIT — free to use, modify, and share.
