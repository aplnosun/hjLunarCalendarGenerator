unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  hjLunarDateType, CalendarCommons, MakeCalendarController,
  SpecifiedData, SpecifiedDataController;

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
    procedure edtNextFocusKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvSpecifiedDblClick(Sender: TObject);
  private
    { Private declarations }
    FMakeCalendarCtrl: TMakeCalendarController;
    FSpecifiedDataCtrl: TSpecifiedDateController;

    // ���´޷� ����
    function GetRangeYear(var AStart, AEnd: Word): Boolean;
    function GetLunarDaysDisplayType: TLunarDaysDisplayType;

    // ����� �޷� ����
    procedure DisplaySpecifiedData;
    procedure ShowSpecifiedDialog(AData: TSpecifiedData);

    procedure AppendSpecifiedData(AData: TSpecifiedData);
    procedure DeleteSpecifiedData(AData: TSpecifiedData);
    procedure UpdateSpecifiedData(AData: TSpecifiedData);
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

function GetApplicationVersion(var Major, Minor, Release, Build: Word): Boolean;
var
  VerInfoSize: DWord;
  VerInfo: Pointer;
  VerValueSize: DWord;
  VerValue: PVSFixedFileInfo;
  Dummy: DWord;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(Application.ExeName), dummy);
  GetMem(VerInfo, VerInfoSize);
  try
    GetFileVersionInfo(PChar(Application.ExeName), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
    with VerValue^ do
    begin
      Major   := dwFileVersionMS shr 16;
      Minor   := dwFileVersionMS and $FFFF;
      Release := dwFileVersionLS shr 16;
      Build   := dwFileVersionLS and $FFFF;
    end;

    Result := True;
  finally
    FreeMem(VerInfo, VerInfoSize);
  end;
end;

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
  V1, V2, V3, V4: Word;
begin

  if GetApplicationVersion(V1, V2, V3, V4) then
    Caption := Caption + Format('(ver.%d.%d.%d)', [V1, V2, V3]);

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

  lvSpecified.Clear;
  DisplaySpecifiedData;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FMakeCalendarCtrl.Free;
  FSpecifiedDataCtrl.Free;
end;

function TfrmMain.GetRangeYear(var AStart, AEnd: Word): Boolean;
var
  Msg: string;
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
  if not FMakeCalendarCtrl.SupportRangeYear(AStart, Msg) then
  begin
    ShowMessage(Msg);
    Exit;
  end;

  if not FMakeCalendarCtrl.SupportRangeYear(AEnd, Msg) then
  begin
    ShowMessage(Msg);
    Exit;
  end;

  Result := True;
end;

// ���ڸ� �Է�
procedure TfrmMain.edtNextFocusKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Length(TEdit(Sender).Text) = TEdit(Sender).MaxLength then
  begin
    Key := 0;
    SelectNext(Sender as TWinControl, True, True);
  end;
end;

procedure TfrmMain.edtOnlyNumericKeyPress(Sender: TObject; var Key: Char);
begin
  if not (CharInSet(Key, ['0'..'9',#25,#08,#13])) then
    Key := #0;
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
       + '����� �� ����� �̿뿡 ������ �����ϴ�.'#13#10#13#10
       + '�� ���α׷����� �߻��� ��� ������ ��������'#13#10
       + '�����ڴ� �ƹ��� å�ӵ� ���� �ʽ��ϴ�.'#13#10#13#10
  ;

  ShowMessage(msg);
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

  dlgsave.InitialDir := ExtractFilePath(Application.ExeName);
  dlgSave.FileName := Format('specfiedcalendar_%d-%d.ics', [StartOfRange, EndOfRange]);
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
      if FMakeCalendarCtrl.MakeSpecifiedCalendar(StartOfRange, EndOfRange, FSpecifiedDataCtrl.DataList, dlgSave.FileName) then
        ShowMessage('�޷����� ������ �Ϸ��Ͽ����ϴ�.');
    except on E: Exception do
      ShowMessage('�޷����� ���� �� ������ �߻��߽��ϴ�.'#13#10 + Format('(��������: %s)', [E.Message]));
    end;
  end;
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

procedure TfrmMain.lblLunarDisplayDaysClick(Sender: TObject);
var
  lbl: TLabel absolute Sender;
begin
  if lbl = lblLunarDisplayDays10 then   rdoLunarDisplayDays10.Checked := True;
  if lbl = lblLunarDisplayDays15 then   rdoLunarDisplayDays15.Checked := True;
  if lbl = lblLunarDisplayDays5 then    rdoLunarDisplayDays5.Checked := True;
  if lbl = lblLunarDisplayDaysKor then  rdoLunarDisplayDaysKor.Checked := True;
end;

// ����� ������ ǥ��
procedure TfrmMain.DisplaySpecifiedData;
var
  I: Integer;
  Data: TSpecifiedData;
  Item: TListItem;
begin
  lvSpecified.Clear;
  for I := 0 to FSpecifiedDataCtrl.Count - 1 do
  begin
    Data := FSpecifiedDataCtrl[I];
    Item := lvSpecified.Items.Add;
    Item.Caption := Format('%.2d�� %s��', [Data.Month, Data.DayStr]);
    Item.SubItems.Add(Data.Summary);
    Item.Data := Data;
  end;
end;

procedure TfrmMain.ShowSpecifiedDialog(AData: TSpecifiedData);
var
  MR: Integer;
begin
  frmSpecified := TfrmSpecified.Create(Self);
  try
    frmSpecified.Left := Self.Left + ((Self.Width - frmSpecified.Width ) div 2);
    frmSpecified.top  := Self.Top + ((Self.Height - frmSpecified.Height ) div 2);
    frmSpecified.Data := AData;
    MR := frmSpecified.ShowModal;

    case MR of
    smrSave:
      AppendSpecifiedData(frmSpecified.Data);
    smrUpdate:
      UpdateSpecifiedData(frmSpecified.Data);
    smrDelete:
      DeleteSpecifiedData(frmSpecified.Data);
    end;
  finally
    frmSpecified.Free;
  end;
end;

// ���� �߰�
procedure TfrmMain.btnAddSpecifiedClick(Sender: TObject);
begin
  ShowSpecifiedDialog(nil);
end;

// ���� ����
procedure TfrmMain.lvSpecifiedDblClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := TListView(Sender).Selected;
  if Assigned(Item) then
  begin
    ShowSpecifiedDialog(Item.Data);
  end;
end;

// ����� �߰�
procedure TfrmMain.AppendSpecifiedData(AData: TSpecifiedData);
var
  I: Integer;
  msg: string;
  Datas: TSpecifiedDatas;

  Item: TListItem;
begin
  if not Assigned(AData) then
    Exit;

  Datas := FSpecifiedDataCtrl.GetDatas(AData.Month, AData.Day);

  if Datas.Count > 0 then
  begin
    msg := Format('[%d�� %s��]���� �̹� %d���� ������� ��ϵǾ� �ֽ��ϴ�.', [AData.Month, AData.DayStr, Datas.Count]);
    for I := 0 to Datas.Count - 1 do
      msg := msg + Format(#13#10' - %s', [Datas[I].Summary]);
    msg := msg + #13#10#13#10'�߰��� ������� ����Ͻðڽ��ϱ�?';

    if Application.MessageBox(PChar(msg), PChar('hjLunarCalendarGenerator'), MB_ICONQUESTION OR MB_YESNO) = ID_NO then
      Exit;
  end;

  if FSpecifiedDataCtrl.AppendData(AData) then
  begin
    Item := lvSpecified.Items.Add;
    Item.Caption := Format('%.2d�� %s��', [AData.Month, AData.DayStr]);
    Item.SubItems.Add(AData.Summary);
    Item.Data := AData;
  end;
end;

// ����� ����(�ܰ�)
procedure TfrmMain.DeleteSpecifiedData(AData: TSpecifiedData);
var
  I: Integer;
  Data: TSpecifiedData;
begin
  for I := 0 to lvSpecified.Items.Count - 1 do
  begin
    Data := lvSpecified.Items[I].Data;
    if Data = AData then
    begin
      lvSpecified.Items.Delete(I);
      Break;
    end;
  end;

  FSpecifiedDataCtrl.DeleteData(AData);
end;

// ����� ����(����)
procedure TfrmMain.UpdateSpecifiedData(AData: TSpecifiedData);
var
  Item: TListItem;
begin
  FSpecifiedDataCtrl.UpdateData(AData);

  Item := lvSpecified.Selected;
  Item.Caption := Format('%.2d�� %s��', [AData.Month, AData.DayStr]);
  Item.SubItems[0] := AData.Summary;
end;

end.
