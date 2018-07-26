TSynURQLSyn
tk              {second Identifier is considered to be the Identifier Prefix }
IdentStart '_', 'a'..'z', 'A'..'Z':: '_', '0'..'9', 'a'..'z', 'A'..'Z'::

TOKENTYPES
Identifier
Comment Style=[fsItalic]|Foreground=clNavy
Space
String Foreground=clRed
Key Style=[fsBold]
Test Background=clSilver|Foreground=clBlue|Style=[fsUnderline, fsItalic]
|><|

KEYS
p
pln
btn
cls
clsb
end
perkill
invkill
pause
input
music
include
or
and
not
quit
if
then
else
goto
proc
instr
inv
|><|

CHARS

'A'..'Z', 'a'..'z', '_':: Ident
BeginProc
  fTokenID := IdentKind(fLine + Run);
  Inc(Run, fStringLen);
  while IsIdentChar(fLine[Run]) do
    Inc(Run);
EndProc

|><|

ENCLOSEDBY

Key,BeginLocation,:,:
Comment,LineComment,;,;
Comment,MultiLineComment,/*,*/,MultiLine
String,String,","

|><|

