import re
import os

def main():
    with open("applications/README.md") as f:
        app_readme = f.read()

    # Dynamically locate the Complete Applications Suite table in applications/README.md
    lines = app_readme.splitlines()
    entries = []
    in_table_section = False
    for line in lines:
        if line.startswith("## ") and "Complete Applications Suite" in line:
            in_table_section = True
            continue
        if in_table_section and line.startswith("## "):
            break
        if (in_table_section or not entries) and line.startswith("| **"):
            m = re.match(r"\|\s*\*\*([^*]+)\*\*\s*\|\s*\[`([^`]+)`\]\([^)]+\)\s*\|\s*(.+)\s*\|", line)
            if m:
                name, path, desc = m.groups()
                basename = path.split("/")[-1].replace(".v", "")
                if not path.startswith("applications/"):
                    path = f"applications/{path.lstrip('./')}"
                entries.append({
                    "name": name.strip(),
                    "path": path.strip(),
                    "basename": basename,
                    "desc": desc.strip()
                })

    print(f"Loaded {len(entries)} applications")

    with open("README.md") as f:
        readme = f.read()

    sec_header = "## Production Workstations & Studio Applications"
    sec_idx = readme.find(sec_header)
    if sec_idx == -1:
        print("Could not find section header in README.md")
        return

    next_sec_match = re.search(r"\n##\s+", readme[sec_idx + len(sec_header):])
    if not next_sec_match:
        print("Could not find next section header in README.md")
        return
    next_sec_idx = sec_idx + len(sec_header) + next_sec_match.start() + 1

    new_sec_lines = []
    new_sec_lines.append("## Production Workstations & Studio Applications\n")
    new_sec_lines.append(f"SimpleGUI includes {len(entries)} complete, native desktop workstation applications in [`applications/`](applications/) designed for engineering workflows, low-level binary & bitwise register engineering, 2D function plotting & network graph topology, symbolic math, physical dimensional analysis, calculus, statistics & data science, network intelligence, text & code editing, universal archiving & compression, stream editing, system monitoring, filesystem discovery, data analysis, speech synthesis, and media transformation:\n")

    new_sec_lines.append("### 📦 Prerequisites & Homebrew Installation:\n")
    new_sec_lines.append("```bash\n# Check status and automatically install missing Homebrew formulae\n./install_deps.vsh\n\n# Or install manually via Homebrew:\nbrew install ripgrep fd sd gawk ouch ffmpeg imagemagick pandoc wget2 yt-dlp subfinder jq libqalculate numbat kalker nmap exiftool tesseract graphviz\n```\n")

    new_sec_lines.append(f"### 🚀 Complete Workstations Catalog ({len(entries)} Applications):\n")
    new_sec_lines.append("| Application | Source File | Description |")
    new_sec_lines.append("| :--- | :--- | :--- |")
    for e in entries:
        n = e['name']
        p = e['path']
        d = e['desc']
        new_sec_lines.append(f"| **{n}** | [`{p}`]({p}) | {d} |")

    new_sec_lines.append("\nAll applications support dynamic runtime theme switching across all 18 curated palettes with automatic state persistence to `~/.config/simplegui/theme.txt`.\n")

    new_sec_lines.append("### 📸 Workstations Showcase & Screenshots\n")
    new_sec_lines.append(f"All {len(entries)} applications are fully equipped with native screenshots. See [`applications/README.md`](applications/README.md) for the complete visual catalog.\n")

    # Categories (all 47 studio applications)
    categories = [
        ("🧮 Computing, Math & Science", [
            "programmer_calculator", "graph_studio", "statistics_studio",
            "qalc_studio", "numbat_studio", "kalker_studio"
        ]),
        ("🌐 Security, Network & OSINT", [
            "api_studio", "nmap_studio", "dns_studio", "recon_studio",
            "ifconfig_studio", "crypto_studio", "subfinder_studio"
        ]),
        ("🎬 Media, Graphics & Publishing", [
            "media_studio_hub", "ffmpeg_studio", "imagemagick_studio",
            "yt_dlp_studio", "exif_studio", "dot_studio", "ocr_studio",
            "audiotag_studio", "pandoc_studio", "say_studio"
        ]),
        ("⚡ Data Engineering & Stream Processing", [
            "jq_studio", "dataconvert_studio", "sqlite_studio", "gawk_studio",
            "sed_studio", "regex_studio", "cut_studio", "tr_studio"
        ]),
        ("🛠️ System, DevOps & Filesystem Workstations", [
            "app_bundler_studio", "omnitool_studio", "task_manager",
            "text_editor", "brew_studio", "docker_studio", "disk_studio", "launchd_studio",
            "watchexec_studio", "rg_studio", "fd_studio", "find_studio",
            "sd_studio", "rip_studio", "ouch_studio", "wget2_studio"
        ])
    ]

    e_map = {e["basename"]: e for e in entries}

    for cat_title, app_keys in categories:
        new_sec_lines.append(f"#### {cat_title}\n")
        for k in app_keys:
            if k in e_map:
                item = e_map[k]
                n = item['name']
                p = item['path']
                b = item['basename']
                new_sec_lines.append(f"- **{n}**: `v run {p}`")
                if os.path.exists(f"screenshots/{b}.png"):
                    new_sec_lines.append(f"  ![{n}](screenshots/{b}.png)\n")
                else:
                    new_sec_lines.append("")

    new_sec_lines.append("---")
    new_sec_lines.append("👉 **Explore the complete detailed documentation and all screenshots in the [SimpleGUI Applications Suite README](applications/README.md).**\n")

    new_sec_content = "\n".join(new_sec_lines)

    updated_readme = readme[:sec_idx] + new_sec_content + "\n---\n\n" + readme[next_sec_idx:]

    with open("README.md", "w") as f:
        f.write(updated_readme)

    print("Updated README.md successfully!")

if __name__ == "__main__":
    main()
