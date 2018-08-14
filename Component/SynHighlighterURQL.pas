unit SynHighlighterURQL;

interface

uses
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
  SynUnicode,
  SysUtils,
  Classes;

type
  TTokenKind = (tkComment, tkIdentifier, tkKeyWord, tkString, tkNumber, tkSpace, tkLabel, tkSymbol, tkOverLine, tkDecoratorType, tkSpecialVar,
    tkUnknown);
  TRangeKind = (rkNull, rkGeneral, rkPlnText, rkString, rkSub, rkMultilineComment);

type
  TSynURQLSyn = class(TSynCustomHighlighter)
  private
    f_CurToken: TTokenKind;
    f_CommentAttr: TSynHighlighterAttributes;
    f_OverlineAttr: TSynHighlighterAttributes;
    f_CurRange: TRangeKind;
    f_NumberAttr: TSynHighlighterAttributes;
    f_DefaultAttr: TSynHighlighterAttributes;
    f_InDecoradd: Boolean;
    f_ThenCount: Integer;
    f_LabelAttr: TSynHighlighterAttributes;
    f_SymbolAttr: TSynHighlighterAttributes;
    f_KeyWordAttr: TSynHighlighterAttributes;
    f_StringAttr: TSynHighlighterAttributes;
    f_PlnTextAttr: TSynHighlighterAttributes;
    f_RangeToSet: TRangeKind;
    f_SubLevel: Integer;
    f_RangeBeforeSub: TRangeKind;
    f_RangeBeforeMLC: TRangeKind;
    f_SpecialAttr: TSynHighlighterAttributes;
    f_StringComma: WideChar;
    f_SubLevel1Attr: TSynHighlighterAttributes;
    f_SubLevel3Attr: TSynHighlighterAttributes;
    f_SubLevel2Attr: TSynHighlighterAttributes;
    function IsLabelChar(aChar: WideChar): Boolean;
    procedure NewCodeLineStarted;
    procedure TP_Ampersand;
    procedure TP_Comma(aChar: WideChar);
    procedure TP_LineComment;
    procedure TP_Ident;
    procedure TP_Label;
    procedure TP_Minus;
    procedure TP_MultilineComment;
    procedure TP_Number;
    procedure TP_Slash;
    procedure TP_Space;
    procedure TP_SubEnd;
    procedure TP_SubStart;
    procedure TP_Symbol;
    procedure TP_Unknown;
  protected
    function IsCurrentTokenStartsWith(const aPrefix: Unicodestring): Boolean;
    function IsCurrentTokenEndsWith(const aSuffix: Unicodestring): Boolean;
    function IsRndVar: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    function GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    class function GetFriendlyLanguageName: Unicodestring; override;
    class function GetLanguageName: string; override;
    function GetRange: Pointer; override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: Integer; override;
    function IsIdentChar(aChar: WideChar): Boolean; override;
    procedure Next; override;
    procedure ResetRange; override;
    procedure SetRange(Value: Pointer); override;
  published
    property CommentAttr: TSynHighlighterAttributes read f_CommentAttr write f_CommentAttr;
    property OverlineAttr: TSynHighlighterAttributes read f_OverlineAttr write f_OverlineAttr;
    property NumberAttr: TSynHighlighterAttributes read f_NumberAttr write f_NumberAttr;
    property DefaultAttr: TSynHighlighterAttributes read f_DefaultAttr write f_DefaultAttr;
    property LabelAttr: TSynHighlighterAttributes read f_LabelAttr write f_LabelAttr;
    property SymbolAttr: TSynHighlighterAttributes read f_SymbolAttr write f_SymbolAttr;
    property KeyWordAttr: TSynHighlighterAttributes read f_KeyWordAttr write f_KeyWordAttr;
    property StringAttr: TSynHighlighterAttributes read f_StringAttr write f_StringAttr;
    property PlnTextAttr: TSynHighlighterAttributes read f_PlnTextAttr write f_PlnTextAttr;
    property SpecialAttr: TSynHighlighterAttributes read f_SpecialAttr write f_SpecialAttr;
    property SubLevel1Attr: TSynHighlighterAttributes read f_SubLevel1Attr write f_SubLevel1Attr;
    property SubLevel2Attr: TSynHighlighterAttributes read f_SubLevel2Attr write f_SubLevel2Attr;
    property SubLevel3Attr: TSynHighlighterAttributes read f_SubLevel3Attr write f_SubLevel3Attr;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SynEdit Highlighters', [TSynURQLSyn]);
end;

const
  cURQFilter = 'URQ Quest File (*.qst)|*.qst';

  cAttrName_Default = 'default';
  cAttrName_Comment = 'comments';
  cAttrName_Label = 'label';
  cAttrName_Symbol = 'symbol';
  cAttrName_Number = 'number';
  cAttrName_Keyword = 'keyword';
  cAttrName_Special = 'special';
  cAttrName_PlnText = 'textout';
  cAttrName_String = 'string';
  cAttrName_Overline = 'overline';
  cAttrName_SubLevel1 = 'substitute1';
  cAttrName_SubLevel2 = 'substitute2';
  cAttrName_SubLevel3 = 'substitute3';

  cAttrFName_Default = 'Текст по умолчанию';
  cAttrFName_Comment = 'Комментарии';
  cAttrFName_Label = 'Метка';
  cAttrFName_Symbol = 'Символ';
  cAttrFName_Number = 'Число';
  cAttrFName_Keyword = 'Ключевое слово';
  cAttrFName_Special = 'Особые переменные и значения';
  cAttrFName_PlnText = 'Выводимый текст';
  cAttrFName_String = 'Строка';
  cAttrFName_Overline = 'Перенос';
  cAttrFName_SubLevel1 = 'Подстановка первого уровня';
  cAttrFName_SubLevel2 = 'Подстановка второго уровня';
  cAttrFName_SubLevel3 = 'Подстановка третьего уровня';

const
  cNumOfKeywords = 35;
  cKeyWords: array [1 .. cNumOfKeywords] of Unicodestring = ('p', 'pln', 'cls', 'clsb', 'clst', 'clsl', 'if', 'then', 'else', 'and', 'or', 'not',
    'inv', 'invkill', 'goto', 'proc', 'pause', 'input', 'anykey', 'btn', 'image', 'music', 'fademusic', 'play', 'voice', 'save', 'tokens', 'end',
    'decoradd', 'decordel', 'decormov', 'decorcor', 'decorrot', 'decorscl', 'decorscr');

  cDecorTypeCount = 8;
  cDecorTypes: array [1 .. cDecorTypeCount] of Unicodestring = ('text', 'rect', 'image', 'animation', 'gif', 'textbutton', 'imgbutton', 'clickarea');

  cSpecialVarsCount = 51;
  cSpecialVars: array [1 .. cSpecialVarsCount] of Unicodestring = ('textcolor', 'gametitle', 'time', 'fp_prec', 'last_btn_caption', 'is_syskey',
    'hide_pause_indicator', 'hide_anykey_indicator', 'hide_more_indicator', 'current_loc', 'mousecursor', 'style_dos_textcolor', 'textalign',
    'music_looped', 'textfont', 'textcolor', 'echocolor', 'linkcolor', 'linkhcolor', 'music_volume', 'voice_volume', 'textpane_left', 'textpane_top',
    'textpane_width', 'textpane_height', 'mouse_x', 'mouse_y', 'fp_filename', 'hide_save_echo', 'hide_btn_echo', 'hide_inv_echo', 'hide_link_echo',
    'hide_local_echo', 'menu_textfont', 'menu_bgcolor', 'menu_bordercolor', 'menu_textcolor', 'menu_hindent', 'menu_vindent', 'menu_selectioncolor',
    'menu_seltextcolor', 'menu_disabledcolor', 'btnalign', 'btntxtalign', 'linespacing', 'paraspacing', 'numbuttons', 'bmenualign', 'lmenualign',
    'fullscreen', 'savenamebase');

  cSpecialVarPrefixesCount = 4;
  cSpecialVarPrefixes: array [1 .. cSpecialVarPrefixesCount] of Unicodestring = ('count_', 'idisp_', 'inv_', 'gss_');

  cDecorVarSuffixesCount = 24;
  cDecorVarSuffixes: array [1 .. cDecorVarSuffixesCount] of Unicodestring = ('_color', '_hide', '_script', '_text', '_width', '_height', '_align',
    '_linespacing', '_paraspacing', '_linkcolor', '_linkhcolor', '_hotx', '_hoty', '_angle', '_rotspeed', '_scale', '_frame', '_anispeed', '_anitype',
    '_target', '_enabled', '_menualign', '_flipx', '_flipy');

  cPlnIdx = [1, 2];
  cDecorAddIdx = 29;
  cThenIdx = 8;
  cElseIdx = 9;

constructor TSynURQLSyn.Create(AOwner: TComponent);
begin
  inherited;
  fCaseSensitive := False;
  f_CommentAttr := TSynHighlighterAttributes.Create(cAttrName_Comment, cAttrFName_Comment);
  f_CommentAttr.Foreground := clTeal;
  AddAttribute(f_CommentAttr);
  f_LabelAttr := TSynHighlighterAttributes.Create(cAttrName_Label, cAttrFName_Label);
  f_LabelAttr.Foreground := clFuchsia;
  AddAttribute(f_LabelAttr);
  f_SymbolAttr := TSynHighlighterAttributes.Create(cAttrName_Symbol, cAttrFName_Symbol);
  f_SymbolAttr.Foreground := clWhite;
  AddAttribute(f_SymbolAttr);
  f_DefaultAttr := TSynHighlighterAttributes.Create(cAttrName_Default, cAttrFName_Default);
  f_DefaultAttr.Foreground := clSilver;
  AddAttribute(f_DefaultAttr);
  f_NumberAttr := TSynHighlighterAttributes.Create(cAttrName_Number, cAttrFName_Number);
  f_NumberAttr.Foreground := clLime;
  AddAttribute(f_NumberAttr);
  f_KeyWordAttr := TSynHighlighterAttributes.Create(cAttrName_Keyword, cAttrFName_Keyword);
  f_KeyWordAttr.Foreground := clYellow;
  AddAttribute(f_KeyWordAttr);
  f_PlnTextAttr := TSynHighlighterAttributes.Create(cAttrName_PlnText, cAttrFName_PlnText);
  f_PlnTextAttr.Foreground := $EDDCBC;
  AddAttribute(f_PlnTextAttr);
  f_StringAttr := TSynHighlighterAttributes.Create(cAttrName_String, cAttrFName_String);
  f_StringAttr.Foreground := clAqua;
  AddAttribute(f_StringAttr);
  f_OverlineAttr := TSynHighlighterAttributes.Create(cAttrName_Overline, cAttrFName_Overline);
  f_OverlineAttr.Foreground := $75BEFF; // clBlue;
  AddAttribute(f_OverlineAttr);
  f_SpecialAttr := TSynHighlighterAttributes.Create(cAttrName_Special, cAttrFName_Special);
  f_SpecialAttr.Foreground := $4EBFFF;
  AddAttribute(f_SpecialAttr);
  f_SubLevel1Attr := TSynHighlighterAttributes.Create(cAttrName_SubLevel1, cAttrFName_SubLevel1);
  f_SubLevel1Attr.Foreground := $AAAAFF;
  AddAttribute(f_SubLevel1Attr);
  f_SubLevel2Attr := TSynHighlighterAttributes.Create(cAttrName_SubLevel2, cAttrFName_SubLevel2);
  f_SubLevel2Attr.Foreground := $8277FB;
  AddAttribute(f_SubLevel2Attr);
  f_SubLevel3Attr := TSynHighlighterAttributes.Create(cAttrName_SubLevel3, cAttrFName_SubLevel3);
  f_SubLevel3Attr.Foreground := clRed;
  AddAttribute(f_SubLevel3Attr);
  fDefaultFilter := cURQFilter;
end;

function TSynURQLSyn.GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT:
      Result := f_CommentAttr;
    // SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    // SYN_ATTR_KEYWORD: Result := fKeyAttri;
    // SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
  else
    Result := nil;
  end;
end;

function TSynURQLSyn.GetEol: Boolean;
begin
  Result := Run = fLineLen + 1;
end;

class function TSynURQLSyn.GetFriendlyLanguageName: Unicodestring;
begin
  Result := 'URQ Quest';
end;

class function TSynURQLSyn.GetLanguageName: string;
begin
  Result := 'URQ';
end;

function TSynURQLSyn.GetRange: Pointer;
begin
  Result := Pointer(f_CurRange);
end;

function TSynURQLSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  Result := f_DefaultAttr;
  if f_CurToken = tkComment then
    Result := f_CommentAttr
  else
  begin
    if f_CurToken = tkOverLine then
      Result := f_OverlineAttr
    else if f_CurRange = rkGeneral then
      case f_CurToken of
        tkLabel:
          Result := f_LabelAttr;
        tkSymbol:
          Result := f_SymbolAttr;
        tkNumber:
          Result := f_NumberAttr;
        tkIdentifier:
          Result := f_DefaultAttr;
        tkKeyWord:
          Result := f_KeyWordAttr;
        tkDecoratorType:
          Result := f_SpecialAttr;
        tkSpecialVar:
          Result := f_SpecialAttr;
        tkUnknown:
          Result := f_DefaultAttr;
      else
        Result := nil;
      end
    else
    begin
      case f_CurRange of
        rkPlnText:
          Result := f_PlnTextAttr;
        rkString:
          Result := f_StringAttr;
        rkSub:
          case f_SubLevel of
            1:
              Result := f_SubLevel1Attr;
            2:
              Result := f_SubLevel2Attr;
          else
            Result := f_SubLevel3Attr;
          end;
        rkMultilineComment:
          Result := f_CommentAttr;
      end; // case
    end;
  end;
end;

function TSynURQLSyn.GetTokenKind: Integer;
begin
  Result := Ord(f_CurToken);
end;

function TSynURQLSyn.IsCurrentTokenStartsWith(const aPrefix: Unicodestring): Boolean;
var
  I: Integer;
  l_Temp: PWideChar;
begin
  if Length(aPrefix) < fStringLen then
  begin
    l_Temp := fToIdent;
    Result := True;
    for I := 1 to Length(aPrefix) do
    begin
      if l_Temp^ <> aPrefix[I] then
      begin
        Result := False;
        break;
      end;
      inc(l_Temp);
    end;
  end
  else
    Result := False;
end;

function TSynURQLSyn.IsCurrentTokenEndsWith(const aSuffix: Unicodestring): Boolean;
var
  I: Integer;
  l_Temp: PWideChar;
begin
  if Length(aSuffix) < fStringLen then
  begin
    l_Temp := fToIdent + fStringLen - 1;
    Result := True;
    for I := Length(aSuffix) downto 1 do
    begin
      if l_Temp^ <> aSuffix[I] then
      begin
        Result := False;
        break;
      end;
      Dec(l_Temp);
    end;
  end
  else
    Result := False;
end;

function TSynURQLSyn.IsIdentChar(aChar: WideChar): Boolean;
begin
  case aChar of
    '_', '0' .. '9', 'a' .. 'z', #1072 .. #1103:
      Result := True;
  else
    Result := False;
  end;
end;

function TSynURQLSyn.IsLabelChar(aChar: WideChar): Boolean;
begin
  case aChar of
    'a' .. 'z', '0' .. '9', #1072 .. #1103, '-', '.', '_':
      Result := True;
  else
    Result := False;
  end;
end;

function TSynURQLSyn.IsRndVar: Boolean;
var
  I: Integer;
  l_Temp: PWideChar;
begin
  Result := IsCurrentTokenStartsWith('rnd');
  if Result then
  begin
    l_Temp := fToIdent + 3;
    for I := 4 to fStringLen do
    begin
      case l_Temp^ of
        '0' .. '9':
          ;
      else
        begin
          Result := False;
          break;
        end;
      end;
      inc(l_Temp);
    end;
  end;
end;

procedure TSynURQLSyn.NewCodeLineStarted;
begin
  ResetRange;
  f_ThenCount := 0;
  f_SubLevel := 0;
  f_InDecoradd := False;
end;

procedure TSynURQLSyn.Next;
begin
  if (Run = 0) and (f_CurRange <> rkMultilineComment) then
  begin
    while (not IsLineEnd(Run)) and IsWhiteChar(fLine[Run]) do
      inc(Run);
    if fLine[Run] <> '_' then
      NewCodeLineStarted
    else
    begin
      f_CurToken := tkOverLine;
      inc(Run);
      inherited;
      Exit;
    end;
  end
  else if f_RangeToSet <> rkNull then
  begin
    if (f_CurRange <> rkMultilineComment) and (f_SubLevel > 0) then
    begin
      Dec(f_SubLevel);
      if f_SubLevel = 0 then
        f_CurRange := f_RangeToSet;
    end
    else
      f_CurRange := f_RangeToSet;
    f_RangeToSet := rkNull;
  end;
  fTokenPos := Run;
  if f_CurRange = rkMultilineComment then
    TP_MultilineComment
  else
    case fLine[Run] of
      ';':
        TP_LineComment;
      ':':
        TP_Label;
      #1 .. #9, #11, #12, #14 .. #32:
        TP_Space;
      '+', '=', ',', '<', '>', '*', '(', ')':
        TP_Symbol;
      '&':
        TP_Ampersand;
      '-':
        TP_Minus;
      '"', '''':
        TP_Comma(fLine[Run]);
      '0' .. '9':
        TP_Number;
      '#':
        TP_SubStart;
      '$':
        TP_SubEnd;
      '/':
        TP_Slash;
      '_', 'a' .. 'z', #1072 .. #1103:
        TP_Ident;
    else
      TP_Unknown;
    end; // case
  inherited;
end;

procedure TSynURQLSyn.ResetRange;
begin
  f_CurRange := rkGeneral;
  f_RangeToSet := rkNull;
end;

procedure TSynURQLSyn.SetRange(Value: Pointer);
begin
  f_CurRange := TRangeKind(Value);
end;

procedure TSynURQLSyn.TP_Ampersand;
begin
  f_CurToken := tkSymbol;
  inc(Run);
  f_CurRange := rkGeneral;
  f_InDecoradd := False;
end;

procedure TSynURQLSyn.TP_Comma(aChar: WideChar);
begin
  f_CurToken := tkSymbol;
  inc(Run);
  case f_CurRange of
    rkGeneral:
      begin
        f_CurRange := rkString;
        f_StringComma := aChar;
      end;
    rkString:
      if aChar = f_StringComma then
        f_RangeToSet := rkGeneral;
  end;
end;

procedure TSynURQLSyn.TP_LineComment;
begin
  f_CurToken := tkComment;
  repeat
    inc(Run);
  until IsLineEnd(Run);
end;

procedure TSynURQLSyn.TP_Ident;
var
  I: Integer;
  l_Start: Integer;
begin
  fToIdent := fLine + Run;
  l_Start := Run;
  repeat
    inc(Run);
  until IsLineEnd(Run) or (not IsIdentChar(fLine[Run]));
  fStringLen := Run - l_Start;
  f_CurToken := tkIdentifier;

  for I := 1 to cSpecialVarsCount do
    if IsCurrentToken(cSpecialVars[I]) then
    begin
      f_CurToken := tkSpecialVar;
      break;
    end;

  if (f_CurToken = tkIdentifier) then
  begin
    for I := 1 to cSpecialVarPrefixesCount do
      if IsCurrentTokenStartsWith(cSpecialVarPrefixes[I]) then
      begin
        f_CurToken := tkSpecialVar;
        break;
      end;
  end;

  if (f_CurToken = tkIdentifier) and IsCurrentTokenStartsWith('decor_') then
  begin
    for I := 1 to cDecorVarSuffixesCount do
      if IsCurrentTokenEndsWith(cDecorVarSuffixes[I]) then
      begin
        f_CurToken := tkSpecialVar;
        break;
      end;
  end;

  if (f_CurToken = tkIdentifier) and IsRndVar then
    f_CurToken := tkSpecialVar;

  if f_InDecoradd and (f_CurToken = tkIdentifier) then
  begin
    for I := 1 to cDecorTypeCount do
      if IsCurrentToken(cDecorTypes[I]) then
      begin
        f_CurToken := tkDecoratorType;
        break;
      end;
  end;

  if f_CurToken = tkIdentifier then
  begin
    for I := 1 to cNumOfKeywords do
      if IsCurrentToken(cKeyWords[I]) then
      begin
        f_CurToken := tkKeyWord;
        if (I in cPlnIdx) and (f_CurRange = rkGeneral) then
          f_RangeToSet := rkPlnText;
        if (I = cThenIdx) and (f_CurRange = rkGeneral) then
          inc(f_ThenCount);
        if (I = cElseIdx) and (f_ThenCount > 0) then
        begin
          Dec(f_ThenCount);
          if (f_CurRange = rkPlnText) then
            f_CurRange := rkGeneral;
        end;
        if (I = cDecorAddIdx) then
          f_InDecoradd := True;
        break;
      end;
  end;
end;

procedure TSynURQLSyn.TP_Label;
begin
  inc(Run);
  if Run = 1 then
  begin
    f_CurToken := tkLabel;
    while (not IsLineEnd(Run)) and IsLabelChar(fLine[Run]) do
      inc(Run);
  end
  else
    f_CurToken := tkSymbol;
end;

procedure TSynURQLSyn.TP_Minus;
begin
  f_CurToken := tkSymbol;
  inc(Run);
  case fLine[Run] of
    '0' .. '9':
      TP_Number;
  end;
end;

procedure TSynURQLSyn.TP_MultilineComment;
begin
  f_CurToken := tkComment;
  repeat
    if fLine[Run] = '*' then
    begin
      inc(Run);
      if fLine[Run] = '/' then
      begin
        f_RangeToSet := f_RangeBeforeMLC;
        inc(Run);
      end;
    end
    else
      inc(Run);
  until IsLineEnd(Run) or (f_RangeToSet <> rkNull);
end;

procedure TSynURQLSyn.TP_Number;
var
  l_FirstZero: Integer;
  l_IsHex: Boolean;

  function IsNumberChar: Boolean;
  begin
    case fLine[Run] of
      '0' .. '9':
        Result := True;
      '.':
        Result := not l_IsHex;
      'a' .. 'f':
        Result := l_IsHex;
    else
      Result := False;
    end;
  end;

begin
  f_CurToken := tkNumber;
  if fLine[Run] = '0' then
    l_FirstZero := Run
  else
    l_FirstZero := -1;
  l_IsHex := False;
  repeat
    inc(Run);
    if (not IsLineEnd(Run)) and (fLine[Run] = 'x') and (Run = l_FirstZero + 1) then
    begin
      l_IsHex := True;
      inc(Run);
    end;
  until (not IsNumberChar) or IsLineEnd(Run);
end;

procedure TSynURQLSyn.TP_Slash;
begin
  f_CurToken := tkSymbol;
  inc(Run);
  if fLine[Run] = '*' then
  begin
    inc(Run);
    f_RangeBeforeMLC := f_CurRange;
    f_CurRange := rkMultilineComment;
  end;
end;

procedure TSynURQLSyn.TP_Space;
begin
  f_CurToken := tkSpace;
  repeat
    inc(Run);
  until (fLine[Run] > #32) or IsLineEnd(Run);
end;

procedure TSynURQLSyn.TP_SubEnd;
begin
  if f_CurRange <> rkMultilineComment then
  begin
    f_CurToken := tkSymbol;
    inc(Run);
    if f_SubLevel > 0 then
      f_RangeToSet := f_RangeBeforeSub;
  end
  else
  begin
    inc(Run);
    f_CurToken := tkSymbol;
  end;
end;

procedure TSynURQLSyn.TP_SubStart;
begin
  if f_CurRange <> rkMultilineComment then
  begin
    inc(f_SubLevel);
    if f_SubLevel = 1 then
      f_RangeBeforeSub := f_CurRange;
    f_CurToken := tkSymbol;
    inc(Run);
    f_CurRange := rkSub;
  end
  else
  begin
    inc(Run);
    f_CurToken := tkSymbol;
  end;
end;

procedure TSynURQLSyn.TP_Symbol;
begin
  inc(Run);
  f_CurToken := tkSymbol;
end;

procedure TSynURQLSyn.TP_Unknown;
begin
  inc(Run);
  f_CurToken := tkUnknown;
end;

end.
