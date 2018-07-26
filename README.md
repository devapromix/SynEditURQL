# SynEditURQL
Подсветка синтаксиса урки (URQ) для SynEdit.

Генерируется программой SynGen из шаблона SynHighlighterURQL.msg.

После генерации необходимо добавить в исходник:

1.
procedure Register;
begin
 RegisterComponents('SynEdit Highlighters', [TSynURQLSyn]);
end;

Заменить аналогичный код:

1.
procedure TSynURQLSyn.BeginLocationProc;
begin
  fTokenID := tkKey;
  repeat
    if (fLine[Run] = ':') then
      Break;

2.
procedure TSynURQLSyn.LineCommentProc;
begin
  fTokenID := tkComment;
  repeat
    if (fLine[Run] = ';') then
      Break;