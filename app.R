library(shiny)

ui <- fluidPage(
  tags$head(tags$style(HTML("
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body, .container-fluid { width: 100%; height: 100%; overflow: hidden; background: #000; font-family: 'Segoe UI', sans-serif; user-select: none; }
    #app { display: flex; height: 100vh; width: 100vw; }
    #sb {
      width: 290px; flex-shrink: 0; background: rgba(4,4,8,0.98);
      border-right: 1px solid #0d1520; padding: 16px; overflow-y: auto; color: #ddd;
      z-index: 10; box-shadow: 4px 0 32px rgba(0,0,0,0.99);
    }
    #sb::-webkit-scrollbar { width: 3px; }
    #sb::-webkit-scrollbar-thumb { background: #ff4400; border-radius: 2px; }
    #cw { flex: 1; position: relative; background: #000; cursor: grab; }
    #cw:active { cursor: grabbing; }
    #cv { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }
    h2 { font-size: 15px; color: #ff5500; font-weight: 900; text-transform: uppercase; margin-bottom: 14px; border-bottom: 1px solid #1a2030; padding-bottom: 8px; letter-spacing: 2px; }
    h3 { font-size: 10px; color: #4a9eff; text-transform: uppercase; margin: 14px 0 7px; font-weight: 700; letter-spacing: 2px; border-bottom: 1px solid #0d1520; padding-bottom: 4px; }
    .rw { margin-bottom: 9px; }
    .lb { display: flex; justify-content: space-between; margin-bottom: 3px; }
    .lb span { font-size: 11px; color: #888; }
    .lb b { font-size: 11px; color: #fff; background: #0a0a14; padding: 1px 5px; border-radius: 3px; border: 1px solid #1a2030; font-weight: 700; }
    input[type=range] { -webkit-appearance: none; width: 100%; height: 2px; background: #1a2030; outline: none; border-radius: 2px; }
    input[type=range]::-webkit-slider-thumb { -webkit-appearance: none; width: 10px; height: 10px; border-radius: 50%; background: #ff5500; cursor: pointer; border: 2px solid #fff; }
    .tb-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
    .tl { font-size: 11px; color: #888; }
    .tb { width: 34px; height: 17px; background: #1a2030; border-radius: 9px; cursor: pointer; position: relative; transition: background 0.2s; flex-shrink: 0; }
    .tb.on { background: #ff5500; }
    .tb::after { content: ''; position: absolute; top: 2px; left: 2px; width: 13px; height: 13px; background: #fff; border-radius: 50%; transition: left 0.2s; }
    .tb.on::after { left: 19px; }
    .btn { display: block; width: 100%; padding: 7px; font-size: 11px; font-weight: 700; color: #bbb; background: #080810; border: 1px solid #1a2030; border-radius: 3px; cursor: pointer; text-align: center; margin-bottom: 3px; transition: all 0.15s; letter-spacing: 0.5px; }
    .btn:hover { background: #0f0f20; border-color: #4a9eff; color: #fff; }
    .btn.danger { border-color: #ff2200; color: #ff5533; }
    .btn.danger:hover { background: #1a0800; border-color: #ff5500; color: #ff8866; }
    .info { font-size: 10px; color: #445; line-height: 1.5; margin-top: 4px; }
    .stat { font-size: 10px; color: #4a9eff; margin-bottom: 2px; font-family: monospace; }
    .stat.warn { color: #ff8800; }
    #hint { position: absolute; bottom: 14px; right: 14px; font-size: 10px; color: rgba(255,255,255,0.45); pointer-events: none; z-index: 2; background: rgba(0,0,0,0.7); padding: 7px 10px; border-radius: 5px; border: 1px solid rgba(255,255,255,0.06); line-height: 1.8; }
    #hint b { color: #ff5500; }
    select { width:100%; background:#080810; color:#ccc; border:1px solid #1a2030; padding:4px 6px; font-size:11px; border-radius:3px; outline:none; margin-bottom:4px; }
    select:focus { border-color:#4a9eff; }
  "))),
  
  div(id="app",
      div(id="sb",
          tags$h2("● Black Hole Sim"),
          
          tags$h3("Parameters"),
          div(class="rw",
              div(class="lb", tags$span("Mass (M☉ ×10⁶)"), tags$b(id="vmass","6.5")),
              tags$input(type="range",id="rmass",min="1",max="20",step="0.5",value="6.5",
                         oninput="UP('mass',this.value,'vmass',true)")),
          div(class="rw",
              div(class="lb", tags$span("Spin (a/M)"), tags$b(id="vspin","0.72")),
              tags$input(type="range",id="rspin",min="0",max="0.998",step="0.01",value="0.72",
                         oninput="UP('spin',this.value,'vspin',true)")),
          div(class="rw",
              div(class="lb", tags$span("Luminosity"), tags$b(id="vdbr","1.4")),
              tags$input(type="range",id="rdbr",min=".1",max="4",step=".1",value="1.4",
                         oninput="UP('dBr',this.value,'vdbr')")),
          div(class="rw",
              div(class="lb", tags$span("Disk outer radius"), tags$b(id="vout","20")),
              tags$input(type="range",id="rout",min="8",max="35",step="1",value="20",
                         oninput="UP('outR',this.value,'vout',true)")),
          
          tags$h3("Schwarzschild"),
          div(id="stats",
              div(class="stat", id="rs_label",   "Rs = 2GM/c² = 19.2 km"),
              div(class="stat", id="isco_label", "ISCO = 3.39 Rs (Kerr)"),
              div(class="stat", id="spin_label", "a/M = 0.720"),
              div(class="stat warn", id="tidal_label","Tidal force: extreme")
          ),
          div(class="info","Kerr metric. Frame-dragging compresses ISCO. Tidal forces scale as M/r³."),
          
          tags$h3("Rendering"),
          div(class="rw",
              div(class="lb", tags$span("Particle density (k)"), tags$b(id="vdens","28")),
              tags$input(type="range",id="rdens",min="10",max="50",step="2",value="28",
                         oninput="UP('density',this.value,'vdens',true)")),
          div(class="rw",
              div(class="lb", tags$span("Lensing strength"), tags$b(id="vlens","1.0")),
              tags$input(type="range",id="rlens",min="0",max="2",step="0.1",value="1.0",
                         oninput="UP('lensStr',this.value,'vlens')")),
          div(class="tb-row", tags$span(class="tl","Accretion disk"),
              div(class="tb on",id="tdisk",onclick="TGL('disk',this)")),
          div(class="tb-row", tags$span(class="tl","Grav. lensing ring"),
              div(class="tb on",id="tlens",onclick="TGL('lensRing',this)")),
          div(class="tb-row", tags$span(class="tl","Background stars"),
              div(class="tb on",id="tstars",onclick="TGL('bgStars',this)")),
          
          tags$h3("Test Objects"),
          tags$select(id="pmode",
                      tags$option(value="spiral",    "Spiral infall"),
                      tags$option(value="slingshot", "Gravitational slingshot"),
                      tags$option(value="star",      "Star (spaghettification)"),
                      tags$option(value="debris",    "Debris field"),
                      tags$option(value="photon",    "Photon trajectory")
          ),
          tags$button(class="btn",        onclick="addParticle()",   "Launch object"),
          tags$button(class="btn danger", onclick="clearParticles()","Clear all"),
          
          tags$h3("Camera"),
          tags$button(class="btn", onclick="resetCam()",  "Top-down"),
          tags$button(class="btn", onclick="setEdgeOn()", "Edge-on"),
          tags$button(class="btn", onclick="setOblique()","Oblique")
      ),
      
      div(id="cw",
          tags$canvas(id="cv"),
          div(id="hint",
              HTML("<b>L-DRAG</b> Orbit &nbsp;<b>R-DRAG</b> Pan &nbsp;<b>SCROLL</b> Zoom"))
      )
  ),
  
  tags$script(HTML("
const cv  = document.getElementById('cv');
const ctx = cv.getContext('2d');
const cw  = document.getElementById('cw');

// star field -- rebuilt on every resize
let STARS = [];
function buildStars(W, H) {
  STARS = [];
  for (let i = 0; i < 2200; i++) {
    let t = Math.random();
    let r = 255, g = 255, b = 255;
    if      (t > 0.85) { r=170; g=200; b=255; }
    else if (t > 0.70) { r=255; g=230; b=160; }
    else if (t > 0.60) { r=255; g=180; b=100; }
    else if (t > 0.55) { r=255; g=100; b=80;  }
    STARS.push({
      x0: Math.random()*W, y0: Math.random()*H,
      x: 0, y: 0,
      s: Math.random()*1.3 + 0.15,
      a: Math.random()*0.7 + 0.1,
      r, g, b,
      blink: Math.random() < 0.08,
      blinkPhase: Math.random()*Math.PI*2
    });
  }
}

// physical constants (SI)
const C  = 3e8;
const GN = 6.674e-11;
const MS = 1.989e30;

// simulation state
const S = {
  mass: 6.5, spin: 0.72, dBr: 1.4, outR: 20.0,
  density: 28, lensStr: 1.0,
  disk: true, lensRing: true, bgStars: true
};

// Kerr ISCO -- Bardeen et al. 1972, eq. 2.21
function getISCO(a) {
  let Z1 = 1 + Math.pow(1 - a*a, 1/3) * (Math.pow(1+a, 1/3) + Math.pow(1-a, 1/3));
  let Z2 = Math.sqrt(3*a*a + Z1*Z1);
  return 3 + Z2 - Math.sqrt((3 - Z1)*(3 + Z1 + 2*Z2));
}

function updateStats() {
  let Mkg  = S.mass * 1e6 * MS;
  let Rs   = (2 * GN * Mkg / (C*C)) / 1000;
  let isco = getISCO(S.spin).toFixed(2);
  let tid  = S.mass < 3 ? 'moderate' : S.mass < 8 ? 'extreme' : 'catastrophic';
  document.getElementById('rs_label').textContent   = 'Rs = 2GM/c² = ' + Rs.toFixed(1) + ' km';
  document.getElementById('isco_label').textContent = 'ISCO = ' + isco + ' Rs (Kerr)';
  document.getElementById('spin_label').textContent = 'a/M = ' + parseFloat(S.spin).toFixed(3);
  document.getElementById('tidal_label').textContent = 'Tidal force: ' + tid;
}
updateStats();

// camera
let camTheta = 0.18, camPhi = 0.5, camZoom = 1.0, panX = 0, panY = 0;
let dragMode = null, mx = 0, my = 0;

cw.addEventListener('contextmenu', e => e.preventDefault());
cw.addEventListener('mousedown', e => {
  dragMode = e.button === 2 ? 'pan' : 'orbit';
  mx = e.clientX; my = e.clientY;
});
window.addEventListener('mouseup', () => dragMode = null);
cw.addEventListener('mousemove', e => {
  if (!dragMode) return;
  if (dragMode === 'orbit') {
    camPhi   -= (e.clientX - mx) * 0.005;
    camTheta += (e.clientY - my) * 0.005;
    camTheta  = Math.max(0.01, Math.min(Math.PI - 0.01, camTheta));
  } else {
    panX += e.clientX - mx;
    panY += e.clientY - my;
  }
  mx = e.clientX; my = e.clientY;
});
cw.addEventListener('wheel', e => {
  e.preventDefault();
  camZoom *= e.deltaY > 0 ? 0.92 : 1.08;
  camZoom  = Math.max(0.04, Math.min(6.0, camZoom));
}, { passive: false });

window.resetCam   = function() { camTheta=0.18; camPhi=0.5; camZoom=1.0; panX=0; panY=0; };
window.setEdgeOn  = function() { camTheta=Math.PI/2-0.04; camPhi=0.5; camZoom=1.0; panX=0; panY=0; };
window.setOblique = function() { camTheta=1.05; camPhi=0.5; camZoom=1.0; panX=0; panY=0; };

function resize() {
  let W = cw.clientWidth, H = cw.clientHeight;
  if (W > 0 && H > 0) { cv.width = W; cv.height = H; buildStars(W, H); }
}
resize();
window.addEventListener('resize', resize);

// accretion disk -- particle-based, Keplerian orbits with Kerr correction
let DISK = [];
function initDisk() {
  DISK = [];
  const N = S.density * 1000;
  const inner = getISCO(S.spin), outer = S.outR;
  const NB = 60;

  for (let i = 0; i < N; i++) {
    let bf = Math.pow(Math.random(), 1.6);
    let r  = inner + (Math.floor(bf*NB)/NB) * (outer-inner) + (Math.random()-0.5)*0.2;
    r = Math.max(inner, r);

    let t = 1.0 - (r - inner) / (outer - inner);
    let rC, gC, bC, aC;
    if      (t > 0.88) { rC=255; gC=255; bC=255; aC=0.85; }
    else if (t > 0.74) { rC=210; gC=235; bC=255; aC=0.70; }
    else if (t > 0.58) { rC=255; gC=210; bC=90;  aC=0.58; }
    else if (t > 0.40) { rC=255; gC=110; bC=15;  aC=0.45; }
    else if (t > 0.22) { rC=230; gC=45;  bC=0;   aC=0.30; }
    else               { rC=130; gC=12;  bC=0;   aC=0.14; }

    let thick = 0.30 * Math.pow(r - inner + 0.1, 0.52);
    DISK.push({
      r, angle: Math.random()*Math.PI*2,
      y_off: (Math.random()+Math.random()+Math.random()-1.5)*thick,
      omega_k: 1.0 / (Math.pow(r, 1.5) + S.spin),
      rC, gC, bC, aC,
      sz: Math.random()*1.6 + 0.35,
      turb: Math.random()*0.4 + 0.8
    });
  }
}
initDisk();

// test objects
let PARTICLES = [];

window.addParticle = function() {
  const mode = document.getElementById('pmode').value;
  const ISCO = getISCO(S.spin);

  if (mode === 'spiral') {
    PARTICLES.push({
      type: 'spiral',
      r: S.outR*0.85 + Math.random()*5,
      a: Math.random()*Math.PI*2,
      dr: -0.008 - Math.random()*0.012,
      da: 0.035 + S.spin*0.02,
      ddr: -0.0003,
      trail: [], age: 0,
      glowPulse: Math.random()*Math.PI*2
    });

  } else if (mode === 'slingshot') {
    let sR = S.outR*1.4, sA = Math.random()*Math.PI*2;
    PARTICLES.push({
      type: 'slingshot',
      x: sR*Math.cos(sA), y: 0, z: sR*Math.sin(sA),
      vx: -0.15*Math.sin(sA) + 0.08*Math.cos(sA),
      vy: (Math.random()-0.5)*0.04,
      vz:  0.15*Math.cos(sA) + 0.08*Math.sin(sA),
      trail: [], age: 0, dead: false,
      glowPulse: Math.random()*Math.PI*2
    });

  } else if (mode === 'star') {
    PARTICLES.push({
      type: 'star',
      r: S.outR*0.9, a: Math.random()*Math.PI*2,
      dr: -0.018, da: 0.025 + S.spin*0.015,
      stretch: 1.0, trail: [], age: 0,
      fragments: [], coronaAngle: 0
    });

  } else if (mode === 'debris') {
    let cr = S.outR*0.7 + Math.random()*8, ca = Math.random()*Math.PI*2;
    for (let k = 0; k < 18; k++) {
      PARTICLES.push({
        type: 'debris',
        r: cr + (Math.random()-0.5)*3,
        a: ca + (Math.random()-0.5)*0.3*Math.PI,
        dr: -0.005 - Math.random()*0.01,
        da: 0.03 + S.spin*0.015 + (Math.random()-0.5)*0.01,
        trail: [], age: 0,
        sz: Math.random()*2.5 + 0.8,
        color: [200+Math.random()*55, 100+Math.random()*100, 50+Math.random()*80],
        glowPulse: Math.random()*Math.PI*2
      });
    }

  } else if (mode === 'photon') {
    let sR = S.outR*1.2, sA = Math.random()*Math.PI*2;
    PARTICLES.push({
      type: 'photon',
      r: sR, a: sA,
      dr: -0.18,
      da: (2.6 + Math.random()*1.8) / Math.max(sR*sR, 1) * 4,
      trail: [], age: 0, maxAge: 220
    });
  }
};

window.clearParticles = function() { PARTICLES = []; };

// lensing displacement for background stars
// simple approximation: deflect ~ Rs^2 / dist
function lensedStar(s, cx, cy, sc, sr) {
  let dx = s.x0 - cx, dy = s.y0 - cy;
  let d2 = dx*dx + dy*dy;
  let lR = sr * 5.5 * S.lensStr;
  if (d2 > lR*lR) { s.x = s.x0; s.y = s.y0; return 1.0; }
  let d  = Math.sqrt(d2);
  let df = (sr*sr * 2.2 * S.lensStr) / Math.max(d, sr*0.5);
  s.x = s.x0 + (dx/d)*df;
  s.y = s.y0 + (dy/d)*df;
  let rd = Math.abs(d - sr*1.5);
  return rd < sr*0.4 ? 1.0 + 2.5*(1 - rd/(sr*0.4)) : 1.0;
}

function drawDiskParticle(p, front, sc, ct, st, cx, cy, sr, t) {
  let a    = p.angle + t * p.omega_k * p.turb;
  let xw   = p.r*Math.cos(a), zw = p.r*Math.sin(a);
  let xr   = xw*Math.cos(camPhi) - zw*Math.sin(camPhi);
  let zr   = xw*Math.sin(camPhi) + zw*Math.cos(camPhi);
  if ((zr <= 0) !== front) return;

  // relativistic Doppler -- Luminet 1979
  let beta = Math.min(0.98, p.omega_k * p.r * 0.32);
  let dop  = (1 - (xr/p.r)*beta) / Math.sqrt(1 - beta*beta);
  let df   = Math.pow(Math.max(0.04, dop), 2.8);

  let R = Math.min(255, Math.floor(p.rC*df));
  let G = Math.min(255, Math.floor(p.gC*df));
  let B = Math.min(255, Math.floor(p.bC*df));
  let A = Math.min(1.0, p.aC * Math.min(2.8,df) * S.dBr * (front ? 1.35 : 1.0));
  if (A < 0.015) return;

  ctx.fillStyle = `rgba(${R},${G},${B},${A})`;
  let sx = xr*sc;
  let sp = Math.max(0.35, Math.min(2.9, p.sz));

  if (!front) {
    let ry = p.r*sc*ct, zn = zr/p.r;
    let yt = (-( ry*(1-st) + (sr+sr*2.5/p.r)*st )*zn)*st + (zr*ct*sc)*(1-st) - p.y_off*st*sc;
    let yb = (  ( ry*(1-st) + (sr+sr*1.4/p.r)*st )*zn)*st + (zr*ct*sc)*(1-st) - p.y_off*st*sc;
    ctx.fillRect(cx+sx, cy+yt, sp, sp);
    ctx.fillRect(cx+sx, cy+yb, sp, sp);
    let y0 = zr*ct*sc - p.y_off*st*sc;
    if (sx*sx + y0*y0 > sr*sr*0.88) ctx.fillRect(cx+sx, cy+y0, sp, sp);
  } else {
    ctx.fillRect(cx+sx, cy + zr*ct*sc - p.y_off*Math.max(0.12,st)*sc, sp, sp);
  }
}

// volumetric glow -- 3 layered radial gradients
// outer halo + corona + hard core
function glow(sX, sY, r, g, b, rad, intensity, c2d) {
  let g1 = c2d.createRadialGradient(sX,sY,0, sX,sY, rad*8);
  g1.addColorStop(0,   `rgba(${r},${g},${b},${intensity*0.18})`);
  g1.addColorStop(0.3, `rgba(${r},${g},${b},${intensity*0.07})`);
  g1.addColorStop(0.7, `rgba(${Math.floor(r*.5)},${Math.floor(g*.3)},${b},${intensity*0.02})`);
  g1.addColorStop(1,   'rgba(0,0,0,0)');
  c2d.fillStyle = g1;
  c2d.beginPath(); c2d.arc(sX,sY,rad*8,0,Math.PI*2); c2d.fill();

  let g2 = c2d.createRadialGradient(sX,sY,0, sX,sY, rad*3.5);
  g2.addColorStop(0,    `rgba(255,255,255,${intensity*0.85})`);
  g2.addColorStop(0.15, `rgba(${r},${g},${b},${intensity*0.70})`);
  g2.addColorStop(0.5,  `rgba(${r},${g},${b},${intensity*0.25})`);
  g2.addColorStop(1,    'rgba(0,0,0,0)');
  c2d.fillStyle = g2;
  c2d.beginPath(); c2d.arc(sX,sY,rad*3.5,0,Math.PI*2); c2d.fill();

  let g3 = c2d.createRadialGradient(sX,sY,0, sX,sY, rad);
  g3.addColorStop(0,   `rgba(255,255,255,${Math.min(1,intensity*1.2)})`);
  g3.addColorStop(0.4, `rgba(${r},${g},${b},${intensity*0.9})`);
  g3.addColorStop(1,   `rgba(${r},${g},${b},0)`);
  c2d.fillStyle = g3;
  c2d.beginPath(); c2d.arc(sX,sY,rad,0,Math.PI*2); c2d.fill();
}

// 3-pass trail: outer glow / mid / bright spine
function trail(pts, r, g, b, maxW, c2d, colorFn) {
  if (pts.length < 3) return;
  c2d.save();
  c2d.globalCompositeOperation = 'screen';
  c2d.lineCap = 'round'; c2d.lineJoin = 'round';

  for (let pass = 0; pass < 3; pass++) {
    for (let j = 1; j < pts.length; j++) {
      let f   = j / pts.length;
      let p   = pts[j], p0 = pts[j-1];
      let col = colorFn ? colorFn(f, p) : {r,g,b};
      let lw, alpha;
      if      (pass === 0) { lw = Math.max(1,   f*maxW*5);    alpha = f*f*0.22; }
      else if (pass === 1) { lw = Math.max(0.5, f*maxW*2);    alpha = f*f*0.55; col = colorFn ? colorFn(f,p) : {r,g,b}; }
      else                 { lw = Math.max(0.3, f*maxW*0.45); alpha = f*0.9;    col = {r:255,g:255,b:255}; }
      c2d.strokeStyle = `rgba(${col.r},${col.g},${col.b},${alpha})`;
      c2d.lineWidth   = lw;
      c2d.beginPath(); c2d.moveTo(p0.x,p0.y); c2d.lineTo(p.x,p.y); c2d.stroke();
    }
  }
  c2d.restore();
}

function lensFlare(sX, sY, r, g, b, intensity, c2d) {
  if (intensity < 0.3) return;
  c2d.save();
  c2d.globalCompositeOperation = 'screen';
  let len = 60 * intensity;
  for (let ang of [0, Math.PI/2, Math.PI/4, -Math.PI/4]) {
    let gr = c2d.createLinearGradient(
      sX-Math.cos(ang)*len, sY-Math.sin(ang)*len,
      sX+Math.cos(ang)*len, sY+Math.sin(ang)*len
    );
    gr.addColorStop(0,    'rgba(0,0,0,0)');
    gr.addColorStop(0.45, `rgba(${r},${g},${b},${intensity*0.15})`);
    gr.addColorStop(0.5,  `rgba(255,255,255,${intensity*0.5})`);
    gr.addColorStop(0.55, `rgba(${r},${g},${b},${intensity*0.15})`);
    gr.addColorStop(1,    'rgba(0,0,0,0)');
    c2d.strokeStyle = gr; c2d.lineWidth = 1.5;
    c2d.beginPath();
    c2d.moveTo(sX-Math.cos(ang)*len, sY-Math.sin(ang)*len);
    c2d.lineTo(sX+Math.cos(ang)*len, sY+Math.sin(ang)*len);
    c2d.stroke();
  }
  c2d.restore();
}

function updateAndDrawParticles(sc, ct, st, cx, cy, sr, t) {
  ctx.globalCompositeOperation = 'source-over';
  const ISCO  = getISCO(S.spin);
  const TMAX  = 700;

  for (let i = PARTICLES.length-1; i >= 0; i--) {
    let p = PARTICLES[i];
    p.age++;

    if (p.type === 'spiral') {
      p.a  += p.da + p.age*0.00005;
      p.r  += p.dr;
      p.dr += p.ddr - (p.r < ISCO+3 ? 0.003 : 0);

      let xr = p.r*Math.cos(p.a-camPhi), zr = p.r*Math.sin(p.a-camPhi);
      let sX = cx+xr*sc, sY = cy+zr*ct*sc;
      let hf = Math.min(1, (S.outR-p.r)/S.outR);  // heat 0..1

      if (p.r > 1.2) p.trail.push({x:sX, y:sY, heat:hf});
      if (p.trail.length > TMAX) p.trail.shift();

      trail(p.trail, 80, 200, 255, 5, ctx, (f, pt) => ({
        r: Math.floor(80  + (pt.heat||0)*175),
        g: Math.floor(200 - (pt.heat||0)*80),
        b: Math.floor(255 - (pt.heat||0)*200)
      }));

      if (p.r > 1.5) {
        let pulse = 0.7 + 0.3*Math.sin(t*9 + p.glowPulse);
        ctx.globalCompositeOperation = 'screen';
        glow(sX,sY, Math.floor(80+hf*175), Math.floor(200-hf*80), Math.floor(255-hf*200), 8, pulse*(0.6+hf*0.4), ctx);
        lensFlare(sX,sY, Math.floor(80+hf*175), Math.floor(200-hf*80), Math.floor(255-hf*200), hf*pulse, ctx);
        ctx.globalCompositeOperation = 'source-over';
      }
      if (p.r < 1.0) PARTICLES.splice(i,1);

    } else if (p.type === 'slingshot') {
      if (p.dead) { PARTICLES.splice(i,1); continue; }

      let r2 = p.x*p.x + p.y*p.y + p.z*p.z, r = Math.sqrt(r2);
      let GM = S.mass*0.8;
      // post-Newtonian correction factor
      let GR = 1 + 1.5*S.mass/(r*r);
      p.vx -= GR*GM*p.x/(r2*r)*0.016;
      p.vy -= GR*GM*p.y/(r2*r)*0.016;
      p.vz -= GR*GM*p.z/(r2*r)*0.016;

      // frame dragging -- only kicks in close
      if (r < 8) {
        let fd = S.spin*0.04 / Math.max(r, 1);
        let tmp = p.vx; p.vx += fd*p.vz; p.vz -= fd*tmp;
      }
      p.x += p.vx; p.y += p.vy; p.z += p.vz;

      let xr = p.x*Math.cos(camPhi) - p.z*Math.sin(camPhi);
      let zr = p.x*Math.sin(camPhi) + p.z*Math.cos(camPhi);
      let sX = cx+xr*sc, sY = cy+zr*ct*sc - p.y*st*sc;
      let spd = Math.sqrt(p.vx*p.vx + p.vy*p.vy + p.vz*p.vz);
      let ht  = Math.min(1, spd*5);

      if (r > 1.2) p.trail.push({x:sX, y:sY, heat:ht});
      if (p.trail.length > TMAX) p.trail.shift();
      if (Math.sqrt(p.x*p.x+p.z*p.z) > S.outR*3.5 || p.age > 2000) p.dead = true;

      trail(p.trail, 255, 220, 80, 6, ctx, (f, pt) => ({
        r: 255,
        g: Math.floor(220 - (pt.heat||0)*140),
        b: Math.floor((1-(pt.heat||0))*80)
      }));

      if (r > 1.5) {
        ctx.globalCompositeOperation = 'screen';
        let tG = Math.floor(220-ht*140), tB = Math.floor((1-ht)*80);
        let pulse = 0.8 + 0.2*Math.sin(t*12+p.glowPulse);
        glow(sX,sY, 255,tG,tB, 10, pulse*(0.5+ht*0.6), ctx);
        if (ht > 0.65) {
          let sR = 14 + 8*Math.sin(t*20);
          let sg = ctx.createRadialGradient(sX,sY,sR*0.7,sX,sY,sR);
          sg.addColorStop(0,   'rgba(0,0,0,0)');
          sg.addColorStop(0.5, `rgba(255,180,50,${ht*0.3})`);
          sg.addColorStop(1,   'rgba(0,0,0,0)');
          ctx.fillStyle = sg;
          ctx.beginPath(); ctx.arc(sX,sY,sR,0,Math.PI*2); ctx.fill();
        }
        lensFlare(sX,sY, 255,tG,tB, ht*pulse, ctx);
        ctx.globalCompositeOperation = 'source-over';
      }
      if (r < 1.0) PARTICLES.splice(i,1);

    } else if (p.type === 'star') {
      p.a += p.da; p.r += p.dr;
      if (p.r < ISCO+2) p.dr -= 0.006;
      p.coronaAngle += 0.08;

      let isco_r = getISCO(S.spin);
      p.stretch  = 1.0 + Math.max(0, (isco_r+6-p.r)/(isco_r+5)) * 14;

      let xr = p.r*Math.cos(p.a-camPhi), zr = p.r*Math.sin(p.a-camPhi);
      let sX = cx+xr*sc, sY = cy+zr*ct*sc;
      let sf = Math.min(1, p.stretch/14);

      // spawn fragments once it starts stretching
      if (p.stretch > 2.5 && p.age%3 === 0 && p.r > 2) {
        let fA = Math.random()*Math.PI*2, fs = p.stretch*0.25;
        p.fragments.push({
          x: sX, y: sY,
          vx: (Math.random()-0.5)*fs + Math.cos(fA)*p.stretch*0.15,
          vy: (Math.random()-0.5)*fs*0.4,
          life: 50+Math.random()*40, maxLife: 90,
          size: Math.random()*3+1,
          r: 255, g: Math.floor(100+Math.random()*120), b: Math.floor(Math.random()*60)
        });
      }

      ctx.save();
      ctx.globalCompositeOperation = 'screen';
      for (let fi = p.fragments.length-1; fi >= 0; fi--) {
        let fr = p.fragments[fi];
        fr.x += fr.vx; fr.y += fr.vy;
        fr.vx *= 0.97; fr.vy *= 0.97;
        fr.life--;
        let lf = fr.life / fr.maxLife;
        let fg = ctx.createRadialGradient(fr.x,fr.y,0, fr.x,fr.y, fr.size*6);
        fg.addColorStop(0,   `rgba(255,255,255,${lf*0.9})`);
        fg.addColorStop(0.3, `rgba(${fr.r},${fr.g},${fr.b},${lf*0.6})`);
        fg.addColorStop(0.7, `rgba(${fr.r},${Math.floor(fr.g*.5)},0,${lf*0.2})`);
        fg.addColorStop(1,   'rgba(0,0,0,0)');
        ctx.fillStyle = fg;
        ctx.beginPath(); ctx.arc(fr.x,fr.y,fr.size*6,0,Math.PI*2); ctx.fill();
        if (fr.life <= 0) p.fragments.splice(fi,1);
      }
      ctx.restore();

      p.trail.push({x:sX, y:sY, sf});
      if (p.trail.length > TMAX) p.trail.shift();
      trail(p.trail, 255, 160, 60, 5, ctx, (f, pt) => ({
        r: 255,
        g: Math.floor(160 - (pt.sf||0)*100),
        b: Math.floor(60  - (pt.sf||0)*60)
      }));

      if (p.r > 1.8) {
        ctx.save();
        ctx.globalCompositeOperation = 'screen';
        ctx.translate(sX, sY);
        ctx.rotate(Math.atan2(sY-cy, sX-cx) + Math.PI/2);

        let spx = Math.min(p.stretch,18)*sc*0.5, cpx = Math.max(4, 5*camZoom);

        let atmo = ctx.createRadialGradient(0,0,0, 0,0, spx*1.4);
        atmo.addColorStop(0,   'rgba(255,255,220,0)');
        atmo.addColorStop(0.5, `rgba(255,120,20,${0.12+sf*0.18})`);
        atmo.addColorStop(1,   'rgba(255,40,0,0)');
        ctx.fillStyle = atmo;
        ctx.beginPath(); ctx.ellipse(0,0,cpx*2.5,spx*1.4,0,0,Math.PI*2); ctx.fill();

        let photo = ctx.createRadialGradient(0,0,0, 0,0, spx);
        photo.addColorStop(0,    `rgba(255,255,240,${0.95-sf*0.2})`);
        photo.addColorStop(0.25, `rgba(255,220,100,${0.8-sf*0.15})`);
        photo.addColorStop(0.6,  'rgba(255,80,10,0.5)');
        photo.addColorStop(1,    'rgba(255,20,0,0)');
        ctx.fillStyle = photo;
        ctx.beginPath(); ctx.ellipse(0,0,cpx,spx,0,0,Math.PI*2); ctx.fill();

        if (p.stretch < 4) {
          for (let k = 0; k < 6; k++) {
            let sAng = p.coronaAngle + k*Math.PI/3;
            let sLen = cpx*(1.5 + 0.5*Math.sin(t*7+k));
            let sg = ctx.createLinearGradient(0,0, Math.cos(sAng)*sLen, Math.sin(sAng)*sLen);
            sg.addColorStop(0, 'rgba(255,255,200,0.5)');
            sg.addColorStop(1, 'rgba(255,100,0,0)');
            ctx.strokeStyle = sg; ctx.lineWidth = 2;
            ctx.beginPath(); ctx.moveTo(0,0);
            ctx.lineTo(Math.cos(sAng)*sLen, Math.sin(sAng)*sLen); ctx.stroke();
          }
        }
        ctx.restore();

        if (sf > 0.4) {
          let shR = cpx*(2+sf*3);
          let sw  = ctx.createRadialGradient(sX,sY,shR*0.75,sX,sY,shR);
          sw.addColorStop(0,   'rgba(0,0,0,0)');
          sw.addColorStop(0.6, `rgba(255,150,30,${sf*0.4*(0.5+0.5*Math.sin(t*15))})`);
          sw.addColorStop(1,   'rgba(0,0,0,0)');
          ctx.save();
          ctx.globalCompositeOperation = 'screen';
          ctx.fillStyle = sw;
          ctx.beginPath(); ctx.arc(sX,sY,shR,0,Math.PI*2); ctx.fill();
          ctx.restore();
        }
        lensFlare(sX,sY, 255,160,60, 0.5+sf*0.5, ctx);
      }
      if (p.r < 1.0) PARTICLES.splice(i,1);

    } else if (p.type === 'debris') {
      p.a  += p.da + p.age*0.00003;
      p.r  += p.dr;
      p.dr += -0.0002 - (p.r < ISCO+3 ? 0.002 : 0);

      let xr = p.r*Math.cos(p.a-camPhi), zr = p.r*Math.sin(p.a-camPhi);
      let sX = cx+xr*sc, sY = cy+zr*ct*sc;
      let [cr,cg,cb] = p.color;
      let ht = Math.max(0, 1-(p.r-ISCO)/(S.outR*0.5));

      if (p.r > 1.2) p.trail.push({x:sX, y:sY, heat:ht});
      if (p.trail.length > 200) p.trail.shift();

      trail(p.trail, Math.floor(cr+ht*(255-cr)), Math.floor(cg-ht*cg*.5), Math.floor(cb-ht*cb*.7), 3.5, ctx, (f, pt) => {
        let h = pt.heat||0;
        return { r: Math.floor(cr+h*(255-cr)), g: Math.floor(cg-h*cg*.5), b: Math.floor(cb-h*cb*.7) };
      });

      if (p.r > 1.5) {
        ctx.globalCompositeOperation = 'screen';
        let pulse = 0.6 + 0.4*Math.sin(t*11+p.glowPulse);
        glow(sX,sY, Math.floor(cr+ht*(255-cr)), Math.floor(cg-ht*cg*.5), Math.floor(cb-ht*cb*.7), p.sz*4, pulse*(0.4+ht*0.5), ctx);
        ctx.globalCompositeOperation = 'source-over';
      }
      if (p.r < 1.0) PARTICLES.splice(i,1);

    } else if (p.type === 'photon') {
      p.a += p.da; p.r += p.dr;
      if (p.r < 1.5) p.dr += 0.005;
      if (p.r <= 2.6 && p.r >= 2.3 && p.age < 60) p.dr *= 0.98;  // photon sphere

      let xr = p.r*Math.cos(p.a-camPhi), zr = p.r*Math.sin(p.a-camPhi);
      let sX = cx+xr*sc, sY = cy+zr*ct*sc;
      let bl = Math.max(0, Math.min(1, (S.outR-p.r)/S.outR));

      p.trail.push({x:sX, y:sY, blue:bl});
      if (p.trail.length > 180) p.trail.shift();

      trail(p.trail, 255, 255, 160, 2, ctx, (f, pt) => ({
        r: Math.floor(255 - (pt.blue||0)*80),
        g: Math.floor(255 - (pt.blue||0)*30),
        b: Math.floor(160 + (pt.blue||0)*95)
      }));

      if (p.r > 1.0) {
        ctx.globalCompositeOperation = 'screen';
        glow(sX,sY, Math.floor(255-bl*80), 255, Math.floor(160+bl*95), 3, 1.0, ctx);
        ctx.globalCompositeOperation = 'source-over';
      }
      if (p.r < 1.0 || p.r > S.outR*2 || p.age > p.maxAge) PARTICLES.splice(i,1);
    }
  }
}

// main loop
let time = 0;

function draw() {
  requestAnimationFrame(draw);
  if (cv.width === 0 || cv.height === 0) return;
  time += 0.008;

  const W = cv.width, H = cv.height;
  const cx = W/2 + panX, cy = H/2 + panY;
  const scB = Math.min(W,H)*0.038, sc = scB*camZoom;
  const st = Math.sin(camTheta), ct = Math.cos(camTheta);
  const sr = 2.6 * scB;

  ctx.globalCompositeOperation = 'source-over';
  ctx.fillStyle = '#000';
  ctx.fillRect(0, 0, W, H);

  if (S.bgStars) {
    for (let s of STARS) {
      let boost = lensedStar(s, cx, cy, sc, sr);
      let dx = s.x0-cx, dy = s.y0-cy, d2 = dx*dx+dy*dy;
      let alpha = s.a * (s.blink ? 0.5+0.5*Math.sin(time*3+s.blinkPhase) : 1.0) * Math.min(2, boost);
      if (boost > 1.5) {
        let nd = Math.sqrt(d2)||1;
        ctx.fillStyle = `rgba(${s.r},${s.g},${s.b},${Math.min(1,alpha*0.5)})`;
        ctx.beginPath();
        ctx.arc(cx-(dx/nd)*sr*1.5+(s.x0-cx)*0.05, cy-(dy/nd)*sr*1.5+(s.y0-cy)*0.05, s.s*0.7, 0, Math.PI*2);
        ctx.fill();
      }
      ctx.fillStyle = `rgba(${s.r},${s.g},${s.b},${Math.min(1,alpha)})`;
      ctx.beginPath(); ctx.arc(s.x, s.y, s.s*Math.min(2,boost*0.8), 0, Math.PI*2); ctx.fill();
    }
  }

  if (S.disk) {
    ctx.globalCompositeOperation = 'screen';
    for (let p of DISK) drawDiskParticle(p, false, sc,ct,st,cx,cy,sr,time);
  }

  ctx.globalCompositeOperation = 'source-over';

  // outer red glow around event horizon
  let og = ctx.createRadialGradient(cx,cy,sr*1.8, cx,cy,sr*6);
  og.addColorStop(0,   `rgba(120,20,0,${0.12*S.dBr})`);
  og.addColorStop(0.5, `rgba(60,5,0,${0.05*S.dBr})`);
  og.addColorStop(1,   'rgba(0,0,0,0)');
  ctx.fillStyle = og;
  ctx.beginPath(); ctx.arc(cx,cy,sr*6,0,Math.PI*2); ctx.fill();

  // photon sphere glow
  let pg = ctx.createRadialGradient(cx,cy,sr*0.92, cx,cy,sr*2.8);
  pg.addColorStop(0,    `rgba(255,235,160,${Math.min(1,S.dBr)})`);
  pg.addColorStop(0.12, `rgba(255,140,25,${Math.min(1,0.75*S.dBr)})`);
  pg.addColorStop(0.35, `rgba(200,40,0,${0.25*S.dBr})`);
  pg.addColorStop(0.65, `rgba(80,5,0,${0.08*S.dBr})`);
  pg.addColorStop(1,    'rgba(0,0,0,0)');
  ctx.fillStyle = pg;
  ctx.beginPath(); ctx.arc(cx,cy,sr*2.8,0,Math.PI*2); ctx.fill();

  if (S.lensRing) {
    let flk = 0.55 + 0.15*Math.sin(time*7.3) + 0.08*Math.sin(time*13.1);
    ctx.beginPath(); ctx.arc(cx,cy,sr*1.5,0,Math.PI*2);
    ctx.strokeStyle = `rgba(255,210,120,${flk*Math.min(1,S.dBr*0.6)})`;
    ctx.lineWidth = 2.5; ctx.stroke();
    ctx.beginPath(); ctx.arc(cx,cy,sr*1.25,0,Math.PI*2);
    ctx.strokeStyle = `rgba(255,180,80,${flk*0.4*S.dBr})`;
    ctx.lineWidth = 1.0; ctx.stroke();
    for (let k = 0; k < 3; k++) {
      let hA = time*2.1 + k*2.094 + Math.sin(time*3)*0.5;
      let hR = sr*(1.45 + 0.15*Math.sin(time*5.5+k));
      ctx.beginPath(); ctx.arc(cx+Math.cos(hA)*hR, cy+Math.sin(hA)*hR, 1.5, 0, Math.PI*2);
      ctx.fillStyle = `rgba(255,240,200,${0.3+0.3*Math.sin(time*11+k*1.3)})`; ctx.fill();
    }
  }

  // black hole silhouette
  let sh = ctx.createRadialGradient(cx,cy,sr*0.6, cx,cy,sr*1.05);
  sh.addColorStop(0,    'rgba(0,0,0,1)');
  sh.addColorStop(0.75, 'rgba(0,0,0,1)');
  sh.addColorStop(1,    'rgba(0,0,0,0)');
  ctx.fillStyle = sh;
  ctx.beginPath(); ctx.arc(cx,cy,sr*1.05,0,Math.PI*2); ctx.fill();
  ctx.fillStyle = '#000';
  ctx.beginPath(); ctx.arc(cx,cy,sr*0.97,0,Math.PI*2); ctx.fill();

  if (S.disk) {
    ctx.globalCompositeOperation = 'screen';
    for (let p of DISK) drawDiskParticle(p, true, sc,ct,st,cx,cy,sr,time);
  }

  ctx.globalCompositeOperation = 'source-over';
  updateAndDrawParticles(sc, ct, st, cx, cy, sr, time);
}
draw();

// ui callbacks
window.UP = function(key, val, lid, reinit) {
  S[key] = parseFloat(val);
  document.getElementById(lid).textContent = val;
  if (reinit) { initDisk(); updateStats(); }
};
window.TGL = function(key, btn) {
  S[key] = !S[key];
  btn.classList.toggle('on', S[key]);
};
  "))
)

server <- function(input, output, session) {}
shinyApp(ui, server)