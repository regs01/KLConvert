unit FormSettings;

{$mode ObjFPC}{$H+}
{$ModeSwitch implicitfunctionspecialization+}
{$Macro On}

interface

uses
  Classes, SysUtils, Forms, Controls, LCLType, Graphics, Dialogs, ComCtrls, StdCtrls, StrUtils,
  Translations, LCLTranslator, LCLProc, LCLIntf, LResources, LMessages, LCLPlatformDef, FileInfo, InterfaceBase,
  LazHotKeyFunctions, FormShortCutGrabber,
  Unix,
  ExtCtrls, ComboEx, laz.VirtualTrees, Types,
  UnitKLCType, UnitConvert;

type

  { TfrmSettings }
  TfrmSettings = class(TForm)
    btnApply: TButton;
    chbAltGrSymbols: TCheckBox;
    chbCapitalSymbols: TCheckBox;
    cbTrayIcons: TComboBoxEx;
    cbLanguages: TComboBoxEx;
    ilTrayIcons: TImageList;
    lblURL: TLabel;
    lblApplicationTitle: TLabel;
    lblLanguage: TLabel;
    lblConvertLayouts: TLabel;
    sbPageAbout: TScrollBox;
    vstConvertLayouts: TLazVirtualStringTree;
    panelConvertLayouts: TPanel;
    vstKeyBinds: TLazVirtualStringTree;
    panelMainSettings: TPanel;
    btnSave: TButton;
    btnCancel: TButton;
    chbShowIcon: TCheckBox;
    chbAutostart: TCheckBox;
    chbLaunchMinimized: TCheckBox;
    chbKbGroupsSwitch: TCheckBox;
    cbInputHotkey: TComboBox;
    cbOutputHotkey: TComboBox;
    cbKbGroupPair1: TComboBox;
    cbKbGroupPair2: TComboBox;
    lblInputMethodCaption: TLabel;
    lblKbGroupPair1: TLabel;
    lblKbGroupPair2: TLabel;
    lblInputPrimarySelectionDescription: TLabel;
    lblInputClipboardDescription: TLabel;
    lblOutputMethodCaption: TLabel;
    lblAboutInfo: TLabel;
    lblOutputPrimarySelectionDescription: TLabel;
    lblOutputClipboardDescription: TLabel;
    lblOutputSendTextDescription: TLabel;
    lbSettingsCategories: TListBox;
    nbSettings: TNotebook;
    Panel1: TPanel;
    panelInputMethod: TPanel;
    panelOutputMethod: TPanel;
    panelKbSwitch: TPanel;
    rbOutputPrimarySelection: TRadioButton;
    rbOutputClipboard: TRadioButton;
    rbInputPrimarySelection: TRadioButton;
    rbInputClipboard: TRadioButton;
    rbOutputSendText: TRadioButton;
    rbKbGroupDetect: TRadioButton;
    rbKbGroupPair: TRadioButton;
    sbPageMethod: TScrollBox;
    sbPageMain: TScrollBox;
    tsPageMain: TPage;
    tsPageMethod: TPage;
    tsPageKeyBindings: TPage;
    tsPageAbout: TPage;
    Splitter1: TSplitter;
    procedure btnApplyClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure chbAltGrSymbolsChange(Sender: TObject);
    procedure chbCapitalSymbolsChange(Sender: TObject);
    procedure chbKbGroupsSwitchChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
    procedure lbSettingsCategoriesDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure lbSettingsCategoriesMouseLeave(Sender: TObject);
    procedure lbSettingsCategoriesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure lbSettingsCategoriesSelectionChange(Sender: TObject; User: Boolean);
    procedure rbInputPrimarySelectionChange(Sender: TObject);
    procedure rbOutputPrimarySelectionChange(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure vstConvertLayoutsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstConvertLayoutsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstConvertLayoutsChecking(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
    procedure vstConvertLayoutsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure vstConvertLayoutsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstConvertLayoutsGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure vstConvertLayoutsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: String);
    procedure vstConvertLayoutsInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstKeyBindsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstKeyBindsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure vstKeyBindsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstKeyBindsGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure vstKeyBindsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: String);
    procedure vstKeyBindsKeyAction(Sender: TBaseVirtualTree; var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
    procedure vstKeyBindsNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
  protected
    procedure FormTranslate(var Msg: TLMessage); message LM_TRANSLATE;
    procedure OpenKeyBinding(Sender: TBaseVirtualTree);
    procedure LoadFromSettings;
    procedure SaveToSettings;
  private

  public

  end;

  PTRActionShortCutData = ^TRActionShortCutData;
  TRActionShortCutData = record
    Description: String;
    ID: String;
    ShortCut: TShortCut;
  end;

  PTRConvertLayoutData = ^TRConvertLayoutData;
  TRConvertLayoutData = record
    LayoutName: String;
    ClassName: String;
    Active: Boolean;
    PossibleOptions: TKLConvertOptions;
    ConvertOptions: TKLConvertOptions;
  end;

resourcestring
  RSPageMain = 'Main';
  RSPageMethod = 'Method';
  RSPageKeyBindings = 'Key Bindings';
  RSPageAbout = 'About';
  RSThemeLight = 'Light';
  RSThemeDark = 'Dark';
  RSThemeDark2 = 'Dark2';
  RSThemeGray = 'Gray';
  RSThemeColor = 'Color';
  RSAbout =
    'Version %s'#10#32#10 +
    'Icons used in the app are create by FTurtle and Roland Hahn.'#10#32#10 +
    'Lazarus: %s'#10 +
    'Free Pascal: %s'#10 +
    'Platform: %s %s'#10 +
    'Widgetset: %s';

var
  frmSettings: TfrmSettings;

implementation

uses
  UnitSettings, UnitXKeyInput;

{$R *.lfm}

const
  ITEM_HEIGHT = 24;
  SELECT_MARKER_WIDTH = 4;

{ TfrmSettings }

procedure TfrmSettings.FormCreate(Sender: TObject);
var
  iPageIndex: Integer;
  LTrayIcon: TIcon;
begin

  lbSettingsCategories.Tag := -1;
  lbSettingsCategories.ItemHeight := Self.Scale96ToForm(ITEM_HEIGHT);
  for iPageIndex := 0 to nbSettings.PageCount-1 do
    lbSettingsCategories.Items.Append(nbSettings.Page[iPageIndex].Caption);
  lbSettingsCategories.ItemIndex := 0;

  cbLanguages.ItemsEx.AddItem('English', -1, -1, -1, -1, TObject(PAnsiChar('en')));
  cbLanguages.ItemsEx.AddItem('Russian (Русский)', -1, -1, -1, -1, TObject(PAnsiChar('ru')));

  // review: update in OnChangeBounds?
  ilTrayIcons.Width := Self.Scale96ToForm(16);
  ilTrayIcons.Height := Self.Scale96ToForm(16);

  LTrayIcon := TIcon.Create;
  LTrayIcon.LoadFromResourceName(Application.{%H-}Handle, 'TRAYICON-LIGHT');
  ilTrayIcons.AddIcon(LTrayIcon);
  LTrayIcon.LoadFromResourceName(Application.{%H-}Handle, 'TRAYICON-DARK');
  ilTrayIcons.AddIcon(LTrayIcon);
  LTrayIcon.LoadFromResourceName(Application.{%H-}Handle, 'TRAYICON-DARK2');
  ilTrayIcons.AddIcon(LTrayIcon);
  LTrayIcon.LoadFromResourceName(Application.{%H-}Handle, 'TRAYICON-GREY');
  ilTrayIcons.AddIcon(LTrayIcon);
  LTrayIcon.LoadFromResourceName(Application.{%H-}Handle, 'TRAYICON-COLOR');
  ilTrayIcons.AddIcon(LTrayIcon);
  LTrayIcon.Free;

  cbTrayIcons.Images := ilTrayIcons;
  cbTrayIcons.ItemsEx.AddItem( RSThemeLight, 0, 0, 0, -1, TObject(PAnsiChar('Light')) );
  cbTrayIcons.ItemsEx.AddItem( RSThemeDark, 1, 1, 1, -1, TObject(PAnsiChar('Dark')) );
  cbTrayIcons.ItemsEx.AddItem( RSThemeDark2, 2, 2, 2, -1, TObject(PAnsiChar('Dark2')) );
  cbTrayIcons.ItemsEx.AddItem( RSThemeGray, 3, 3, 3, -1, TObject(PAnsiChar('Grey')) );
  cbTrayIcons.ItemsEx.AddItem( RSThemeColor, 4, 4, 4, -1, TObject(PAnsiChar('Color')) );

  SendMessage(Self.Handle, LM_TRANSLATE, 0, 0);

  LoadFromSettings;

end;

procedure TfrmSettings.FormTranslate(var Msg: TLMessage);
var
  iPageIndex, iItemIndex: Integer;
  LFileInfo: TFileVersionInfo;
  sVersion: String;
begin

  tsPageMain.Caption := RSPageMain;
  tsPageMethod.Caption := RSPageMethod;
  tsPageKeyBindings.Caption := RSPageKeyBindings;
  tsPageAbout.Caption := RSPageAbout;

  if lbSettingsCategories.Items.Count = nbSettings.PageCount then
  for iPageIndex := 0 to lbSettingsCategories.Items.Count-1 do
    lbSettingsCategories.Items.Strings[iPageIndex] := nbSettings.Page[iPageIndex].Caption;

  for iItemIndex := 0 to cbTrayIcons.ItemsEx.Count-1 do
  begin
    with cbTrayIcons.ItemsEx.Items[iItemIndex] do
    begin
      if Data = PAnsiChar('Light') then
        Caption := RSThemeLight;
      if Data = PAnsiChar('Dark') then
        Caption := RSThemeDark;
      if Data = PAnsiChar('Dark2') then
        Caption := RSThemeDark2;
      if Data = PAnsiChar('Grey') then
        Caption := RSThemeGray;
      if Data = PAnsiChar('Color') then
        Caption := RSThemeColor;
    end;
  end;

  LFileInfo := TFileVersionInfo.Create(nil);
  try
    LFileInfo.ReadFileInfo;
    sVersion := LFileInfo.VersionStrings.Values['FileVersion'];
  finally
    LFileInfo.Free;
  end;
  lblApplicationTitle.Caption := Application.Title;
  lblAboutInfo.Caption := Format(RSAbout, [sVersion, LCLVersion, {$I %FPCVERSION%}, {$I %FPCTARGETOS%}, {$I %FPCTARGETCPU%},
                      LCLPlatformDisplayNames[WidgetSet.LCLPlatform]]);

end;

procedure TfrmSettings.LoadFromSettings;
var
  iItemIndex: Integer;
  arKbGroups: TKbGroupsArray;
  sKbGroup: String;
  sShortcut: String;
  iShortcutIndex, iConvertLayoutIndex: Integer;
  pActiveShortCutNode: PVirtualNode;
  pActiveShortCutData: PTRActionShortCutData;
  pConvertLayoutNode: PVirtualNode;
  pConvertLayoutData: PTRConvertLayoutData;
  sTrayIcon, sLanguageId: String;
begin

  // todo: extract to procedure
  chbShowIcon.Checked := Settings.ShowInTray;
  chbLaunchMinimized.Checked := Settings.LaunchMinimized;
  chbAutostart.Checked := Settings.Autostart;

  // review: with?
  for iItemIndex := 0 to cbLanguages.ItemsEx.Count-1 do
  begin
    if Assigned(cbLanguages.ItemsEx.Items[iItemIndex].Data) then
    begin
      sLanguageId := PAnsiChar (cbLanguages.ItemsEx.Items[iItemIndex].Data);
      if sLanguageId = Settings.LanguageId then
        cbLanguages.ItemIndex := iItemIndex;
    end;
  end;

  for iItemIndex := 0 to cbTrayIcons.ItemsEx.Count-1 do
  begin
    if Assigned(cbTrayIcons.ItemsEx.Items[iItemIndex].Data) then
    begin
      sTrayIcon := PAnsiChar (cbTrayIcons.ItemsEx.Items[iItemIndex].Data);
      if sTrayIcon = Settings.TrayIcon then
      begin
        cbTrayIcons.ItemIndex := iItemIndex;
        Break;
      end;
    end;
  end;

  //doing full cycle to fire onchange
  case Settings.LayoutSwitch of
    TKLLayoutSwitch.lsDisable:
      begin
        chbKbGroupsSwitch.Checked := True;
        chbKbGroupsSwitch.Checked := False;
      end;
    TKLLayoutSwitch.lsDetect:
      begin
        chbKbGroupsSwitch.Checked := False;
        chbKbGroupsSwitch.Checked := True;
        rbKbGroupDetect.Checked := False;
        rbKbGroupDetect.Checked := True;
      end;
    TKLLayoutSwitch.lsDefinedPair:
      begin
        chbKbGroupsSwitch.Checked := False;
        chbKbGroupsSwitch.Checked := True;
        rbKbGroupPair.Checked := False;
        rbKbGroupPair.Checked := True;
      end;
  end;

  arKbGroups := UnitXKeyInput.GetKeyboardGroups;
  for sKbGroup in arKbGroups do
  begin
    cbKbGroupPair1.Items.Add(sKbGroup);
    cbKbGroupPair2.Items.Add(sKbGroup);
  end;

  if Length(arKbGroups) > 0 then
  begin
    if Settings.LayoutPair[0] in [0..Length(arKbGroups)-1] then
      cbKbGroupPair1.ItemIndex := Settings.LayoutPair[0]
    else
      cbKbGroupPair1.ItemIndex := 0;
  end;

  if Length(arKbGroups) > 1 then
  begin
    if Settings.LayoutPair[1] in [0..Length(arKbGroups)-1] then
      cbKbGroupPair2.ItemIndex := Settings.LayoutPair[1]
    else
      cbKbGroupPair2.ItemIndex := 1;
  end;

  //again cycling to fire onchange event
  case Settings.InputMethod of
    TKLInputMethod.imPrimarySelection:
      begin
        rbInputPrimarySelection.Checked := False;
        rbInputPrimarySelection.Checked := True;
      end;
    TKLInputMethod.imCopyClipboard:
      begin
        rbInputClipboard.Checked := False;
        rbInputClipboard.Checked := True;
      end;
  end;

  //again cycling to fire onchange event
  case Settings.OutputMethod of
    TKLOutputMethod.omPrimarySelection:
      begin
        rbOutputPrimarySelection.Checked := False;
        rbOutputPrimarySelection.Checked := True;
      end;
    TKLOutputMethod.omCopyClipboard:
      begin
        rbOutputClipboard.Checked := False;
        rbOutputClipboard.Checked := True;
      end;
    TKLOutputMethod.omTypeText:
      begin
        rbOutputSendText.Checked := False;
        rbOutputSendText.Checked := True;
      end;
  end;

  sShortcut := ShortCutToTextRaw(Settings.ClipboardCopyShortcut);
  iShortcutIndex := cbInputHotkey.Items.IndexOf(sShortcut);
  if (iShortcutIndex < 0) and not(Settings.ClipboardCopyShortcut in [0, 255]) then
    iShortcutIndex := cbInputHotkey.Items.Add(sShortcut);
  if (iShortcutIndex < 0) then
    iShortcutIndex := 1;
  cbInputHotkey.ItemIndex := iShortcutIndex;

  sShortcut := ShortCutToTextRaw(Settings.ClipboardPasteShortcut);
  iShortcutIndex := cbOutputHotkey.Items.IndexOf(sShortcut);
  if (iShortcutIndex < 0) and not(Settings.ClipboardPasteShortcut in [0, 255]) then
    iShortcutIndex := cbOutputHotkey.Items.Add(sShortcut);
  if (iShortcutIndex < 0) then
    iShortcutIndex := 1;
  cbOutputHotkey.ItemIndex := iShortcutIndex;

  vstKeyBinds.BeginUpdate;
  try

    for iShortCutIndex := 0 to Settings.KeyBinds.Count-1 do
    begin
      pActiveShortCutNode := vstKeyBinds.AddChild(nil);
      pActiveShortCutData := vstKeyBinds.GetNodeData(pActiveShortCutNode);
      pActiveShortCutData^.Description := Settings.KeyBinds.Keys[iShortCutIndex];
      pActiveShortCutData^.ID := Settings.KeyBinds.Keys[iShortCutIndex];
      pActiveShortCutData^.ShortCut := Settings.KeyBinds.Data[iShortCutIndex];
    end;

  finally
    vstKeyBinds.EndUpdate;
  end;

  vstConvertLayouts.BeginUpdate;
  try

    for iConvertLayoutIndex := 0 to ConvertList.Count-1 do
    begin
      pConvertLayoutNode := vstConvertLayouts.AddChild(nil);
      pConvertLayoutData := vstConvertLayouts.GetNodeData(pConvertLayoutNode);
      pConvertLayoutData^.LayoutName := ConvertList.Items[iConvertLayoutIndex].LayoutName;
      pConvertLayoutData^.Active := ConvertList.Items[iConvertLayoutIndex].Active;
      pConvertLayoutData^.PossibleOptions := ConvertList.Items[iConvertLayoutIndex].PossibleOptions;;
      pConvertLayoutData^.ConvertOptions := ConvertList.Items[iConvertLayoutIndex].ConvertOptions;
      pConvertLayoutData^.ClassName := ConvertList.Items[iConvertLayoutIndex].ShortClassName;
    end;

  finally
    vstConvertLayouts.EndUpdate;
  end;

end;

procedure TfrmSettings.SaveToSettings;
var
  iConvertLayoutIndex: Integer;
  pActiveShortCutData: PTRActionShortCutData;
  pActiveShortCutNode: PVirtualNode;
  pConvertLayoutNode: PVirtualNode;
  pConvertLayoutData: PTRConvertLayoutData;
begin

  Settings.ShowInTray := chbShowIcon.Checked;
  Settings.LaunchMinimized := chbLaunchMinimized.Checked;
  Settings.Autostart := chbAutostart.Checked;

  if cbLanguages.ItemIndex > -1 then
  begin
    if Assigned(cbLanguages.ItemsEx.Items[cbLanguages.ItemIndex].Data) then
      Settings.LanguageId := PAnsiChar (cbLanguages.ItemsEx.Items[cbLanguages.ItemIndex].Data);
  end;

  if cbTrayIcons.ItemIndex > -1 then
  begin
    if Assigned(cbTrayIcons.ItemsEx.Items[cbTrayIcons.ItemIndex].Data) then
      Settings.TrayIcon := PAnsiChar (cbTrayIcons.ItemsEx.Items[cbTrayIcons.ItemIndex].Data);
  end;

  if rbInputPrimarySelection.Checked then
    Settings.InputMethod := TKLInputMethod.imPrimarySelection
  else if rbInputClipboard.Checked then
    Settings.InputMethod := TKLInputMethod.imCopyClipboard;

  if rbOutputPrimarySelection.Checked then
    Settings.OutputMethod := TKLOutputMethod.omPrimarySelection
  else if rbOutputClipboard.Checked then
    Settings.OutputMethod := TKLOutputMethod.omCopyClipboard
  else if rbOutputSendText.Checked then
    Settings.OutputMethod := TKLOutputMethod.omTypeText;

  if not chbKbGroupsSwitch.Checked then
    Settings.LayoutSwitch := TKLLayoutSwitch.lsDisable
  else if rbKbGroupDetect.Checked then
    Settings.LayoutSwitch := TKLLayoutSwitch.lsDetect
  else if rbKbGroupPair.Checked then
  begin
    Settings.LayoutSwitch := TKLLayoutSwitch.lsDefinedPair;
    if cbKbGroupPair1.Items.Count>0  then
      Settings.LayoutPair[0] := cbKbGroupPair1.ItemIndex;
    if cbKbGroupPair2.Items.Count>0  then
      Settings.LayoutPair[1] := cbKbGroupPair2.ItemIndex;
  end;

  Settings.ClipboardCopyShortcut := TextToShortCutRaw(cbInputHotkey.Text);
  Settings.ClipboardPasteShortcut := TextToShortCutRaw(cbOutputHotkey.Text);


  pActiveShortCutNode := vstKeyBinds.GetFirst;
  repeat
    pActiveShortCutData := vstKeyBinds.GetNodeData(pActiveShortCutNode);
    Settings.KeyBinds.KeyData[pActiveShortCutData^.ID] := pActiveShortCutData^.ShortCut;
    pActiveShortCutNode := vstKeyBinds.GetNext(pActiveShortCutNode);
  until
    pActiveShortCutNode = vstKeyBinds.GetLast;

  pConvertLayoutNode := vstConvertLayouts.GetFirst;
  repeat
    pConvertLayoutData := vstConvertLayouts.GetNodeData(pConvertLayoutNode);
    iConvertLayoutIndex := ConvertList.IndexByClassName(pConvertLayoutData^.ClassName);
    if iConvertLayoutIndex > -1 then
    begin
      ConvertList.Items[iConvertLayoutIndex].Active := pConvertLayoutData^.Active;
      ConvertList.Items[iConvertLayoutIndex].ConvertOptions := pConvertLayoutData^.ConvertOptions;
    end;
    pConvertLayoutNode := vstConvertLayouts.GetNext(pConvertLayoutNode);
  until
    pConvertLayoutNode = vstConvertLayouts.GetLast;

end;

procedure TfrmSettings.chbKbGroupsSwitchChange(Sender: TObject);
var
  bKbSwitchEnabled: Boolean;
  bKbSwitchPairEnabled: Boolean;
begin

  bKbSwitchEnabled := chbKbGroupsSwitch.Checked;
  bKbSwitchPairEnabled := chbKbGroupsSwitch.Checked;
  if bKbSwitchEnabled then
    bKbSwitchPairEnabled := not rbKbGroupDetect.Checked;

  rbKbGroupPair.Enabled := bKbSwitchEnabled;

  rbKbGroupDetect.Enabled := bKbSwitchEnabled;

  lblKbGroupPair1.Enabled := bKbSwitchPairEnabled;
  cbKbGroupPair1.Enabled := bKbSwitchPairEnabled;

  lblKbGroupPair2.Enabled := bKbSwitchPairEnabled;
  cbKbGroupPair2.Enabled := bKbSwitchPairEnabled;

end;

procedure TfrmSettings.FormShow(Sender: TObject);
begin

  lbSettingsCategories.Repaint;

end;

procedure TfrmSettings.lblURLClick(Sender: TObject);
begin

  OpenURL(TLabel(Sender).Caption);

end;

procedure TfrmSettings.lbSettingsCategoriesDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
var
  iTextPosition: Integer;
  iMarkerWidth: Integer;
begin

  iMarkerWidth := Self.Scale96ToForm(SELECT_MARKER_WIDTH);

  with TListBox(Control) do
  begin

    Canvas.Font.Color :=  clWindowText;
    if (odSelected in State) then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.FillRect(ARect.Left, ARect.Top, ARect.Left + iMarkerWidth , ARect.Bottom);
      Canvas.Brush.Color := clWindow;
      Canvas.FillRect(ARect.Left + iMarkerWidth, ARect.Top, ARect.Right, ARect.Bottom);
      Canvas.Font.Color :=  clHighlight;
      // todo: focus rect and themed font color for qt6
    end
    //else if (odHotLight in State) then
    //begin
    //  Canvas.Brush.Color := clWindow;
    //  Canvas.FillRect(ARect);
    //  Canvas.Font.Color :=  clHighlight;
    //end
    else if (Tag = Index) and (Tag > -1) then
    begin
      Canvas.Brush.Color := clWindow;
      Canvas.FillRect(ARect);
      Canvas.Font.Color :=  clHighlight;
    end
    else
    begin
      Canvas.Brush.Color := clWindow;
      Canvas.FillRect(ARect);
    end;

    iTextPosition := (ARect.Bottom - ARect.Top - Canvas.TextHeight(Items[Index])) div 2;
    Canvas.TextOut(ARect.Left + iTextPosition + iMarkerWidth*3, ARect.Top + iTextPosition, Items[Index]);

    // review: focus rect
    //if (odFocused in State) then
    //begin
    ////  Canvas.Pen.Color := clWindow;
    //  Canvas.Pen.Style := psClear;
    //  Canvas.DrawFocusRect(ARect);
    //end;

  end;

end;

procedure TfrmSettings.lbSettingsCategoriesMouseLeave(Sender: TObject);
begin

  with TListBox(Sender) do
  begin
    if Tag > -1 then
    begin
      Tag := -1;
      Invalidate;
    end;
  end;

end;

procedure TfrmSettings.lbSettingsCategoriesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin

  with TListBox(Sender) do
  begin
    Index := ItemAtPos(Point(X, Y), True);
    if Tag <> Index then
      begin;
        Tag := Index;
        Invalidate;
      end;
  end;

end;

procedure TfrmSettings.lbSettingsCategoriesSelectionChange(Sender: TObject; User: boolean);
begin

  if (lbSettingsCategories.ItemIndex > -1) and (lbSettingsCategories.ItemIndex < lbSettingsCategories.Count) then
    nbSettings.PageIndex := lbSettingsCategories.ItemIndex;

end;

procedure TfrmSettings.rbInputPrimarySelectionChange(Sender: TObject);
begin

  cbInputHotkey.Enabled := rbInputClipboard.Checked;

end;

procedure TfrmSettings.rbOutputPrimarySelectionChange(Sender: TObject);
begin

  cbOutputHotkey.Enabled := rbOutputClipboard.Checked;

end;

procedure TfrmSettings.btnSaveClick(Sender: TObject);
begin

  SaveToSettings;
  UpdateSettings;
  Close;

end;

procedure TfrmSettings.btnApplyClick(Sender: TObject);
begin

  SaveToSettings;
  UpdateSettings

end;

procedure TfrmSettings.btnCancelClick(Sender: TObject);
begin

  Close;

end;

procedure TfrmSettings.chbAltGrSymbolsChange(Sender: TObject);
var
  pData: PTRConvertLayoutData;
  pXNode: PVirtualNode;
begin

  pXNode := vstConvertLayouts.GetFirstSelected;
  if pXNode = nil then
    Exit;

  pData := vstConvertLayouts.GetNodeData(pXNode);

  if chbAltGrSymbols.Checked then
    pData^.ConvertOptions := pData^.ConvertOptions + [coAltGrSymbols]
  else
    pData^.ConvertOptions := pData^.ConvertOptions - [coAltGrSymbols];

end;

procedure TfrmSettings.chbCapitalSymbolsChange(Sender: TObject);
var
  pData: PTRConvertLayoutData;
  pXNode: PVirtualNode;
begin

  pXNode := vstConvertLayouts.GetFirstSelected;
  if pXNode = nil then
    Exit;

  pData := vstConvertLayouts.GetNodeData(pXNode);

  if chbCapitalSymbols.Checked then
    pData^.ConvertOptions := pData^.ConvertOptions + [coCapitalSymbols]
  else
    pData^.ConvertOptions := pData^.ConvertOptions - [coCapitalSymbols];

end;

procedure TfrmSettings.vstConvertLayoutsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  pData: PTRConvertLayoutData;
begin

  if Node = nil then
    Exit;

  pData := Sender.GetNodeData(Node);

  chbAltGrSymbols.Enabled := IfThen((coAltGrSymbols in pData^.PossibleOptions), True, False);
  chbCapitalSymbols.Enabled := IfThen((coCapitalSymbols in pData^.PossibleOptions), True, False);

  chbAltGrSymbols.Checked := IfThen((coAltGrSymbols in pData^.ConvertOptions), True, False);
  chbCapitalSymbols.Checked := IfThen((coCapitalSymbols in pData^.ConvertOptions), True, False);

  Sender.Refresh;

end;

procedure TfrmSettings.vstConvertLayoutsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  pData: PTRConvertLayoutData;
begin

  Sender.Refresh;

  pData := Sender.GetNodeData(Node);
  pData^.Active := IfThen((Node^.CheckState = csCheckedNormal), True, False);

end;

procedure TfrmSettings.vstConvertLayoutsChecking(Sender: TBaseVirtualTree; Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
begin

  Sender.Refresh;

end;

procedure TfrmSettings.vstConvertLayoutsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin

  Sender.Refresh;

end;

procedure TfrmSettings.vstKeyBindsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin

  Sender.Refresh;

end;

procedure TfrmSettings.vstKeyBindsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin

  Sender.Refresh;

end;

procedure TfrmSettings.vstConvertLayoutsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  pData: PTRConvertLayoutData;
begin

  pData := Sender.GetNodeData(Node);
  if Assigned(pData) then begin
    pData^.Active := False;
    pData^.ClassName := '';
    pData^.LayoutName := '';
  end;


end;

procedure TfrmSettings.vstKeyBindsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  pData: PTRActionShortCutData;
begin

  pData := Sender.GetNodeData(Node);
  if Assigned(pData) then begin
    pData^.Description := '';
    pData^.ID := '';
    pData^.ShortCut := 0;
  end;

end;

procedure TfrmSettings.vstConvertLayoutsGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin

  NodeDataSize := SizeOf(TRConvertLayoutData);

end;

procedure TfrmSettings.vstKeyBindsGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin

  NodeDataSize := SizeOf(TRActionShortCutData);

end;

procedure TfrmSettings.vstConvertLayoutsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: String);
var
  pData: PTRConvertLayoutData;
begin

  pData := Sender.GetNodeData(Node);
  case Column of
    0: CellText := '';
    1: CellText := pData^.LayoutName;
  end;

end;

procedure TfrmSettings.vstConvertLayoutsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  pData: PTRConvertLayoutData;
begin

  if Sender.GetNodeLevel(Node) = 0 then
  begin
    Node^.CheckType := ctCheckBox;
    pData := Sender.GetNodeData(Node);
    if pData^.Active then
      Node^.CheckState :=  TCheckState.csCheckedNormal
    else
      Node^.CheckState :=  TCheckState.csUncheckedNormal;
  end;

end;

procedure TfrmSettings.vstKeyBindsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: String);
var
  pData: PTRActionShortCutData;
begin

  pData := Sender.GetNodeData(Node);
  case Column of
    0: CellText := pData^.Description;
    1:
      begin
        CellText := '';
        if not (pData^.ShortCut in [VK_UNKNOWN, VK_UNDEFINED]) then
          CellText := ShortCutToTextFix(pData^.ShortCut);
      end;
  end;

end;

procedure TfrmSettings.OpenKeyBinding(Sender: TBaseVirtualTree);
var
  LFormShortCutGrabber: TfrmShortCutGrabber;
  iFormResponse: Integer;
  pData: PTRActionShortCutData;
begin

  if Sender.SelectedCount <> 1 then
    Exit;

  LFormShortCutGrabber := TfrmShortCutGrabber.Create(Self);
  try

    pData := Sender.GetNodeData(Sender.GetFirstSelected);

    LFormShortCutGrabber.UngrabButton := True;
    LFormShortCutGrabber.ShortCut := pData^.ShortCut;
    LFormShortCutGrabber.Caption := pData^.ID;

    iFormResponse := LFormShortCutGrabber.ShowModal;
    if iFormResponse = mrCancel then
      Exit;

    if iFormResponse = mrOK then
      pData^.ShortCut := LFormShortCutGrabber.ShortCut;
    if iFormResponse = mrAbort then
      pData^.ShortCut := VK_UNDEFINED;

    Sender.Refresh;

  finally
    LFormShortCutGrabber.Free;
  end;

end;

procedure TfrmSettings.vstKeyBindsKeyAction(Sender: TBaseVirtualTree;
  var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
begin

  if (CharCode = VK_RETURN) and (Shift = []) then
    OpenKeyBinding(Sender);

end;

procedure TfrmSettings.vstKeyBindsNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
begin

  OpenKeyBinding(Sender);

end;

end.

