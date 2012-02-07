unit MakeCalendarController;

interface

uses
  hjLunarDateType, hjLunarDateConverter, Classes, Windows, SysUtils,
  CalendarCommons, CalendarDataGenerator, CalendarDataSaver,
  SpecifiedData;

type
  TMakeCalendarController = class(TObject)
  private
    FLunDataConv: ThjLunarDateConverter;

    function MakeCalendar(AGenerator: TCalendarDataGenerator; ASaver: TCalendarDataSaver): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function SolarToLunar(ADate: TSolarDateRec): TLunarDateRec;
    function LunarToSolar(ADate: TLunarDateRec): TSolarDateRec;

    function MakeLunarCalendar(AStartOfRange, AEndOfRange: Word; ADisplayType: TLunarDaysDisplayType; APath: string): Boolean;
    function MakeSpecifiedCalendar(AStartOfRange, AEndOfRange: Word;
      ADispDate: Boolean; ADataList: TSpecifiedDataList; APath: string): Boolean;

    function SupportRangeYear(AYear: Word; var Msg: string): boolean;
  end;

implementation

uses
  LunarCalendarDataGenerator,
  SpecifiedCalendarDataGenerator,
  CalendarData,
  CalendarDataSaverToICS;

{ TMainController }

constructor TMakeCalendarController.Create;
begin
  FLunDataConv := ThjLunarDateConverter.Create;
end;

destructor TMakeCalendarController.Destroy;
begin
  FLunDataConv.Free;

  inherited;
end;

function TMakeCalendarController.LunarToSolar(ADate: TLunarDateRec): TSolarDateRec;
begin
  try
    Result := FLunDataConv.LunarToSolar(ADate);
  except
    raise
  end;
end;

function TMakeCalendarController.SolarToLunar(ADate: TSolarDateRec): TLunarDateRec;
begin
  try
    Result := FLunDataConv.SolarToLunar(ADate);
  except
    raise
  end;
end;

function TMakeCalendarController.SupportRangeYear(AYear: Word;
  var Msg: string): boolean;
begin
  Result := (AYear >= FLunDataConv.SupportLunarStart.Year) and (AYear <= FLunDataConv.SupportLunarEnd.Year);

//  AYear in [..FLunDataConv.SupportLunarEnd.Year];
  if not Result then
    Msg := Format('''%d''�⵵�� �������� �ʽ��ϴ�.'#13#10'(�����Ⱓ: %d�� ~ %d��)', [AYear, FLunDataConv.SupportLunarStart.Year, FLunDataConv.SupportLunarEnd.Year]);
end;

// �޷� ����
function TMakeCalendarController.MakeCalendar(AGenerator: TCalendarDataGenerator; ASaver: TCalendarDataSaver): Boolean;
var
  Data: TCalendarData;
begin
  try
    Data := AGenerator.NextData;

    if not Assigned(Data) then
      raise Exception.Create('�ش��ϴ� �����Ͱ� �����ϴ�.');

    ASaver.BeginSave;
    try
      while Assigned(Data) do
      begin
        ASaver.AddData(Data);

        Data := AGenerator.NextData;
      end;
    finally
      ASaver.EndSave;
    end;

    Result := True;
  except
    raise
  end;
end;

{
  FUNCTION
    ������ ǥ�õ� �޷��� ����
  PARAMETER
    AStartOfRange   : �޷� �������� ����
    AEndOfRange     : �޷� �������� ����
    ADispDays       : ����ǥ�� ����
    APath           : �޷� �������
  RETURN
    Boolean : �޷� ���� ���� ����
}
function TMakeCalendarController.MakeLunarCalendar(AStartOfRange, AEndOfRange: Word;
  ADisplayType: TLunarDaysDisplayType; APath: string): Boolean;
var
  Source: TLunarCalendarSource;
  Generator: TLunarCalendarDataGenerator;
  Saver: TCalendarSaverToICS;
begin
  Source    := TLunarCalendarSource.Create(ADisplayType);
  Generator := TLunarCalendarDataGenerator.Create(Source, AStartOfRange, AendOfRange);
  Saver     := TCalendarSaverToICS.Create(APath);
  try
    Result := MakeCalendar(Generator, Saver);
  finally
    Source.Free;
    Generator.Free;
    Saver.Free;
  end;
end;

function TMakeCalendarController.MakeSpecifiedCalendar(AStartOfRange, AEndOfRange: Word;
  ADispDate: Boolean; ADataList: TSpecifiedDataList; APath: string): Boolean;
var
  Source: TSpecifiedCalendarSource;
  Generator: TSpecifiedCalendarDataGenerator;
  Saver: TCalendarSaverToICS;
begin
  Source    := TSpecifiedCalendarSource.Create(ADispDate, ADataList);
  Generator := TSpecifiedCalendarDataGenerator.Create(Source, AStartOfRange, AendOfRange);
  Saver     := TCalendarSaverToICS.Create(APath);
  try
    Result := MakeCalendar(Generator, Saver);
  finally
    Source.Free;
    Generator.Free;
    Saver.Free;
  end;
end;

end.
