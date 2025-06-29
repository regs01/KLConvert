program klconvert;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  {$IfDef Debug}
  {$EndIf}
  Interfaces, SysUtils, // this includes the LCL widgetset
  Forms, LCLType,
  FormSettings, FormMain,
  UnitKLCType, UnitSettings, UnitProcessFunctions, UnitXKeyInput, UnitClipboard, UnitConvert, UnitIniFileEx,
  UnitConvertRussianEnglish, UnitConvertGreekEnglish, UnitConvertBulgarianEnglish, UnitConvertTatarEnglish;

{$R *.res}

var
  bFirstLanuch: Boolean;
  LLockHandle: TLCLHandle;

begin

  Application.Title := 'KLConvert';

  if not FreeInstance then
    Exit;

  LLockHandle := FileCreate(GetLockFilename, fmShareExclusive, &0600);

  try

  {$IfDef Debug}
  SetHeapTraceOutput('HeaptrcTrace.log');
  {$EndIf}

  ConvertList.Add(TKLConvertRussianEnglish.Create);
  ConvertList.Add(TKLConvertTatarEnglish.Create);
  ConvertList.Add(TKLConvertBulgarianEnglish.Create);
  ConvertList.Add(TKLConvertGreekEnglish.Create);

  bFirstLanuch := not FileExists(GetConfigFilename);

  LoadSettings;

  RequireDerivedFormResource := True;
  Application.Scaled := True;
  {$PUSH}
  {$WARN 5044 OFF}
  Application.MainFormOnTaskbar := True;
  {$POP}
  {$IfNDef Debug}
  if Settings.LaunchMinimized then
    Application.ShowMainForm := False;
  {$EndIf}

  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  if bFirstLanuch then
  begin
    Application.CreateForm(TfrmSettings, frmSettings);
    frmSettings.ShowModal;
  end;
  Application.Run;

  SaveSettings;

  finally

  FileClose(LLockHandle);
  DeleteFile(GetLockFilename);

  end;

end.

