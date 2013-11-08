unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, sComboBox, ExtCtrls, sPanel, sSkinProvider,
  sSkinManager, DCPcrypt2, DCPmd5, DCPrc4;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Abrir1: TMenuItem;
    sSkinManager1: TsSkinManager;
    sSkinProvider1: TsSkinProvider;
    sPanel2: TsPanel;
    ComboBox1: TsComboBox;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    DCP_rc4: TDCP_rc4;
    DCP_md5: TDCP_md5;
    procedure ComboBox1Change(Sender: TObject);
    procedure Abrir1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    bLoading : Boolean;
    function Codificar(const Texto:string):string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.Codificar(const Texto:string):string;
begin
  DCP_RC4.InitStr('Grupo Abril', TDCP_md5);
  Result := DCP_RC4.EncryptString(Texto);
  DCP_RC4.Burn;
end;


procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if not bLoading then sSkinManager1.SkinName := ComboBox1.Text;
end;

procedure TForm1.Abrir1Click(Sender: TObject);
  function Descodificar(const Texto:string):string;
  begin
    Result := '';
    DCP_RC4.InitStr('Grupo Abril', TDCP_MD5);
    Result := DCP_RC4.DecryptString(Texto);
    DCP_RC4.Burn;
  end;

var
  Lista:TStringList;
begin
  if OpenDialog1.Execute then begin
    Lista := TStringList.Create;
    Lista.LoadFromFile(OpenDialog1.FileName);
    Memo1.Text := Descodificar(Lista.Text);
    Lista.Destroy;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
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

begin


  bLoading := True;
  sSkinManager1.GetSkinNames(ComboBox1.Items);
  ComboBox1.ItemIndex := ComboBox1.Items.count-1;
  bLoading := False;

  OpenDialog1.InitialDir := GetTempDirectory;
end;

end.
