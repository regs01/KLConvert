Layouts, although Korean and Eastern Phoenician branch scripts aren't simple straight forward conversations.
Would required overriden functions with extensive logic.
https://kbdlayout.info/

### Icon themes
https://github.com/double-commander/doublecmd/blob/master/src/platform/uicontheme.pas

### Debug
 - Memory leak in WaitForChange ProcessMessages with GTK2 (InitKeyboardTables, line 3483 of gtk2/gtk2proc.inc)

### Refactor
 - Refactor (Variable types and scopes)
 - Refactor [Convert UnitXKeyInput to class with class functions?]
 - Syntax Check (fgl unit disables all warnings, hints)
 + [x] Message user, if hotkey registration did fail.
 + [x] Open/Close settings without saving leads to memory leak

### Deployment
 + [x] Autostart
 + [x] Icon from deb package
 + [x] DEB package
 + [x] DEB package variations
 - RPM package
 + [x] Licenses
 + [x] Readme

### Settings
 + [x] Show settings on first run
 - Portability (--portable/-P argument to create portable config and check for config in app folder)
 - Key press delay option
 - Clipboard wait delay option
 - Sounds
 - App Exceptions (detect active app image name)
 - Option to disable check for clipboard content
 - Language: default (detect system language)
 - TrayIcon: default (detect taskbar theme)
 - ConvertLayouts: Active: default (detect default language from keyboard group names)
 - ConvertLayouts: Order (TRConvertLayoutData property)
 - Translated names of key bindings
 - Option to keep selection in main form
 - Option for wordwrap in main form
 + [x] Default (Break) bind for Convert
 - Check autostart checkbox, if file exist

### FormSettings
 + [x] Extract Load and Save into own functions
 + [x] Apply and Save buttons
 - Non-modal settings
 - Update method descrptions
 - Add hints with descriptions
 + [x] About
 + [x] Links into about

### Processing
 + [x] Fallback to local if window is active
 - Primary/Secondary Selection + Keystroke
 + [x] Make sure backup is cleared before making or not a new one

### Processing types
 - ConvertLastWord?
 - TrasnlitSelection?
 - RandomCase?
 - FixEncodings?

### Platforms
 - GTK3: GetFormat is not implemented [Remove HasFormat check for GTK3]
 - GTK3: OnRequest FormatID is not implemented [Do simple delay with checks]
 - GTK3: Form is always active, if visible
 - Qt: OnRequest is not implemented [Do simple delay with checks]
 - LXQt: Showing some wrong unrelated icon in tray
 + [x] ~~Gnome: Doesn't launch~~ (XWayland issue. XkbGetKeyboard is not implemented in XWayland.)
 - GTK3, Qt5, Qt6: Deal with double high DPI scaling (WS+LCL) [Disable either WS scaling or LCL scaling]
