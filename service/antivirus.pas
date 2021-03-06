unit antivirus;

interface
 
uses windows, sysutils;
 
function detection: boolean;
 
implementation

const
 infection = '��������� �������� ������� ��� ���� ����������.'#10#13 +
             '��������� ������ �������� ���������� ������������ ����������!';
 caption = '�����������';
 controlext = '.sum';

var detect: boolean;

function detection: boolean;
begin
 result := detect;
end;

procedure scanner;
var
 controlname: string;
 programname: string;
 fw: file of longword;
 buf: array[1..1024] of byte;
 h, i, s: integer;
 oldsize, oldsum: longword;
 size, sum: longword;
begin
 detect := true;
 programname := paramstr (0);
 controlname := changefileext (programname, controlext);
 h := fileopen (programname, fmopenread or fmsharedenywrite);
 size := getfilesize (h, nil);
 sum := 0;
 for i := 1 to 1024 do buf[i] := 0;
 repeat
  s := fileread (h, buf, 1024);
  for i := 1 to s do inc (sum, buf[i]);
 until s < 1024;
 fileclose (h);
 assignfile (fw, controlname);
{$i-}
 reset (fw);
 read (fw, oldsize, oldsum);
 closefile (fw);
{$i+}
 if ioresult <> 0 then begin
  rewrite (fw);
  write (fw, size, sum);
  closefile (fw);
 end else if (size <> oldsize) or (sum <> oldsum) then
  MessageBox(0, infection, caption, mb_iconwarning + mb_ok)
 else detect := false;
end;

initialization
 scanner;
 
end.