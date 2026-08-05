# Bengali Font Installer

A small, dependency-free bash project to install a folder of Bengali (Bangla)
fonts on any Linux system — either just for your user account or system-wide
for everyone.

## Setup

1. Drop your Bengali `.ttf` / `.otf` (or `.ttc`, `.otc`, `.woff`, `.woff2`)
   font files into the `fonts/` folder here. Subfolders are fine too.
2. Make the script executable (only needed once):
   ```bash
   chmod +x install.sh
   ```

## Usage

### Interactive (easiest)
```bash
./install.sh
```
You'll be prompted to choose **user** or **system** install.

### Non-interactive
```bash
# Install for just your user account (no sudo/root needed)
./install.sh --user

# Install system-wide for all users (will prompt for sudo password)
./install.sh --system

# Point at a font folder that isn't ./fonts
./install.sh --user /path/to/some/other/font-folder
```

### Uninstall
```bash
./install.sh --uninstall --user
./install.sh --uninstall --system
```
This only removes the `bengali-fonts` folder this tool created — it won't
touch any other fonts on your system.

## Where fonts get installed

| Mode   | Location                                  | Needs sudo? |
|--------|--------------------------------------------|-------------|
| user   | `~/.local/share/fonts/bengali-fonts/`      | No          |
| system | `/usr/local/share/fonts/bengali-fonts/`    | Yes         |

Both are standard, distro-agnostic locations that `fontconfig` already scans
by default on virtually every Linux distro (Ubuntu, Fedora, Arch, etc.) — no
extra config files needed.

## What the script does

1. Validates the fonts folder exists and contains real font files.
2. Copies them into the appropriate fontconfig-managed directory.
3. Sets sane permissions (world-readable for system installs).
4. Runs `fc-cache -f` to rebuild the font cache so apps pick them up
   immediately.
5. Prints a `fc-list` check so you can confirm the fonts registered
   correctly.

## Notes

- After installing, you may need to restart already-open apps (browser,
  LibreOffice, GIMP, terminal emulator settings, etc.) before the new fonts
  show up in their font pickers.
- If `fc-cache` / `fc-list` aren't found, install `fontconfig` first:
  - Debian/Ubuntu: `sudo apt install fontconfig`
  - Fedora: `sudo dnf install fontconfig`
  - Arch: `sudo pacman -S fontconfig`
