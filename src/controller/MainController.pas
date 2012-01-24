{
  1, ���� ��� ����
  2, �޷� ����
  3, ����� ���� ���
}

unit MainController;

interface

uses
  hjLunarDateType, hjLunarDateConverter, Classes, Windows, SysUtils,
  CalendarCommons, CalendarDataGenerator, CalendarDataSaver;

type
  TMainController = class(TObject)
  private
    FLunDataConv: ThjLunarDateConverter;
//    FCalDataGen: TCalendarDataGenerate;
    function MakeCalendar(AGenerator: TCalendarDataGenerator; ASaver: TCalendarDataSaver): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function SolarToLunar(ADate: TSolarDateRec): TLunarDateRec;
    function LunarToSolar(ADate: TLunarDateRec): TSolarDateRec;

    function MakeLunarCalendar(AStartOfRange, AEndOfRange: Word; ADispDays: TDispDays; APath: string): Boolean;
    function MakeSpecifiedCalendar(AStartOfRange, AEndOfRange: Word; APath: string): Boolean;
  end;

implementation

uses
  LunarCalendarDataGenerator,
  CalendarDataSaverToICS;

{ TMainController }

constructor TMainController.Create;
begin
  FLunDataConv := ThjLunarDateConverter.Create;
//  FCalDataGen
end;

destructor TMainController.Destroy;
begin
  FLunDataConv.Free;

  inherited;
end;

function TMainController.LunarToSolar(ADate: TLunarDateRec): TSolarDateRec;
begin
  try
    Result := FLunDataConv.LunarToSolar(ADate);
  except
    raise
  end;
end;

function TMainController.SolarToLunar(ADate: TSolarDateRec): TLunarDateRec;
begin
  try
    Result := FLunDataConv.SolarToLunar(ADate);
  except
    raise
  end;
end;

function TMainController.MakeCalendar(AGenerator: TCalendarDataGenerator; ASaver: TCalendarDataSaver): Boolean;
var
  Data: TCalendarData;
begin
  Data := AGenerator.Next;

  while Assigned(Data) do
  begin
    ASaver.AddData(Data);

    AGenerator.Next;
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
function TMainController.MakeLunarCalendar(AStartOfRange, AEndOfRange: Word; ADispDays: TDispDays; APath: string): Boolean;
var
  Source: TLunarCalendarSource;
  Generator: TLunarCalendarDataGenerator;
  Saver: TCalendarSaverToICS;
begin
  Source    := TLunarCalendarSource.Create(ADispDays);
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

function TMainController.MakeSpecifiedCalendar(AStartOfRange, AEndOfRange: Word;
  APath: string): Boolean;
begin

end;

end.
