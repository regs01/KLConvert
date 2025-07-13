unit UnitSettings;

{$mode ObjFPC}{$H+}
{$ModeSwitch advancedrecords+}
{$ModeSwitch ImplicitFunctionSpecialization+}


interface

uses
  Classes, SysUtils, Forms, LCLIntf, LCLProc, LCLType,
  LCLTranslator, Translations, LResources,
  UnitKLCType, LazHotKeyFunctions,
  UnitIniFileEx, TypInfo;

type

  TUpdateSettingsEvent = procedure of object;

  TRSettings = record
    ShowInTray: Boolean;
    LaunchMinimized: Boolean;
    Autostart: Boolean;
    Portable: Boolean;
    LanguageId: String;
    TrayIcon: String;
    InputMethod: TKLInputMethod;
    OutputMethod: TKLOutputMethod;
    ClipboardCopyShortcut: TShortCut;
    ClipboardPasteShortcut: TShortCut;
    LayoutSwitch: TKLLayoutSwitch;
    LayoutPair: array[0..1] of Byte;
    MainFormBounds: TRect;
    MainFormMaximize: Boolean;
    SettingsFormBounds: TRect;
    SettingsFormMaximize: Boolean;
    KeyBinds: TKLActionShortCutList;
    OnUpdateSettings: TUpdateSettingsEvent;
  end;

  procedure SetLocale;
  procedure UpdateSettings;
  procedure LoadSettings;
  procedure SaveSettings;

  resourcestring
    RSErrorWritingIni = 'Failed to write into settings file:'#10'%s';

  var
    Settings: TRSettings;

implementation

uses
  UnitConvert, UnitXKeyInput;

function GetAutostartDir: String;
begin

  Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) + '.config' + DirectorySeparator + 'autostart';

end;

procedure SetLocale;
var
  LResourceStream: TResourceStream;
  LResourceHandle: TFPResourceHandle;
  LPoFile: TPOFile;
  LPoFileStream: TStringStream;
  LLocalTranslator: TUpdateTranslator;
  iIndex: Integer;
  sLocaleName: String;
begin

  sLocaleName := 'LOCALE-' + UpperCase(Settings.LanguageId);

  LResourceHandle := FindResource(HINSTANCE, sLocaleName, RT_RCDATA);
  if LResourceHandle = 0 then
    sLocaleName := 'LOCALE-EN';

  LResourceStream := TResourceStream.Create(HINSTANCE, sLocaleName, RT_RCDATA);

  LPoFileStream := TStringStream.Create;
  LResourceStream.SaveToStream(LPoFileStream);
  LResourceStream.Free;

  LPoFile := TPOFile.Create(False);
  LPoFile.ReadPOText(LPoFileStream.DataString);
  LPoFileStream.Free;

  LLocalTranslator := TPOTranslator.Create(LPoFile);
  TranslateResourceStrings(LPoFile);

  if LLocalTranslator<>nil then
  begin
    if Assigned(LRSTranslator) then
      LRSTranslator.Free;
    LRSTranslator := LLocalTranslator;
    for iIndex := 0 to Screen.DataModuleCount-1 do
      LLocalTranslator.UpdateTranslation(Screen.DataModules[iIndex]);
    for iIndex := 0 to Screen.CustomFormCount-1 do
    begin
      LLocalTranslator.UpdateTranslation(Screen.CustomForms[iIndex]);
      PostMessage(Screen.CustomForms[iIndex].Handle, LM_TRANSLATE, 0, 0);
    end;
  end;

end;

procedure MakeAutostartFile;
var
  slDesktopFile: TStringList;
  sFilename: String;
begin

  slDesktopFile := TStringList.Create;
  try

    slDesktopFile.Append('[Desktop Entry]');
    slDesktopFile.Append('Type=Application');
    slDesktopFile.Append('Name=KLConvert');
    slDesktopFile.Append('Comment=Keyboard layout conventer');
    slDesktopFile.Append('Exec=' + Application.ExeName);
    slDesktopFile.Append('Icon=klconvert');

    sFilename := GetAutostartDir + DirectorySeparator + 'klconvert.desktop' ;
    slDesktopFile.SaveToFile(sFilename);

  finally
    slDesktopFile.Free;
  end;

end;

procedure RemoveAutostartFile;
var
  sFilename: String;
begin

  sFilename := GetAutostartDir + DirectorySeparator + 'klconvert.desktop' ;

  if FileExists(sFilename) then
    DeleteFile(sFilename);

end;

procedure UpdateSettings;
begin

  SetLocale;

  if Settings.Autostart then
    MakeAutostartFile
  else
    RemoveAutostartFile;

  if Assigned(Settings.OnUpdateSettings) then
    Settings.OnUpdateSettings;

end;

procedure LoadSettings;
var
  LSettingsIni: TIniFileEx;
  sIdent: String;
  iConvertLayoutIndex: Integer;
  LConvertItem: TKLConvert;

  procedure LoadKeyBind(AName: String);
  var
    wShortCut: TShortCut;
    sShortCutDefault: String;
  begin
    sShortCutDefault := '';
    If AName = 'ConvertSelection' then
      sShortCutDefault := 'Break';
    wShortCut := TextToShortCutFix( LSettingsIni.ReadString('KeyBinds', AName, sShortCutDefault) );
    Settings.KeyBinds.Add(AName, wShortCut);
  end;

  function GetDefaultLayoutSwitch: TKLLayoutSwitch;
  var
    arKbGroups: TKbGroupsArray;
  begin
    Result := lsDisable;
    arKbGroups := UnitXKeyInput.GetKeyboardGroups;
    if Length(arKbGroups) < 2 then
      Result := lsDisable;
    if Length(arKbGroups) = 2 then
      Result := lsDefinedPair;
    if Length(arKbGroups) > 2 then
      Result := lsDetect;
  end;

  procedure DefaultSettings;
  var
    iConvertLayoutIndex: Integer;
    LConvertItem: TKLConvert;
  begin

    with Settings do
    begin

      InputMethod := imCopyClipboard;
      OutputMethod := omCopyClipboard;
      LayoutSwitch := GetDefaultLayoutSwitch;

      LayoutPair[0] := 0;
      LayoutPair[1] := 1;

      ClipboardCopyShortcut := TextToShortCutFix( 'Ctrl+Ins' );
      ClipboardPasteShortcut := TextToShortCutFix( 'Shift+Ins' );

      ShowInTray := True;
      LaunchMinimized := True;
      Autostart := False;
      Portable := False;
      LanguageId := 'en';
      TrayIcon := 'Dark2';

      MainFormBounds := Rect(-1, -1, -1, -1);
      MainFormMaximize := False;

      SettingsFormBounds := Rect(-1, -1, -1, -1);
      SettingsFormMaximize := False;

      KeyBinds.Add('OpenWindow', VK_UNDEFINED);
      KeyBinds.Add('ConvertSelection', VK_PAUSE);
      KeyBinds.Add('UpperCase', VK_UNDEFINED);
      KeyBinds.Add('LowerCase', VK_UNDEFINED);
      KeyBinds.Add('SwapCase', VK_UNDEFINED);
      KeyBinds.Add('ProperCase', VK_UNDEFINED);

      for iConvertLayoutIndex:=0 to ConvertList.Count-1 do
      begin
        LConvertItem := ConvertList.Items[iConvertLayoutIndex];
        sIdent := LConvertItem.ShortClassName;
        LConvertItem.Active := False;
        LConvertItem.ConvertOptions := [];
      end;

    end;

  end;

begin


  try
  LSettingsIni := TIniFileEx.Create(GetConfigFilename);

  try

    Settings.InputMethod := LSettingsIni.ReadEnum('Main', 'InputMethod', imCopyClipboard, 'im');
    Settings.OutputMethod := LSettingsIni.ReadEnum('Main', 'OutputMethod', omCopyClipboard, 'om');
    Settings.LayoutSwitch := LSettingsIni.ReadEnum('Main', 'LayoutSwitch', GetDefaultLayoutSwitch, 'ls');

    Settings.LayoutPair[0] := LSettingsIni.ReadInteger('Main', 'LayoutPair1', 0);
    Settings.LayoutPair[1] := LSettingsIni.ReadInteger('Main', 'LayoutPair2', 1);

    Settings.ClipboardCopyShortcut := TextToShortCutFix( LSettingsIni.ReadString('Main', 'ClipboardCopyShortcut', 'Ctrl+Ins') );
    Settings.ClipboardPasteShortcut := TextToShortCutFix( LSettingsIni.ReadString('Main', 'ClipboardPasteShortcut', 'Shift+Ins') );

    Settings.ShowInTray := LSettingsIni.ReadBool('Main', 'ShowInTray', True);
    Settings.LaunchMinimized := LSettingsIni.ReadBool('Main', 'LaunchMinimized', True);
    Settings.Autostart := LSettingsIni.ReadBool('Main', 'Autorun', False);
    Settings.Portable := LSettingsIni.ReadBool('Main', 'Portable', False);
    Settings.LanguageId := LSettingsIni.ReadString('Main', 'Language', 'en'); 
    Settings.TrayIcon := LSettingsIni.ReadString('Main', 'TrayIcon', 'Dark2');

    Settings.MainFormBounds := LSettingsIni.ReadRect('Main', 'MainFormBounds', Rect(-1, -1, -1, -1));
    Settings.MainFormMaximize := LSettingsIni.ReadBool('Main', 'MainFormMaximize', False);

    Settings.SettingsFormBounds := LSettingsIni.ReadRect('Main', 'SettingsFormBounds', Rect(-1, -1, -1, -1));
    Settings.SettingsFormMaximize := LSettingsIni.ReadBool('Main', 'SettingsFormMaximize', False);

    LoadKeyBind('OpenWindow');
    LoadKeyBind('ConvertSelection');
    LoadKeyBind('UpperCase');
    LoadKeyBind('LowerCase');
    LoadKeyBind('SwapCase');
    LoadKeyBind('ProperCase');

    for iConvertLayoutIndex:=0 to ConvertList.Count-1 do
    begin
      LConvertItem := ConvertList.Items[iConvertLayoutIndex];
      sIdent := LConvertItem.ShortClassName;
      LConvertItem.Active := LSettingsIni.ReadBool('ConvertLayouts', sIdent, False);
      LConvertItem.ConvertOptions :=
        LSettingsIni.specialize ReadSet<TKLConvertOption, TKLConvertOptions>('ConvertOptions', sIdent, [], 'co');
    end;

  finally
    LSettingsIni.Free;
  end;

  except
    DefaultSettings;
  end;

end;

procedure SaveSettings;
var
  LSettingsIni: TIniFileEx;
  sIdent: String;
  iKeyBindIndex, iConvertLayoutIndex: Integer;
  LConvertItem: TKLConvert;
begin

  try
  LSettingsIni := TIniFileEx.Create(GetConfigFilename);

  try

    LSettingsIni.WriteEnum('Main', 'InputMethod', Settings.InputMethod, 'im');
    LSettingsIni.WriteEnum('Main', 'OutputMethod', Settings.OutputMethod, 'om');
    LSettingsIni.WriteEnum('Main', 'LayoutSwitch', Settings.LayoutSwitch, 'ls');

    LSettingsIni.WriteInteger('Main', 'LayoutPair1', Settings.LayoutPair[0]);
    LSettingsIni.WriteInteger('Main', 'LayoutPair2', Settings.LayoutPair[1]);

    LSettingsIni.WriteString('Main', 'ClipboardCopyShortcut', ShortCutToTextFix(Settings.ClipboardCopyShortcut));
    LSettingsIni.WriteString('Main', 'ClipboardPasteShortcut', ShortCutToTextFix(Settings.ClipboardPasteShortcut));

    LSettingsIni.WriteBool('Main', 'ShowInTray', Settings.ShowInTray);
    LSettingsIni.WriteBool('Main', 'LaunchMinimized', Settings.LaunchMinimized);
    LSettingsIni.WriteBool('Main', 'Autorun', Settings.Autostart);
    LSettingsIni.WriteBool('Main', 'Portable', Settings.Portable);
    LSettingsIni.WriteString('Main', 'Language', Settings.LanguageId);
    LSettingsIni.WriteString('Main', 'TrayIcon', Settings.TrayIcon);

    LSettingsIni.WriteRect('Main', 'MainFormBounds', Settings.MainFormBounds);
    LSettingsIni.WriteBool('Main', 'MainFormMaximize', Settings.MainFormMaximize);
    LSettingsIni.WriteRect('Main', 'SettingsFormBounds', Settings.SettingsFormBounds);
    LSettingsIni.WriteBool('Main', 'SettingsFormMaximize', Settings.SettingsFormMaximize);

    for iKeyBindIndex:=0 to Settings.KeyBinds.Count-1 do
      LSettingsIni.WriteString('KeyBinds', Settings.KeyBinds.Keys[iKeyBindIndex], ShortCutToTextFix(Settings.KeyBinds.Data[iKeyBindIndex]));

    for iConvertLayoutIndex:=0 to ConvertList.Count-1 do
    begin
      LConvertItem := ConvertList.Items[iConvertLayoutIndex];
      sIdent := LConvertItem.ShortClassName;
      LSettingsIni.WriteBool('ConvertLayouts', sIdent, LConvertItem.Active);
      LSettingsIni.specialize WriteSet<TKLConvertOption, TKLConvertOptions>
        ('ConvertOptions', sIdent, LConvertItem.ConvertOptions, 'co');
    end;

  finally
    LSettingsIni.Free;
  end;

  except
    Application.MessageBox(PChar(Format(RSErrorWritingIni, [GetConfigFilename])), PChar(Application.Title), MB_OK + MB_ICONERROR);
  end;

end;

initialization

  Settings.KeyBinds := TKLActionShortCutList.Create;

finalization

  Settings.KeyBinds.Free;

end.

