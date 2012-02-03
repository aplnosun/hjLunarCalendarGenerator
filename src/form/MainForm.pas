unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  hjLunarDateType, CalendarCommons, MakeCalendarController, SpecifiedDateController;

type
  TfrmMain = class(TForm)
    GroupBox1: TGroupBox;
    btnLunarToSolar: TButton;
    edtLunarYear: TEdit;
    edtLunarMonth: TEdit;
    edtLunarDay: TEdit;
    btnSolarToLunar: TButton;
    edtSolarYear: TEdit;
    edtSolarMonth: TEdit;
    edtSolarDay: TEdit;
    pgcCalendar: TPageControl;
    tsLunar: TTabSheet;
    tsSpecified: TTabSheet;
    rdoLunarDisplayDays10: TRadioButton;
    rdoLunarDisplayDays15: TRadioButton;
    rdoLunarDisplayDays5: TRadioButton;
    rdoLunarDisplayDaysKor: TRadioButton;
    lvSpecified: TListView;
    lblSpecified: TLabel;
    btnAddSpecified: TButton;
    btnDelSpecified: TButton;
    btnMakeSpecifiedCalendar: TButton;
    lblLunarDisplayDays10: TLabel;
    lblLunarDisplayDays15: TLabel;
    lblLunarDisplayDays5: TLabel;
    lblLunarDisplayDaysKor: TLabel;
    btnMakeLunarCalendar: TButton;
    Label5: TLabel;
    Label6: TLabel;
    lblBlog: TLabel;
    ��: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    chkLunarLeap: TCheckBox;
    BalloonHint1: TBalloonHint;
    edtStartOfRange: TEdit;
    Label1: TLabel;
    edtEndOfRange: TEdit;
    Label2: TLabel;
    dlgSave: TSaveDialog;
    btnAbout: TButton;
    procedure btnLunarToSolarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSolarToLunarClick(Sender: TObject);
    procedure lblLunarDisplayDaysClick(Sender: TObject);
    procedure lblBlogMouseEnter(Sender: TObject);
    procedure lblBlogMouseLeave(Sender: TObject);
    procedure lblBlogClick(Sender: TObject);
    procedure btnMakeLunarCalendarClick(Sender: TObject);
    procedure btnMakeSpecifiedCalendarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtOnlyNumericKeyPress(Sender: TObject; var Key: Char);
    procedure btnAddSpecifiedClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
  private
    { Private declarations }
    FMakeCalendarCtrl: TMakeCalendarController;
    FSpecifiedDataCtrl: TSpecifiedDateController;

    function GetRangeYear(var AStart, AEnd: Word): Boolean;
    function GetLunarDaysDisplayType: TLunarDaysDisplayType;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ShellAPI, DateUtils, CalendarDataSaverToICS,
  SpecifiedForm;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FMakeCalendarCtrl   := TMakeCalendarController.Create;
  FSpecifiedDataCtrl  := TSpecifiedDateController.Create;

  pgcCalendar.ActivePageIndex := 0;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  Lunar: TLunarDateRec;
  Year, Month, Day: Word;
begin
  // ���� ����
  DecodeDate(Now, Year, Month, Day);

  // ���� �⺻ �� ����
  Lunar := FMakeCalendarCtrl.SolarToLunar(DateRec(Year, Month, Day));
  edtLunarYear.Text   := IntToStr(Lunar.Year);
  edtLunarMonth.Text  := IntToStr(Lunar.Month);
  edtLunarDay.Text    := IntToStr(Lunar.Day);

  // ��� �⺻ �� ����
  edtSolarYear.Text   := IntToStr(Year);
  edtSolarMonth.Text  := IntToStr(Month);
  edtSolarDay.Text    := IntToStr(Day);

  // ��� ���� ����
  edtStartOfRange.Text  := IntToStr(Year);
  edtEndOfRange.Text    := IntToStr(Year + 50);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FMakeCalendarCtrl.Free;
  FSpecifiedDataCtrl.Free;
end;

function TfrmMain.GetLunarDaysDisplayType: TLunarDaysDisplayType;
begin
  if rdoLunarDisplayDays5.Checked then        Result := lddt5
  else if rdoLunarDisplayDays10.Checked then  Result := lddt10
  else if rdoLunarDisplayDays15.Checked then  Result := lddt15
  else if rdoLunarDisplayDaysKor.Checked then Result := lddtKor
  else { default }                            Result := lddt5
  ;
end;

function TfrmMain.GetRangeYear(var AStart, AEnd: Word): Boolean;
begin
  Result := False;

  AStart  := StrToIntDef(edtStartOfRange.Text, 0);
  AEnd    := StrToIntDef(edtEndOfRange.Text, 0);

  if (AStart = 0) or (AEnd = 0) then
  begin
    ShowMessage('�޷� ���������� ��Ȯ�� �Է��� �ּ���.');
    edtStartOfRange.SetFocus;
    Exit;
  end;

  // ���� ���� ó��

  Result := True;
end;

//  1, �������ڸ� ������ڷ� ����
procedure TfrmMain.btnLunarToSolarClick(Sender: TObject);
var
  Lunar: TLunarDateRec;
  Solar: TSolarDateRec;
begin
  Lunar.Year  := StrToIntDef(edtLunarYear.Text, 0);
  Lunar.Month := StrToIntDef(edtLunarMonth.Text, 0);
  Lunar.Day   := StrToIntDef(edtLunarDay.Text, 0);
  Lunar.IsLeapMonth := chkLunarLeap.Checked;

  try
    Solar := FMakeCalendarCtrl.LunarToSolar(Lunar);

    ShowMessage(Format('���� ''%d�� %d�� %d''����'#13#10#13#10'��� ''%d�� %d�� %d��'' �Դϴ�.',
      [Lunar.Year, Lunar.Month, Lunar.Day, Solar.Year, Solar.Month, Solar.Day]));
  except on E: Exception do
    ShowMessage(E.Message);
  end;
end;

//  2, ������ڸ� �������ڷ� ����
procedure TfrmMain.btnSolarToLunarClick(Sender: TObject);
var
  Lunar: TLunarDateRec;
  Solar: TSolarDateRec;
begin
  Solar.Year  := StrToIntDef(edtSolarYear.Text, 0);
  Solar.Month := StrToIntDef(edtSolarMonth.Text, 0);
  Solar.Day   := StrToIntDef(edtSolarDay.Text, 0);

  try
    Lunar := FMakeCalendarCtrl.SolarToLunar(Solar);

    ShowMessage(Format('��� ''%d�� %d�� %d��''��'#13#10#13#10'���� ''%d�� %d�� %d''�� �Դϴ�.',
      [Solar.Year, Solar.Month, Solar.Day, Lunar.Year, Lunar.Month, Lunar.Day]));
  except on E: Exception do
    ShowMessage(E.Message);
  end;
end;

//  3, ���� �޷� ����
procedure TfrmMain.btnMakeLunarCalendarClick(Sender: TObject);
var
  StartOfRange, EndOfRange: Word;
begin
  if not GetRangeYear(StartOfRange, EndOfRange) then
    Exit;

  dlgsave.InitialDir := ExtractFilePath(Application.ExeName);
  dlgSave.FileName := Format('lunarcalendar_%d-%d.ics', [StartOfRange, EndOfRange]);
  if dlgSave.Execute then
  begin
    if FileExists(dlgSave.FileName) then
    begin
      if Application.MessageBox(PChar(Format('%s ������ �̹� �����մϴ�.'#13#10'�� ������ �ٲٽðڽ��ϱ�?', [dlgSave.Filename])), PChar('hjLunarCalendarGenerator'), MB_ICONQUESTION OR MB_YESNO) = ID_NO then
      begin
        Exit;
      end;
    end;

    try
      if FMakeCalendarCtrl.MakeLunarCalendar(StartOfRange, EndOfRange, GetLunarDaysDisplayType, dlgSave.FileName) then
        ShowMessage('�޷����� ������ �Ϸ��Ͽ����ϴ�.');
    except on E: Exception do
      ShowMessage('�޷����� ���� �� ������ �߻��߽��ϴ�.'#13#10 + Format('(��������: %s)', [E.Message]));
    end;
  end;
end;

//  4, ���� ����� �޷� ����
procedure TfrmMain.btnMakeSpecifiedCalendarClick(Sender: TObject);
var
  StartOfRange, EndOfRange: Word;
begin
  if not GetRangeYear(StartOfRange, EndOfRange) then
    Exit;

  ShowMessage('�غ� ��');
end;

// ���ڸ� �Է�
procedure TfrmMain.edtOnlyNumericKeyPress(Sender: TObject; var Key: Char);
begin
  if not (CharInSet(Key, ['0'..'9',#25,#08,#13])) then
    Key := #0;
end;

procedure TfrmMain.lblLunarDisplayDaysClick(Sender: TObject);
var
  lbl: TLabel absolute Sender;
begin
  if lbl = lblLunarDisplayDays10 then   rdoLunarDisplayDays10.Checked := True;
  if lbl = lblLunarDisplayDays15 then   rdoLunarDisplayDays15.Checked := True;
  if lbl = lblLunarDisplayDays5 then    rdoLunarDisplayDays5.Checked := True;
  if lbl = lblLunarDisplayDaysKor then  rdoLunarDisplayDaysKor.Checked := True;
end;

procedure TfrmMain.lblBlogClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(TLabel(Sender).Caption), nil, nil, SW_SHOW);
end;

procedure TfrmMain.lblBlogMouseEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
  TLabel(Sender).Font.Color := clBlue;
  TLabel(Sender).Cursor := crHandPoint;
end;

procedure TfrmMain.lblBlogMouseLeave(Sender: TObject);
begin
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style - [fsUnderline];
  TLabel(Sender).Font.Color := clBlack;
  TLabel(Sender).Cursor := crDefault;
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
var
  msg: string;
begin
  msg := '�� ���α׷��� �����̷� ���۵� �������α׷��̸�'#13#10
       + '����� �� ����� �̿뿡 ������ �����ϴ�.'#13#10
       + '�� ���α׷����� �߻��� ��� ������ ���ؼ���'#13#10
       + '�����ڴ� ��� å�ӵ� ���� �ʽ��ϴ�.';

  ShowMessage(msg);
end;

procedure TfrmMain.btnAddSpecifiedClick(Sender: TObject);
var
  MR: Integer;
begin
  frmSpecified := TfrmSpecified.Create(Self);
  try
    frmSpecified.Left := Self.Left + ((Self.Width - frmSpecified.Width ) div 2);
    frmSpecified.top  := Self.Top + ((Self.Height - frmSpecified.Height ) div 2);
    MR := frmSpecified.ShowModal;

    case MR of
    smrSave:
      FSpecifiedDataCtrl.Append(frmSpecified.Data);
    smrUpdate:
      FSpecifiedDataCtrl.Update(frmSpecified.Data);
    smrDelete:
      FSpecifiedDataCtrl.Delete(frmSpecified.Data);
    end;
  finally
    frmSpecified.Free;
  end;
end;

end.
