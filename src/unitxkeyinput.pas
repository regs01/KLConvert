(* 
  Copyright 2025 coth
  https://github.com/regs01/
  This file is also alternatively licensed under MIT (see COPYING.MIT.txt) 
  or LGPL 2.1 with static link exception (see COPYING.LGPL.txt and COPYING.modifiedLGPL.txt)
*)
unit UnitXKeyInput;

{$mode ObjFPC}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Menus, Unix, X, xlib, XKB, xkblib, StrUtils, LCLProc, LazUTF8, Character,
  LazHotKeyFunctionsUnix;

const
  libXtst = 'libXtst.so.6';
  libXkbcommon = 'libxkbcommon.so.0';
  XtKeyPressed: TBool = 1;
  XtKeyUnPressed: TBool = 0;
  XBoolTrue: TBool = 1;
  XBoolFalse: TBool = 0;
  XEmptyMask: Byte = 0;

type
  TKbGroupsArray = type TStringArray;

  function XTestFakeKeyEvent(display: PDisplay; keycode: TKeyCode; is_press: TBool; delay: LongWord): TStatus; cdecl; external libXtst;
  function xkb_keysym_to_utf32(keysym: TKeySym): cuint32; cdecl; external libXkbcommon;

  function XConnectServer(out AXDisplay: PDisplay): Boolean;
  function XDisconnectServer(AXDisplay: PDisplay): Boolean;
  procedure XSyncServer;

  function GetKeyboardGroups: TKbGroupsArray;
  function GetCurrentKeyboardGroup: SmallInt;
  procedure SetKeyboardGroup(const AGroup: Byte);
  function DetectKeyboardGroup(constref AText: UTF8String; out AGroup: Byte): Boolean;

  procedure ToggleModdifiers(const AShiftState: TShiftState; const AState: TBool);
  procedure ToggleModdifiers(const AMask: Byte; const AState: TBool);
  procedure SendKey(const AKeySym: TKeySym);
  procedure SendKeyStroke(const AShortCut: TShortCut);
  procedure SendKeyStroke(const AKeySym: TKeySym; const AShiftState: TShiftState);
  procedure SendKeyStroke(const AKeySym: TKeySym; const AMask: Byte);
  procedure SendKeyStrokeEvent(const AKeySym: TKeySym; const AMask: Byte);
  procedure SendKeyStrokeEvent(const AKeySym: TKeySym; const AShiftState: TShiftState);
  procedure SendKeyStrokeEvent(const AShortCut: TShortCut);
  procedure SendText(constref AText: UTF8String);

implementation

function XConnectServer(out AXDisplay: PDisplay): Boolean;
begin

  Result := False;

  AXDisplay := XOpenDisplay(nil);
  if AXDisplay = nil then
  begin
    WriteLn(StdErr, ApplicationName, ': ',  'No X11 connection.');
    Exit;
  end;

  Result := True;

end;

function XDisconnectServer(AXDisplay: PDisplay): Boolean;
begin

  Result := False;

  if AXDisplay <> nil then
  begin
    XCloseDisplay(AXDisplay);
    Result := True;
  end;

end;

procedure XSyncServer;
var
  LDisplay: PDisplay;
begin

  if not XConnectServer(LDisplay) then
    Exit;
  try
    XFlush(LDisplay);
    //XSync(LDisplay, False);
  finally
    XDisconnectServer(LDisplay);
  end;

end;

function DoGetKeyboardGroups(AXDisplay: PDisplay; out AGroups: TKbGroupsArray): Boolean;
var
  pDesc: PXkbDescPtr;
  btGroup, btGroups: Byte;
  psGroupName: PAnsiChar;
begin

  Result := False;
  SetLength({%H-}AGroups, 0);

  //pDesc := XkbGetKeyboard(AXDisplay, XkbAllComponentsMask, XkbUseCoreKbd);
  pDesc := XkbAllocKeyboard; // XkbGetKeyboard is not implemented in XWayland
  if pDesc = nil then
    Exit;

  try

    pDesc^.dpy := AXDisplay;

    if XkbGetControls(AXDisplay, XkbAllControlsMask, pDesc) <> Success then
      Exit;
    if XkbGetNames(AXDisplay, XkbGroupNamesMask, pDesc) <> Success then
      Exit;

    btGroups := pDesc^.ctrls^.num_groups;

    for btGroup := 0 to btGroups-1 do
    begin
      psGroupName := XGetAtomName(AXDisplay, pDesc^.names^.groups[btGroup]);
      // Avoid duplication due to XWayland bug
      if not(String(psGroupName) in AGroups) then
      begin
        SetLength(AGroups, btGroup+1);
        AGroups[btGroup] := String(psGroupName);
      end;
    end;

    Result := True;

  finally
    XkbFreeKeyboard(pDesc, 0, True);
  end;

end;

function DoGetCurrentKeyboardGroup(AXDisplay: PDisplay): SmallInt;
var
  LState: TXkbStateRec;
begin

  Result := -1;

  if XkbGetState(AXDisplay, XkbUseCoreKbd, @LState) <> Success then
    Exit;
  Result := LState.group;

end;

function DoSetKeyboardGroup(AXDisplay: PDisplay; const AGroup: Byte): Boolean;
begin

  Result := XkbLockGroup(AXDisplay, XkbUseCoreKbd, AGroup);

end;

function GetCodePointData(AXDisplay: PDisplay; const ACodePoint: LongWord;
  out AKeyCode: TKeyCode; out AGroup: Byte; out AMask: Byte): Boolean;
var
  pDesc: PXkbDescPtr;
  btKeycode, btKeycodeLow, btKeycodeHigh: TKeyCode;
  btGroup, btGroups, btLevel, btLevels: Byte;
  parKeySyms: PKeySym;
  iKeySymsPerKeycode: cint;
  wXkbKeySym: TKeySym;
  pLXkbKeyType: PXkbKeyTypePtr;
  iModifierMap: Integer;
  {%H-}wsChar: WideString;
  wCodePoint: cuint32;
begin

  AKeyCode := 0;
  AGroup := 0;
  AMask := 0;
  Result := False;

  XDisplayKeycodes(AXDisplay, @btKeycodeLow, @btKeycodeHigh);
  parKeySyms := XGetKeyboardMapping(AXDisplay, btKeycodeLow, btKeycodeHigh - btKeycodeLow + 1,  @iKeySymsPerKeycode);
  XFree(parKeySyms);

  pDesc := XkbGetMap(AXDisplay, XkbAllClientInfoMask, XkbUseCoreKbd);

  try

    for btKeycode := btKeycodeLow to btKeycodeHigh do
    begin

      btGroups := XkbKeyNumGroups(pDesc, btKeycode);
      if btGroups = 0 then
        Continue;

      for btGroup := 0 to btGroups-1 do
      begin

        pLXkbKeyType := XkbKeyKeyType(pDesc, btKeycode, btGroup);
        btLevels := pLXkbKeyType^.num_levels;
        if btLevels = 0 then
          Continue;

        for btLevel := 0 to btLevels-1 do
        begin

          wXkbKeySym := XkbKeycodeToKeysym(AXDisplay, btKeycode, btGroup, btLevel);
          if wXkbKeySym = 0 then
            Continue;

          wCodePoint := xkb_keysym_to_utf32(wXkbKeySym);
          if wCodePoint = 0 then
            Continue;

          if wCodePoint <> ACodePoint then
            Continue;

          AMask := 0;
          for iModifierMap:=0 to pLXkbKeyType^.map_count-1 do
          begin
            if (pLXkbKeyType^.map[iModifierMap].active = 1) and (pLXkbKeyType^.map[iModifierMap].level = btLevel) then
            begin
              AMask := pLXkbKeyType^.map[iModifierMap].mods.mask;
              Break;
            end;
          end;

          //wsChar := LazUTF16.UnicodeToUTF16(wCodePoint);
          //WriteLn('Char=',  wsChar, ', wXkbKeySym=', wXkbKeySym, ', wCodePoint=', IntToHex(wCodePoint), ', Group=', btGroup, ', Level=', btLevel, ', Mask=', AMask, '. Found!');

          AKeyCode := btKeycode;
          AGroup := btGroup;
          Result := True;
          Exit;

        end;

      end;

    end;

  finally
    XkbFreeKeyboard(pDesc, 0, True);
  end;

end;

function DoDetectKeyboardGroup(AXDisplay: PDisplay; constref AText: UTF8String; out AGroup: Byte): Boolean;
var
  pDesc: PXkbDescPtr;
  iTextLength, iCharLength, iCharIndex : Integer;
  sUTF8Char: UTF8String;
  cUnicodeChar: UnicodeChar;
  wCodePoint: LongWord;
  bResult: Boolean;
  btKeyCode: TKeyCode;
  btCodepointMask, btGroup: Byte;
  btGroupIndex, btGroupCount: Byte;
  arGroups: array of Integer;
begin

  Result := False;
  btGroupCount := 0;
  SetLength({%H-}arGroups, 0);

  //pDesc := XkbGetKeyboard(AXDisplay, XkbAllComponentsMask, XkbUseCoreKbd);
  pDesc := XkbAllocKeyboard; // XkbGetKeyboard is not implemented in XWayland
  if pDesc = nil then
    Exit;

  try
    pDesc^.dpy := AXDisplay;
    if XkbGetControls(AXDisplay, XkbAllControlsMask, pDesc) <> Success then
      Exit;
    btGroupCount := pDesc^.ctrls^.num_groups;
  finally
    XkbFreeKeyboard(pDesc, 0, True);
  end;

  if btGroupCount = 0 then
    Exit;

  if btGroupCount = 1 then
    Exit(True);

  SetLength(arGroups, btGroupCount);
  for btGroupIndex := 0 to btGroupCount-1 do
    arGroups[btGroupIndex] := 0;

  iTextLength := UTF8Length(AText);
  if iTextLength = 0 then
    Exit;

  for iCharIndex := 1 to iTextLength do
  begin

    sUTF8Char := UTF8Copy(AText, iCharIndex, 1);
    iCharLength := UTF8Length(sUTF8Char);
    if iCharLength = 0 then
      Break;

    wCodePoint := UTF8CodepointToUnicode(PChar(sUTF8Char), iCharLength);
    if wCodePoint = NoSymbol then
      Continue;

    cUnicodeChar := UnicodeChar(wCodePoint);
    if (not IsLetter(cUnicodeChar)) then
      Continue;

    bResult := GetCodePointData (AXDisplay, wCodePoint, btKeyCode, btGroup, btCodepointMask);
    if (not bResult) then
      Continue;

    Inc(arGroups[btGroup]);

  end;

  AGroup := 0;
  for btGroupIndex := 1 to btGroupCount-1 do
  begin
    if arGroups[btGroupIndex] > arGroups[AGroup] then
      AGroup := btGroupIndex;
  end;

  Result := True;

end;

function GetUnusedKeycode(AXDisplay: PDisplay): TKeyCode;
var
  btKeycode, btKeycodeLow, btKeycodeHigh: TKeyCode;
  paKeySyms: PKeySym;
  iKeySymsPerKeycode, iKeySymOfKeycodeIndex, iKeySymIndex: cint;
  bKeycodeInUse: Boolean;
begin

  Result := 0;

  XDisplayKeycodes(AXDisplay, @btKeycodeLow, @btKeycodeHigh);
  paKeySyms := XGetKeyboardMapping(AXDisplay, btKeycodeLow, btKeycodeHigh - btKeycodeLow + 1,  @iKeySymsPerKeycode);

  try

    for btKeycode := btKeycodeHigh downto btKeycodeLow do
    begin;

      bKeycodeInUse := False;
      for iKeySymOfKeycodeIndex := 0 to iKeySymsPerKeycode-1 do
      begin
        // test: xmodmap -e "keycode 248 = NoSymbol NoSymbol a A"
        iKeySymIndex := (btKeycode - btKeycodeLow) * iKeySymsPerKeycode + iKeySymOfKeycodeIndex;
        //WriteLn('Keycode=', btKeycode, ', btKeySymOfKeycodeIndex=', iKeySymOfKeycodeIndex, ', SymIndex=', iKeySymIndex, ', KeySyms[iSymIndex]=', paKeySyms[iKeySymIndex]);
        if (paKeySyms[iKeySymIndex] <> 0) then
          bKeycodeInUse := True;
      end;

      if not bKeycodeInUse then
      begin
        Result := btKeycode;
        Exit;
      end;

    end;

  finally
    XFree(paKeySyms);
  end;

end;

function RemapKeycode (AXDisplay: PDisplay; const AKeyCode: TKeyCode; const AKeySym: TKeySym): Boolean;
var
  paKeySyms: PKeySym;
begin

  Result := False;
  New(paKeySyms);
  try
    paKeySyms^ := AKeySym;
    XChangeKeyboardMapping(AXDisplay, AKeyCode, 1, paKeySyms, 1);
    XFlush(AXDisplay);
    Result := True;
  finally
    Dispose(paKeySyms);
  end;

End;

function DoSendKey(AXDisplay: PDisplay; const AKeyCode: TKeyCode; const AState: TBool): TStatus;
begin

  Result := XTestFakeKeyEvent(AXDisplay, AKeyCode, AState, CurrentTime);

end;

function DoSendKey(AXDisplay: PDisplay; const AKeyCode: TKeyCode): Boolean;
begin

  Result := False;

  try
    DoSendKey(AXDisplay, AKeyCode, XtKeyPressed);
  finally
    Sleep(50);
    DoSendKey(AXDisplay, AKeyCode, XtKeyUnPressed);
    //XSync(AXDisplay, False);
  end;

end;

function DoSendKey(AXDisplay: PDisplay; const AKeySym: TKeySym): Boolean;
var
  btKeycode: Byte;
begin

  Result := False;

  btKeycode := XKeysymToKeycode(AXDisplay, AKeySym);
  if btKeycode = 0 then
    Exit;

  Result := DoSendKey(AXDisplay, btKeycode);

end;

function DoSendKeyEvent(AXDisplay: PDisplay; const AKeyCode: TKeyCode; const AMask: Byte{; const AState: TBool}): TStatus;
var
  LFocusWindow: TWindow;
  iRevertTo: Integer;
  LEvent: TXKeyEvent;
begin

  // XSendEvent won't work with GTK3/4 apps

  iRevertTo := RevertToNone;
  XGetInputFocus(AXDisplay, @LFocusWindow, @iRevertTo);

  LEvent := Default(TXKeyEvent);
  LEvent.display := AXDisplay;
  LEvent.window := LFocusWindow; // InputFocus unreliable
  LEvent.root := DefaultRootWindow(AXDisplay);
  LEvent.keycode := AKeyCode;
  LEvent.state := AMask;

  //LEvent.subwindow := None;
  //LEvent.x := 1;
  //LEvent.y := 1;
  //LEvent.x_root := 1;
  //LEvent.y_root := 1;
  //LEvent.same_screen := 1;

  try
    LEvent._type := X.KeyPress;
    LEvent.time := CurrentTime;
    Result := XSendEvent(AXDisplay, LFocusWindow, XBoolFalse, KeyPressMask, @LEvent);
  finally
    Sleep(50);
    LEvent._type := X.KeyRelease;
    LEvent.time := CurrentTime;
    XSendEvent(AXDisplay, LFocusWindow, XBoolFalse, KeyReleaseMask, @LEvent);
  end;

end;

function DoSendKeyEvent(AXDisplay: PDisplay; const AKeySym: TKeySym; const AMask: Byte): Boolean;
var
  btKeycode: Byte;
begin

  Result := False;

  btKeycode := XKeysymToKeycode(AXDisplay, AKeySym);
  if btKeycode = 0 then
    Exit;

  Result := not(Boolean(DoSendKeyEvent(AXDisplay, btKeycode, AMask)));

end;


procedure DoToggleModdifiers(AXDisplay: PDisplay; const AMask: Byte; const AState: TBool);
var
  pLXModifierKeymap: PXModifierKeymap;
  iMaskIndex: Integer;
  btModKey: cint;
  btModifierKeycode: TKeyCode;
begin

  pLXModifierKeymap := XGetModifierMapping(AXDisplay);

  try

    for iMaskIndex := ShiftMapIndex to Mod5MapIndex do
    begin

      if ((AMask and (1 shl iMaskIndex)) <> 0) then
      begin
        for btModKey := 0 to pLXModifierKeymap^.max_keypermod-1 do
        begin
          btModifierKeycode := pLXModifierKeymap^.modifiermap[iMaskIndex*pLXModifierKeymap^.max_keypermod + btModKey];
          {$IfNDef NoSendKeysTest}
          if btModifierKeycode > 0 then
            DoSendKey(AXDisplay, btModifierKeycode, AState);
          {$EndIf}
        end;
      end;

    end;

  finally
    XFreeModifiermap(pLXModifierKeymap);
    XSync(AXDisplay, False);
  end;

end;

procedure DoSendText(AXDisplay: PDisplay; const AText: UTF8String);
var
  iTextLength, iCharLength, iCharIndex : Integer;
  btKeyCode, btUnusedKeycode: TKeyCode;
  wKeySym: TKeySym;
  bRemaped: Boolean;
  sUTF8Char: UTF8String;
  wCodePoint: LongWord;
  btOriginalMask, btCodepointMask: Byte;
  bResult: Boolean;
  LState: TXkbStateRec;
  btOriginalGroup, btTargetGroup: Byte;
begin

  iTextLength := UTF8Length(AText);
  if iTextLength = 0 then
    Exit;

  {!$Define NoSendKeysTest}

  btUnusedKeycode := GetUnusedKeycode(AXDisplay);

  if XkbGetState(AXDisplay, XkbUseCoreKbd, @LState) <> Success then
    Exit;
  btOriginalGroup := LState.group;
  btOriginalMask := LState.base_mods;

  for iCharIndex := 1 to iTextLength do
  begin

    bRemaped := False;

    sUTF8Char := UTF8Copy(AText, iCharIndex, 1);
    iCharLength := UTF8Length(sUTF8Char);
    if iCharLength = 0 then
      Break;

    wCodePoint := UTF8CodepointToUnicode(PChar(sUTF8Char), iCharLength);
    if wCodePoint = NoSymbol then
      Continue;
    wKeySym := wCodePoint;

    if (wCodePoint >= $007F) and (wCodePoint <= $10FFFF) then
       wKeySym := $01000000 + wCodePoint;

    if (XKeysymToString(wKeySym) = Nil) then
      Continue;

    bResult := GetCodePointData (AXDisplay, wCodePoint, btKeyCode, btTargetGroup, btCodepointMask);
    if (not bResult) then
    begin

      if btUnusedKeycode = 0 then
        Exit;

      if not RemapKeycode(AXDisplay, btUnusedKeycode, wKeySym) then
        Continue;

      btTargetGroup := 0;
      bRemaped := True;

    end;

    if bRemaped then
      btKeyCode := btUnusedKeycode;

    if btKeyCode = 0 then
      Continue;

    if btOriginalMask <> XEmptyMask then
      DoToggleModdifiers(AXDisplay, btOriginalMask, XtKeyUnPressed);

    XkbLockGroup(AXDisplay, XkbUseCoreKbd, btTargetGroup);

    if not bRemaped then
      DoToggleModdifiers(AXDisplay, btCodepointMask, XtKeyPressed);
    //if bRemaped then
    //  btCodepointMask := XEmptyMask;

    try

      {$IfNDef NoSendKeysTest}
      DoSendKey(AXDisplay, btKeyCode);
      //DoSendKeyEvent(AXDisplay, btKeyCode, btCodepointMask);
      {$EndIf}

    finally

      if not bRemaped then
        DoToggleModdifiers(AXDisplay, btCodepointMask, XtKeyUnPressed);

      XkbLockGroup(AXDisplay, XkbUseCoreKbd, btOriginalGroup);

      if bRemaped then
        RemapKeycode(AXDisplay, btUnusedKeycode, NoSymbol);

      // note: won't restore modifiers to avoid lock ups
      //if btOriginalMask <> XEmptyMask then
      //  DoToggleModdifiers(AXDisplay, btOriginalMask, XtKeyPressed);

      // Just one XSync in the end
      XSync(AXDisplay, False);

    end;

  end;

end;

function GetKeyboardGroups: TKbGroupsArray;
var
  LDisplay: PDisplay;
  arKbGroups: TKbGroupsArray;
begin

  SetLength(Result{%H-}, 0);

  if not XConnectServer(LDisplay) then
    Exit;

  try
    if DoGetKeyboardGroups(LDisplay, arKbGroups) then
      Result := arKbGroups;
  finally
    XDisconnectServer(LDisplay);
  end;

end;

function GetCurrentKeyboardGroup: SmallInt;
var
  LDisplay: PDisplay;
begin

  Result := -1;

  if not XConnectServer(LDisplay) then
    Exit;

  try
    Result := DoGetCurrentKeyboardGroup(LDisplay);
  finally
    XDisconnectServer(LDisplay);
  end;

end;

procedure SetKeyboardGroup(const AGroup: Byte);
var
  LDisplay: PDisplay;
begin

  if not XConnectServer(LDisplay) then
    Exit;

  try
    DoSetKeyboardGroup(LDisplay, AGroup);
  finally
    XDisconnectServer(LDisplay);
  end;

end;

function DetectKeyboardGroup(constref AText: UTF8String; out AGroup: Byte): Boolean;
var
  LDisplay: PDisplay;
begin

  if not XConnectServer(LDisplay) then
    Exit;

  try
    Result := DoDetectKeyboardGroup(LDisplay, AText, AGroup);
  finally
    XDisconnectServer(LDisplay);
  end;

end;

procedure ToggleModdifiers(const AShiftState: TShiftState; const AState: TBool);
var
  btMask: Byte;
begin

  btMask := ShiftStateToXKeysymMask(AShiftState);
  ToggleModdifiers(btMask, AState);

end;

procedure ToggleModdifiers(const AMask: Byte; const AState: TBool);
var
  LDisplay: PDisplay;
begin

  if not XConnectServer(LDisplay) then
    Exit;

  try
    DoToggleModdifiers(LDisplay, AMask, AState);
  finally
    XSync(LDisplay, False);
    XDisconnectServer(LDisplay);
  end;

end;

procedure SendKey(const AKeySym: TKeySym);
var
  LDisplay: PDisplay;
begin

  if not XConnectServer(LDisplay) then
    Exit;

  try
    DoSendKey(LDisplay, AKeySym);
  finally
    XSync(LDisplay, False);
    XDisconnectServer(LDisplay);
  end;

end;

procedure SendKeyStroke(const AShortCut: TShortCut);
var
  LShiftState: TShiftState;
  wKeycode: Word;
  wKeysym: TKeySym;
begin

  // WriteLn('SendKeyStroke: AShortCut=', ShortCutToTextFix(AShortCut));
  ShortCutToKey(AShortCut, wKeycode, LShiftState);
  wKeysym := VKKeycodeToXKeysym(wKeycode);
  SendKeyStroke(wKeysym, LShiftState);

end;

procedure SendKeyStroke(const AKeySym: TKeySym; const AShiftState: TShiftState);
var
  btMask: Byte;
begin

  btMask := ShiftStateToXKeysymMask(AShiftState);
  SendKeyStroke(AKeySym, btMask);

end;

procedure SendKeyStroke(const AKeySym: TKeySym; const AMask: Byte);
var
  LDisplay: PDisplay;
  LState: TXkbStateRec;
  btOriginalMask: Byte;
begin

  WriteLn('SendKeyStroke: AMask+AKeySym=$', IntToHex(AMask), '+$', IntToHex(AKeySym, 4));

  if not XConnectServer(LDisplay) then
    Exit;

  try

    if XkbGetState(LDisplay, XkbUseCoreKbd, @LState) <> Success then
      Exit;
    btOriginalMask := LState.base_mods;
    if btOriginalMask <> XEmptyMask then
      DoToggleModdifiers(LDisplay, btOriginalMask, XtKeyUnPressed);

    DoToggleModdifiers(LDisplay, AMask, XtKeyPressed);
    try
      DoSendKey(LDisplay, AKeySym);
    finally
      DoToggleModdifiers(LDisplay, AMask, XtKeyUnPressed);
      // note: won't restore modifiers to avoid lock ups
      //if btOriginalMask <> XEmptyMask then
      //  DoToggleModdifiers(LDisplay, btOriginalMask, XtKeyPressed);
    end;

  finally
    XSync(LDisplay, False);
    XDisconnectServer(LDisplay);
  end;

end;

procedure SendKeyStrokeEvent(const AShortCut: TShortCut);
var
  LShiftState: TShiftState;
  wKeycode: Word;
  wKeysym: TKeySym;
begin

  ShortCutToKey(AShortCut, wKeycode, LShiftState);
  wKeysym := VKKeycodeToXKeysym(wKeycode);
  SendKeyStrokeEvent(wKeysym, LShiftState);

end;

procedure SendKeyStrokeEvent(const AKeySym: TKeySym; const AShiftState: TShiftState);
var
  btMask: Byte;
begin

  btMask := ShiftStateToXKeysymMask(AShiftState);
  SendKeyStrokeEvent(AKeySym, btMask);

end;

procedure SendKeyStrokeEvent(const AKeySym: TKeySym; const AMask: Byte);
var
  LDisplay: PDisplay;
  LState: TXkbStateRec;
  btOriginalMask: Byte;
begin

  WriteLn('SendKeyStrokeEvent: AMask+AKeySym=$', IntToHex(AMask), '+$', IntToHex(AKeySym, 4));

  if not XConnectServer(LDisplay) then
    Exit;

  try

    if XkbGetState(LDisplay, XkbUseCoreKbd, @LState) <> Success then
      Exit;
    btOriginalMask := LState.base_mods;
    if btOriginalMask <> XEmptyMask then
      DoToggleModdifiers(LDisplay, btOriginalMask, XtKeyUnPressed);

    try
      DoSendKeyEvent(LDisplay, AKeySym, AMask);
    finally
      // note: won't restore modifiers to avoid lock ups
      //if btOriginalMask <> XEmptyMask then
      //  DoToggleModdifiers(LDisplay, btOriginalMask, XtKeyPressed);
    end;

  finally
    XSync(LDisplay, False);
    XDisconnectServer(LDisplay);
  end;

end;

procedure SendText(constref AText: UTF8String);
var
  LDisplay: PDisplay;
begin

  if not XConnectServer(LDisplay) then
    Exit;

  try
    DoSendText(LDisplay, AText);
  finally
    XDisconnectServer(LDisplay);
  end;

end;

end.

