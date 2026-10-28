# Split Network (Ethernet + Wi-Fi at the same time)

Lets a Windows PC use a wired network and Wi-Fi at the same time, splitting traffic by destination:

- Private IP ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) always go over Ethernet, so file shares and internal systems keep working.
- All other traffic goes over Wi-Fi by default (Wi-Fi interface metric 10, Ethernet 60).
- The system proxy stays off.

The scripts read each PC's own adapter and gateway settings when they run; nothing is hard-coded.

## Usage
1. Connect to Wi-Fi and plug in the Ethernet cable.
2. Double-click `setup.bat` and click **Yes** on the administrator prompt. A log is written to `split.log`.
3. To undo everything, double-click `undo.bat`. It removes the routes, restores automatic metrics, disables Ethernet and turns the manual proxy off.

The routes are persistent and survive a reboot. After setup, don't use any tool that disables one of the adapters.

## Files
- `split-setup.ps1`: enables Ethernet, sets interface metrics, and adds the private-range routes (requires administrator).
- `split-undo.ps1`: reverts all changes (requires administrator).
- `split-proxy.ps1`: helper that turns the Windows manual proxy on or off (`-Off` turns it off); used by the undo script.
- `setup.bat` / `undo.bat`: launchers that run the scripts with administrator rights.

## Notes
- If your Wi-Fi subnet falls inside one of the private ranges, Wi-Fi still works because its own subnet route is more specific, but any wired-network hosts in that exact subnet become unreachable.
- Check your organization's IT policy before connecting to two networks at once.
- Requires Windows 10 or later with PowerShell 5.1.
