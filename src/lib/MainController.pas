{
  ������� INI���Ϸ� �����Ѵ�.
  ���´޷� �����ʹ�
}

unit MainController;

interface

uses
  hjLunarDateConverter, Classes, Windows, SysUtils,
  CalendarDataGenerate;

type
  TMainController = class(TObject)
  private
    FCalendarDataGenerator: TCalendarDataGenerate;
  public
    constructor Create;
    destructor Destroy; override;

    procedure test(A, B, C: Word);

    function SolarToLunar(ADate: TSolarDateRec): TLunarDateRec;
    function LunarToSolar(ADate: TLunarDateRec): TSolarDateRec;
  end;

implementation

uses
  StrUtils;

{ TMainController }

constructor TMainController.Create;
begin
//  FLunarCalc := ThjLunarDateConverter.Create;
end;

destructor TMainController.Destroy;
begin
//  FLunarCalc.Free;

  inherited;
end;

function TMainController.LunarToSolar(ADate: TLunarDateRec): TSolarDateRec;
begin

end;

function TMainController.SolarToLunar(ADate: TSolarDateRec): TLunarDateRec;
begin

end;

procedure TMainController.test(A, B, C: Word);
begin
//  with TCalendarDataGenerate.Create();
end;

end.
