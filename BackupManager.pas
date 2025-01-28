unit BackupManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.FileCtrl, FireDAC.Stan.Intf, FireDAC.Stan.Option,
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
    BtnAddProfile: TButton;
    PanelCreateProfile: TPanel;
    BtnCancelProfileCreation: TButton;
    BtnConfirmProfileCreation: TButton;
    Label4: TLabel;
    edNewProfileName: TEdit;
    btnChooseOriginPath: TButton;
    btnTargetPath: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ProfileSelectorSelect(Sender: TObject);
    procedure DefaultCheckboxClick(Sender: TObject);
    procedure BtnAddProfileClick(Sender: TObject);
    procedure BtnCancelProfileCreationClick(Sender: TObject);
    procedure btnChooseOriginPathClick(Sender: TObject);
    procedure btnTargetPathClick(Sender: TObject);
    procedure BtnConfirmProfileCreationClick(Sender: TObject);
  private
    { Private declarations }
    function Query(QueryString: String):TFDQuery;
    procedure Load;
    procedure FillInfoSelected;
    procedure ClearProfileCreation;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  OriginPath,
  TargetPath: String;


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
    ProfileSelector.Items.Clear;
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

procedure TForm1.BtnAddProfileClick(Sender: TObject);
begin
  PanelCreateProfile.Visible := True;
end;

procedure TForm1.ClearProfileCreation;
begin
  PanelCreateProfile.Visible := False;
  btnChooseOriginPath.Caption := 'Origin path';
  btnTargetPath.Caption := 'Target path';
  OriginPath := '';
  TargetPath := '';
  edNewProfileName.Text := '';
end;

procedure TForm1.BtnCancelProfileCreationClick(Sender: TObject);
begin
  ClearProfileCreation;
end;

procedure TForm1.btnChooseOriginPathClick(Sender: TObject);
begin
  if SelectDirectory('Select a folder', '', OriginPath) then
    btnChooseOriginPath.Caption := OriginPath;
end;

procedure TForm1.BtnConfirmProfileCreationClick(Sender: TObject);
  var
    QueryObj : TFDQuery;
    NameExists: Boolean;
begin
  if (edNewProfileName.Text = '') or (OriginPath = '') or (TargetPath = '') then
  begin
    ShowMessage('There is information missing');
    exit;
  end;

  QueryObj := Query('SELECT COUNT(1) AS AMOUNTNAME FROM CONFIGURATION WHERE NAME = :NAME');
  QueryObj.Params.ParamByName('NAME').asString := edNewProfileName.Text;
  QueryObj.Open;
  NameExists := QueryObj.FieldByName('AMOUNTNAME').AsInteger > 0;
  QueryObj.Close;
  QueryObj.Free;

  if NameExists then
  begin
    ShowMessage('The profile already exists');
    exit;
  end;

  QueryObj := Query('INSERT INTO CONFIGURATION(NAME, ORIGINPATH, TARGETPATH, ACTIVE) VALUES(:NAME, :ORIGINPATH, :TARGETPATH, FALSE)');
  QueryObj.Params.ParamByName('NAME').asString := edNewProfileName.Text;
  QueryObj.Params.ParamByName('ORIGINPATH').asString := OriginPath;
  QueryObj.Params.ParamByName('TARGETPATH').asString := TargetPath;
  QueryObj.ExecSQL;
  QueryObj.Free;
  ClearProfileCreation;
  Load;
end;

procedure TForm1.btnTargetPathClick(Sender: TObject);
begin
   if SelectDirectory('Select a folder', '', TargetPath) then
    btnTargetPath.Caption := TargetPath;
end;

procedure TForm1.DefaultCheckboxClick(Sender: TObject);
  var QueryObj: TFDQuery;
begin
  QueryObj := Query('UPDATE CONFIGURATION SET ACTIVE = FALSE WHERE ACTIVE = TRUE');
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
  OriginPath := '';
  TargetPath := '';

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
