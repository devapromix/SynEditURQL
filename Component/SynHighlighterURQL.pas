{ -------------------------------------------------------------------------------
  The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in compliance
  with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
  the specific language governing rights and limitations under the License.

  Code template generated with SynGen.
  The original code is: D:\dev\github-synedit-urql-git\Component\SynHighlighterURQL.pas, released 2018-07-26.
  Description: Syntax Parser/Highlighter
  The initial author of this file is Apromix.
  Copyright (c) 2018, all rights reserved.

  Contributors to the SynEdit and mwEdit projects are listed in the
  Contributors.txt file.

  Alternatively, the contents of this file may be used under the terms of the
  GNU General Public License Version 2 or later (the "GPL"), in which case
  the provisions of the GPL are applicable instead of those above.
  If you wish to allow use of your version of this file only under the terms
  of the GPL and not to allow others to use your version of this file
  under the MPL, indicate your decision by deleting the provisions above and
  replace them with the notice and other provisions required by the GPL.
  If you do not delete the provisions above, a recipient may use your version
  of this file under either the MPL or the GPL.

  $Id: $

  You may retrieve the latest version of this file at the SynEdit home page,
  located at http://SynEdit.SourceForge.net

  ------------------------------------------------------------------------------- }

{$IFNDEF QSYNHIGHLIGHTERURQL}
unit SynHighlighterURQL;
{$ENDIF}
{$I SynEdit.inc}

interface

uses
{$IFDEF SYN_CLX}
  QGraphics,
  QSynEditTypes,
  QSynEditHighlighter,
  QSynUnicode,
{$ELSE}
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
  SynUnicode,
{$ENDIF}
  SysUtils,
  Classes;

type
  TtkTokenKind = (tkComment, tkIdentifier, tkKey, tkNull, tkSpace, tkString,
    tkTest, tkUnknown);

  TRangeState = (rsUnKnown, rsBeginLocation, rsLineComment, rsMultiLineComment,
    rsString);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function(Index: Integer): TtkTokenKind of object;

type
  TSynURQLSyn = class(TSynCustomHighlighter)
  private
    fRange: TRangeState;
    fTokenID: TtkTokenKind;
    fIdentFuncTable: array [0 .. 30] of TIdentFuncTableFunc;
    fCommentAttri: TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    fTestAttri: TSynHighlighterAttributes;
    function HashKey(Str: PWideChar): Cardinal;
    function FuncAnd(Index: Integer): TtkTokenKind;
    function FuncBtn(Index: Integer): TtkTokenKind;
    function FuncCls(Index: Integer): TtkTokenKind;
    function FuncClsb(Index: Integer): TtkTokenKind;
    function FuncElse(Index: Integer): TtkTokenKind;
    function FuncEnd(Index: Integer): TtkTokenKind;
    function FuncGoto(Index: Integer): TtkTokenKind;
    function FuncIf(Index: Integer): TtkTokenKind;
    function FuncInclude(Index: Integer): TtkTokenKind;
    function FuncInput(Index: Integer): TtkTokenKind;
    function FuncInstr(Index: Integer): TtkTokenKind;
    function FuncInv(Index: Integer): TtkTokenKind;
    function FuncInvkill(Index: Integer): TtkTokenKind;
    function FuncMusic(Index: Integer): TtkTokenKind;
    function FuncNot(Index: Integer): TtkTokenKind;
    function FuncOr(Index: Integer): TtkTokenKind;
    function FuncP(Index: Integer): TtkTokenKind;
    function FuncPause(Index: Integer): TtkTokenKind;
    function FuncPerkill(Index: Integer): TtkTokenKind;
    function FuncPln(Index: Integer): TtkTokenKind;
    function FuncProc(Index: Integer): TtkTokenKind;
    function FuncQuit(Index: Integer): TtkTokenKind;
    function FuncThen(Index: Integer): TtkTokenKind;
    procedure IdentProc;
    procedure UnknownProc;
    function AltFunc(Index: Integer): TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PWideChar): TtkTokenKind;
    procedure NullProc;
    procedure SpaceProc;
    procedure CRProc;
    procedure LFProc;
    procedure BeginLocationOpenProc;
    procedure BeginLocationProc;
    procedure LineCommentOpenProc;
    procedure LineCommentProc;
    procedure MultiLineCommentOpenProc;
    procedure MultiLineCommentProc;
    procedure StringOpenProc;
    procedure StringProc;
  protected
    function GetSampleSource: UnicodeString; override;
    function IsFilterStored: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetFriendlyLanguageName: UnicodeString; override;
    class function GetLanguageName: string; override;
    function GetRange: Pointer; override;
    procedure ResetRange; override;
    procedure SetRange(Value: Pointer); override;
    function GetDefaultAttribute(Index: Integer)
      : TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    function GetKeyWords(TokenKind: Integer): UnicodeString; override;
    function GetTokenID: TtkTokenKind;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: Integer; override;
    function IsIdentChar(AChar: WideChar): Boolean; override;
    procedure Next; override;
  published
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri
      write fCommentAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri
      write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri
      write fSpaceAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri
      write fStringAttri;
    property TestAttri: TSynHighlighterAttributes read fTestAttri
      write fTestAttri;
  end;

procedure Register;

implementation

uses
{$IFDEF SYN_CLX}
  QSynEditStrConst;
{$ELSE}
  SynEditStrConst;
{$ENDIF}

procedure Register;
begin
  RegisterComponents('SynEdit Highlighters', [TSynURQLSyn]);
end;

resourcestring
  SYNS_FilterURQL = 'Quest files (*.qst)|*.qst';
  SYNS_LangURQL = 'URQL';
  SYNS_FriendlyLangURQL = 'URQL';
  SYNS_AttrTest = 'Test';
  SYNS_FriendlyAttrTest = 'Test';

const
  // as this language is case-insensitive keywords *must* be in lowercase
  KeyWords: array [0 .. 22] of UnicodeString = ('and', 'btn', 'cls', 'clsb',
    'else', 'end', 'goto', 'if', 'include', 'input', 'instr', 'inv', 'invkill',
    'music', 'not', 'or', 'p', 'pause', 'perkill', 'pln', 'proc',
    'quit', 'then');

  KeyIndices: array [0 .. 30] of Integer = (2, 11, -1, 0, 1, 4, 5, 3, 14, -1,
    -1, 17, 9, 12, 7, 8, 6, -1, 19, 18, 20, -1, 21, -1, 22, -1, 16, -1,
    15, 13, 10);

procedure TSynURQLSyn.InitIdent;
var
  i: Integer;
begin
  for i := Low(fIdentFuncTable) to High(fIdentFuncTable) do
    if KeyIndices[i] = -1 then
      fIdentFuncTable[i] := AltFunc;

  fIdentFuncTable[3] := FuncAnd;
  fIdentFuncTable[4] := FuncBtn;
  fIdentFuncTable[0] := FuncCls;
  fIdentFuncTable[7] := FuncClsb;
  fIdentFuncTable[5] := FuncElse;
  fIdentFuncTable[6] := FuncEnd;
  fIdentFuncTable[16] := FuncGoto;
  fIdentFuncTable[14] := FuncIf;
  fIdentFuncTable[15] := FuncInclude;
  fIdentFuncTable[12] := FuncInput;
  fIdentFuncTable[30] := FuncInstr;
  fIdentFuncTable[1] := FuncInv;
  fIdentFuncTable[13] := FuncInvkill;
  fIdentFuncTable[29] := FuncMusic;
  fIdentFuncTable[8] := FuncNot;
  fIdentFuncTable[28] := FuncOr;
  fIdentFuncTable[26] := FuncP;
  fIdentFuncTable[11] := FuncPause;
  fIdentFuncTable[19] := FuncPerkill;
  fIdentFuncTable[18] := FuncPln;
  fIdentFuncTable[20] := FuncProc;
  fIdentFuncTable[22] := FuncQuit;
  fIdentFuncTable[24] := FuncThen;
end;

{$Q-}

function TSynURQLSyn.HashKey(Str: PWideChar): Cardinal;
begin
  Result := 0;
  while IsIdentChar(Str^) do
  begin
    Result := Result * 977 + Ord(Str^) * 3;
    inc(Str);
  end;
  Result := Result mod 31;
  fStringLen := Str - fToIdent;
end;
{$Q+}

function TSynURQLSyn.FuncAnd(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncBtn(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncCls(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncClsb(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncElse(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncEnd(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncGoto(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncIf(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncInclude(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncInput(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncInstr(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncInv(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncInvkill(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncMusic(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncNot(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncOr(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncP(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncPause(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncPerkill(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncPln(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncProc(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncQuit(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.FuncThen(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynURQLSyn.AltFunc(Index: Integer): TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TSynURQLSyn.IdentKind(MayBe: PWideChar): TtkTokenKind;
var
  Key: Cardinal;
begin
  fToIdent := MayBe;
  Key := HashKey(MayBe);
  if Key <= High(fIdentFuncTable) then
    Result := fIdentFuncTable[Key](KeyIndices[Key])
  else
    Result := tkIdentifier;
end;

procedure TSynURQLSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while (FLine[Run] <= #32) and not IsLineEnd(Run) do
    inc(Run);
end;

procedure TSynURQLSyn.NullProc;
begin
  fTokenID := tkNull;
  inc(Run);
end;

procedure TSynURQLSyn.CRProc;
begin
  fTokenID := tkSpace;
  inc(Run);
  if FLine[Run] = #10 then
    inc(Run);
end;

procedure TSynURQLSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TSynURQLSyn.BeginLocationOpenProc;
begin
  inc(Run);
  fRange := rsBeginLocation;
  BeginLocationProc;
  fTokenID := tkKey;
end;

procedure TSynURQLSyn.BeginLocationProc;
begin
  fTokenID := tkKey;
  repeat
    if (FLine[Run] = ':') then
      Break;
    if not IsLineEnd(Run) then
      inc(Run);
  until IsLineEnd(Run);
end;

procedure TSynURQLSyn.LineCommentOpenProc;
begin
  inc(Run);
  fRange := rsLineComment;
  LineCommentProc;
  fTokenID := tkComment;
end;

procedure TSynURQLSyn.LineCommentProc;
begin
  fTokenID := tkComment;
  repeat
    if (FLine[Run] = ';') then
      Break;
    if not IsLineEnd(Run) then
      inc(Run);
  until IsLineEnd(Run);
end;

procedure TSynURQLSyn.MultiLineCommentOpenProc;
begin
  inc(Run);
  if (FLine[Run] = '*') then
  begin
    inc(Run, 1);
    fRange := rsMultiLineComment;
    fTokenID := tkComment;
  end
  else
    fTokenID := tkIdentifier;
end;

procedure TSynURQLSyn.MultiLineCommentProc;
begin
  case FLine[Run] of
    #0:
      NullProc;
    #10:
      LFProc;
    #13:
      CRProc;
  else
    begin
      fTokenID := tkComment;
      repeat
        if (FLine[Run] = '*') and (FLine[Run + 1] = '/') then
        begin
          inc(Run, 2);
          fRange := rsUnKnown;
          Break;
        end;
        if not IsLineEnd(Run) then
          inc(Run);
      until IsLineEnd(Run);
    end;
  end;
end;

procedure TSynURQLSyn.StringOpenProc;
begin
  inc(Run);
  fRange := rsString;
  StringProc;
  fTokenID := tkString;
end;

procedure TSynURQLSyn.StringProc;
begin
  fTokenID := tkString;
  repeat
    if (FLine[Run] = '"') then
    begin
      inc(Run, 1);
      fRange := rsUnKnown;
      Break;
    end;
    if not IsLineEnd(Run) then
      inc(Run);
  until IsLineEnd(Run);
end;

constructor TSynURQLSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fCaseSensitive := False;

  fCommentAttri := TSynHighlighterAttributes.Create(SYNS_AttrComment,
    SYNS_FriendlyAttrComment);
  fCommentAttri.Style := [fsItalic];
  fCommentAttri.Foreground := clNavy;
  AddAttribute(fCommentAttri);

  fIdentifierAttri := TSynHighlighterAttributes.Create(SYNS_AttrIdentifier,
    SYNS_FriendlyAttrIdentifier);
  AddAttribute(fIdentifierAttri);

  fKeyAttri := TSynHighlighterAttributes.Create(SYNS_AttrReservedWord,
    SYNS_FriendlyAttrReservedWord);
  fKeyAttri.Style := [fsBold];
  AddAttribute(fKeyAttri);

  fSpaceAttri := TSynHighlighterAttributes.Create(SYNS_AttrSpace,
    SYNS_FriendlyAttrSpace);
  AddAttribute(fSpaceAttri);

  fStringAttri := TSynHighlighterAttributes.Create(SYNS_AttrString,
    SYNS_FriendlyAttrString);
  fStringAttri.Foreground := clRed;
  AddAttribute(fStringAttri);

  fTestAttri := TSynHighlighterAttributes.Create(SYNS_AttrTest,
    SYNS_FriendlyAttrTest);
  fTestAttri.Style := [fsUnderline, fsItalic];
  fTestAttri.Foreground := clBlue;
  fTestAttri.Background := clSilver;
  AddAttribute(fTestAttri);

  SetAttributesOnChange(DefHighlightChange);
  InitIdent;
  fDefaultFilter := SYNS_FilterURQL;
  fRange := rsUnKnown;
end;

procedure TSynURQLSyn.IdentProc;
begin
  fTokenID := IdentKind(FLine + Run);
  inc(Run, fStringLen);
  while IsIdentChar(FLine[Run]) do
    inc(Run);
end;

procedure TSynURQLSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TSynURQLSyn.Next;
begin
  fTokenPos := Run;
  case fRange of
    rsMultiLineComment:
      MultiLineCommentProc;
  else
    case FLine[Run] of
      #0:
        NullProc;
      #10:
        LFProc;
      #13:
        CRProc;
      ':':
        BeginLocationOpenProc;
      ';':
        LineCommentOpenProc;
      '/':
        MultiLineCommentOpenProc;
      '"':
        StringOpenProc;
      #1 .. #9, #11, #12, #14 .. #32:
        SpaceProc;
      'A' .. 'Z', 'a' .. 'z', '_':
        IdentProc;
    else
      UnknownProc;
    end;
  end;
  inherited;
end;

function TSynURQLSyn.GetDefaultAttribute(Index: Integer)
  : TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT:
      Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER:
      Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD:
      Result := fKeyAttri;
    SYN_ATTR_STRING:
      Result := fStringAttri;
    SYN_ATTR_WHITESPACE:
      Result := fSpaceAttri;
  else
    Result := nil;
  end;
end;

function TSynURQLSyn.GetEol: Boolean;
begin
  Result := Run = fLineLen + 1;
end;

function TSynURQLSyn.GetKeyWords(TokenKind: Integer): UnicodeString;
begin
  Result := 'and,btn,cls,clsb,else,end,goto,if,include,input,instr,inv,invkill,mus'
    + 'ic,not,or,p,pause,perkill,pln,proc,quit,then';
end;

function TSynURQLSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenID;
end;

function TSynURQLSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case GetTokenID of
    tkComment:
      Result := fCommentAttri;
    tkIdentifier:
      Result := fIdentifierAttri;
    tkKey:
      Result := fKeyAttri;
    tkSpace:
      Result := fSpaceAttri;
    tkString:
      Result := fStringAttri;
    tkTest:
      Result := fTestAttri;
    tkUnknown:
      Result := fIdentifierAttri;
  else
    Result := nil;
  end;
end;

function TSynURQLSyn.GetTokenKind: Integer;
begin
  Result := Ord(fTokenID);
end;

function TSynURQLSyn.IsIdentChar(AChar: WideChar): Boolean;
begin
  case AChar of
    '_', '0' .. '9', 'a' .. 'z', 'A' .. 'Z':
      Result := True;
  else
    Result := False;
  end;
end;

function TSynURQLSyn.GetSampleSource: UnicodeString;
begin
  Result := 'Sample source for: '#13#10 + 'Syntax Parser/Highlighter';
end;

function TSynURQLSyn.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterURQL;
end;

class function TSynURQLSyn.GetFriendlyLanguageName: UnicodeString;
begin
  Result := SYNS_FriendlyLangURQL;
end;

class function TSynURQLSyn.GetLanguageName: string;
begin
  Result := SYNS_LangURQL;
end;

procedure TSynURQLSyn.ResetRange;
begin
  fRange := rsUnKnown;
end;

procedure TSynURQLSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

function TSynURQLSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

initialization

{$IFNDEF SYN_CPPB_1}
  RegisterPlaceableHighlighter(TSynURQLSyn);
{$ENDIF}

end.
