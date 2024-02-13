unit F_ImportMicroMine;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  IdGlobal,
  U_MicroMineFile,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm_ImportMicroMine = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Memo1: TMemo;
    Label1: TLabel;
    Edit_DecimlSeparator: TEdit;
    Edit_FieldSeparator: TEdit;
    Label2: TLabel;
    CheckBox_FieldNamesFirstRecord: TCheckBox;
    Button2: TButton;
    SaveDialog1: TSaveDialog;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    // имя файла источника
    FFileNameSrc           : String;
    // источник
    procedure SetFFileNameSrc(const Value: String);

    procedure ReadFile(AFileName : String);
  public
    { Public declarations }
    MicroMineFile : TMicroMineFile;
  published
    property FileNameSrc  : String read FFileNameSrc write SetFFileNameSrc;
  end;

var
  Form_ImportMicroMine: TForm_ImportMicroMine;

implementation

uses U_Tools;

{$R *.dfm}


procedure TForm_ImportMicroMine.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute() then
      FileNameSrc := OpenDialog1.FileName;
end;

procedure TForm_ImportMicroMine.Button2Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    MicroMineFile.TxtTable.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm_ImportMicroMine.FormCreate(Sender: TObject);
begin
  OpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);
end;


procedure TForm_ImportMicroMine.SetFFileNameSrc(const Value: String);
begin
  FFileNameSrc := Value;
  // читаем файл
  ReadFile(FFileNameSrc);
end;

procedure TForm_ImportMicroMine.ReadFile(AFileName: String);
var
   wTStringList : TStringList;
begin
   Button2.Enabled := False;
   try
    // создаем экземпляр класса модуль U_MicroMineFile.pas
    // и читаем содержимое файла
    if MicroMineFile <> nil then
      MicroMineFile.Destroy;
    MicroMineFile := TMicroMineFile.Create;
    MicroMineFile.DecSeparator   := Edit_DecimlSeparator.Text;
    MicroMineFile.FieldSeparator := Edit_FieldSeparator.Text;
    MicroMineFile.FirstRowNames  := CheckBox_FieldNamesFirstRecord.Checked;

    // загружаем файл, определяем тип и начмнаем разбор
    MicroMineFile.FileName := AFileName;

    if MicroMineFile.FileType = 'UNKNOWN' then
      begin
           ShowMessage('Неизвестная специфмкация файла.');
           Exit;
      end;
    try
     // Отображаем в Memo
      if MicroMineFile.FileType = 'MICROMINE' then
        begin
          wTStringList := MicroMineFile.ExportToTxt;
          Memo1.Lines.Assign(wTStringList);
          Button2.Enabled := True;
        end;
      if MicroMineFile.FileType = 'MAINFRAME' then
        begin
          Memo1.Lines.Assign(MicroMineFile.TxtTable);
          Button2.Enabled := True;
        end;
    finally
      FreeAndNil(wTStringList);
    end;
   finally
     Label3.Caption := MicroMineFile.FileType;
   end;
end;

end.
