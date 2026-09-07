# LAN Helper (Tesla Overlay) — nx-mod fork

A Tesla overlay that generates and applies a valid, unique static IP for
[Switch LAN Play](https://www.lan-play.com/) or
[XLink Kai](https://www.teamxlink.co.uk/), and resets the console back to
DHCP when you're done playing.

Part of the [switch-cfw](https://github.com/nx-mod) build. Based on the
[official libtesla template](https://github.com/WerWolv/Tesla-Template);
upstream is also on the
[Switch Homebrew appstore](https://hb-app.store/switch/LANHelperTesla).

## What this fork changes

Nothing functional — the overlay behaves exactly as upstream. The changes are
packaging, so it builds inside switch-cfw's flat-library layout:

- **Flat libs.** Upstream's nested `libs/libtesla` submodule is dropped in
  favour of the flat sibling `../tesla-lib`, matching every other overlay in
  this project.
- **Added the Makefile.** The source copy this fork was imported from had none,
  so it was not buildable as-is. The Makefile is modelled on the
  `switch-lan-play-nx` overlay's.
- **Added `build.bat` / `build.sh`** following the repo's per-project
  menu-driven build convention.

## Building

Needs devkitPro (devkitA64) and the flat `tesla-lib` and `libnx` siblings
checked out alongside this repo.

```
bash build.sh          # build -> lanhelper.ovl
bash build.sh dist     # build + package ../_ZIPS_/lanhelper-release.zip
bash build.sh clean
```

On Windows, `build.bat` gives the same targets as a menu. `build.sh` overrides
`LIBNX` to the flat `../libnx/nx` fork rather than devkitPro's stock system
libnx, which is stale for this project's needs.

## Installing

`dist` produces a zip whose top level is the SD card root, so it extracts
straight onto the card:

```
switch/.overlays/LANHelper.ovl
```

It installs as `LANHelper.ovl` (not `lanhelper.ovl`) so it overwrites an
existing copy rather than adding a second Tesla menu entry.

## Gotcha: applying a LAN Play IP takes the console off your LAN

"Use Lan Play" writes a static **`10.13.x.x/16` with gateway `10.13.37.1`**
(see `genIp` in `include/lanhelper.h`). That subnet is virtual — it only exists
because the PC's `lan-play.exe` bridges it at layer 2 over the same Wi-Fi. Two
consequences worth knowing before you go looking for a bug:

- **FTP to the console stops working.** Your PC's IP stack has no route to
  `10.13.0.0/16`, so sys-ftpd becomes unreachable even though it's running fine.
  Pull logs *before* applying the LAN Play IP, or reset to DHCP first. If you
  need both at once, add an on-link route on the PC (same Wi-Fi required):
  `New-NetRoute -DestinationPrefix 10.13.0.0/16 -InterfaceIndex <wifi> -NextHop 0.0.0.0`
- **With `lan-play.exe` down, the console reaches nothing.** `10.13.37.1` is
  fictitious; only the PC client answers for it. "Can't connect to servers"
  right after a LAN Play IP is applied usually means the PC client isn't
  running — not that the console is misconfigured.

## Licence

GPLv2, as upstream. See [LICENSE](LICENSE).
