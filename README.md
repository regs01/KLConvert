# KLConvert
Keyboard layout converter for X11

The app is switching layout or case for selected text. It's made for X11 and somewhat working with under Wayland, but with XWayland apps only. Wayland is missing crucial functionality for accessibility to make it possible for apps running under Wayland.

But X11 isn't Win32 either, so there is no way to automate conversion. And even by a hotkey there is no fully reliable way to do it manually, so there are multiple methods available.

Two methods of getting selection from the app:
  1. Retrieve text from the Primary Selection clipboard. This is a special clipboard that contain recently selected text. Unfortunately, not every app is reporting to the Primary Selection. As well as WINE doesn't report to the Primary Selection.
  2. Emulate copy to clipboard keystroke (Ctrl+Insert or Ctrl+C), so selected text will be copied into the main Clipboard. Unfortunately, some widgetsets ignoring synthetic keystrokes, like GTK 3/4. And in this case content of the main clipboard will be overridden. However, if clipboard content was just a text it will be restored after conversion. 

Three methods of sending conversion back to the app:
  1. Copy converted text back into the Primary Selection. Unfortunately, there is no way to paste from the Primary Selection using keyboard. It can only be done with a middle mouse button, but mouse cursor should be positioned exactly at the place of paste, so it's very difficult to automate paste.
  2. Emulate paste from clipboard keystroke (Shift+Insert or Ctrl+V). So conversion will be copied into the main Clipboard and pasted with a keystroke. But again, it wouldn't work with widgetsets that won't accept synthetic keystrokes.
  3. Third method is to emulate typing. But this method is also not reliable. Due to X11 bug some input may get lost and some might even get reordered.

### Dependencies
The app requires libXtst and libxkbcommon. Also libQt5Pas for Qt5 and libQt6Pas for Qt6.
- Debian-based packages: libxtst6, libxkbcommon0, libqt5pas1, libqt6pas6.
- Red Hat-based packages: libXtst, libxkbcommon, qt5pas, qt6pas.
- Arch-based packages: libxtst,	libxkbcommon, qt5pas, qt6pas.
- Gentoo-based packages: libXtst, libxkbcommon, libqt6pas (no qt5 support).
- FreeBSD packages: libXtst, libxkbcommon, qt5pas, qt6pas. 

### Qt bindings
Binary release of most recent version of qt6 bindings can ve downloaded from here:\
https://github.com/davidbannon/libqt6pas

### Building

At the moment it won't compile even with FPC trunk and require some fixes into FPC.\
https://gitlab.com/freepascal.org/fpc/source/-/merge_requests/1011

With fixes the app theoretically should compile and work for most operating systems with X11, surely except Darwin BSD (macOS), and for most platforms supported by Free Pascal Compiler.

An only required additional package is LazGlobalHotKey. Preinstall it into Lazarus before opening the project. \
https://github.com/regs01/LazGlobalHotKey



