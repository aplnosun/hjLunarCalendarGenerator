unit CommonType;

interface

const
  // Invalid range error code
  ERROR_INVALID_RANGE_START = 10011;
  ERROR_INVALID_RANGE_END   = 10012;
  ERROR_INVALID_RANGE_YEAR  = 10020;
  ERROR_INVALID_RANGE_MONTH = 10030;
  ERROR_INVALID_RANGE_DAY   = 10040;

  DISP_DAYS_5DAY    = 110;  // 1, 5, 10, 15, 20, 25, 29(30)
  DISP_DAYS_10DAY   = 120;  // 1, 10, 20, 29(30)
  DISP_DAYS_15DAY   = 130;  // 1, 15, 29(30)
  DISP_DAYS_KOR     = 200;  // ����, ����, �׹�

  Days5Day: array[0..5] of Word = (1, 5, 10, 20, 25, 30);
  Days10Day: array[0..3] of Word = (1, 10, 20, 30);
  Days15Day: array[0..2] of Word = (1, 15, 30);
  DaysKor: array[0..2] of Word = (1, 15, 30);

  // �ѱ� ���̸�
  LunarKoreanMonthName: array[1..12] of string = (
      '����', '�̿�', '���', '���', '����',   '����'
    , 'ĥ��', '�ȿ�', '����', '�ÿ�', '������', '����'
  );
  LunarKoreanHalfMonth: string      = '����';
  LunarKoreanEndOfTheMonth: string  = '�׹�';

implementation

end.
