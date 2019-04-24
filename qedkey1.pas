{

The MIT License (MIT)

Copyright (C) 1996-2019 Lukasz Komsta SP8QED

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

}
unit qedkey1;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, mmsystem, ComCtrls, Buttons, Menus, ExtCtrls, {Rcadigi,} printers, inifiles;

type
  TForm1 = class(TForm)
  TrackBar1: TTrackBar;
  TrackBar2: TTrackBar;
  TrackBar3: TTrackBar;
  TrackBar4: TTrackBar;
  Memo1: TMemo;
  SpeedButton1: TSpeedButton;
  MainMenu1: TMainMenu;
  Plik1: TMenuItem;
  Nowytekst1: TMenuItem;
  Otwrzplikzeznakami1: TMenuItem;
  Zapiszznaki1: TMenuItem;
  N1: TMenuItem;
  Koniec1: TMenuItem;
  Transmisja1: TMenuItem;
  Odtwarzaj1: TMenuItem;
  Zatrzymaj1: TMenuItem;
  N2: TMenuItem;
  N3: TMenuItem;
  SpeedButton2: TSpeedButton;
  ComboBox1: TComboBox;
  SpeedButton3: TSpeedButton;
  SpeedButton4: TSpeedButton;
  StaticText1: TStaticText;
  StaticText2: TStaticText;
  StaticText3: TStaticText;
  StaticText4: TStaticText;
  SpeedButton5: TSpeedButton;
  Zapiszdwik1: TMenuItem;
  SpeedButton6: TSpeedButton;
  SpeedButton7: TSpeedButton;
  SpeedButton8: TSpeedButton;
  OpenDialog1: TOpenDialog;
  SaveDialog1: TSaveDialog;
  SaveDialog2: TSaveDialog;
  SpeedButton9: TSpeedButton;
  Drukuj1: TMenuItem;
  SpeedButton10: TSpeedButton;
  SpeedButton11: TSpeedButton;
  SpeedButton12: TSpeedButton;
  StatusBar1: TStatusBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
procedure FormCreate(Sender: TObject);
procedure trtofile(ff,h: string);
procedure txtofile(f,s: string);
procedure SpeedButton1Click(Sender: TObject);
procedure TrackBar1Change(Sender: TObject);
procedure TrackBar2Change(Sender: TObject);
procedure TrackBar3Change(Sender: TObject);
procedure TrackBar4Change(Sender: TObject);
procedure SpeedButton2Click(Sender: TObject);
procedure N2Click(Sender: TObject);
procedure Nowytekst1Click(Sender: TObject);
procedure Koniec1Click(Sender: TObject);
procedure Ustawstandardowe1Click(Sender: TObject);
procedure Otwrzplikzeznakami1Click(Sender: TObject);
procedure Zapiszznaki1Click(Sender: TObject);
procedure Zapiszdwik1Click(Sender: TObject);
procedure Drukuj1Click(Sender: TObject);
procedure SpeedButton10Click(Sender: TObject);
procedure SpeedButton11Click(Sender: TObject);
procedure SpeedButton12Click(Sender: TObject);
procedure setto(a : byte);
procedure Odczytaj1Click(Sender: TObject);
procedure Zapisz1Click(Sender: TObject);
procedure FormClose(Sender: TObject; var Action: TCloseAction);
private
    { Private declarations }
public
    { Public declarations }
end;

type
  header = record      
    riff  : dword;
    sizeb : dword;
    wave  : dword;
    fmt   : dword;
    last  : string[23];
    size  : dword;
  end;
  sett = record
    speed,spaces,noise : byte;
    tone : integer;
    chars : string;
  end;
  settings = array[1..3] of sett;
var
  Form1: TForm1;
  wavlen, dotlen, dashlen, spaces : longint;
  actual,noise : byte;
  wav : array[1..60] of byte;
  dash, spc : array[1..50000] of byte;
  tab : settings;

implementation

{$R *.lfm}

procedure tform1.trtofile(ff,h : string);
var f : file;
  a : word;
  l : dword;
  hd: header;
begin
  hd.last:=#0+#0+#0+#1+#0+#1+#0+#17+'+'+#0+#0+#17+'+'+#0+#0+#1+#0+#8+#0+'data';
  hd.last[0]:=#16;
  hd.riff:=$46464952; hd.wave:=$45564157; hd.fmt:=$20746d66;
  l:=0;
  for a:=1 to length(h) do
  case h[a] of
    '.' : l:=l+2*dotlen;
    '-' : l:=l+dashlen+dotlen;
    ' ' : l:=l+(3+spaces)*dotlen;
  end;
  hd.size:=l; hd.sizeb:=l+36;
  assignfile(f,ff);
  rewrite(f,1);
  blockwrite(f,hd,44);
  for a:=1 to length(h) do
  case h[a] of
    '.' : //
    begin
      blockwrite(f,dash,dotlen); blockwrite(f,spc,dotlen);
    end;
    '-' : //
    begin
      blockwrite(f,dash,dashlen); blockwrite(f,spc,dotlen);
    end;
    ' ' : blockwrite(f,spc,(3+spaces)*dotlen);
  end;
  closefile(f);
end;

procedure tform1.txtofile(f,s : string);
var ss,h : string;
  a : integer;
begin
  ss:=s;
  for a:=1 to length(ss) do if (ord(ss[a])>64) and (ord(ss[a])<91) then ss[a]:=chr(ord(ss[a])+32);
  spaces:=trackbar2.position;
  noise:=trackbar4.position;
  dotlen:=round(48700/trackbar1.position);
  dashlen:=3*dotlen;
  wavlen:=round(11025/trackbar3.position);
  for a:=1 to 50000 do spc[a]:=128+random(noise)-(noise div 2);
  for a:=0 to dashlen do dash[a]:=wav[(a mod wavlen)+1];
  for a:=1 to wavlen do wav[a]:=128+round((100*sin(2*pi*(a/wavlen))));
  for a:=0 to dashlen do dash[a]:=wav[(a mod wavlen)+1] +random(noise)-(noise div 2);
  h:='';
  for a:=1 to length(ss) do
  case ss[a] of
    'a' : h:=concat(h,'.- ');
(*    '¦' : h:=concat(h,'.-..- '); *)
    'b' : h:=concat(h,'-... ');
    'c' : h:=concat(h,'-.-. ');
(*    'Š' : h:=concat(h,'---. '); *)
    'd' : h:=concat(h,'-.. ');
    'e' : h:=concat(h,'. ');
(*    'ŕ' : h:=concat(h,'--..- '); *)
    'f' : h:=concat(h,'..-. ');
    'g' : h:=concat(h,'--. ');
    'h' : h:=concat(h,'.... ');
    'i' : h:=concat(h,'.. ');
    'j' : h:=concat(h,'.--- ');
    'k' : h:=concat(h,'-.- ');
    'l' : h:=concat(h,'.-.. ');
    '-' : h:=concat(h,'--.. ');
    'm' : h:=concat(h,'-- ');
    'n' : h:=concat(h,'-. ');
(*    '˝' : h:=concat(h,'--.-- '); *)
    'o' : h:=concat(h,'--- ');
(*    'ˇ' : h:=concat(h,'.--. '); *)
    'p' : h:=concat(h,'.--. ');
    'q' : h:=concat(h,'--.- ');
    'r' : h:=concat(h,'.-. ');
    's' : h:=concat(h,'... ');
    't' : h:=concat(h,'- ');
    'u' : h:=concat(h,'..- ');
    'v' : h:=concat(h,'...- ');
    'w' : h:=concat(h,'.-- ');
    'x' : h:=concat(h,'-..- ');
    'y' : h:=concat(h,'-.-- ');
    'z' : h:=concat(h,'--.. ');
(*    'č' : h:=concat(h,'--..- '); *)
(*    '¬' : h:=concat(h,'--.. '); *)
    '0' : h:=concat(h,'----- ');
    '1' : h:=concat(h,'.---- ');
    '2' : h:=concat(h,'..--- ');
    '3' : h:=concat(h,'...-- ');
    '4' : h:=concat(h,'....- ');
    '5' : h:=concat(h,'..... ');
    '6' : h:=concat(h,'-.... ');
    '7' : h:=concat(h,'--... ');
    '8' : h:=concat(h,'---.. ');
    '9' : h:=concat(h,'----. ');
    '!' : h:=concat(h,'--..-- ');
    '?' : h:=concat(h,'..--.. ');
    '/' : h:=concat(h,'-..-. ');
    '=' : h:=concat(h,'-...- ');
    ' ' : h:=concat(h,'  ');
    #13 : h:=concat(h,'  ');
    '#' : h:=concat(h,'---- ');
    '%' : h:=concat(h,'.-.-. ');
    '|' : h:=concat(h,'-.--. ');
    '@' : h:=concat(h,'...-.- ');
    '$' : h:=concat(h,'----.- ');
    '&' : h:=concat(h,'-.-..-.. ');
    '^' : h:=concat(h,'..-- ');
    '*' : h:=concat(h,'.-.- ');

  end;
  trtofile(f,h);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  actual:=1;
  tab[1].speed:=60; tab[1].spaces:=0; tab[1].tone:=600; tab[1].noise:=0; tab[1].chars:='abcdefghijklmnopqrstuvwxyz0123456789!?/=';
  tab[2].speed:=60; tab[2].spaces:=0; tab[2].tone:=600; tab[2].noise:=0; tab[2].chars:='abcdefghijklmnopqrstuvwxyz0123456789!?/=';
  tab[3].speed:=60; tab[3].spaces:=0; tab[3].tone:=600; tab[3].noise:=0; tab[3].chars:='abcdefghijklmnopqrstuvwxyz0123456789!?/=';
  odczytaj1click(sender);
  speedbutton10.down:=true;
  label1.caption:=inttostr(trackbar1.position);
  label2.caption:=inttostr(trackbar2.position);
  label3.caption:=inttostr(trackbar3.position);
  label4.caption:=inttostr(trackbar4.position);
  memo1.lines.add('vvv =');
  memo1.modified:=true;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  if memo1.modified then txtofile('qedkey.wav',memo1.text);
  memo1.modified:=false;
  playsound('qedkey.wav',0,snd_async);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  label1.caption:=inttostr(trackbar1.position);
  memo1.modified:=true;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
  label2.caption:=inttostr(trackbar2.position);
  memo1.modified:=true;
end;

procedure TForm1.TrackBar3Change(Sender: TObject);
begin
  label3.caption:=inttostr(trackbar3.position);
  memo1.modified:=true;
end;

procedure TForm1.TrackBar4Change(Sender: TObject);
begin
  label4.caption:=inttostr(trackbar4.position);
  memo1.modified:=true;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  playsound(nil,0,snd_purge);
end;

procedure TForm1.N2Click(Sender: TObject);
var a,b,l : byte;
  s,tab : string;
begin
  randomize;
  tab:=combobox1.text;
  l:=length(tab);
  if l>1 then
  begin
    s:='';
    for a:=1 to 6 do
    begin
      for b:=1 to 5 do s:=concat(s,tab[random(l)+1]);
      s:=concat(s,' ');
    end;
    memo1.lines.add(s);
  end;
end;

procedure TForm1.Nowytekst1Click(Sender: TObject);
begin
  memo1.lines.Clear;
  memo1.lines.add('vvv =');
  memo1.modified:=true;
end;

procedure TForm1.Koniec1Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.Ustawstandardowe1Click(Sender: TObject);
begin
  trackbar1.position:=60;
  trackbar2.position:=0;
  trackbar3.position:=600;
  trackbar4.position:=0;
  combobox1.text:='abcdefghijklmnopqrstuvwxyz0123456789=/!?';
  label1.caption:=inttostr(trackbar1.position);
  label2.caption:=inttostr(trackbar2.position);
  label3.caption:=inttostr(trackbar3.position);
  label4.caption:=inttostr(trackbar4.position);
  memo1.modified:=true;
end;

procedure TForm1.Otwrzplikzeznakami1Click(Sender: TObject);
begin
  if opendialog1.execute then memo1.lines.loadfromfile(opendialog1.filename);
end;

procedure TForm1.Zapiszznaki1Click(Sender: TObject);
begin
  if savedialog2.execute then memo1.lines.savetofile(savedialog2.filename);
end;

procedure TForm1.Zapiszdwik1Click(Sender: TObject);
begin
  if savedialog1.execute then txtofile(savedialog1.filename,memo1.text);
end;

procedure TForm1.Drukuj1Click(Sender: TObject);
var a : integer;
begin
  with printer do
  begin
    title:='Wydruk z QedKey+';
    canvas.Font.name:='Courier New CE';
    canvas.Font.size:=14;
    begindoc;
    for a:=0 to memo1.lines.count do canvas.textout(5,40*a,memo1.lines[a]);
    enddoc;
  end;
end;

procedure TForm1.setto(a : byte);
begin
  tab[actual].speed:=trackbar1.position;
  tab[actual].spaces:=trackbar2.position;
  tab[actual].tone:=trackbar3.position;
  tab[actual].noise:=trackbar4.position;
  tab[actual].chars:=combobox1.text;
  actual:=1;
  trackbar1.Position:=tab[a].speed;
  trackbar2.Position:=tab[a].spaces;
  trackbar3.Position:=tab[a].tone;
  trackbar4.Position:=tab[a].noise;
  combobox1.text:=tab[a].chars;
  label1.caption:=inttostr(trackbar1.position);
  label2.caption:=inttostr(trackbar2.position);
  label3.caption:=inttostr(trackbar3.position);
  label4.caption:=inttostr(trackbar4.position);
  memo1.modified:=true;
end;

procedure tform1.speedbutton10click(Sender : TObject);
begin
  setto(1);
  actual:=1;
end;

procedure TForm1.SpeedButton11Click(Sender: TObject);
begin
  setto(2);
  actual:=2;
end;

procedure TForm1.SpeedButton12Click(Sender: TObject);
begin
  setto(3);
  actual:=3;
end;

procedure TForm1.Odczytaj1Click(Sender: TObject);
var
  ini : tinifile;
  a : byte;
begin
  ini:=tinifile.create('qedkey.ini');
  with ini do
  begin
    for a:=1 to 3 do
    begin
      tab[a].speed:=readinteger('settings'+floattostr(a),'speed',60);
      tab[a].spaces:=readinteger('settings'+floattostr(a),'spaces',0);
      tab[a].tone:=readinteger('settings'+floattostr(a),'tone',60);
      tab[a].noise:=readinteger('settings'+floattostr(a),'noise',60);
      tab[a].chars:=readstring('settings'+floattostr(a),'chars','abcdefghijklmnopqrstuvwxyz0123456789/=?!');
    end;
    free;
  end;

end;

procedure TForm1.Zapisz1Click(Sender: TObject);
var
  ini : tinifile;
  a : byte;
begin
  ini:=tinifile.create('qedkey.ini');
  with ini do
  begin
    for a:=1 to 3 do
    begin
      writeinteger('settings'+floattostr(a),'speed',tab[a].speed);
      writeinteger('settings'+floattostr(a),'spaces',tab[a].spaces);
      writeinteger('settings'+floattostr(a),'tone',tab[a].tone);
      writeinteger('settings'+floattostr(a),'noise',tab[a].noise);
      writestring('settings'+floattostr(a),'chars',tab[a].chars);
    end;
    free;
  end;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if fileexists('qedkey.wav') then deletefile('qedkey.wav');
  zapisz1click(sender);
end;

end.
