unit UnitConvertTatarEnglish;

{$mode ObjFPC}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, LazUTF8, UnitKLCType, UnitConvert;

type
  TKLConvertTatarEnglish = class(TKLConvert)
  protected
  public
    constructor Create;
  end;

implementation

constructor TKLConvertTatarEnglish.Create;
begin

  FScriptLeft := 'Cyrillic (Tatar)';
  FScriptRight := 'Roman (English)';

  FPossibleOptions := [coAltGrSymbols];

  FPairsCapital := [];

  FPairs := [

    ['һ', '`'],
    ['-', '-'],
    ['=', '='],
    ['й', 'q'],
    ['ө', 'w'],
    ['у', 'e'],
    ['к', 'r'],
    ['е', 't'],
    ['н', 'y'],
    ['г', 'u'],
    ['ш', 'i'],
    ['ә', 'o'],
    ['з', 'p'],
    ['х', '['],
    ['ү', ']'],
    ['\', '\'],
    ['ф', 'a'],
    ['ы', 's'],
    ['в', 'd'],
    ['а', 'f'],
    ['п', 'g'],
    ['р', 'h'],
    ['о', 'j'],
    ['л', 'k'],
    ['д', 'l'],
    ['ң', ';'],
    ['э', ''''],
    ['я', 'z'],
    ['ч', 'x'],
    ['с', 'c'],
    ['м', 'v'],
    ['и', 'b'],
    ['т', 'n'],
    ['җ', 'm'],
    ['б', ','],
    ['ю', '.'],
    ['.', '/'],

    ['Һ', '~'],
    ['!', '!'],
    ['"', '@'],
    ['№', '#'],
    [';', '$'],
    ['%', '%'],
    [':', '^'],
    ['?', '&'],
    ['*', '*'],
    ['(', '('],
    [')', ')'],
    ['_', '_'],
    ['+', '+'],
    ['Й', 'Q'],
    ['Ө', 'W'],
    ['У', 'E'],
    ['К', 'R'],
    ['Е', 'T'],
    ['Н', 'Y'],
    ['Г', 'U'],
    ['Ш', 'I'],
    ['Ә', 'O'],
    ['З', 'P'],
    ['Х', '{'],
    ['Ү', '}'],
    ['/', '|'],
    ['Ф', 'A'],
    ['Ы', 'S'],
    ['В', 'D'],
    ['А', 'F'],
    ['П', 'G'],
    ['Р', 'H'],
    ['О', 'J'],
    ['Л', 'K'],
    ['Д', 'L'],
    ['Ң', ':'],
    ['Э', '"'],
    ['Я', 'Z'],
    ['Ч', 'X'],
    ['С', 'C'],
    ['М', 'V'],
    ['И', 'B'],
    ['Т', 'N'],
    ['Җ', 'M'],
    ['Б', '<'],
    ['Ю', '>'],
    [',', '?']

  ];

  FPairsAltGr := [
    ['ё', '`'],
    ['ц', 'w'],
    ['щ', 'o'],
    ['ъ', ']'],
    ['ж', ';'],
    ['ь', 'm']
  ];


end;

end.
