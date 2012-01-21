unit hjLunarDateConverter;

interface

uses
  Windows, Classes, SysUtils, hjLunarDateType;

type
  ERangeError = class(Exception);

  ThjLunarDateConverter = class(TObject)
  private
    procedure RangeError(const Msg: string);
  protected
    procedure ValidateDate(ADate: TSolarDateRec); overload;
    procedure ValidateDate(ADate: TLunarDateRec); overload;
  public
    constructor Create;
    destructor Destroy; override;

    procedure test;

    function SolarToLunar(ADate: TSolarDateRec): TLunarDateRec;
    function LunarToSolar(ADate: TLunarDateRec): TSolarDateRec;

    function GetLunarDaysOfMonth(AYear, AMonth: Word; AIsLeapMonth: Boolean): Word;

    function GetSupportSolarPriod: string;
    function GetSupportLunarPriod: string;
  end;

implementation

uses
  Math, DateUtils, CalendarCommons;

{$include LunarTableData.inc}


{ ThjLunarCalculator }

constructor ThjLunarDateConverter.Create;
begin

end;

destructor ThjLunarDateConverter.Destroy;
begin

  inherited;
end;

function ThjLunarDateConverter.GetSupportLunarPriod: string;
begin
  Result := Format('%s-1-1~%s-12-31)', [SupportYearStart, SupportYearEnd]);
end;

function ThjLunarDateConverter.GetSupportSolarPriod: string;
begin
  Result := SupportDateStartStr + '~' + SupportDateEndStr;
end;

procedure ThjLunarDateConverter.RangeError(const Msg: string);
  function ReturnAddr: Pointer;
  asm
    MOV     EAX,[EBP+4]
  end;
begin
  raise ERangeError.Create(Msg) at ReturnAddr;
end;

procedure ThjLunarDateConverter.ValidateDate(ADate: TSolarDateRec);
var
  ErrMsg: string;
begin
  ErrMsg := Format('��ȿ������ ���� �����ϴ�.(������� ����: %0:s~%1:s)', [SupportDateStartStr, SupportDateEndStr]);

  // ### ���� ���� ����
  if ADate.Year < SupportYearStart then
    RangeError(ErrMsg);

  // ��� ���� ������ ����
  if (ADate.Year = SupportYearStart) and (ADate.Month = 1) and (ADate.Day <= StandardBetweenStart) then
    RangeError(ErrMsg); // INVALID_RANGE_START

  // ��� ���� ������ ����
  if (ADate.Year > SupportYearEnd) and ((ADate.Month > 1) or (ADate.Day > StandardBetweenEnd)) then
    RangeError(ErrMsg); // INVALID_RANGE_END

  // ### �� ���� ����
  if (ADate.Month < 1) or (ADate.Month > 12) then
    RangeError(Format('''%0:d''���� ��ȿ���� ���� ���Դϴ�.', [ADate.Month]));

  // ### �� ���� ����
  if (ADate.Day < 1) or (MonthDays[IsLeapYear(ADate.Year)][ADate.Month] < ADate.Day) then
    RangeError(Format('''%0:d''���� ��ȿ���� ���� �����Դϴ�.', [ADate.Day]));
end;

procedure ThjLunarDateConverter.ValidateDate(ADate: TLunarDateRec);
var
  I: Integer;
  ErrMsg: string;
  MonthTable: string;
  MonthIndex: Integer;
  DaysOfMonth: Integer;
begin
  // ### ���� ���� ����
  if (ADate.Year < SupportYearStart) or (ADate.Year > SupportYearEnd) then
  begin
    ErrMsg := Format('��ȿ������ ���� �����ϴ�.(�������� ����: %0:d-01-01~%1:d-12-31)', [SupportYearStart, SupportYearEnd]);
    RangeError(ErrMsg);
  end;

  // ### �� ���� ����
  if (ADate.Month < 1) or (ADate.Month > 12) then
    RangeError(Format('''%0:d''���� ��ȿ���� ���� ���Դϴ�.', [ADate.Month]));

  // ### �� ���� ����
  if (ADate.Day < 1) then
    RangeError(Format('''%0:d''���� ��ȿ���� ���� �����Դϴ�.', [ADate.Day]));

  // ��� �ҿ� ����
  MonthTable := LunarMonthTable[ADate.Year - SupportYearStart];
  MonthIndex := ADate.Month;
  for I := 1 to ADate.Month do
  begin
    if CharInSet(MonthTable[I], ['3', '4']) then
      Inc(MonthIndex);
  end;
  DaysOfMonth := IfThen(CharInSet(MonthTable[MonthIndex], ['1', '3']), 29, 30);
  if ADate.Day > DaysOfMonth then
    RangeError(Format('���� ''%0:d�� %1:d��''�� ''%3:d��'' ���� �ֽ��ϴ�.(''%2:d��''�� ��ȿ���� �ʽ��ϴ�.)', [ADate.Year, ADate.Month, ADate.Day, DaysOfMonth]));

  // ���� ����
  MonthTable := LunarMonthTable[ADate.Year - SupportYearStart];
  if ADate.IsLeapMonth and (not CharInSet(MonthTable[ADate.Month+1], ['3', '4'])) then
    RangeError(Format('���� ''%0:d�� %1:d��''�� ������ �ƴմϴ�.', [ADate.Year, ADate.Month]));
end;

{===============================================================================
  # �������ڸ� ������ڷ� ��ȯ�Ͽ� ��ȯ
  # Parameter
    ADate: TLunarDateRec : ��ȯ ��� ��������(���޿��� ����)
  # Return
    TSolarDateRec: ��ȯ�� ��� ����
===============================================================================}
function ThjLunarDateConverter.LunarToSolar(ADate: TLunarDateRec): TSolarDateRec;
  function GetDayCountFromYear(AYear: Word): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to AYear - SupportYearStart do
      Result := Result + LunarYearDays[I];
  end;

  function GetDayCountFromMonth(AYear, AMonth: Word; AIsLeap: Boolean): Integer;
  var
    I: Integer;
    MonthTable: string;
  begin
    Result := 0;
    MonthTable := LunarMonthTable[AYear - SupportYearStart];
    if AIsLeap then
      Inc(AMonth);
    for I := 1 to AMonth do
      Result := Result + IfThen(CharInSet(MonthTable[I], ['1', '3']), 29, 30);
  end;

var
  I: Integer;
  DayCount: Integer;
  DaysOfYear, DaysOfMonth: Integer;
begin
  try
    ValidateDate(ADate);
  except
    raise;
  end;

  ZeroMemory(@Result, SizeOf(Result));

  // ###### ����ϼ� ���ϱ� ######
  // [STEP 1] ����> ���س� ���� ���⵵������ ������ �ϼ� ����
  // [STEP 2] ����> �������� ���� �ϼ� ����(����ó�� ����)
  // [STEP 3] ����> ���� ����

  DayCount := 0;
  // STEP 1
  DayCount := DayCount + GetDayCountFromYear(ADate.Year - 1);
  // STEP 2
  DayCount := DayCount + GetDayCountFromMonth(ADate.Year, ADate.Month - 1, ADate.IsLeapMonth);
  // STEP 3
  DayCount := DayCount + ADate.Day;


  // [STEP 4] �������� �������� ����
    // ��)1/1 = ��)1/30 ��� �Ʒ� ���� �� ��� 1/1�Ϻ��� ����ϹǷ� 29���� ����
  DayCount := DayCount + StandardBetweenStart;

  // ###### ����ϼ����� ��������  ���ϱ� ######
  // [STEP 5] ���> ������ ���ڼ� �����ϸ� ���� ����
  // [STEP 6] ���> ���� ���ڼ� �����ϸ� �� ����
  // [STEP 7] ���> �ܿ��� �� �Ϸ� ���

  // STEP 5
  Result.Year := SupportYearStart - 1;
  for I := 0 to SupportYearCount - 1 do
  begin
    Inc(Result.Year);

    DaysOfYear := DaysPerYear[IsLeapYear(SupportYearStart + I)];
    if DayCount <= DaysOfYear then
      Break;

    DayCount := DayCount - DaysOfYear;
  end;

  // STEP 6
  Result.Month := 0;
  for I := 1 to 12 do
  begin
    Inc(Result.Month);

    DaysOfMonth := MonthDays[IsLeapYear(Result.Year)][I];
    if DayCount <= DaysOfMonth then
      Break;

    DayCount := DayCount - DaysOfMonth;
  end;

  // STEP 7
  Result.Day := DayCount;
end;

{===============================================================================
  # ������ڸ� �������ڷ� ��ȯ�Ͽ� ��ȯ
  # Parameter
    ADate: TSolarDateRec - ��ȯ ��� �������
  # Return
    TLunarDateRec - ��ȯ�� ��������(���޿��� ����)
===============================================================================}
function ThjLunarDateConverter.SolarToLunar(ADate: TSolarDateRec): TLunarDateRec;
  // ���س⵵ ���� ��û �⵵������ �ϼ� �� ��ȯ
  function GetDayCountFromYear(AYear: Word): Integer;
  begin
    Result := (AYear * 365) + (AYear div 4) - (AYear div 100) + (AYear div 400);
    Result := Result - StandardDateDelta;
  end;

  // ��û�⵵�� ������ �ϼ� �� ��ȯ
  function GetDayCountFromMonth(AYear, AMonth: Word): Integer;
  var
    I: Integer;
  begin
    Result := 0;

    for I := 1 to AMonth do
      Inc(Result, MonthDays[IsLeapYear(AYear)][I]);
  end;
var
  I: Integer;
  DayCount, MonDays: Integer;
  MonthTable: string;
begin
  try
    ValidateDate(ADate);
  except
    raise;
  end;

  ZeroMemory(@Result, SizeOf(Result));

  // ###### ����ϼ� ���ϱ� ######
  // [STEP 1] ���> ���س� ���� ���⵵���� ������ ���ڼ� ����
  // [STEP 2] ���> �������� ���� �ϼ� ����(����ó�� ����)
  // [STEP 3] ���> ���� ����

  DayCount := 0;
  // STEP 1
  DayCount := DayCount + GetDayCountFromYear(ADate.Year - 1);
  // STEP 2
  DayCount := DayCount + GetDayCountFromMonth(ADate.Year, ADate.Month - 1);
  // STEP 3
  DayCount := DayCount + ADate.Day;

  // [STEP 4] �������� �������� ����
    // ��)1/1 = ��)1/30 ��� �Ʒ� ���� �� ��]1/30(��]1/1)�Ϻ��� ����ؾ� �ϹǷ� 29 ����
  DayCount := DayCount - StandardBetweenStart;

  // ###### ����ϼ����� ��������  ���ϱ� ######
  // [STEP 5] ����> ���� �� ���� ���� ���� ���� ����
  // [STEP 6] ����> ���� ���� ���� ���� �� ����
    // 6-1> ��޸� ���¿� ����(������ ������ �޹�ȣ ��ӻ��, ex>...3��,��3��,4��...)
    // 6-2> ���¿��� ��/�ҿ� ����(29 or 30)
    // 6-3> �ܿ��ϼ�(DayCount)�� ���¿��� �ϼ����� �۾��������� �ݺ�
  // [STEP 7] �ܿ� �ϼ��� �����Ϸ� ó��

  // STEP 5
  Result.Year := SupportYearStart - 1;
  for I := 0 to Length(LunarYearDays) - 1 do
  begin
    Inc(Result.Year);

    if LunarYearDays[I] >= DayCount  then
      Break;

    DayCount := DayCount - LunarYearDays[I];
  end;

  // STEP 6
  Result.Month := 0;
  MonthTable := LunarMonthTable[I];
  for I := 1 to Length(MonthTable) do
  begin
    // 6-1
    if CharInSet(MonthTable[I], ['1', '2']) then
      Inc(Result.Month);

    // 6-2
    if CharInSet(MonthTable[I], ['1', '3']) then      // �ҿ��� 29��
      MonDays := 29
    else if CharInSet(MonthTable[I], ['2', '4']) then // ����� 30��
      MonDays := 30
    else
      raise Exception.CreateFmt('Incorrect lunar month table data(Index: %d, Char: %s)', [I, MonthTable[I]])
    ;

    // 6-3
    if MonDays >= DayCount then
    begin
      if CharInSet(MonthTable[I], ['3', '4']) then
        Result.IsLeapMonth := True;
      Break;
    end;

    DayCount := DayCount - MonDays;
  end;

  // STEP 7
  Result.Day := DayCount;
end;

procedure ThjLunarDateConverter.test;
var
  I, J, Sum: Integer;
begin
  for I := 0 to Length(LunarMonthTable) - 1 do
  begin
    Sum := 0;
    for J := 0 to Length(LunarMonthTable[I]) - 1 do
    begin

      if CharInSet(LunarMonthTable[I][J], ['1', '3']) then
        Sum := Sum + 29
      else if CharInSet(LunarMonthTable[I][J], ['2', '4']) then
        Sum := Sum + 30
      ;
    end;

    if Sum <> LunarYearDays[I] then
      OutputDebugString(PChar(Format('Incorrect Index: %d, SumDays: (%d, %d)', [I, Sum, LunarYearDays[I]])));
  end;
  OutputDebugString(PChar('Correct Table data'));
end;

// ���� ���� ������ ���� ��ȯ�Ѵ�.
function ThjLunarDateConverter.GetLunarDaysOfMonth(AYear, AMonth: Word;
  AIsLeapMonth: Boolean): Word;
var
  MonthTable: string;
  I, MonthIndex: Integer;
begin
  Result := 0;
  MonthTable := LunarMonthTable[AYear - SupportYearStart];

  MonthIndex := AMonth;
  // ��û���� ������ ������ ������ Index ����
  for I := 1 to AMonth do
  begin
    if CharInSet(MonthTable[I], ['3', '4']) then
      Inc(MonthIndex);
  end;

  // ���޿�û ��� ����
  if AIsLeapMonth then
  begin
    Inc(MonthIndex);
    // ���� ������ �ƴϸ� ����
    if not CharInSet(MonthTable[MonthIndex], ['3', '4']) then
      Exit;
    Result := IfThen(MonthTable[MonthIndex] = '3', 29, 30);
  end;

  Result := IfThen(MonthTable[MonthIndex] = '1', 29, 30);
end;


end.



