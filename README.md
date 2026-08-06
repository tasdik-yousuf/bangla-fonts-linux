# Bangla Fonts Linux

A collection of 640+ Bengali (Bangla) fonts, bundled with a simple,
dependency-free installer for Linux. Install just for your user account or
system-wide for everyone — no manual font-dropping required, the fonts are
already included.

## Installation

### Option 1: `.deb` package (Debian/Ubuntu)

The easiest option if you're on a Debian-based distro. Installs system-wide
automatically.

```bash
sudo apt install ./bangla-fonts-linux_1.0.0_all.deb
```

### Option 2: Install script (any distro)

Works on any Linux distro with `fontconfig` (Ubuntu, Fedora, Arch, etc).

```bash
./install.sh
```
You'll be prompted to choose **user** or **system** install.

Non-interactive:
```bash
# Install for just your user account (no sudo/root needed)
./install.sh --user

# Install system-wide for all users (will prompt for sudo password)
./install.sh --system
```

## Uninstall

**If installed via `.deb`:**
```bash
sudo apt remove bangla-fonts-linux
```

**If installed via `install.sh`:**
```bash
./install.sh --uninstall --user
./install.sh --uninstall --system
```
This only removes the `bengali-fonts` folder this tool created — it won't
touch any other fonts on your system.

## Where fonts get installed

| Method              | Location                                  | Needs sudo? |
|---------------------|--------------------------------------------|-------------|
| `.deb`               | `/usr/share/fonts/truetype/bangla-fonts-linux/` | Yes (handled by apt) |
| `install.sh --user`   | `~/.local/share/fonts/bengali-fonts/`      | No          |
| `install.sh --system` | `/usr/local/share/fonts/bengali-fonts/`    | Yes         |

All are standard, distro-agnostic locations that `fontconfig` already scans
by default — no extra config needed.

## What's included

640+ Bengali/Bangla `.ttf` fonts, bundled in the `fonts/` folder — ready to
install as-is, no downloading or sourcing fonts yourself.

## What the script does

1. Confirms the bundled `fonts/` folder is present.
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
