unit UnitKLCType;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LCLType, Forms, LMessages, fgl;

const
  APP_ID = 'klconvert';
  CONFIG_FILENAME = APP_ID + '.cfg';
  LOCK_FILENAME = APP_ID + '.lck';
  LM_TRANSLATE = LM_USER + $010;

type
  TKLActionShortCutList = specialize TFPGMap<String, TShortCut>;
  TKLClipboardBackupType = (cbtNone, cbtOther, cbtAll, cbtText);
  TKLInputMethod = (imPrimarySelection, imCopyClipboard);
  TKLOutputMethod = (omPrimarySelection, omCopyClipboard, omTypeText);
  TKLLayoutSwitch = (lsDisable, lsDetect, lsDefinedPair);
  TKLCaseAction = (caUpper, caLower, caSwap, caProper);
  TKLConvertDirection = (cdBoth, cdRight, cdLeft);
  TKLConvertOption = (coCapitalSymbols, coAltGrSymbols);
  TKLConvertOptions = set of TKLConvertOption;
  TKLConvertPairs = array of array of String;

  function GetConfigDir: String;
  function GetCacheDir: String;
  function GetConfigFilename: String;
  function GetLockFilename: String;
  function FreeInstance: Boolean;

implementation

function GetConfigDir: String;
var
  sDirectory: String;
begin

  sDirectory := EmptyStr;

  {$IfNDef Debug}
    sDirectory := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) + '.config' + DirectorySeparator + APP_ID;
  {$EndIf}

  if sDirectory = EmptyStr then
    sDirectory :=  IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

  Result := sDirectory;

end;

function GetCacheDir: String;
begin

  Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) + '.cache' + DirectorySeparator + APP_ID;

end;

function GetConfigFilename: String;
begin

  Result := IncludeTrailingPathDelimiter(GetConfigDir) + CONFIG_FILENAME;

end;

function GetLockFilename: String;
begin

  Result := IncludeTrailingPathDelimiter(GetCacheDir) + LOCK_FILENAME;

end;


function FreeInstance: Boolean;
begin

  Result := False;

  if FileExists(GetLockFilename) then
  begin
    if FileOpen(GetLockFilename, fmOpenReadWrite + fmShareExclusive) = -1 then
    begin
      Application.MessageBox(PChar(Format('Other instance of %s is running.', [Application.Title])), PChar(Application.Title), MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;

  if not DirectoryExists(GetCacheDir) then
    ForceDirectories(GetCacheDir);
  if FileExists(GetLockFilename) and (not DeleteFile(GetLockFilename)) then
    Exit;

  Result := True;

end;



end.

