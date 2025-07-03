unit UnitConvert;

{$mode ObjFPC}{$H+}
{$codepage utf8}
{$ModeSwitch arrayoperators+}

interface

uses
  Classes, SysUtils, LazUTF8, fgl, LConvEncoding, UnitKLCType;

type
  TKLConvert = class
  protected var
    FActive: Boolean;
    FScriptLeft: String;
    FScriptRight: String;
    FPossibleOptions: TKLConvertOptions;
    FConvertOptions: TKLConvertOptions;
    FPairs: TKLConvertPairs;
    FPairsCapital: TKLConvertPairs;
    FPairsAltGr: TKLConvertPairs;
  protected
    procedure Register;
  protected
    function DetectDirection(constref AText: UTF8String): TKLConvertDirection;
    function GetName: String;
    function GetPairs: TKLConvertPairs;
  public
    function FindChar(constref AChar: UTF8String; const ADirection: TKLConvertDirection): UTF8String;
    function Convert(constref AText: UTF8String; const ADirection: TKLConvertDirection): UTF8String;
    function ShortClassName: String;
  public
    property Active: Boolean read FActive write FActive;
    property LayoutName: String read GetName;
    property ConvertOptions: TKLConvertOptions read FConvertOptions write FConvertOptions;
    property PossibleOptions: TKLConvertOptions read FPossibleOptions;
    property Pairs: TKLConvertPairs read GetPairs;
    property ScriptLeft: String read FScriptLeft;
    property ScriptRight: String read FScriptRight;
  end;

  TKLConvertCustomList = specialize TFPGObjectList<TKLConvert>;
  TKLConvertList = class(TKLConvertCustomList)
    function IndexByClassName(AClassName: String): Integer;
  end;

var
  ConvertList: TKLConvertList;

implementation

function TKLConvertList.IndexByClassName(AClassName: String): Integer;
var
  iIndex: Integer;

begin

  Result := -1;
  //AClassName := 'TKLConvert' + AClassName;

  for iIndex := 0 to FCount-1 do
  begin
    if Items[iIndex].ClassNameIs('TKLConvert' + AClassName) or Items[iIndex].ClassNameIs(AClassName) then
    begin
      Result := iIndex;
      Exit;
    end;
  end;

end;

procedure TKLConvert.Register;
begin

  if ConvertList.IndexOf(Self) = -1 then
    ConvertList.Add(Self);

end;

function TKLConvert.ShortClassName: String;
begin

  Result := Self.ClassName.Remove(0, 10);

end;

function TKLConvert.DetectDirection(constref AText: UTF8String): TKLConvertDirection;
var
  LPairs: TKLConvertPairs;
  iCharIndex, iCharPairIndex: Integer;
  sChar: UTF8String;
  iCharLeftCount, iCharRightCount: Integer;
begin

  LPairs := GetPairs;

  iCharLeftCount := 0;
  iCharRightCount := 0;

  for iCharIndex := 1 to UTF8Length(AText) do
  begin
    sChar := LazUTF8.UTF8Copy(AText, iCharIndex, 1);
    for iCharPairIndex := 0 to Length(LPairs)-1 do
    begin
      if sChar = LPairs[iCharPairIndex][0] then
        Inc(iCharLeftCount);
      if sChar = LPairs[iCharPairIndex][1] then
        Inc(iCharRightCount);
    end;
  end;

  if iCharRightCount > iCharLeftCount then
    Result := cdLeft
  else if iCharLeftCount > iCharRightCount then
    Result := cdRight
  else
    Result := cdBoth;

end;

function TKLConvert.GetName: String;
begin

  Result := Format('%s - %s', [FScriptLeft, FScriptRight]);

end;

function TKLConvert.GetPairs: TKLConvertPairs;
begin

  Result := FPairs;

  if (coCapitalSymbols in FPossibleOptions) and (coCapitalSymbols in FConvertOptions) then
    Result := Result + FPairsCapital;

  if (coAltGrSymbols in FPossibleOptions) and (coAltGrSymbols in FConvertOptions) then
    Result := Result + FPairsAltGr;

end;

function TKLConvert.FindChar(constref AChar: UTF8String; const ADirection: TKLConvertDirection): UTF8String;
var
  LPairs: TKLConvertPairs;
  iCharIndex: Integer;
begin

  Result := AChar;
  LPairs := GetPairs;

  for iCharIndex := 0 to Length(LPairs)-1 do
  begin

    if ADirection = cdRight then
    begin
      if AChar = LPairs[iCharIndex][0] then
      begin
        Result := LPairs[iCharIndex][1];
        Exit;
      end;
    end;

    if ADirection = cdLeft then
    begin
      if AChar = LPairs[iCharIndex][1] then
      begin
        Result := LPairs[iCharIndex][0];
        Exit;
      end;
    end;

  end;

end;

function TKLConvert.Convert(constref AText: UTF8String; const ADirection: TKLConvertDirection): UTF8String;
var
  iCharIndex: Integer;
  iCharLength: Integer;
  sChar, sFoundChar, sNewChar: UTF8String;
  sNewString: UTF8String;
  LPrimaryDirectionOrder, LSecondaryDirectionOrder: TKLConvertDirection;
begin

  LPrimaryDirectionOrder := ADirection;

  if LPrimaryDirectionOrder = cdBoth then
    LPrimaryDirectionOrder := DetectDirection(AText);

  if LPrimaryDirectionOrder = cdBoth then
    LPrimaryDirectionOrder := cdRight; 

  if LPrimaryDirectionOrder = cdLeft then
    LSecondaryDirectionOrder := cdRight
  else
    LSecondaryDirectionOrder := cdLeft;

  sNewString := UTF8String('');
  for iCharIndex := 1 to UTF8Length(AText) do
  begin

    sChar := LazUTF8.UTF8Copy(AText, iCharIndex, 1);
    sNewChar := sChar;

    if (ADirection = LSecondaryDirectionOrder) or (ADirection = cdBoth) then
    begin
      sFoundChar := FindChar(sChar, LSecondaryDirectionOrder);
      if sFoundChar <> sChar then
        sNewChar := sFoundChar;

    end;
    if (ADirection = LPrimaryDirectionOrder) or (ADirection = cdBoth) then
    begin
      sFoundChar := FindChar(sChar, LPrimaryDirectionOrder);
      if sFoundChar <> sChar then
        sNewChar := sFoundChar;
    end;

    sNewString := sNewString + sNewChar;

  end;

  Result := sNewString;

end;

initialization

  ConvertList := TKLConvertList.Create;

finalization;

  ConvertList.Free;

end.


