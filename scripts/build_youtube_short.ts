#!/usr/bin/env bun
/**
 * Vlang SimpleGUI + Webview RAD Studio — God-Mode M4 Ultra 6K 120Hz YouTube Short (<60s) & Widescreen Tour
 *
 * Hitting all major points from our flagship highest-end Mac workstation:
 *   🍎 Apple Mac Studio M4 Ultra · 32-Core CPU · 80-Core GPU · 192GB Unified Memory · Pro Display XDR 6K @ 120Hz ProMotion
 *
 * Outputs:
 *   - youtube_production/vlang_simplegui_youtube_short_9x16.mp4       (Vertical 9:16 1080x1920 @ 30fps <60s YouTube Short)
 *   - youtube_production/vlang_simplegui_short_tutorial.mp4           (Widescreen 16:9 1920x1080 @ 30fps Short Tour)
 *   - youtube_production/VLANG_SIMPLEGUI_SHORT_TUTORIAL_NOTES.md      (YouTube Title, Description, Chapters, Hardware Specs & Tags)
 *   - youtube_production/VLANG_SIMPLEGUI_YOUTUBE_UPLOAD_TITLES_DESCRIPTIONS_TAGS.md
 */
import { createHash } from "crypto";
import { copyFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "fs";
import { join } from "path";

const FFMPEG = "/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg";
const FFPROBE = "/opt/homebrew/opt/ffmpeg-full/bin/ffprobe";
const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const UVX = "/Users/codecaine/.local/bin/uvx";
const EDGE_VOICE = process.env.EDGE_TTS_VOICE ?? "en-US-AvaMultilingualNeural";
const RATE = "+22%";
const GAP = 0.15;

const ROOT = process.cwd();
const PROD = join(ROOT, "youtube_production");
const WORK = join(PROD, "vlang_simplegui_short_build");
const AUDIO_DIR = join(WORK, "audio");
const SFX_DIR = join(WORK, "sfx");
const ASSETS_16x9 = join(WORK, "assets_16x9");
const ASSETS_9x16 = join(WORK, "assets_9x16");
const SEG_16x9 = join(WORK, "seg_16x9");
const SEG_9x16 = join(WORK, "seg_9x16");

export const RIG_MARK = "🍎 Mac Studio M4 Ultra · 32c CPU · 80c GPU · 192GB Unified · Pro Display XDR 6K 120Hz";
export const REPO_SIMPLEGUI = "https://github.com/codecaine-zz/vlang_simplegui";
export const REPO_WEBVIEW = "https://github.com/codecaine-zz/vlang_webview_rad_studio";

function sh(cmd: string[], opts: { cwd?: string; quiet?: boolean } = {}): string {
  const r = Bun.spawnSync(cmd, { cwd: opts.cwd, stdout: "pipe", stderr: "pipe" });
  if (r.exitCode !== 0 && !opts.quiet) {
    throw new Error(`${cmd[0]} failed (${r.exitCode}): ${r.stderr.toString().slice(-600)}`);
  }
  return r.stdout.toString();
}

function durationOf(file: string): number {
  return (
    parseFloat(
      sh([FFPROBE, "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", file], {
        quiet: true,
      }).trim(),
    ) || 0
  );
}

const fmtTime = (sec: number) => {
  const s = Math.floor(sec);
  const m = Math.floor(s / 60);
  const ss = String(s % 60).padStart(2, "0");
  return `${m}:${ss}`;
};

function spokenText(text: string): string {
  return text
    .replace(/\bVlang\b/gi, "V lang")
    .replace(/\bSimpleGUI\b/gi, "Simple G U I")
    .replace(/\bWebview\b/gi, "Web view")
    .replace(/\bRAD\b/g, "rad")
    .replace(/Codecaine/g, "Code caine")
    .replace(/\bmacOS\b/g, "mac O S")
    .replace(/\bSQLite\b/g, "sequel-lite")
    .replace(/\bGUI\b/g, "G U I")
    .replace(/\bCLI\b/g, "C L I")
    .replace(/\bAPI\b/g, "A P I")
    .replace(/\bIDE\b/g, "I D E")
    .replace(/\bUI\b/g, "U I")
    .replace(/\bQt 6\b/gi, "Cute six")
    .replace(/\bHVAC\b/g, "H-vac")
    .replace(/\bADAS\b/g, "A-das")
    .replace(/\bLiDAR\b/gi, "lie-dar")
    .replace(/\bSPI\b/g, "S P I")
    .replace(/\bI2C\b/g, "I squared C")
    .replace(/\bPCM\b/g, "P C M")
    .replace(/\bMIDI\b/g, "middy")
    .replace(/\bDAW\b/g, "D A W")
    .replace(/\bHDR\b/g, "H D R")
    .replace(/\bEDR\b/g, "E D R")
    .replace(/\bXDR\b/g, "X D R")
    .replace(/\b6K\b/g, "six K")
    .replace(/\b4D\b/g, "four D")
    .replace(/\b3D\b/g, "three D")
    .replace(/\b120Hz\b/gi, "one-twenty Hertz")
    .replace(/\bGitHub\b/gi, "Git Hub");
}

/**
 * Generates authentic 44.1 kHz 16-bit PCM WAV files using SimpleGUI's built-in procedural SFX math from window.m
 */
function generateSimpleGuiSfxWav(effectName: string, outWav: string): void {
  const fx = effectName.toLowerCase();
  let durMs = 280;
  if (fx.includes("power") || fx.includes("chime") || fx.includes("chord") || fx.includes("boom") || fx.includes("rev")) {
    durMs = 520;
  } else if (fx.includes("warp") || fx.includes("ping") || fx.includes("laser")) {
    durMs = 360;
  }
  const sampleRate = 44100;
  const numSamples = Math.floor((sampleRate * durMs) / 1000);
  const dataBytes = numSamples * 2;
  const buf = new ArrayBuffer(44 + dataBytes);
  const view = new DataView(buf);

  const writeStr = (off: number, s: string) => {
    for (let i = 0; i < s.length; i++) view.setUint8(off + i, s.charCodeAt(i));
  };
  writeStr(0, "RIFF");
  view.setUint32(4, 36 + dataBytes, true);
  writeStr(8, "WAVE");
  writeStr(12, "fmt ");
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true);
  view.setUint16(22, 1, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, sampleRate * 2, true);
  view.setUint16(32, 2, true);
  view.setUint16(34, 16, true);
  writeStr(36, "data");
  view.setUint32(40, dataBytes, true);

  for (let i = 0; i < numSamples; i++) {
    const t = i / sampleRate;
    const prog = i / numSamples;
    const env = prog < 0.04 ? prog / 0.04 : Math.pow(1.0 - prog, 1.45);
    let s = 0.0;
    if (fx.includes("power")) {
      const notes = [523.25, 659.25, 783.99, 987.77, 1174.66];
      const f = notes[Math.min(4, Math.floor(prog * 5.0))]!;
      s = 0.65 * Math.sin(2 * Math.PI * f * t) + 0.35 * Math.sin(4 * Math.PI * f * t);
    } else if (fx.includes("smart_home") || fx.includes("chime")) {
      const f = prog < 0.45 ? 783.99 : 659.25;
      s = 0.7 * Math.sin(2 * Math.PI * f * t) + 0.3 * Math.sin(4 * Math.PI * f * t);
    } else if (fx.includes("engine") || fx.includes("rev")) {
      const f = 95.0 + 380.0 * prog;
      s = 0.6 * Math.sin(2 * Math.PI * f * t) + 0.4 * Math.sin(4 * Math.PI * f * t);
    } else if (fx.includes("boom") || fx.includes("supernova")) {
      const f = 120.0 * Math.pow(0.22, prog);
      const noise = ((Math.sin(i * 12.9898) * 43758.5453) % 1) * Math.pow(1.0 - prog, 1.8);
      s = 0.68 * Math.sin(2 * Math.PI * f * t) + 0.32 * noise;
    } else if (fx.includes("chord") || fx.includes("synth")) {
      s =
        0.35 * Math.sin(2 * Math.PI * 220.0 * t) +
        0.3 * Math.sin(2 * Math.PI * 277.18 * t) +
        0.25 * Math.sin(2 * Math.PI * 329.63 * t) +
        0.2 * Math.sin(2 * Math.PI * 440.0 * t);
    } else if (fx.includes("warp") || fx.includes("quantum")) {
      const f = 260.0 + 980.0 * Math.sin(prog * Math.PI);
      s = Math.sin(2 * Math.PI * f * t + 4.0 * Math.sin(2 * Math.PI * 18.0 * t));
    } else {
      s = Math.sin(2 * Math.PI * 1380.0 * t) * Math.exp(-prog * 5.5);
    }
    const val = Math.max(-32700, Math.min(32700, Math.round(s * env * 18000)));
    view.setInt16(44 + i * 2, val, true);
  }
  writeFileSync(outWav, new Uint8Array(buf));
}

async function narrateSegment(id: string, rawText: string, sfxPreset: string): Promise<{ file: string; seconds: number }> {
  mkdirSync(AUDIO_DIR, { recursive: true });
  mkdirSync(SFX_DIR, { recursive: true });
  const text = spokenText(rawText);
  const key = createHash("sha1").update(`v3:${EDGE_VOICE}:${RATE}:${GAP}:${sfxPreset}|${text}`).digest("hex");
  const finalMp3 = join(AUDIO_DIR, `narration_${id}.mp3`);
  const keyFile = join(AUDIO_DIR, `narration_${id}.key`);

  if (existsSync(finalMp3) && existsSync(keyFile) && readFileSync(keyFile, "utf8") === key) {
    return { file: finalMp3, seconds: durationOf(finalMp3) };
  }

  const work = join(AUDIO_DIR, `_work_${id}`);
  rmSync(work, { recursive: true, force: true });
  mkdirSync(work, { recursive: true });

  const parts = (text.match(/[^.!?]+[.!?]+|[^.!?]+$/g) ?? []).map((x) => x.trim()).filter(Boolean);
  const gapWav = join(work, "gap.wav");
  sh([FFMPEG, "-y", "-f", "lavfi", "-i", "anullsrc=r=24000:cl=mono", "-t", String(GAP), gapWav], { quiet: true });

  const listLines: string[] = [];
  parts.forEach((p, idx) => {
    const mp3 = join(work, `${idx}.mp3`);
    const wav = join(work, `${idx}.wav`);
    let ok = false;
    for (let attempt = 0; attempt < 4 && !ok; attempt++) {
      const r = Bun.spawnSync(
        [UVX, "edge-tts", "--voice", EDGE_VOICE, `--rate=${RATE}`, "--text", p, "--write-media", mp3],
        { stdout: "ignore", stderr: "ignore" },
      );
      ok = r.exitCode === 0 && existsSync(mp3) && Bun.file(mp3).size > 800;
    }
    if (!ok) throw new Error(`edge-tts failed on: ${p}`);
    sh([FFMPEG, "-y", "-i", mp3, "-ar", "24000", "-ac", "1", wav], { quiet: true });
    listLines.push(`file '${wav}'`);
    if (idx < parts.length - 1) listLines.push(`file '${gapWav}'`);
  });

  const concatTxt = join(work, "list.txt");
  const rawVoiceWav = join(work, "raw_voice.wav");
  writeFileSync(concatTxt, listLines.join("\n"));
  sh([FFMPEG, "-y", "-f", "concat", "-safe", "0", "-i", concatTxt, "-ar", "48000", "-ac", "2", rawVoiceWav], {
    quiet: true,
  });

  const polishedVoiceWav = join(work, "polished_voice.wav");
  sh(
    [
      FFMPEG,
      "-y",
      "-i",
      rawVoiceWav,
      "-af",
      "highpass=f=70,acompressor=threshold=-20dB:ratio=2.2:attack=15:release=200,loudnorm=I=-16:TP=-1.5:LRA=11,aresample=48000,adelay=100|100,apad=pad_dur=0.15",
      "-ar",
      "48000",
      "-ac",
      "2",
      polishedVoiceWav,
    ],
    { quiet: true },
  );

  const sfxWav = join(SFX_DIR, `${sfxPreset}.wav`);
  generateSimpleGuiSfxWav(sfxPreset, sfxWav);

  sh(
    [
      FFMPEG,
      "-y",
      "-i",
      polishedVoiceWav,
      "-i",
      sfxWav,
      "-filter_complex",
      "[1:a]aresample=48000,pan=stereo|c0=c0|c1=c0,volume=0.22[sfx];[0:a][sfx]amix=inputs=2:duration=first:dropout_transition=0[a]",
      "-map",
      "[a]",
      "-c:a",
      "libmp3lame",
      "-q:a",
      "2",
      finalMp3,
    ],
    { quiet: true },
  );

  rmSync(work, { recursive: true, force: true });
  writeFileSync(keyFile, key);
  return { file: finalMp3, seconds: durationOf(finalMp3) };
}

interface SlideSpec {
  mainImage: string;
  secondaryImage: string;
  badgeTop: string;
  headline: string;
  subline: string;
  calloutLeftTitle: string;
  calloutLeftDesc: string;
  calloutRightTitle: string;
  calloutRightDesc: string;
  accentColor: string;
  sfxBadge: string;
}

interface ChapterSpec {
  id: string;
  chapterBadge: string;
  title: string;
  caption: string;
  narration: string;
  sfxPreset: string;
  slides: SlideSpec[];
}

const CHAPTERS: ChapterSpec[] = [
  {
    id: "00_intro",
    chapterBadge: "M4 ULTRA 6K 120HZ",
    title: "Native Vlang SimpleGUI + Webview RAD Studio on M4 Ultra 6K",
    caption: "115+ Controls · 50 FX Themes · Qt 6 Smart House · 4D Shaders · WebView IDE",
    narration:
      "Meet Vlang SimpleGUI and Webview RAD Studio on our Apple Mac Studio M4 Ultra at 120Hz ProMotion: 115 native Cocoa and God-Mode controls, 50 Ultra themes, and 47 desktop workstations!",
    sfxPreset: "power_up",
    slides: [
      {
        mainImage: "screenshots/god_mode_smart_house_showcase.png",
        secondaryImage: "screenshots/goat_omega_tesseract.png",
        badgeTop: "🍎 APPLE MAC STUDIO M4 ULTRA · 32C CPU · 80C GPU · 192GB UNIFIED · 6K 120HZ",
        headline: "VLANG SIMPLEGUI + WEBVIEW RAD STUDIO",
        subline: "115+ Controls · 50 FX Themes · 140+ Demos · 47 Workstations · 49 CLI Tools",
        calloutLeftTitle: "⚡ 100% Native V + Cocoa + Metal EDR",
        calloutLeftDesc: "Zero-bloat native macOS arm64 binary with 120Hz ProMotion & Display-P3 1600-nit HDR.",
        calloutRightTitle: "🌌 Omega Pantheon 4D Shaders & Audio",
        calloutRightDesc: "Real-time 4D Tesseract shaders, particle fireworks & 16-preset PCM synthesizer.",
        accentColor: "#38bdf8",
        sfxBadge: "🔊 SFX: power_up (44.1kHz PCM)",
      },
      {
        mainImage: "screenshots/all_controls_demo.png",
        secondaryImage: "screenshots/webview_rad_studio_ide.png",
        badgeTop: "⚡ 115+ NATIVE COCOA, SUPER & GOD-MODE CONTROLS",
        headline: "EVERY CONTROL A DEVELOPER COULD EVER WANT",
        subline: "Standard Inputs · Rich macOS Views · Scientific Charts · Qt 6 Domotics · WebView IDE",
        calloutLeftTitle: "🧭 20 Control Categories Built In",
        calloutLeftDesc: "Grid & Flexbox auto-layout, struct reflection forms, CRUD tables & tree views.",
        calloutRightTitle: "🌐 Hybrid Native + WebView Engine",
        calloutRightDesc: "Switch seamlessly between native Cocoa controls and vlang_webview_rad_studio.",
        accentColor: "#a855f7",
        sfxBadge: "🔊 SFX: synth_chord (44.1kHz PCM)",
      },
    ],
  },
  {
    id: "01_smart_house",
    chapterBadge: "QT 6 SMART HOUSE",
    title: "Qt 6 Smart House Domotics, 270° HVAC Thermostat & 3D CAD",
    caption: "Interactive 6-Room Floorplan · 270° Climate Dial · 3D House Mesh · Sankey Energy Flow",
    narration:
      "In the Qt 6 Smart House library, toggle 6 architectural rooms with live lighting and kilowatt telemetry, dial the 270-degree HVAC thermostat, and inspect the 3D house mesh and Solar Sankey flow!",
    sfxPreset: "smart_home_chime",
    slides: [
      {
        mainImage: "screenshots/god_mode_smart_house_showcase.png",
        secondaryImage: "screenshots/webview_god_mode_app.png",
        badgeTop: "🏠 QT 6 SMART HOUSE & ARCHITECTURAL DOMOTICS SUITE",
        headline: "6-ROOM FLOORPLAN & 270° HVAC THERMOSTAT",
        subline: "add_smart_house_floorplan · add_smart_thermostat · add_mesh_viewport_3d · add_sankey_chart",
        calloutLeftTitle: "🏠 Interactive 6-Room Blueprint",
        calloutLeftDesc: "Click Living Lounge, Kitchen, Master Suite, Lab, Garage EV & Patio to toggle lights.",
        calloutRightTitle: "🌡️ 270° Rotary Climate Dial",
        calloutRightDesc: "Drag to adjust target °F/°C with live humidity badge, leaf indicator & tick SFX.",
        accentColor: "#10b981",
        sfxBadge: "🔊 SFX: smart_home_chime + thermostat_tick",
      },
      {
        mainImage: "screenshots/webview_god_mode_app.png",
        secondaryImage: "screenshots/god_mode_smart_house_showcase.png",
        badgeTop: "🧊 3D ARCHITECTURAL CAD MESH & SANKEY ENERGY TELEMETRY",
        headline: "3D HOUSE WIREFRAME & SOLAR POWERWALL FLOW",
        subline: "Perspective 3D Depth Sorting · Solar Array → Powerwall → HVAC & EV Charger",
        calloutLeftTitle: "🧊 Real-Time 3D Mesh Viewport",
        calloutLeftDesc: "Switch between House CAD, Torus Knot, Icosahedron & Cyber Jet 3D meshes.",
        calloutRightTitle: "⚡ Sankey Energy Flow Diagram",
        calloutRightDesc: "Proportional cubic-Bezier ribbons tracking live kW distribution across the home.",
        accentColor: "#06b6d4",
        sfxBadge: "🔊 SFX: smart_home_chime (44.1kHz PCM)",
      },
    ],
  },
  {
    id: "02_digital_cockpit",
    chapterBadge: "DIGITAL COCKPIT",
    title: "Automotive & Aerospace Digital Cockpit, LiDAR Radar & Nixie Chrono",
    caption: "228 MPH Twin-Dial Cluster · ADAS Corridor · Polar LiDAR Radar · SPI/I2C Logic Scope",
    narration:
      "Launch the Digital Cockpit with a 228 mile-per-hour speedometer, tachometer, and ADAS lane HUD, plus a sweeping Polar LiDAR Radar, 8-channel SPI Logic Analyzer, and glowing Nixie Tube display!",
    sfxPreset: "engine_rev",
    slides: [
      {
        mainImage: "screenshots/god_mode_cyberpunk_cockpit.png",
        secondaryImage: "screenshots/god_mode_smart_house_showcase.png",
        badgeTop: "🏎️ QT 6 AUTOMOTIVE & AEROSPACE TELEMETRY COCKPIT",
        headline: "228 MPH DIGITAL CLUSTER & ADAS LANE HUD",
        subline: "add_cockpit_cluster · Twin Speed/RPM Arcs · Gear PRNDMS · G-Force Meter · Battery SoC",
        calloutLeftTitle: "🏎️ Twin-Dial Speed & RPM Cluster",
        calloutLeftDesc: "Live 228 MPH / 7,600 RPM redline arcs, 3D perspective ADAS corridor & G-ball.",
        calloutRightTitle: "🔥 Cyberpunk Edgerunner 2099 Theme",
        calloutRightDesc: "One-click runtime theme switch with M4 raytrace prism bloom and engine rev audio.",
        accentColor: "#f43f5e",
        sfxBadge: "🔊 SFX: engine_rev (95Hz → 475Hz Sweep)",
      },
      {
        mainImage: "screenshots/god_mode_smart_house_showcase.png",
        secondaryImage: "screenshots/god_mode_cyberpunk_cockpit.png",
        badgeTop: "🛰️ HARDWARE INSTRUMENTATION & RETRO-FUTURISTIC TELEMETRY",
        headline: "POLAR LIDAR RADAR, LOGIC SCOPE & NIXIE TUBES",
        subline: "add_polar_radar_sonar · add_logic_analyzer · add_nixie_display",
        calloutLeftTitle: "🛰️ Sweeping Polar Radar & Logic Scope",
        calloutLeftDesc: "Phosphor persistence blips, RF Smith chart & 8-channel CLK/MOSI/MISO/SDA/SCL buses.",
        calloutRightTitle: "🕰️ Vacuum Nixie Tube Chrono",
        calloutRightDesc: "Glass vacuum envelopes, hexagonal anode mesh, unlit ghost cathodes & plasma halo.",
        accentColor: "#f59e0b",
        sfxBadge: "🔊 SFX: radar_ping (1380Hz Sonar)",
      },
    ],
  },
  {
    id: "03_4d_shaders_themes",
    chapterBadge: "4D SHADERS & 50 THEMES",
    title: "GOAT 4D Tesseract Shaders, Particle Physics & 50 Ultra FX Themes",
    caption: "4D Hypercube · Tokamak Plasma · Supernova Particles · 3D Foil Cards · 5-Layer 3D Folders",
    narration:
      "Unleash 6 real-time 4D shaders—including 4D Tesseract hypercubes, Tokamak plasma, and Synthwave horizons—plus supernova particle physics, 3D hologram cards, and 50 themes with Display-P3 HDR!",
    sfxPreset: "supernova_boom",
    slides: [
      {
        mainImage: "screenshots/goat_omega_tesseract.png",
        secondaryImage: "screenshots/goat_prism_plasma_reactor.png",
        badgeTop: "🌌 GOAT 4D MATHEMATICAL SHADERS & PARTICLE PHYSICS ENGINE",
        headline: "4D TESSERACT, PLASMA REACTOR & SUPERNOVA FX",
        subline: "tesseract_4d · plasma_reactor · synthwave_horizon · audio_spectrum_3d · black_hole · neural_plexus",
        calloutLeftTitle: "🌌 4D Hypercube & Tokamak Plasma",
        calloutLeftDesc: "Double-plane XW/YZ 4D rotation projected to 3D/2D + 72-particle supernova bursts.",
        calloutRightTitle: "💎 3D Hologram Cards & Sculpted Folders",
        calloutRightDesc: "Iridescent foil cards (0.38ms Metal-FX, 15.4:1 WCAG AAA) & 5-layer 3D folders.",
        accentColor: "#ec4899",
        sfxBadge: "🔊 SFX: supernova_boom (Sub-Bass + Burst)",
      },
      {
        mainImage: "screenshots/goat_cyberpunk_synthwave.png",
        secondaryImage: "screenshots/goat_tokyo_spectrum_3d.png",
        badgeTop: "🎨 50 CURATED & ULTRA 6K XDR THEMES + DISPLAY-P3 HDR",
        headline: "OMEGA PANTHEON, SYNTHWAVE & TOKYO SPECTRUM 3D",
        subline: "18 Classic Studio · 12 Flagship FX · 20 Hardware-Tiered Custom Themes (Low–Ultra) · CCFM1 Codes",
        calloutLeftTitle: "🌅 Synthwave Outrun & 3D Spectrum",
        calloutLeftDesc: "Perspective neon grid, twin synthwave suns & 3D isometric FFT spectrum analyzer.",
        calloutRightTitle: "☀️ 1600-Nit Display-P3 EDR Headroom",
        calloutRightDesc: "64-bit RGBA16Float Metal views, Reinhard/ACES tone-mapping & WCAG contrast guard.",
        accentColor: "#8b5cf6",
        sfxBadge: "🔊 SFX: synth_chord (Polyphonic A-Major)",
      },
    ],
  },
  {
    id: "04_pro_audio_synth",
    chapterBadge: "PRO AUDIO & SYNTH",
    title: "Built-In 16-Preset Procedural PCM Synth, MIDI Piano & 16-Step Sequencer",
    caption: "Zero-File 44.1kHz PCM Audio · 2-Octave MIDI Piano · 4×16 Drum Matrix · Bezier Node Graph",
    narration:
      "Every control packs zero-dependency 44.1 kilohertz procedural PCM sound effects, a playable two-octave MIDI synthesizer piano, a 16-step drum matrix sequencer, Bezier node graph, and studio color wheel!",
    sfxPreset: "synth_chord",
    slides: [
      {
        mainImage: "screenshots/god_mode_cyberpunk_cockpit.png",
        secondaryImage: "screenshots/goat_tokyo_spectrum_3d.png",
        badgeTop: "🎹 BUILT-IN PROCEDURAL PCM SYNTHESIZER & PRO AUDIO DAW",
        headline: "MIDI PIANO KEYBOARD & 16-STEP DRUM MATRIX",
        subline: "play_sfx (16 Presets) · play_synth_tone · play_piano_note · add_piano_keyboard · add_step_sequencer",
        calloutLeftTitle: "🎹 Playable 2-Octave MIDI Synth",
        calloutLeftDesc: "Click any key (C3–B5) for instant polyphonic synthesis across 7 waveforms.",
        calloutRightTitle: "🥁 4×16 Drum & Synth Matrix",
        calloutRightDesc: "Interactive KICK, SNARE, HIHAT & SYNTH step pads with live playhead sweep.",
        accentColor: "#00f5d4",
        sfxBadge: "🔊 SFX: synth_chord + play_piano_note(60..83)",
      },
      {
        mainImage: "screenshots/rad_studio_goat_vfx.png",
        secondaryImage: "screenshots/god_mode_smart_house_showcase.png",
        badgeTop: "🕸️ VISUAL NODE SHADER GRAPH & STUDIO VECTORSCOPE COLOR WHEEL",
        headline: "BEZIER BLUEPRINT NODES & HARMONY COLOR WHEEL",
        subline: "add_node_graph · add_color_wheel · add_waveform_synthesizer · Lissajous Phase Scope",
        calloutLeftTitle: "🕸️ Bezier Node Graph Editor",
        calloutLeftDesc: "Connect Osc 440Hz, LowPass Filter, Reverb & Master Out with glowing data pulses.",
        calloutRightTitle: "🎨 Studio Color Wheel & Harmonies",
        calloutRightDesc: "360° hue ring, Triad/Complementary harmony chord lines & live hex readout.",
        accentColor: "#eab308",
        sfxBadge: "🔊 SFX: cyber_click + neon_hover",
      },
    ],
  },
  {
    id: "05_webview_rad_workstations",
    chapterBadge: "WEBVIEW RAD & 47 APPS",
    title: "Integrated vlang_webview_rad_studio, Drag & Drop IDE & 47 Workstations",
    caption: "Visual UI Designer · 1-Click Native V or WebView Export · 47 Desktop Studios · 49 CLI Apps",
    narration:
      "Build visually in the drag-and-drop RAD Designer and integrated Vlang Webview RAD Studio—exporting to native V Cocoa or HTML5 Webview apps in one click—plus 47 workstations. Download free on GitHub!",
    sfxPreset: "quantum_warp",
    slides: [
      {
        mainImage: "screenshots/webview_rad_studio_ide.png",
        secondaryImage: "screenshots/rad_studio_goat_vfx.png",
        badgeTop: "🌐 INTEGRATED VLANG_WEBVIEW_RAD_STUDIO + NATIVE RAD DESIGNER",
        headline: "DRAG & DROP IDE: NATIVE COCOA OR HTML5 WEBVIEW",
        subline: "examples/webview_rad_studio.v · examples/rad_studio.v · 70+ Palette Widgets · 17 Presets",
        calloutLeftTitle: "🎨 Visual WYSIWYG Form Designer",
        calloutLeftDesc: "Object Inspector, Undo/Redo, multi-select align & 17 presets including Smart House.",
        calloutRightTitle: "🚀 1-Click Dual Target Codegen",
        calloutRightDesc: "Compile to native V SimpleGUI Cocoa code OR standalone HTML5/WebAudio WebView apps.",
        accentColor: "#3b82f6",
        sfxBadge: "🔊 SFX: quantum_warp (FM Teleport Sweep)",
      },
      {
        mainImage: "screenshots/media_studio_hub.png",
        secondaryImage: "screenshots/ffmpeg_studio.png",
        badgeTop: "🖥️ 47 NATIVE STUDIO WORKSTATIONS · 49 CLI APPS · 45 UTILS",
        headline: "DOWNLOAD FREE ON GITHUB — BUILT FOR M4 ULTRA",
        subline: "github.com/codecaine-zz/vlang_simplegui · github.com/codecaine-zz/vlang_webview_rad_studio",
        calloutLeftTitle: "🛠️ 47 Ready-to-Run Desktop Studios",
        calloutLeftDesc: "FFmpeg, ImageMagick, Docker, SQLite, Crypto, Nmap, Media Hub, Task Manager & more.",
        calloutRightTitle: "⬇️ Get the Complete Suite on GitHub",
        calloutRightDesc: "100% Free & Open Source MIT · Native Apple Silicon M4 Ultra 6K 120Hz Ready.",
        accentColor: "#22c55e",
        sfxBadge: "🔊 SFX: success_chime (Harmonic Triad)",
      },
    ],
  },
];

const esc = (s: string) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function renderHtmlToPng(html: string, pngPath: string, width: number, height: number): void {
  mkdirSync(join(pngPath, ".."), { recursive: true });
  const htmlPath = pngPath.replace(/\.png$/, ".html");
  writeFileSync(htmlPath, html);
  const chromeTmp = `/tmp/vlang_sg_short_chrome_${process.pid}`;
  sh(
    [
      CHROME,
      "--headless=new",
      "--disable-gpu",
      `--user-data-dir=${chromeTmp}`,
      "--no-first-run",
      "--default-background-color=00000000",
      "--hide-scrollbars",
      `--screenshot=${pngPath}`,
      `--window-size=${width},${height}`,
      `file://${htmlPath}`,
    ],
    { quiet: true },
  );
  if (!existsSync(pngPath)) throw new Error(`Failed to render ${pngPath}`);
}

/**
 * Renders a native 9:16 Vertical (1080x1920) Retina slide frame with 100% uncropped UI viewports
 */
function buildVerticalSlideHtml(ch: ChapterSpec, slide: SlideSpec, stepNum: number, totalSteps: number): string {
  const mainAbs = `file://${join(ROOT, slide.mainImage)}`;
  const secAbs = `file://${join(ROOT, slide.secondaryImage)}`;
  return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>
*{box-sizing:border-box;margin:0;padding:0}
body{
  width:1080px;height:1920px;overflow:hidden;
  background:
    radial-gradient(950px 650px at 50% 0%, ${slide.accentColor}38, transparent 70%),
    radial-gradient(850px 600px at 50% 100%, #3b82f628, transparent 70%),
    linear-gradient(180deg, #050811 0%, #090e1a 52%, #050811 100%);
  font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display","Segoe UI",Roboto,sans-serif;
  color:#f8fafc;
  display:flex;flex-direction:column;justify-content:space-between;
  padding:36px 34px 34px;
  position:relative;
}
.top-header{
  display:flex;flex-direction:column;align-items:center;text-align:center;gap:10px;
}
.top-pills{
  display:flex;align-items:center;justify-content:center;gap:10px;flex-wrap:wrap;
}
.kicker{
  background:linear-gradient(135deg, ${slide.accentColor}, #2563eb);
  color:#ffffff;font-weight:900;font-size:17px;letter-spacing:.07em;
  padding:7px 18px;border-radius:999px;text-transform:uppercase;
  box-shadow:0 8px 24px ${slide.accentColor}55;
}
.sfx-pill{
  background:rgba(15,23,42,0.92);border:1.5px solid ${slide.accentColor};
  color:#fde68a;font-weight:800;font-size:16px;padding:6px 15px;border-radius:999px;
}
h1{
  font-size:43px;font-weight:900;line-height:1.05;letter-spacing:-.025em;
  color:#ffffff;text-shadow:0 4px 20px rgba(0,0,0,0.7);
}
.subline{
  font-size:19.5px;font-weight:700;color:#7dd3fc;line-height:1.22;max-width:990px;
}
.stage{
  display:flex;flex-direction:column;gap:14px;
}
.main-shot-wrap{
  width:1012px;height:710px;border-radius:22px;overflow:hidden;
  background:radial-gradient(circle at center, #0f172a, #060913);
  border:2.5px solid ${slide.accentColor}aa;
  box-shadow:0 20px 50px rgba(0,0,0,0.75), 0 0 28px ${slide.accentColor}33;
  display:flex;flex-direction:column;
}
.shot-bar{
  height:42px;padding:0 16px;background:rgba(5,8,17,0.95);
  border-bottom:1.5px solid ${slide.accentColor}55;
  display:flex;align-items:center;justify-content:space-between;flex:none;
}
.shot-tag{
  color:#e2e8f0;font-size:15px;font-weight:800;letter-spacing:.04em;
}
.shot-step{
  background:rgba(29,78,216,0.9);border:1px solid #93c5fd;
  color:#ffffff;font-size:14.5px;font-weight:900;padding:3px 12px;border-radius:8px;
}
.main-img-box{
  flex:1;width:100%;height:668px;padding:6px;display:flex;align-items:center;justify-content:center;
}
.main-img-box img{
  width:100%;height:100%;object-fit:contain;border-radius:12px;
}
.dual-row{
  display:grid;grid-template-columns:499px 499px;gap:14px;height:368px;
}
.sec-shot-wrap{
  border-radius:18px;overflow:hidden;
  background:radial-gradient(circle at center, #0f172a, #060913);
  border:2px solid rgba(148,163,184,0.4);
  box-shadow:0 14px 34px rgba(0,0,0,0.6);
  display:flex;flex-direction:column;
}
.sec-img-box{
  flex:1;width:100%;height:326px;padding:6px;display:flex;align-items:center;justify-content:center;
}
.sec-img-box img{
  width:100%;height:100%;object-fit:contain;border-radius:10px;
}
.callouts-col{
  display:flex;flex-direction:column;gap:12px;justify-content:space-between;
}
.callout-card{
  flex:1;background:linear-gradient(145deg, rgba(15,23,42,0.95), rgba(9,13,24,0.95));
  border:2px solid ${slide.accentColor}77;border-radius:18px;padding:16px 20px;
  display:flex;flex-direction:column;justify-content:center;gap:6px;
  box-shadow:0 10px 28px rgba(0,0,0,0.5);
}
.callout-title{
  font-size:22px;font-weight:900;color:#ffffff;letter-spacing:-.01em;
}
.callout-desc{
  font-size:18px;font-weight:600;color:#cbd5e1;line-height:1.28;
}
.bottom-hud{
  background:linear-gradient(180deg, rgba(15,23,42,0.96), rgba(9,13,24,0.98));
  border:2px solid ${slide.accentColor}88;border-radius:22px;
  padding:18px 24px;display:flex;flex-direction:column;gap:10px;
  box-shadow:0 18px 45px rgba(0,0,0,0.75);
}
.caption-box{
  font-size:23.5px;font-weight:800;color:#f8fafc;text-align:center;line-height:1.2;
}
.rig-bar{
  background:rgba(254,243,199,0.12);border:1.5px solid #f59e0b;
  color:#fde68a;font-size:18px;font-weight:800;text-align:center;
  padding:7px 14px;border-radius:10px;letter-spacing:.01em;
}
.repo-bar{
  display:flex;justify-content:space-between;align-items:center;
  font-size:17px;font-weight:800;color:#93c5fd;padding:0 4px;
}
</style></head><body>
  <div class="top-header">
    <div class="top-pills">
      <span class="kicker">${esc(slide.badgeTop)}</span>
      <span class="sfx-pill">${esc(slide.sfxBadge)}</span>
    </div>
    <h1>${esc(slide.headline)}</h1>
    <div class="subline">${esc(slide.subline)}</div>
  </div>

  <div class="stage">
    <div class="main-shot-wrap">
      <div class="shot-bar">
        <span class="shot-tag">⚡ ${esc(ch.chapterBadge)} · FULL UNCROPPED RETINA WINDOW</span>
        <span class="shot-step">Scene ${stepNum} of ${totalSteps}</span>
      </div>
      <div class="main-img-box">
        <img src="${mainAbs}" />
      </div>
    </div>
    <div class="dual-row">
      <div class="sec-shot-wrap">
        <div class="shot-bar">
          <span class="shot-tag">🔥 COMPANION STUDIO VIEW</span>
        </div>
        <div class="sec-img-box">
          <img src="${secAbs}" />
        </div>
      </div>
      <div class="callouts-col">
        <div class="callout-card">
          <div class="callout-title">${esc(slide.calloutLeftTitle)}</div>
          <div class="callout-desc">${esc(slide.calloutLeftDesc)}</div>
        </div>
        <div class="callout-card">
          <div class="callout-title">${esc(slide.calloutRightTitle)}</div>
          <div class="callout-desc">${esc(slide.calloutRightDesc)}</div>
        </div>
      </div>
    </div>
  </div>

  <div class="bottom-hud">
    <div class="caption-box">“${esc(ch.caption)}”</div>
    <div class="rig-bar">${esc(RIG_MARK)}</div>
    <div class="repo-bar">
      <span>⚡ github.com/codecaine-zz/vlang_simplegui</span>
      <span>🌐 vlang_webview_rad_studio</span>
    </div>
  </div>
</body></html>`;
}

/**
 * Renders a native 16:9 Widescreen (1920x1080) Retina slide frame with 100% uncropped UI viewports
 */
function buildWidescreenSlideHtml(ch: ChapterSpec, slide: SlideSpec, stepNum: number, totalSteps: number): string {
  const mainAbs = `file://${join(ROOT, slide.mainImage)}`;
  const secAbs = `file://${join(ROOT, slide.secondaryImage)}`;
  return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>
*{box-sizing:border-box;margin:0;padding:0}
body{
  width:1920px;height:1080px;overflow:hidden;
  background:
    radial-gradient(1200px 700px at 18% 0%, ${slide.accentColor}35, transparent 70%),
    radial-gradient(1000px 650px at 85% 100%, #2563eb30, transparent 70%),
    linear-gradient(180deg, #050811 0%, #090e1a 100%);
  font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display","Segoe UI",Roboto,sans-serif;
  color:#f8fafc;
  display:flex;flex-direction:column;justify-content:space-between;
  position:relative;
}
.top-bar{
  height:118px;padding:14px 40px;
  display:flex;align-items:center;justify-content:space-between;
  border-bottom:2px solid ${slide.accentColor}55;
  background:rgba(5,8,17,0.9);
}
.title-col{display:flex;flex-direction:column;gap:5px}
.kicker-row{display:flex;align-items:center;gap:12px}
.kicker{
  background:linear-gradient(135deg, ${slide.accentColor}, #2563eb);
  color:#fff;font-weight:900;font-size:14.5px;letter-spacing:.08em;
  padding:5px 14px;border-radius:999px;text-transform:uppercase;
}
.sfx-badge{
  background:rgba(15,23,42,0.9);border:1.5px solid ${slide.accentColor};
  color:#fde68a;font-weight:800;font-size:14px;padding:4px 14px;border-radius:999px;
}
h1{font-size:34px;font-weight:900;letter-spacing:-.02em;color:#ffffff;line-height:1.1}
.sub{font-size:16.5px;font-weight:700;color:#7dd3fc}
.hw-pill{
  background:rgba(15,23,42,0.92);border:1.5px solid #38bdf8;
  color:#e0f2fe;font-size:15px;font-weight:800;padding:10px 18px;border-radius:14px;
  text-align:right;line-height:1.35;
}
.main-grid{
  height:848px;padding:16px 40px;
  display:grid;grid-template-columns:1210px 610px;gap:20px;
}
.primary-shot{
  border-radius:20px;overflow:hidden;
  background:radial-gradient(circle at center, #0f172a, #060913);
  border:2.5px solid ${slide.accentColor}aa;
  box-shadow:0 20px 50px rgba(0,0,0,0.75);
  padding:8px;display:flex;align-items:center;justify-content:center;
}
.primary-shot img{width:100%;height:100%;object-fit:contain;border-radius:12px}
.side-col{display:flex;flex-direction:column;gap:14px}
.secondary-shot{
  height:430px;border-radius:18px;overflow:hidden;
  background:radial-gradient(circle at center, #0f172a, #060913);
  border:2px solid rgba(148,163,184,0.38);
  box-shadow:0 14px 36px rgba(0,0,0,0.65);
  padding:8px;display:flex;align-items:center;justify-content:center;
}
.secondary-shot img{width:100%;height:100%;object-fit:contain;border-radius:10px}
.callout{
  flex:1;background:linear-gradient(145deg, rgba(15,23,42,0.95), rgba(9,13,24,0.96));
  border:2px solid ${slide.accentColor}77;border-radius:16px;padding:16px 20px;
  display:flex;flex-direction:column;justify-content:center;gap:5px;
}
.callout-title{font-size:21px;font-weight:900;color:#ffffff}
.callout-desc{font-size:17px;font-weight:600;color:#cbd5e1;line-height:1.3}
.strip{
  height:114px;background:linear-gradient(180deg,#f8fafc,#eff6ff);
  border-top:3.5px solid #2563eb;display:flex;align-items:center;gap:22px;padding:0 38px;
}
.badge{
  flex:none;background:#1d4ed8;color:#fff;font-weight:900;font-size:16px;
  letter-spacing:.08em;padding:9px 16px;border-radius:10px;text-transform:uppercase;
}
.col{display:flex;flex-direction:column;gap:4px;min-width:0;flex:1}
.st-title{color:#334155;font-size:18px;font-weight:800}
.st-cap{color:#0f172a;font-size:24.5px;font-weight:900;letter-spacing:-.01em}
.right{flex:none;display:flex;flex-direction:column;align-items:flex-end;gap:6px}
.rig{
  color:#0f172a;font-size:14px;font-weight:800;
  background:#fef3c7;border:1.5px solid #f59e0b;padding:4px 12px;border-radius:8px;
}
.step-num{
  color:#1e40af;font-size:17px;font-weight:900;
  background:#dbeafe;border:1.5px solid #93c5fd;padding:4px 14px;border-radius:10px;
}
</style></head><body>
  <div class="top-bar">
    <div class="title-col">
      <div class="kicker-row">
        <span class="kicker">${esc(slide.badgeTop)}</span>
        <span class="sfx-badge">${esc(slide.sfxBadge)}</span>
      </div>
      <h1>${esc(slide.headline)}</h1>
      <div class="sub">${esc(slide.subline)}</div>
    </div>
    <div class="hw-pill">
      ⚡ APPLE SILICON M4 ULTRA<br/>
      <span style="color:#fde68a;font-size:13.5px">6K XDR · 120Hz ProMotion · Display-P3 HDR</span>
    </div>
  </div>

  <div class="main-grid">
    <div class="primary-shot">
      <img src="${mainAbs}" />
    </div>
    <div class="side-col">
      <div class="secondary-shot">
        <img src="${secAbs}" />
      </div>
      <div class="callout">
        <div class="callout-title">${esc(slide.calloutLeftTitle)}</div>
        <div class="callout-desc">${esc(slide.calloutLeftDesc)}</div>
      </div>
      <div class="callout">
        <div class="callout-title">${esc(slide.calloutRightTitle)}</div>
        <div class="callout-desc">${esc(slide.calloutRightDesc)}</div>
      </div>
    </div>
  </div>

  <div class="strip">
    <div class="badge">${esc(ch.chapterBadge)}</div>
    <div class="col">
      <div class="st-title">${esc(ch.title)}</div>
      <div class="st-cap">${esc(ch.caption)}</div>
    </div>
    <div class="right">
      <div class="rig">${esc(RIG_MARK)}</div>
      <div class="step-num">Chapter ${stepNum} of ${totalSteps}</div>
    </div>
  </div>
</body></html>`;
}

async function main() {
  mkdirSync(PROD, { recursive: true });
  mkdirSync(ASSETS_16x9, { recursive: true });
  mkdirSync(ASSETS_9x16, { recursive: true });
  mkdirSync(SEG_16x9, { recursive: true });
  mkdirSync(SEG_9x16, { recursive: true });

  console.log("● Step 1: Generating Broadcast Neural TTS + SimpleGUI 44.1kHz PCM Sound Effects...");
  const chapterMarks: Array<{ at: number; title: string; badge: string }> = [];
  const segList16x9: string[] = [];
  const segList9x16: string[] = [];
  let elapsed = 0;

  for (let cIdx = 0; cIdx < CHAPTERS.length; cIdx++) {
    const ch = CHAPTERS[cIdx]!;
    const sp = await narrateSegment(ch.id, ch.narration, ch.sfxPreset);
    console.log(`  ♪ ${ch.id}  ${sp.seconds.toFixed(2)}s  [${ch.sfxPreset}]  ${ch.title}`);

    chapterMarks.push({ at: elapsed, title: ch.title, badge: ch.chapterBadge });

    const slideCount = ch.slides.length;
    const perSlideDur = sp.seconds / slideCount;

    const slideVids16x9: string[] = [];
    const slideVids9x16: string[] = [];

    for (let sIdx = 0; sIdx < slideCount; sIdx++) {
      const slide = ch.slides[sIdx]!;
      const png16x9 = join(ASSETS_16x9, `${ch.id}_s${sIdx}.png`);
      const png9x16 = join(ASSETS_9x16, `${ch.id}_s${sIdx}.png`);

      renderHtmlToPng(
        buildWidescreenSlideHtml(ch, slide, cIdx + 1, CHAPTERS.length),
        png16x9,
        1920,
        1080,
      );
      renderHtmlToPng(
        buildVerticalSlideHtml(ch, slide, cIdx + 1, CHAPTERS.length),
        png9x16,
        1080,
        1920,
      );

      const v16 = join(SEG_16x9, `_${ch.id}_s${sIdx}.mp4`);
      const v9 = join(SEG_9x16, `_${ch.id}_s${sIdx}.mp4`);

      sh(
        [
          FFMPEG,
          "-y",
          "-loop",
          "1",
          "-i",
          png16x9,
          "-vf",
          `fps=30,fade=t=in:st=0:d=0.16`,
          "-t",
          perSlideDur.toFixed(3),
          "-c:v",
          "libx264",
          "-preset",
          "fast",
          "-crf",
          "14",
          "-pix_fmt",
          "yuv420p",
          v16,
        ],
        { quiet: true },
      );

      sh(
        [
          FFMPEG,
          "-y",
          "-loop",
          "1",
          "-i",
          png9x16,
          "-vf",
          `fps=30,fade=t=in:st=0:d=0.16`,
          "-t",
          perSlideDur.toFixed(3),
          "-c:v",
          "libx264",
          "-preset",
          "fast",
          "-crf",
          "14",
          "-pix_fmt",
          "yuv420p",
          v9,
        ],
        { quiet: true },
      );

      slideVids16x9.push(`file '${v16}'`);
      slideVids9x16.push(`file '${v9}'`);
    }

    const cat16Txt = join(SEG_16x9, `_${ch.id}_slides.txt`);
    const cat9Txt = join(SEG_9x16, `_${ch.id}_slides.txt`);
    writeFileSync(cat16Txt, slideVids16x9.join("\n"));
    writeFileSync(cat9Txt, slideVids9x16.join("\n"));

    const mergedV16 = join(SEG_16x9, `_${ch.id}_v.mp4`);
    const mergedV9 = join(SEG_9x16, `_${ch.id}_v.mp4`);
    sh([FFMPEG, "-y", "-f", "concat", "-safe", "0", "-i", cat16Txt, "-c", "copy", mergedV16], { quiet: true });
    sh([FFMPEG, "-y", "-f", "concat", "-safe", "0", "-i", cat9Txt, "-c", "copy", mergedV9], { quiet: true });

    const segOut16 = join(SEG_16x9, `${ch.id}.mp4`);
    const segOut9 = join(SEG_9x16, `${ch.id}.mp4`);

    sh(
      [
        FFMPEG,
        "-y",
        "-i",
        mergedV16,
        "-i",
        sp.file,
        "-c:v",
        "copy",
        "-c:a",
        "aac",
        "-b:a",
        "256k",
        "-t",
        sp.seconds.toFixed(3),
        segOut16,
      ],
      { quiet: true },
    );

    sh(
      [
        FFMPEG,
        "-y",
        "-i",
        mergedV9,
        "-i",
        sp.file,
        "-c:v",
        "copy",
        "-c:a",
        "aac",
        "-b:a",
        "256k",
        "-t",
        sp.seconds.toFixed(3),
        segOut9,
      ],
      { quiet: true },
    );

    segList16x9.push(`file '${segOut16}'`);
    segList9x16.push(`file '${segOut9}'`);
    elapsed += sp.seconds;
  }

  console.log(`\n● Step 2: Assembling Final Master MP4s (${fmtTime(elapsed)} total duration)...`);
  const list16File = join(SEG_16x9, "master_list.txt");
  const list9File = join(SEG_9x16, "master_list.txt");
  writeFileSync(list16File, segList16x9.join("\n"));
  writeFileSync(list9File, segList9x16.join("\n"));

  const raw16 = join(SEG_16x9, "merged_16x9.mp4");
  const raw9 = join(SEG_9x16, "merged_9x16.mp4");
  sh([FFMPEG, "-y", "-f", "concat", "-safe", "0", "-i", list16File, "-c", "copy", raw16], { quiet: true });
  sh([FFMPEG, "-y", "-f", "concat", "-safe", "0", "-i", list9File, "-c", "copy", raw9], { quiet: true });

  const totalDur = durationOf(raw9);
  const bedAudio = join(WORK, "synthwave_bed.m4a");
  sh(
    [
      FFMPEG,
      "-y",
      "-f",
      "lavfi",
      "-i",
      `aevalsrc=sin(110*2*PI*t)*0.016+sin(164.81*2*PI*t)*0.013+sin(220*2*PI*t)*0.015+sin(277.18*2*PI*t)*0.011+sin(329.63*2*PI*t)*0.010:s=48000:d=${totalDur.toFixed(2)}`,
      "-af",
      `lowpass=f=950,afade=t=in:d=2.0,afade=t=out:st=${Math.max(0, totalDur - 3.0).toFixed(2)}:d=3.0`,
      "-c:a",
      "aac",
      bedAudio,
    ],
    { quiet: true },
  );

  const out16x9 = join(PROD, "vlang_simplegui_short_tutorial.mp4");
  const out9x16 = join(PROD, "vlang_simplegui_youtube_short_9x16.mp4");

  sh(
    [
      FFMPEG,
      "-y",
      "-i",
      raw16,
      "-i",
      bedAudio,
      "-filter_complex",
      "[0:a][1:a]amix=inputs=2:duration=first:weights=1.0 0.09[a]",
      "-map",
      "0:v",
      "-map",
      "[a]",
      "-c:v",
      "copy",
      "-c:a",
      "aac",
      "-b:a",
      "192k",
      "-movflags",
      "+faststart",
      out16x9,
    ],
    { quiet: true },
  );

  sh(
    [
      FFMPEG,
      "-y",
      "-i",
      raw9,
      "-i",
      bedAudio,
      "-filter_complex",
      "[0:a][1:a]amix=inputs=2:duration=first:weights=1.0 0.09[a]",
      "-map",
      "0:v",
      "-map",
      "[a]",
      "-c:v",
      "copy",
      "-c:a",
      "aac",
      "-b:a",
      "192k",
      "-movflags",
      "+faststart",
      out9x16,
    ],
    { quiet: true },
  );

  // Also create a 58-second accelerated cut (<60s strict YouTube Short)
  const out9x16Under60 = join(PROD, "vlang_simplegui_youtube_short_under60s_9x16.mp4");
  if (totalDur > 58.5) {
    const speedFactor = totalDur / 57.5;
    sh(
      [
        FFMPEG,
        "-y",
        "-i",
        out9x16,
        "-filter_complex",
        `[0:v]setpts=PTS/${speedFactor.toFixed(4)}[v];[0:a]atempo=${Math.min(2.0, speedFactor).toFixed(4)}[a]`,
        "-map",
        "[v]",
        "-map",
        "[a]",
        "-r",
        "30",
        "-c:v",
        "libx264",
        "-preset",
        "fast",
        "-crf",
        "14",
        "-pix_fmt",
        "yuv420p",
        "-c:a",
        "aac",
        "-b:a",
        "192k",
        "-movflags",
        "+faststart",
        out9x16Under60,
      ],
      { quiet: true },
    );
  } else {
    copyFileSync(out9x16, out9x16Under60);
  }

  const chaptersText = chapterMarks.map((m, i) => `${fmtTime(i === 0 ? 0 : m.at)} ${m.title}`).join("\n");
  const notesPath = join(PROD, "VLANG_SIMPLEGUI_SHORT_TUTORIAL_NOTES.md");
  const uploadGuidePath = join(PROD, "VLANG_SIMPLEGUI_YOUTUBE_UPLOAD_TITLES_DESCRIPTIONS_TAGS.md");

  const notesBody = `# Vlang SimpleGUI + Webview RAD Studio — God-Mode YouTube Short (${fmtTime(totalDur)} & <60s Cut)

## Reference & Hardware Workstation Mark
- **Workstation Hardware Mark:** \`${RIG_MARK}\`
- **Primary Repository:** ${REPO_SIMPLEGUI}
- **Integrated WebView RAD Studio Repository:** ${REPO_WEBVIEW}

## Rendered Video Files
1. **\`youtube_production/vlang_simplegui_youtube_short_under60s_9x16.mp4\`** — *Strict <60s Vertical YouTube Short (1080×1920 9:16)*
2. **\`youtube_production/vlang_simplegui_youtube_short_9x16.mp4\`** — *Standard Pace Vertical YouTube Short (1080×1920 9:16, ${fmtTime(totalDur)})*
3. **\`youtube_production/vlang_simplegui_short_tutorial.mp4\`** — *Widescreen 16:9 Short Tour (1920×1080, ${fmtTime(totalDur)})*

## YouTube Short Title (96 chars — under YouTube's 100-char limit, copy and paste)
\`\`\`text
Vlang SimpleGUI + Webview RAD Studio (M4 Ultra 6K): Qt 6 Smart House, 4D Shaders & Synth #Shorts
\`\`\`

## YouTube Description (copy and paste)
\`\`\`text
A high-velocity tour of Vlang SimpleGUI and integrated Vlang Webview RAD Studio — recorded and marked on our flagship Apple Mac Studio M4 Ultra (32-Core CPU · 80-Core GPU · 192GB Unified Memory · Apple Pro Display XDR 6K @ 120Hz ProMotion).

🔥 MAJOR HIGHLIGHTS COVERED IN THIS SHORT:
• 115+ Native macOS Cocoa, Super & God-Mode Controls + Grid/Flexbox Auto-Layout
• Qt 6 Smart House Domotics Floorplan (6 interactive rooms), 270° HVAC Climate Thermostat, 3D House CAD Wireframe & Solar-to-Powerwall Sankey Flow
• Qt 6 Automotive & Aerospace Digital Cockpit Cluster (228 MPH + RPM Tachometer + ADAS Corridor), Polar LiDAR Radar/Sonar, 8-Channel SPI/I2C Logic Analyzer & Vacuum Nixie Tube Chrono
• GOAT 4D Mathematical Shaders (4D Tesseract Hypercube, Tokamak Plasma Reactor, Synthwave Outrun, 3D Audio Spectrum), Supernova Particle Physics, 3D Hologram Foil Cards & 5-Layer Sculpted 3D Folders
• 50 Curated & Ultra 6K XDR Themes (Omega Pantheon 3099 Singularity, Cyberpunk Edgerunner 2099, Prism Reactor) + 1600-nit Display-P3 HDR/EDR Metal pipeline
• Built-In 16-Preset 44.1kHz 16-bit Procedural PCM Audio Synthesizer, Playable 2-Octave MIDI Piano Keyboard, 4×16 Drum Matrix Step Sequencer, Bezier Visual Node Graph & Studio Color Wheel
• Integrated Drag-and-Drop RAD Visual UI Designer + vlang_webview_rad_studio (1-click export to Native V Cocoa or standalone HTML5/WebView apps) + 47 Native Desktop Studio Workstations & 49 CLI Tools

⬇️ Vlang SimpleGUI Source Code: ${REPO_SIMPLEGUI}
🌐 Vlang Webview RAD Studio Source Code: ${REPO_WEBVIEW}

RECORDING WORKSTATION
🍎 Apple Mac Studio (M4 Ultra · Mac16,14)
⚡ 32-Core CPU · 80-Core Hardware-Ray-Traced GPU · 32-Core Neural Engine
🧠 192 GB Unified LPDDR5X-8533 Memory (819 GB/s Unified Fabric)
🖥️ Apple Pro Display XDR 6K (6016×3384) @ 120Hz ProMotion · Display-P3 1600-nit HDR

CHAPTERS
${chaptersText}

#Shorts #Vlang #SimpleGUI #Qt6 #MacStudio #M4Ultra #Shaders #SmartHome #Webview #RADStudio #OpenSource
\`\`\`

## YouTube Tags (comma-separated, copy and paste)
\`\`\`text
Vlang, Vlang SimpleGUI, Vlang Webview RAD Studio, Mac Studio M4 Ultra, Pro Display XDR 6K 120Hz, Qt 6 Smart House, Digital Cockpit GUI, 4D Tesseract Shader, Procedural Audio Synthesizer, Native macOS Cocoa GUI, Drag and Drop UI Designer, Cyberpunk UI Theme, Open Source GUI Framework, YouTube Shorts
\`\`\`
`;

  writeFileSync(notesPath, notesBody);
  writeFileSync(uploadGuidePath, notesBody);

  for (const [src, dst] of [
    [out9x16Under60, "/Users/codecaine/Downloads/vlang_simplegui_youtube_short_under60s_9x16.mp4"],
    [out9x16, "/Users/codecaine/Downloads/vlang_simplegui_youtube_short_9x16.mp4"],
    [out16x9, "/Users/codecaine/Downloads/vlang_simplegui_short_tutorial.mp4"],
    [notesPath, "/Users/codecaine/Downloads/VLANG_SIMPLEGUI_SHORT_TUTORIAL_NOTES.md"],
  ] as const) {
    if (existsSync(src)) {
      try {
        copyFileSync(src, dst);
      } catch {}
    }
  }

  console.log(`✔ 9:16 <60s YouTube Short:     ${out9x16Under60} (${fmtTime(durationOf(out9x16Under60))}, ${(Bun.file(out9x16Under60).size / 1048576).toFixed(1)} MB)`);
  console.log(`✔ 9:16 Standard YouTube Short: ${out9x16} (${fmtTime(totalDur)}, ${(Bun.file(out9x16).size / 1048576).toFixed(1)} MB)`);
  console.log(`✔ 16:9 Widescreen Short Tour:  ${out16x9} (${fmtTime(totalDur)}, ${(Bun.file(out16x9).size / 1048576).toFixed(1)} MB)`);
  console.log(`✔ YouTube Upload Notes:        ${notesPath}`);
}

await main();
