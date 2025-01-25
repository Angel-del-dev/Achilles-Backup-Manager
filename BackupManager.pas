unit BackupManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDac.Dapt, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Connection: TFDConnection;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ProfileSelector: TComboBox;
    Label1: TLabel;
    DefaultCheckbox: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    lblOrigin: TLabel;
    lblTarget: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ProfileSelectorSelect(Sender: TObject);
    procedure DefaultCheckboxClick(Sender: TObject);
  private
    { Private declarations }
    function Query(QueryString: String):TFDQuery;
    procedure Load;
    procedure FillInfoSelected;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.Query(QueryString: String):TFDQuery;
  var
    QueryObj: TFDQuery;
begin
   QueryObj := TFDQuery.Create(nil);
   QueryObj.Connection := Connection;

   QueryObj.SQL.Text := QueryString;
   result := QueryObj;
end;

procedure TForm1.Load();
  var Profiles: TFDQuery;
    I : Integer;
begin
    { Load profiles }

    I := 0;

    Profiles := Query('SELECT NAME, ACTIVE FROM CONFIGURATION');
    Profiles.Open;
    while not Profiles.Eof do
    begin
      ProfileSelector.Items.Add(Profiles.FieldByName('NAME').asString);
      if Profiles.FieldByName('ACTIVE').asBoolean then
        ProfileSelector.ItemIndex := I;

      I := I+1;
      Profiles.Next;
    end;
    Profiles.Close;
    FillInfoSelected;
end;

procedure TForm1.ProfileSelectorSelect(Sender: TObject);
begin
  FillInfoSelected;
end;

procedure TForm1.FillInfoSelected();
  var QueryObj: TFDQuery;
begin
  QueryObj := Query('SELECT ACTIVE, ORIGINPATH, TARGETPATH FROM CONFIGURATION WHERE NAME = :NAME');
  QueryObj.Params.ParamByName('NAME').asString := ProfileSelector.Items[ProfileSelector.ItemIndex];
  QueryObj.Open;
  DefaultCheckbox.Checked := QueryObj.FieldByName('ACTIVE').asBoolean;
  lblOrigin.Caption := QueryObj.FieldByName('ORIGINPATH').asString;
  lblTarget.Caption := QueryObj.FieldByName('TARGETPATH').asString;
  QueryObj.Close;
  QueryObj.Free;
end;

procedure TForm1.DefaultCheckboxClick(Sender: TObject);
  var QueryObj: TFDQuery;
begin
  QueryObj := Query('UPDATE CONFIGURATION SET ACTIVE = FALSE');
  QueryObj.ExecSQL;
  QueryObj.Free;

  QueryObj := Query('UPDATE CONFIGURATION SET ACTIVE = :ACTIVE WHERE NAME = :NAME');
  QueryObj.Params.ParamByName('ACTIVE').asBoolean := DefaultCheckbox.Checked;
  QueryObj.Params.ParamByName('NAME').asString := ProfileSelector.Items[ProfileSelector.ItemIndex];
  QueryObj.ExecSQL;
  QueryObj.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
  var StringList: TStringList;
begin
  Connection := TFDConnection.Create(nil);

  StringList := TStringList.Create;
  StringList.Delimiter := '\';
  StringList.StrictDelimiter := True;
  StringList.DelimitedText := ExtractFilePath(ParamStr(0));
  StringList.Delete(StringList.Count - 1);

  try
    Connection.DriverName := 'SQLite';
    Connection.Params.Database :=  StringList.DelimitedText+'\manager.sdb';
    Connection.ConnectionName := 'BackupManager';
    Connection.Open;

    Connection.Connected := True;

    Load;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;

end;

end.
