unit UnitProcessFunctions;

{$mode ObjFPC}{$H+}
{$ModeSwitch implicitfunctionspecialization}

interface

uses
  Classes, SysUtils, Forms, Clipbrd, LazUTF8, LazHotKeyFunctions, UnitKLCType, UnitClipboard, UnitXKeyInput, UnitConvert;

const
  WordDelimiters = [#9, #10, #13, #11, #12, #32, #160];

  procedure ProcessConvert;
  function ProcessConvert(constref AString: UTF8String): UTF8String;
  procedure ProcessCase(const ACaseAction: TKLCaseAction);
  function ProcessCase(constref AString: UTF8String; const ACaseAction: TKLCaseAction): UTF8String;
  function ConvertText(constref AString: UTF8String; const ADirection:TKLConvertDirection = cdBoth): UTF8String;
  function ChangeCaseText(constref AString: UTF8String; const ACaseAction: TKLCaseAction): UTF8String;
  function GetInputSelection(out AString:UTF8String): Boolean;
  procedure SetOutputSelection(const AProcessedString: UTF8String);

implementation

uses
  UnitSettings;

procedure ProcessConvert;
var
  sSelection, sProcessedSelection: UTF8String;
begin

  sSelection := '';
  ClipboardWrapper.ClearBackup;

  try

    if not GetInputSelection(sSelection) then
      Exit;
    WriteLn('sSelection=', sSelection);

    sProcessedSelection := ConvertText(sSelection);
    WriteLn('sProcessedSelection=', sProcessedSelection);

    //if CompareStr(sSelection, sProcessedSelection) <> 0 then
      SetOutputSelection(sProcessedSelection);

  finally

    if (ClipboardWrapper.BackupType <> cbtNone) then
      ClipboardWrapper.RestoreClipboard(True);

  end;

end;

function ProcessConvert(constref AString: UTF8String): UTF8String;
begin

  Result := ConvertText(AString);

end;

procedure ProcessCase(const ACaseAction: TKLCaseAction);
var
  sSelection, sProcessedSelection: UTF8String;
begin

  sSelection := '';

  ClipboardWrapper.ClearBackup;

  try

    if not GetInputSelection(sSelection) then
      Exit;
    WriteLn('sSelection=', sSelection);

    sProcessedSelection := ChangeCaseText(sSelection, ACaseAction);

    //if CompareStr(sSelection, sProcessedSelection) <> 0 then
      SetOutputSelection(sProcessedSelection);

  finally

    if (ClipboardWrapper.BackupType <> cbtNone) then
      ClipboardWrapper.RestoreClipboard(True);

  end;

end;

function ProcessCase(constref AString: UTF8String; const ACaseAction: TKLCaseAction): UTF8String;
begin

  Result := ChangeCaseText(AString, ACaseAction);

end;

function ConvertText(constref AString: UTF8String; const ADirection:TKLConvertDirection = cdBoth): UTF8String;
var
  LConvert: TKLConvert;
  sProcessedString: String;
begin

  sProcessedString := AString;

  for LConvert in ConvertList do
  begin
    if not LConvert.Active then
      Continue;
    sProcessedString := LConvert.Convert(sProcessedString, ADirection);
  end;

  Result := sProcessedString;;

end;

function ChangeCaseText(constref AString: UTF8String; const ACaseAction: TKLCaseAction): UTF8String;
begin

  Result := AString;

  if ACaseAction = caSwap then
    Result := LazUTF8.UTF8SwapCase(AString);

  if ACaseAction = caUpper then
    Result := LazUTF8.UTF8UpperCase(AString);

  if ACaseAction = caLower then
    Result := LazUTF8.UTF8LowerCase(AString);

  if ACaseAction = caProper then
    Result := LazUTF8.UTF8ProperCase(AString, WordDelimiters);

end;

function GetInputSelection(out AString:UTF8String): Boolean;
begin

  AString := '';
  Result := False;

  WriteLn('GetInputSelection:');

  case Settings.InputMethod of

    imPrimarySelection:
      begin
        WriteLn('GetInputSelection: PrimarySelection=', PrimarySelection.AsText, ', PrimarySelection.HasFormat(CF_TEXT)=', PrimarySelection.HasFormat(CF_TEXT));
        {$IfNDef LCLGTK3}
        if PrimarySelection.HasFormat(CF_TEXT) then
        {$EndIf}
          AString := PrimarySelection.AsText
      end;

    imCopyClipboard:
      begin

        AString := Clipboard.AsText; //todo: check for text
        WriteLn('GetInputSelection: ClipboardContent=', AString);
        ClipboardWrapper.BackupClipboard(True);

        UnitXKeyInput.SendKeyStroke(Settings.ClipboardCopyShortcut);
        ClipboardWrapper.WaitForChange(AString);

        {$IfNDef LCLGTK3}
        if Clipboard.HasFormat(CF_TEXT) then
        begin
        {$EndIf}
          WriteLn('GetInputSelection: CopiedContent=', Clipboard.AsText);
          if AString <> Clipboard.AsText then
            AString := Clipboard.AsText
          else
            AString := '';
        {$IfNDef LCLGTK3}
        end;
        {$EndIf}
        WriteLn('GetInputSelection: InputContent=', AString);

      end;

  end;

  if Trim(AString) = '' then
    Exit;

  Result := True;

end;

procedure SetOutputSelection(const AProcessedString: UTF8String);
var
  btOriginalGroup, btTargetGroup: Byte;
  bToggleGroup: Boolean;
begin

  WriteLn('SetOutputSelection: AProcessedString=', AProcessedString);

  btOriginalGroup := 0;
  btTargetGroup := 0;
  bToggleGroup := False;
  if Settings.LayoutSwitch <> TKLLayoutSwitch.lsDisable then
  begin

    btOriginalGroup := UnitXKeyInput.GetCurrentKeyboardGroup;
    if (Settings.LayoutSwitch = TKLLayoutSwitch.lsDefinedPair) and
       (btOriginalGroup in [Settings.LayoutPair[0], Settings.LayoutPair[1]]) then
    begin
      btTargetGroup := IfThen(Settings.LayoutPair[0] = btOriginalGroup, Settings.LayoutPair[1], Settings.LayoutPair[0]);
      bToggleGroup := True;
    end;

    if (Settings.LayoutSwitch = TKLLayoutSwitch.lsDetect) then
    begin
      if UnitXKeyInput.DetectKeyboardGroup(AProcessedString, btTargetGroup) then
        bToggleGroup := True;
    end;

  end;

  case Settings.OutputMethod of

    omPrimarySelection:
      begin
        PrimarySelection.AsText := AProcessedString;
      end;

    omCopyClipboard:
      begin
        if ClipboardWrapper.BackupType = cbtNone then
          ClipboardWrapper.BackupClipboard(True);
        ClipboardWrapper.SetText(AProcessedString, True);
        WriteLn('SetOutputSelection: Sent KeyStroke=', ShortCutToTextFix(Settings.ClipboardPasteShortcut));
        UnitXKeyInput.SendKeyStroke(Settings.ClipboardPasteShortcut);
      end;

    omTypeText:
      begin
        UnitXKeyInput.SendText(AProcessedString);
      end;

  end;

  if bToggleGroup then
    UnitXKeyInput.SetKeyboardGroup(btTargetGroup);

  if Settings.OutputMethod = omCopyClipboard then
    ClipboardWrapper.WaitForRequest;

end;

end.

