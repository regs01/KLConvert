unit UnitConvertBulgarianEnglish;

{$mode ObjFPC}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, LazUTF8, UnitKLCType, UnitConvert;

type
  TKLConvertBulgarianEnglish = class(TKLConvert)
  protected
  public
    constructor Create;
  end;

implementation

constructor TKLConvertBulgarianEnglish.Create;
begin

  FScriptLeft := 'Cyrillic (Bulgarian)';
  FScriptRight := 'Roman (English)';

  FPossibleOptions := [coCapitalSymbols];

  FPairsAltGr := [];

  FPairs := [

    ['(', '`'],
    ['-', '-'],
    ['.', '='],
    [',', 'q'],
    ['у', 'w'],
    ['е', 'e'],
    ['и', 'r'],
    ['ш', 't'],
    ['щ', 'y'],
    ['к', 'u'],
    ['с', 'i'],
    ['д', 'o'],
    ['з', 'p'],
    ['ц', '['],
    [';', ']'],
    ['„', '\'],
    ['ь', 'a'],
    ['я', 's'],
    ['а', 'd'],
    ['о', 'f'],
    ['ж', 'g'],
    ['г', 'h'],
    ['т', 'j'],
    ['н', 'k'],
    ['в', 'l'],
    ['м', ';'],
    ['ч', ''''],
    ['ю', 'z'],
    ['й', 'x'],
    ['ъ', 'c'],
    ['э', 'v'],
    ['ф', 'b'],
    ['х', 'n'],
    ['п', 'm'],
    ['р', ','],
    ['л', '.'],
    ['б', '/'],
    ['ѝ', '\'], // ISO

    [')', '~'],
    ['!', '!'],
    ['?', '@'],
    ['+', '#'],
    ['"', '$'],
    ['%', '%'],
    ['=', '^'],
    [':', '&'],
    ['/', '*'],
    ['–', '('],
    ['№', ')'],
    ['$', '_'],
    ['€', '+'],
    ['ы', 'Q'],
    ['У', 'W'],
    ['Е', 'E'],
    ['И', 'R'],
    ['Ш', 'T'],
    ['Щ', 'Y'],
    ['К', 'U'],
    ['С', 'I'],
    ['Д', 'O'],
    ['З', 'P'],
    ['Ц', '{'],
    ['§', '}'],
    ['“', '|'],
    ['ѝ', 'A'],
    ['Я', 'S'],
    ['А', 'D'],
    ['О', 'F'],
    ['Ж', 'G'],
    ['Г', 'H'],
    ['Т', 'J'],
    ['Н', 'K'],
    ['В', 'L'],
    ['М', ':'],
    ['Ч', '"'],
    ['Ю', 'Z'],
    ['Й', 'X'],
    ['Ъ', 'C'],
    ['Э', 'V'],
    ['Ф', 'B'],
    ['Х', 'N'],
    ['П', 'M'],
    ['Р', '<'],
    ['Л', '>'],
    ['Б', '?'],
    ['Ѝ', '|'] //ISO

  ];

  FPairsCapital := [
    [',', 'q'],
    ['Ь', 'a'],
    ['Ѝ', 'A']
  ];


end;

end.
