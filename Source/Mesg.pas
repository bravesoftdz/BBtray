
//
// BBtray: Message Unit
//
// (c) 1999,2001 - Deluan Cotts Quintão
// bbtray@deluan.com.br
//

unit Mesg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ShellApi;

type
  TfrmMesg = class(TForm)
    Label1: TLabel;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowMesg(msg: String; color: TColor);
  end;

var
  frmMesg: TfrmMesg;

implementation

uses Main;

{$R *.DFM}

procedure TfrmMesg.ShowMesg(msg: String; color: TColor);
begin
     Label1.Caption := Msg;
     Label1.Color := Color;
     Show;
end;

procedure TfrmMesg.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key = #27 then
        Close
     else if Key = #13 then
        Label1Click(Sender);
end;

procedure TfrmMesg.Label1Click(Sender: TObject);
begin
  ShellExecute(Application.MainForm.Handle, Nil, PChar(MainForm.FDisplayURL),
               Nil, Nil, SW_SHOW);
  Close;
end;

end.

