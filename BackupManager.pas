unit BackupManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IOUtils, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.FileCtrl, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDac.Dapt, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus,
  Vcl.Buttons, ShellApi;

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
    PanelCreateProfile: TPanel;
    BtnCancelProfileCreation: TButton;
    BtnConfirmProfileCreation: TButton;
    Label4: TLabel;
    edNewProfileName: TEdit;
    btnChooseOriginPath: TButton;
    btnTargetPath: TButton;
    Panel4: TPanel;
    PopupActionsMenu: TPopupMenu;
    Profile1: TMenuItem;
    Create1: TMenuItem;
    Removecurrent1: TMenuItem;
    PRemove: TPanel;
    lblRemove: TLabel;
    BtnCancelRemove: TButton;
    BtnConfirmRemove: TButton;
    BtnActions: TSpeedButton;
    sbBackupList: TScrollBox;
    lbBackups: TListBox;
    Manager1: TMenuItem;
    Quickbackup1: TMenuItem;
    Restorecurrent1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ProfileSelectorSelect(Sender: TObject);
    procedure DefaultCheckboxClick(Sender: TObject);
    procedure BtnAddProfileClick(Sender: TObject);
    procedure BtnCancelProfileCreationClick(Sender: TObject);
    procedure btnChooseOriginPathClick(Sender: TObject);
    procedure btnTargetPathClick(Sender: TObject);
    procedure BtnConfirmProfileCreationClick(Sender: TObject);
    procedure BtnActionsMenuClick(Sender: TObject);
    procedure Removecurrent1Click(Sender: TObject);
    procedure BtnCancelRemoveClick(Sender: TObject);
    procedure BtnConfirmRemoveClick(Sender: TObject);
    procedure Quickbackup1Click(Sender: TObject);
    procedure Restorecurrent1Click(Sender: TObject);
  private
    { Private declarations }
    function Query(QueryString: String):TFDQuery;
    procedure Load;
    procedure FillInfoSelected;
    procedure ClearProfileCreation;
    procedure DrawBackups(GivenRoute: String);
    function GetLastSeparatedByDelimiter(Delimiter: Char; Text: String):String;
    procedure ShellExecuteWait(Command: String);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  OriginPath,
  TargetPath: String;
  StringList: TStringList;


implementation

{$R *.dfm}

procedure TForm1.ShellExecuteWait(Command: String);
    var
      StartupInfo: TStartupInfo;
      ProcessInfo: TProcessInformation;
begin
   ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
   StartupInfo.cb := SizeOf(StartupInfo);

   {
    Use /c to automatically close the cmd window after it has finished
    Use /k to keep the window after finishing
   }
   CreateProcess(nil, PChar('cmd.exe /c ' + Command), nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);
   WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
   CloseHandle(ProcessInfo.hProcess);
   CloseHandle(ProcessInfo.hThread);
end;

function TForm1.Query(QueryString: String):TFDQuery;
  var
    QueryObj: TFDQuery;
begin
   QueryObj := TFDQuery.Create(nil);
   QueryObj.Connection := Connection;

   QueryObj.SQL.Text := QueryString;
   result := QueryObj;
end;

procedure TForm1.Quickbackup1Click(Sender: TObject);
  var
    QueryObj : TFDQuery;
begin
  if ProfileSelector.Text = '' then
  begin
    ShowMessage('A profile must be selected');
    exit;
  end;

  QueryObj := Query('SELECT ORIGINPATH, TARGETPATH FROM CONFIGURATION WHERE NAME = :NAME');
  QueryObj.Params.ParamByName('NAME').asString := ProfileSelector.Text;
  QueryObj.Open;

  ShellExecuteWait(StringList.DelimitedText+'\compression.exe -operation backup'+
    Format(' -o %s\', [QueryObj.FieldByName('ORIGINPATH').asString])+
    Format(' -t %s\', [QueryObj.FieldByName('TARGETPATH').asString])
  );
  QueryObj.Close;
  QueryObj.Free;
  Load;
end;

procedure TForm1.Removecurrent1Click(Sender: TObject);
begin
  if ProfileSelector.Text = '' then
  begin
    ShowMessage('A profile must be selected');
    exit;
  end;

  PRemove.Visible := True;
end;

procedure TForm1.Restorecurrent1Click(Sender: TObject);
  var
    QueryObj : TFDQuery;
    RestoreRoute: String;
begin
  if ProfileSelector.Text = '' then
  begin
    ShowMessage('A profile must be selected');
    exit;
  end;

  if lbBackups.ItemIndex < 0 then
  begin
    ShowMessage('A backup must be selected');
    exit;
  end;

  if SelectDirectory('Select a folder', '', RestoreRoute) then
  begin
    QueryObj := Query('SELECT TARGETPATH FROM CONFIGURATION WHERE NAME = :NAME');
    QueryObj.Params.ParamByName('NAME').asString := ProfileSelector.Text;
    QueryObj.Open;

    ShellExecuteWait(StringList.DelimitedText+'\compression.exe -operation restore'+
      Format(' -o %s\%s', [QueryObj.FieldByName('TARGETPATH').asString, lbBackups.Items[lbBackups.ItemIndex]])+
      Format(' -t %s\', [RestoreRoute])
    );

    QueryObj.Close;
    QueryObj.Free;
  end;
end;

function TForm1.GetLastSeparatedByDelimiter(Delimiter: Char; Text: String):String;
  var
    StringList: TStringList;
begin
     StringList := TStringList.Create;
     StringList.Delimiter := Delimiter;
     StringList.StrictDelimiter := True;
     StringList.DelimitedText := Text;

     result := StringList.Strings[StringList.Count - 1];
     StringList.Free;
end;

procedure TForm1.DrawBackups(GivenRoute: String);
  var
    FileList: TArray<String>;
    Route: String;
begin
     lbBackups.Items.Clear;
     if ProfileSelector.Text = '' then
      exit;

     FileList := TDirectory.GetFiles(GivenRoute, '*.zip', TSearchOption.soAllDirectories);
     for Route in FileList do
     begin
        lbBackups.Items.Add(GetLastSeparatedByDelimiter('\', Route));
     end;
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
  DrawBackups(QueryObj.FieldByName('TARGETPATH').asString);
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

procedure TForm1.BtnCancelRemoveClick(Sender: TObject);
begin
   PRemove.Visible := False;
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

procedure TForm1.BtnConfirmRemoveClick(Sender: TObject);
  var
    QueryObj : TFDQuery;
begin

  QueryObj := Query('DELETE FROM CONFIGURATION WHERE NAME = :NAME');
  QueryObj.Params.ParamByName('NAME').asString := ProfileSelector.Text;
  QueryObj.ExecSQL;
  QueryObj.Free;

  ProfileSelector.Text := '';
  PRemove.Visible := False;
  Load;
end;

procedure TForm1.btnTargetPathClick(Sender: TObject);
begin
   if SelectDirectory('Select a folder', '', TargetPath) then
    btnTargetPath.Caption := TargetPath;
end;

procedure TForm1.BtnActionsMenuClick(Sender: TObject);
  var
    Pointer: TPoint;
begin
  GetCursorPos(Pointer);
  PopupActionsMenu.Popup(Pointer.X, Pointer.Y);
end;

procedure TForm1.DefaultCheckboxClick(Sender: TObject);
  var QueryObj: TFDQuery;
begin
  if (ProfileSelector.Text = '') and (DefaultCheckbox.Checked) then
  begin
    ShowMessage('A profile must be selected');
    DefaultCheckbox.Checked := False;
    exit;
  end;

  QueryObj := Query('UPDATE CONFIGURATION SET ACTIVE = FALSE WHERE ACTIVE = TRUE');
  QueryObj.ExecSQL;
  QueryObj.Free;

  if not DefaultCheckbox.Checked then
    exit;

  QueryObj := Query('UPDATE CONFIGURATION SET ACTIVE = :ACTIVE WHERE NAME = :NAME');
  QueryObj.Params.ParamByName('ACTIVE').asBoolean := True;
  QueryObj.Params.ParamByName('NAME').asString := ProfileSelector.Items[ProfileSelector.ItemIndex];
  QueryObj.ExecSQL;
  QueryObj.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
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
