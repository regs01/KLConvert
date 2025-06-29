(* TIniFileEx alternatively licensed under MIT *)
unit UnitIniFileEx;

{$mode ObjFPC}{$H+}
{$ModeSwitch ImplicitFunctionSpecialization+}

interface

uses
  Classes, SysUtils, IniFiles, TypInfo;

type
  TIniFileEx = class(TIniFile)
  protected
    generic function IsEnum<TEnum>(const {%H-}AEnumItem: TEnum): Boolean;
    generic function IsSet<TSet>(const {%H-}ASet: TSet): Boolean;
    generic function EnumToString<TEnum>(const AEnumItem: TEnum; const APrefix: String = ''): String;
    generic function SetToString<TEnum, TSet>(const ASet: TSet; const APrefix: String = ''): String;
    generic function StringToEnum<TEnum>(const AEnumName: String; out AEnumItem: TEnum; const APrefix: String = ''): Boolean;
    generic function StringToSet<TEnum, TSet>(const ASetString: String; out ASet: TSet; const APrefix: String = ''): Boolean;
  public
    generic function ReadEnum<TEnum>(const ASection, AIdent: String; const ADefaultValue: TEnum; const APrefix: String): TEnum;
    generic function ReadSet<TEnum, TSet>(const ASection, AIdent: String; const ADefaultValue: TSet; const APrefix: String): TSet;
    function ReadRect(const ASection, AIdent: String; const ADefaultValue: TRect): TRect;
    generic procedure WriteEnum<TEnum>(const ASection, AIdent: String; const AValue: TEnum; const APrefix: String);
    generic procedure WriteSet<TEnum, TSet>(const ASection, AIdent: String; const AValue: TSet; const APrefix: String);
    procedure WriteRect(const ASection, AIdent: String; const AValue: TRect);
  end;

implementation

generic function TIniFileEx.IsEnum<TEnum>(const AEnumItem: TEnum): Boolean;
var
  pLTypeInfo: PTypeInfo;
begin

  Result := False;

  pLTypeInfo := TypeInfo(TEnum);
  if pLTypeInfo^.Kind = tkEnumeration then
    Result := True;

end;

generic function TIniFileEx.IsSet<TSet>(const ASet: TSet): Boolean;
var
  pLTypeInfo: PTypeInfo;
begin

  Result := False;

  pLTypeInfo := TypeInfo(TSet);
  if pLTypeInfo^.Kind = tkSet then
    Result := True;

end;

generic function TIniFileEx.EnumToString<TEnum>(const AEnumItem: TEnum; const APrefix: String = ''): String;
var
  iEnumIndex: Integer;
  LEnumItem: TEnum;
  sEnumName: String;
  arPrefix: TAnsiCharArray;
begin

  Result := '';

  for iEnumIndex:= Ord(Low(TEnum)) to Ord(High(TEnum)) do
  begin
    LEnumItem := TEnum(iEnumIndex);
    if LEnumItem = AEnumItem then
    begin
      arPrefix := TAnsiCharArray(APrefix);
      sEnumName := GetEnumName(TypeInfo(TEnum), iEnumIndex);
      Result := sEnumName.TrimLeft(arPrefix);
      Exit;
    end;
  end;

end;

generic function TIniFileEx.SetToString<TEnum, TSet>(const ASet: TSet; const APrefix: String = ''): String;
var
  iEnumIndex: Integer;
  LEnumItem: TEnum;
  sEnumName: String;
  arPrefix: TAnsiCharArray;
begin

  Result := '';

  for iEnumIndex:= Ord(Low(TEnum)) to Ord(High(TEnum)) do
  begin
    LEnumItem := TEnum(iEnumIndex);
    if LEnumItem in TSet(ASet) then
    begin
      arPrefix := TAnsiCharArray(APrefix);
      sEnumName := GetEnumName(TypeInfo(TEnum), iEnumIndex);
      sEnumName := sEnumName.TrimLeft(arPrefix);
      if Result = '' then
        Result := sEnumName
      else
        Result := String.Join(', ', [Result,   sEnumName]);
    end;
  end;

end;

generic function TIniFileEx.StringToEnum<TEnum>(const AEnumName: String; out AEnumItem: TEnum; const APrefix: String = ''): Boolean;
var
  iEnumIndex: Integer;
  pLTypeInfo: PTypeInfo;
begin

  Result := False;

  pLTypeInfo := TypeInfo(TEnum);
  iEnumIndex := GetEnumValue(pLTypeInfo, APrefix+AEnumName);

  if iEnumIndex > -1 then
  begin
    AEnumItem := TEnum(iEnumIndex);
    Result := True;
  end;

end;

generic function TIniFileEx.StringToSet<TEnum, TSet>(const ASetString: String; out ASet: TSet; const APrefix: String = ''): Boolean;
var
  arEnumItems: array of String;
  sEnumName: String;
  LEnumItem: TEnum;
begin

  Result := False;
  ASet := [];

  arEnumItems := Trim(ASetString).Split([','], TStringSplitOptions.ExcludeEmpty);
  if Length(arEnumItems) = 0 then
    Exit(True);

  for sEnumName in arEnumItems do
  begin
    if (specialize StringToEnum<TEnum>(sEnumName.Trim, LEnumItem, APrefix)) then
    begin
      ASet := ASet + [LEnumItem];
      Result := True;
    end;
  end;

end;

generic function TIniFileEx.ReadEnum<TEnum>(const ASection, AIdent: String; const ADefaultValue: TEnum; const APrefix: String {= ''}): TEnum;
var
  sDefaultValue, sValue: String;
  LValue: TEnum;
begin

  Result := ADefaultValue;

  if not IsEnum(ADefaultValue) then
    Exit;

  sDefaultValue := Self.EnumToString(ADefaultValue, APrefix);
  sValue := Self.ReadString(ASection, AIdent, sDefaultValue);

  if (specialize StringToEnum<TEnum>(sValue, LValue, APrefix)) then
    Result := LValue;

end;

generic function TIniFileEx.ReadSet<TEnum, TSet>(const ASection, AIdent: String; const ADefaultValue: TSet; const APrefix: String {= ''}): TSet;
var
  sDefaultValue, sValue: String;
  LValue: TSet;
begin

  Result := ADefaultValue;

  if not IsSet(ADefaultValue) then
    Exit;

  sDefaultValue := Self.specialize SetToString<TEnum, TSet>(ADefaultValue, APrefix);
  sValue := Self.ReadString(ASection, AIdent, sDefaultValue);

  if (Self.specialize StringToSet<TEnum, TSet>(sValue, LValue, APrefix)) then
    Result := LValue;

end;

function TIniFileEx.ReadRect(const ASection, AIdent: String; const ADefaultValue: TRect): TRect;
var
  sValue: String;
  arNumbers: array of String;
  iLeft, iTop, iRight, iBottom: Integer;
begin

  Result := ADefaultValue;

  sValue := Self.ReadString(ASection, AIdent, '');
  if (Trim(sValue) = '') then
    Exit;

  arNumbers := Trim(sValue).Split([','], TStringSplitOptions.ExcludeEmpty);
  if Length(arNumbers) <> 4 then
    Exit;

  if not TryStrToInt(arNumbers[0], iLeft) then
    Exit;
  if not TryStrToInt(arNumbers[1], iTop) then
    Exit;
  if not TryStrToInt(arNumbers[2], iRight) then
    Exit;
  if not TryStrToInt(arNumbers[3], iBottom) then
    Exit;

  Result := Rect(iLeft, iTop, iRight, iBottom); // todo: check bounds

end;

generic procedure TIniFileEx.WriteEnum<TEnum>(const ASection, AIdent: String; const AValue: TEnum; const APrefix: String {= ''});
var
  sValue: String;
begin

  if not IsEnum(AValue) then
    Exit;

  sValue := Self.EnumToString(AValue, APrefix);
  Self.WriteString(ASection, AIdent, sValue);

end;

generic procedure TIniFileEx.WriteSet<TEnum, TSet>(const ASection, AIdent: String; const AValue: TSet; const APrefix: String {= ''});
var
  sValue: String;
begin

  if not IsSet(AValue) then
    Exit;

  sValue := Self.specialize SetToString<TEnum, TSet>(AValue, APrefix);
  Self.WriteString(ASection, AIdent, sValue);

end;


procedure TIniFileEx.WriteRect(const ASection, AIdent: String; const AValue: TRect);
var
  sValue: String;
begin

  sValue := '';

  with AValue do
    sValue := Format('%d, %d, %d, %d', [Left, Top, Right, Bottom]);

  Self.WriteString(ASection, AIdent, sValue);

end;

end.

