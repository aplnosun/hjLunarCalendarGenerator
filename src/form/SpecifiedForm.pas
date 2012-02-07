unit SpecifiedForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  SpecifiedData, SpecifiedDataController;

const
  smrSave   = 20;
  smrUpdate = 21;
  smrDelete = 22;
  smrCancel = 23;

type
  TfrmSpecified = class(TForm)
    lblLunarDate: TLabel;
    edtLunarMonth: TEdit;
    edtLunarDay: TEdit;
    edtSummary: TEdit;
    lblSummary: TLabel;
    btnSave: TButton;
    btnCancel: TButton;
    lblDescription: TLabel;
    btnDelete: TButton;
    lblLunarMonth: TLabel;
    lblLunarDay: TLabel;
    chkLunarLastDay: TCheckBox;
    procedure chkLunarLastDayClick(Sender: TObject);
    procedure edtOnlyNumericKeyPress(Sender: TObject; var Key: Char);
    procedure edtLunarDayExit(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtNextFocusKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FData: TSpecifiedData;
    FDataCtrl: TSpecifiedDateController;
  public
    property Data: TSpecifiedData read FData write FData;
    property DataCtrl: TSpecifiedDateController read FDataCtrl write FDataCtrl;
  end;

var
  frmSpecified: TfrmSpecified;

implementation

uses
  Math, StrUtils, CalendarCommons;

{$R *.dfm}

procedure TfrmSpecified.FormShow(Sender: TObject);
begin
  if Assigned(FData) then
  begin
    edtLunarMonth.Text  := Format('%.2d', [FData.Month]);
    edtLunarDay.Text    := FData.DayStr;
    chkLunarLastDay.Checked := FData.Day = LunarLastDay;
    edtSummary.Text     := FData.Summary;
  end;
end;

procedure TfrmSpecified.btnCancelClick(Sender: TObject);
begin
  if    Assigned(FData)
    and ((StrToIntDef(edtLunarMonth.Text, 0) <> FData.Month)
    or  (StrToIntDef(edtLunarDay.Text, 99) <> FData.Day)
    or  (edtSummary.Text <> FData.Summary)) then
  begin
    if Application.MessageBox(
      PChar('����� ������ �ֽ��ϴ�.'#13#10 +
            '�׷��� ����Ͻðڽ��ϱ�?'),
      PChar('hjLunarCalendarGenerator'),
      MB_ICONQUESTION OR MB_YESNO) = ID_NO then
    begin
      Exit;
    end;
  end;

  ModalResult := smrCancel;
  Close;
end;

procedure TfrmSpecified.btnDeleteClick(Sender: TObject);
begin
  if Application.MessageBox(
    PChar(Format('����� ''%s(%d�� %s��)''��'#13#10 +
          '�����Ͻðڽ��ϱ�?', [FData.Summary, FData.Month, FData.DayStr])),
    PChar('hjLunarCalendarGenerator'),
    MB_ICONQUESTION OR MB_YESNO) = ID_NO then
  begin
    Exit;
  end;

  ModalResult := smrDelete;
  CloseModal;
end;

procedure TfrmSpecified.btnSaveClick(Sender: TObject);
var
  Day: Integer;
begin
  Day := IfThen(edtLUnarDay.Text = LunarLastDayStr, LunarLastDay, StrToIntDef(edtLUnarDay.Text, LunarLastDay));

  if not Assigned(FData) then
  begin
    FData := TSpecifiedData.Create('', StrToInt(edtLunarMonth.Text), Day, edtSummary.Text);
    ModalResult := smrSave;
  end
  else
  begin
    FData.Month := StrToInt(edtLunarMonth.Text);
    FData.Day   := Day;
    FData.Summary := edtSummary.Text;
    ModalResult := smrUpdate;
  end;
  CloseModal;
end;

procedure TfrmSpecified.chkLunarLastDayClick(Sender: TObject);
begin
  edtLunarDay.Enabled := not TCheckbox(Sender).Checked;
  edtLunarDay.Text    := IfThen(TCheckbox(Sender).Checked, LunarLastDayStr, '');
end;

procedure TfrmSpecified.edtLunarDayExit(Sender: TObject);
begin
  if TEdit(Sender).Text = '30' then
  begin
    if Application.MessageBox(
      PChar('30���� ���� ���� ǥ�õ��� ���� �� �ֽ��ϴ�.'#13#10 +
            '�Ŵ� ���Ϸ� ó���ϰڽ��ϱ�??'),
      PChar('hjLunarCalendarGenerator'),
      MB_ICONQUESTION OR MB_YESNO) = ID_YES then
    begin
      chkLunarLastDay.Checked := True;
    end;
  end;
end;

procedure TfrmSpecified.edtNextFocusKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Length(TEdit(Sender).Text) = TEdit(Sender).MaxLength then
  begin
    Key := 0;
    SelectNext(Sender as TWinControl, True, True);
  end;
end;

procedure TfrmSpecified.edtOnlyNumericKeyPress(Sender: TObject; var Key: Char);
begin
  if not (CharInSet(Key, ['0'..'9',#25,#8,#13])) then
    Key := #0;
end;

end.
