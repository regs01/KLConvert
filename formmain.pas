unit FormMain;

{$mode objfpc}{$H+}
{$Codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ActnList,
  ExtCtrls, Math, LCLType, LCLProc, Menus, StdCtrls, StrUtils,
  ComCtrls, LazHotKey, LazHotKeyType,
  UnitKLCType, UnitSettings, UnitClipboard, UnitProcessFunctions;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    cActionCopy: TAction;
    cActionPaste: TAction;
    cActionLocalProperCase: TAction;
    cActionLocalLowerCase: TAction;
    cActionLocalUpperCase: TAction;
    cActionLocalSwapCase: TAction;
    cActionLocalConvert: TAction;
    cActionSwapCase: TAction;
    cActionProperCase: TAction;
    cActionLowerCase: TAction;
    cActionUpperCase: TAction;
    cActionClose: TAction;
    cActionSettings: TAction;
    cActionShow: TAction;
    cActionConvert: TAction;
    ActionList1: TActionList;
    GlobalHotKey1: TGlobalHotKey;
    ImageList1: TImageList;
    memoText: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu1: TPopupMenu;
    Separator1: TMenuItem;
    ToolBar1: TToolBar;
    tbtnPaste: TToolButton;
    tbtnCopy: TToolButton;
    tDivider1: TToolButton;
    tbtnConvert: TToolButton;
    tbtnSwapCase: TToolButton;
    tbtnUpperCase: TToolButton;
    tbtnLowerCase: TToolButton;
    tbtnProperCase: TToolButton;
    tDivider2: TToolButton;
    tbtnSettings: TToolButton;
    TrayIcon1: TTrayIcon;
    procedure cActionCloseExecute(Sender: TObject);
    procedure cActionCopyExecute(Sender: TObject);
    procedure cActionLocalConvertExecute(Sender: TObject);
    procedure cActionLocalCaseExecute(Sender: TObject);
    procedure cActionPasteExecute(Sender: TObject);
    procedure cActionSettingsExecute(Sender: TObject);
    procedure cActionShowExecute(Sender: TObject);
    procedure cActionConvertExecute(Sender: TObject);
    procedure cActionSwapCaseExecute(Sender: TObject);
    procedure FormChangeBounds(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure GlobalHotKey1HotKey(AHotKeyInfo: PTHotKeyInfo);
    procedure GlobalHotKey1Register(AHotKeyInfo: PTHotKeyInfo; ASuccess: Boolean; AErrorCode: LongInt);
  protected
    FTerminate: Boolean;
    FClipboardWrapper: TClipboardWrapper;
    procedure DoUpdateSettings;
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

uses
  FormSettings;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  FTerminate := False;

  // Form bounds are only updated on launch
  if Settings.MainFormBounds.Left > -1 then
    Self.Left := Settings.MainFormBounds.Left;
  if Settings.MainFormBounds.Top > -1 then
    Self.Top := Settings.MainFormBounds.Top;
  if Settings.MainFormBounds.Right > -1 then
    Self.Width := Min(Monitor.WorkareaRect.Width, Settings.MainFormBounds.Width);
  if Settings.MainFormBounds.Bottom > -1 then
    Self.Height := Min(Monitor.WorkareaRect.Height, Settings.MainFormBounds.Height);

  if Settings.MainFormMaximize then
    Self.WindowState := wsMaximized;

  FClipboardWrapper := TClipboardWrapper.Create;
  Settings.OnUpdateSettings := @DoUpdateSettings;
  UpdateSettings;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin

  FClipboardWrapper.Free;

end;

procedure TfrmMain.DoUpdateSettings;
var
  iKeyBindIndex: Integer;
begin

  if Settings.ShowInTray then
  begin
    if FindResource(Application.{%H-}Handle, 'TRAYICON-' + UpperCase(Settings.TrayIcon), RT_GROUP_ICON) > 0 then
      TrayIcon1.Icon.LoadFromResourceName(Application.{%H-}Handle, 'TRAYICON-' + UpperCase(Settings.TrayIcon))
    else
      Settings.ShowInTray := False;
  end;
  TrayIcon1.Visible := Settings.ShowInTray;

  cActionShow.ShortCut := Settings.KeyBinds.KeyData['OpenWindow'];
  cActionConvert.ShortCut := Settings.KeyBinds.KeyData['ConvertSelection'];
  cActionSwapCase.ShortCut := Settings.KeyBinds.KeyData['SwapCase'];
  cActionUpperCase.ShortCut := Settings.KeyBinds.KeyData['UpperCase'];
  cActionLowerCase.ShortCut := Settings.KeyBinds.KeyData['LowerCase'];
  cActionProperCase.ShortCut := Settings.KeyBinds.KeyData['ProperCase'];

  if GlobalHotKey1.Active then
    GlobalHotKey1.Stop;
  GlobalHotKey1.RemoveAllGloablHotkeys;
  for iKeyBindIndex := 0 to Settings.KeyBinds.Count-1 do
  begin
    if not (Settings.KeyBinds.Data[iKeyBindIndex] in [VK_UNDEFINED, VK_UNKNOWN]) then
      GlobalHotKey1.AddGlobalHotkey(Settings.KeyBinds.Data[iKeyBindIndex])
  end;
  if GlobalHotKey1.HotKeyList.Count > 0 then
    GlobalHotKey1.Start;

end;

procedure TfrmMain.FormWindowStateChange(Sender: TObject);
begin

  Settings.MainFormMaximize := (Self.WindowState in [wsMaximized, wsFullScreen]);

  if Self.WindowState = wsMinimized then
    Self.Hide;

end;

procedure TfrmMain.GlobalHotKey1HotKey(AHotKeyInfo: PTHotKeyInfo);
begin

  WriteLn('HotKey: ', AHotKeyInfo^.ShortCut, ' | ', cActionConvert.ShortCut);

  if AHotKeyInfo^.ShortCut = cActionConvert.ShortCut then
    cActionConvert.Execute;
  if AHotKeyInfo^.ShortCut = cActionSwapCase.ShortCut then
    cActionSwapCaseExecute(cActionSwapCase);

end;

procedure TfrmMain.GlobalHotKey1Register(AHotKeyInfo: PTHotKeyInfo; ASuccess: Boolean; AErrorCode: LongInt);
begin

  WriteLn(ShortCutToTextRaw(AHotKeyInfo^.ShortCut), '=', BoolToStr(ASuccess, True), ', Error=', AErrorCode );

end;

procedure TfrmMain.cActionConvertExecute(Sender: TObject);
begin

  if Self.Showing and Self.Active then
  begin
    cActionLocalConvertExecute(cActionLocalConvert);
    Exit;
  end;

  WriteLn('cActionConvertExecute.');

  ProcessConvert;

end;

procedure TfrmMain.cActionLocalConvertExecute(Sender: TObject);
var
  sSelection, sProcessedString: UTF8String;
  bSelectedText: Boolean;
  iCursorPosition: Integer;
begin

  WriteLn('cActionLocalConvertExecute.');

  bSelectedText := False;

  if memoText.SelLength > 0 then
    bSelectedText := True;

  iCursorPosition := memoText.SelStart;

  sSelection := IfThen(bSelectedText, memoText.SelText, memoText.Text);

  sProcessedString := ProcessConvert(sSelection);

  if bSelectedText then
    memoText.SelText := sProcessedString
  else
  begin
    memoText.Text := sProcessedString;
    memoText.SelStart := iCursorPosition;
  end;

end;

procedure TfrmMain.cActionSwapCaseExecute(Sender: TObject);
var
  LCaseAction: TKLCaseAction;
begin

  if Self.Showing and Self.Active then
  begin

    if Sender = cActionSwapCase then
      cActionLocalCaseExecute(cActionLocalSwapCase)
    else if Sender = cActionUpperCase then
      cActionLocalCaseExecute(cActionLocalUpperCase)
    else if Sender = cActionLowerCase then
      cActionLocalCaseExecute(cActionLocalLowerCase)
    else if Sender = cActionProperCase then
      cActionLocalCaseExecute(cActionLocalProperCase)
    else
      Exit;
    Exit;

  end;

  if Sender = cActionSwapCase then
    LCaseAction := TKLCaseAction.caSwap
  else if Sender = cActionUpperCase then
    LCaseAction := TKLCaseAction.caUpper
  else if Sender = cActionLowerCase then
    LCaseAction := TKLCaseAction.caLower
  else if Sender = cActionProperCase then
    LCaseAction := TKLCaseAction.caProper
  else
    Exit;

  WriteLn('cActionSwapCaseExecute: ', LCaseAction);

  ProcessCase(LCaseAction);

end;

procedure TfrmMain.cActionLocalCaseExecute(Sender: TObject);
var
  sSelection, sProcessedString: UTF8String;
  bSelectedText: Boolean;
  iCursorPosition: Integer;
  LCaseAction: TKLCaseAction;
begin

  if Sender = cActionLocalSwapCase then
    LCaseAction := TKLCaseAction.caSwap
  else if Sender = cActionLocalUpperCase then
    LCaseAction := TKLCaseAction.caUpper
  else if Sender = cActionLocalLowerCase then
    LCaseAction := TKLCaseAction.caLower
  else if Sender = cActionLocalProperCase then
    LCaseAction := TKLCaseAction.caProper
  else
    Exit;

  WriteLn('cActionLocalCaseExecute: ', LCaseAction);

  bSelectedText := False;

  if memoText.SelLength > 0 then
    bSelectedText := True;

  iCursorPosition := memoText.SelStart;

  sSelection := IfThen(bSelectedText, memoText.SelText, memoText.Text);

  sProcessedString := ProcessCase(sSelection, LCaseAction);

  if bSelectedText then
    memoText.SelText := sProcessedString
  else
  begin
    memoText.Text := sProcessedString;
    memoText.SelStart := iCursorPosition;
  end;

end;

procedure TfrmMain.cActionShowExecute(Sender: TObject);
begin

  Self.Show;

end;

procedure TfrmMain.cActionCloseExecute(Sender: TObject);
begin

  FTerminate := True;
  Close;

end;

procedure TfrmMain.cActionPasteExecute(Sender: TObject);
begin

  memoText.PasteFromClipboard;

end;

procedure TfrmMain.cActionCopyExecute(Sender: TObject);
begin

  memoText.CopyToClipboard;

end;


procedure TfrmMain.cActionSettingsExecute(Sender: TObject);
var
  frmSettings: TfrmSettings;
begin

  frmSettings := TfrmSettings.Create(Self);
  try
    frmSettings.ShowModal;
  finally
    frmSettings.Free;
  end;

end;

procedure TfrmMain.FormChangeBounds(Sender: TObject);
begin

  if not (Self.WindowState in [wsMaximized, wsFullScreen]) then
    Settings.MainFormBounds := Self.BoundsRect;

end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  {$IfNDef Debug}
  if FTerminate then
    CloseAction := caFree
  else
    CloseAction := caHide;
  {$EndIf}

end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin


end;


end.

