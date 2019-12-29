unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TfrmMain = class(TForm)
    Label1: TLabel;
    edtText: TEdit;
    Label2: TLabel;
    edtEncode: TEdit;
    Label3: TLabel;
    edtDecode: TEdit;
    chkTerminateWithEqualSigns: TCheckBox;
    procedure edtTextChangeTracking(Sender: TObject);
    procedure chkTerminateWithEqualSignsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DoTest;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Rac.Base64;

{$R *.fmx}

procedure TfrmMain.chkTerminateWithEqualSignsChange(Sender: TObject);
begin
  DoTest;
end;

procedure TfrmMain.DoTest;
begin
  edtEncode.Text := TBase64.Encode(TEncoding.UTF8.GetBytes(edtText.Text), chkTerminateWithEqualSigns.IsChecked);
  try
    edtDecode.Text := TEncoding.UTF8.GetString(TBase64.Decode(edtEncode.Text));
  except
    on E: Exception do
      edtDecode.Text := 'Decode Error: ' + E.Message;
  end;
end;

procedure TfrmMain.edtTextChangeTracking(Sender: TObject);
begin
  DoTest;
end;

end.
