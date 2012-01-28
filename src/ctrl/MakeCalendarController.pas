unit MakeCalendarController;

interface

uses
  hjLunarDateType, hjLunarDateConverter, Classes, Windows, SysUtils,
  CalendarCommons, CalendarDataGenerator, CalendarDataSaver;

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
    function MakeSpecifiedCalendar(AStartOfRange, AEndOfRange: Word; APath: string): Boolean;

    function SupportRange: string;
  end;

implementation

uses
  LunarCalendarDataGenerator,
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

function TMakeCalendarController.SupportRange: string;
begin
  Result := Format('', [FLunDataConv.GetSupportLunarPriod]);
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
  APath: string): Boolean;
begin
  Result := False;
end;

end.
