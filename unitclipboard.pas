unit UnitClipboard;

{$mode ObjFPC}{$H+}
{$codepage UTF8}
{$ModeSwitch AdvancedRecords}

interface

uses
  Classes, SysUtils, LCLType, Forms, fptimer,  Clipbrd, UnitKLCType;

type
  TClipboardWrapper = class
  protected var
    FClipboard: TClipboard;
    FClipboardOnRequest: TClipboardRequestEvent;
    FClipboardDataPending: Boolean;
    FClipboardDataPending2: Boolean;
    FRequestPending: Boolean;
    FLastRequestTime: Int64;
    FClipboardTextBuffer: UTF8String;
    FBackupText: UTF8String;
    FBackupType: TKLClipboardBackupType;

    //FBackupData: TClipboardBackupData;
    //FBackupFormats: array of TClipboardFormat;
    //FBackupStreams: array of TMemoryStream;
    //FFormatList: PClipboardFormat;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure ClipboardOnRequest(const RequestedFormatID: TClipboardFormat; Data: TStream);
  public
    procedure WaitForChange(constref AOriginalText: String);
    procedure WaitForRequest;
  protected
    function DoBackupClipboardText: Boolean;
    //function DoBackupClipboardAll: Boolean;
  protected
    function DoRestoreClipboardText: Boolean;
    //function DoRestoreClipboardAll: Boolean;
  public
    function BackupClipboard(ATextOnly: Boolean): Boolean;
  public
    procedure ClearBackup;
    procedure SetText(AString: UTF8String; AWaitForRequest: Boolean = False);
    function RestoreClipboard(ATextOnly: Boolean): Boolean;
  public
    property BackupType: TKLClipboardBackupType read FBackupType;
    //property Clipboard: TClipboard read FClipboard;
  end;

  var
    ClipboardWrapper: TClipboardWrapper;


implementation

constructor TClipboardWrapper.Create;
begin

  //FBackupStreams := [];
  //FBackupFormats := [];
  //FBackupData := TClipboardBackupData.Create;

  FClipboardDataPending := False;
  FClipboardDataPending2 := False;
  FLastRequestTime := -1;

  FClipboardOnRequest := nil;
  FClipboardOnRequest := Clipboard.OnRequest;

  //FClipboard := TClipboard.Create;
  //FClipboard.OnRequest := @ClipboardOnRequest;
  //FClipboard.Open;
  //SetClipboard(FClipboard);
  FBackupType := cbtNone;

end;

destructor TClipboardWrapper.Destroy;
begin

  ClearBackup;
  //FBackupData.Free;

  if (FClipboardOnRequest <> nil) and (Clipboard.OnRequest = @ClipboardOnRequest) then
    Clipboard.OnRequest := FClipboardOnRequest;
  //FClipboard.Free;

  inherited;

end;

procedure TClipboardWrapper.ClipboardOnRequest(const RequestedFormatID: TClipboardFormat; Data: TStream);
var
  arBuffer: TBytes;
begin

  WriteLn(
    'ClipboardOnRequest: FClipboardTextBuffer=', FClipboardTextBuffer,
    ' FRequestPending=', FRequestPending,
    ' RequestedFormatID=', RequestedFormatID
  );

  if (FRequestPending) and (RequestedFormatID = CF_TEXT) then
  begin
    arBuffer := TEncoding.UTF8.GetBytes(UnicodeString(FClipboardTextBuffer));
    Data.WriteBuffer(arBuffer[0], Length(arBuffer));
    Data.Position := 0;
    FLastRequestTime := GetTickCount64;
  end
  else
    inherited;

end;

procedure TClipboardWrapper.WaitForChange(constref AOriginalText: String);
const
  CHANGE_TIMEOUT = 2000;
  CHECK_DELAY = 20;
var
  iTimeout, iCheckDelay, iCurrentTime: Int64;
begin

  iCurrentTime := GetTickCount64;
  iTimeout := iCurrentTime + CHANGE_TIMEOUT;
  iCheckDelay := iCurrentTime + CHECK_DELAY;

  while GetTickCount64 < iTimeout do
  begin

    Application.ProcessMessages;
    iCurrentTime := GetTickCount64;
    if iCurrentTime > iCheckDelay then
    begin
      //WriteLn('WaitForChange: iCurrentTime=', iCurrentTime);
      iCheckDelay := iCurrentTime + CHECK_DELAY;
      {$IfNDef LCLGTK3}
      if Clipboard.HasFormat(CF_TEXT) then
      {$EndIf}
      if (Clipboard.AsText <> AOriginalText) then
        Exit;
    end;

  end;

end;

procedure TClipboardWrapper.WaitForRequest;
const
  TOTAL_TIMEOUT = 1000;
  LAST_REQUEST_TIMEOUT = 500;
var
  iTimeout: Int64;
  bNoRequestEvent: Boolean;
begin

  bNoRequestEvent := False;

  WriteLn('WaitForRequest:');
  {$If Defined(LCLGTK3) or Defined(LCLQt5) or Defined(LCLQt6)}
    bNoRequestEvent := True;
  {$EndIf}

  if FRequestPending then
  begin

    iTimeout := GetTickCount64 + TOTAL_TIMEOUT;

    while FRequestPending do
    begin
      Application.ProcessMessages;
      //WriteLn('WaitForRequest: FLastRequestTime=', FLastRequestTime);
      if (FLastRequestTime = -1) or (bNoRequestEvent = True) then
      begin
        if GetTickCount64 > iTimeout then
          Break;
        Continue;
      end;
      if (GetTickCount64 > FLastRequestTime+LAST_REQUEST_TIMEOUT) and (bNoRequestEvent = False) then
        Break;
    end;

    if not bNoRequestEvent then
      Clipboard.OnRequest := FClipboardOnRequest;

    WriteLn('WaitForRequest: Ended.');
    FRequestPending := False;
    FLastRequestTime := -1;

  end;

end;

procedure TClipboardWrapper.ClearBackup;
begin

  FBackupText := '';
  FBackupType := cbtNone;

end;

procedure TClipboardWrapper.SetText(AString: UTF8String; AWaitForRequest: Boolean = False);
begin

  {$IfDef LCLGTK3}
  {$Error Writing to Clipboard and Formats are not implemented yet in LCLGTK3}
  {$EndIf}

  {$If Defined(LCLGTK3) or Defined(LCLQt5) or Defined(LCLQt6)}
  AWaitForRequest := False;
  {$EndIf}

  if AWaitForRequest then
  begin
    Clipboard.Clear;
    FRequestPending := True;
    FLastRequestTime := -1;
    FClipboardTextBuffer := AString;
    Clipboard.AddFormat(CF_TEXT, nil);
    //Clipboard.AsText := AString;
    Clipboard.OnRequest := @ClipboardOnRequest
  end
  else
  begin
    FRequestPending := True;
    FLastRequestTime := -1;
    Clipboard.Clear;
    Clipboard.AsText := AString;
  end;

end;

function TClipboardWrapper.DoBackupClipboardText: Boolean;
begin

  Result := False;

  {$IfNDef LCLGTK3}
  if Clipboard.HasFormat(CF_TEXT) then
  begin
  {$EndIf}

    FBackupText := Clipboard.AsText;
    FBackupType := cbtText;
    WriteLn('DoBackupClipboardText: FBackupText=', FBackupText);

    Result := True;

  {$IfNDef LCLGTK3}
  end;
  {$EndIf}

end;

function TClipboardWrapper.DoRestoreClipboardText: Boolean;
begin

  WriteLn('DoRestoreClipboardText: FBackupType=', FBackupType, ', FBackupText=', FBackupText);

  Result := False;
  if FBackupType = cbtText then
    Self.SetText(FBackupText);
  Result := True;

end;

function TClipboardWrapper.BackupClipboard(ATextOnly: Boolean): Boolean;
begin

  Result := False;
  ClearBackup;

  if ATextOnly then
    Result := DoBackupClipboardText;

end;

function TClipboardWrapper.RestoreClipboard(ATextOnly: Boolean): Boolean;
begin

  WriteLn('RestoreClipboard:');

  Result := False;

  if ATextOnly then
    Result := DoRestoreClipboardText;

end;

initialization

  ClipboardWrapper := TClipboardWrapper.Create;

finalization;

  ClipboardWrapper.Free;

end.



