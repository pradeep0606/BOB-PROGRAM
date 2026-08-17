**FREE
// Utility Program - Free Format SQLRPGLE
// Program: UTILPGM - Common Utility Functions
// Provides transaction ID generation, date/time handling, currency conversion

Ctl-Opt DftActGrp(*No) ActGrp('PAYMENT') BndDir('PAYMENTBD');
Ctl-Opt Option(*SrcStmt:*NoDebugIO) DatFmt(*ISO) TimFmt(*ISO);

Dcl-Pi *N;
  pTransactionId Char(20);
  pProcessDate Date;
  pProcessTime Time;
  pCurrencyCode Char(3);
  pExchangeRate Packed(9:4);
End-Pi;

Dcl-S wSequenceNbr Packed(10:0);
Dcl-S wRandomNbr Packed(10:0);
Dcl-S wChecksum Packed(5:0);
Dcl-S wDateString Char(8);
Dcl-S wTimeString Char(6);
Dcl-S wMillisecs Packed(3:0);
Dcl-S wMicrosecs Packed(6:0);
Dcl-S wTimestamp Timestamp;
Dcl-S wJobName Char(10);
Dcl-S wJobUser Char(10);
Dcl-S wJobNumber Char(6);
Dcl-S wSystemName Char(8);
Dcl-S wIPAddress Char(15);
Dcl-S wMACAddress Char(17);
Dcl-S wHostName Char(30);
Dcl-S wDomainName Char(30);
Dcl-S wServerPort Packed(5:0);
Dcl-S wProtocol Char(5);
Dcl-S wSessionId Char(32);
Dcl-S wCorrelationId Char(36);
Dcl-S wRequestId Char(25);
Dcl-S wTraceId Char(32);
Dcl-S wSpanId Char(16);
Dcl-S wParentSpanId Char(16);
Dcl-S wYear Packed(4:0);
Dcl-S wMonth Packed(2:0);
Dcl-S wDay Packed(2:0);
Dcl-S wHour Packed(2:0);
Dcl-S wMinute Packed(2:0);
Dcl-S wSecond Packed(2:0);
Dcl-S wDayOfWeek Packed(1:0);
Dcl-S wDayOfYear Packed(3:0);
Dcl-S wWeekOfYear Packed(2:0);
Dcl-S wQuarter Packed(1:0);
Dcl-S wIsLeapYear Ind;
Dcl-S wIsWeekend Ind;
Dcl-S wIsHoliday Ind;
Dcl-S wIsBusinessDay Ind;
Dcl-S wWorkingDays Packed(3:0);
Dcl-S wCalendarDays Packed(3:0);
Dcl-S wBusinessHours Packed(5:2);
Dcl-S wElapsedDays Packed(5:0);
Dcl-S wElapsedHours Packed(7:0);
Dcl-S wElapsedMins Packed(9:0);
Dcl-S wElapsedSecs Packed(11:0);
Dcl-S wStartDate Date;
Dcl-S wEndDate Date;
Dcl-S wStartTime Time;
Dcl-S wEndTime Time;
Dcl-S wDuration Packed(11:0);
Dcl-S wInterval Packed(9:0);
Dcl-S wFrequency Packed(5:0);
Dcl-S wPeriodType Char(1);
Dcl-S wPeriodLength Packed(3:0);
Dcl-S wCycleCount Packed(5:0);
Dcl-S wIterationNbr Packed(5:0);
Dcl-S wLoopCounter Packed(3:0);
Dcl-S wArrayIndex Packed(2:0);
Dcl-S wMatrixRow Packed(2:0);
Dcl-S wMatrixCol Packed(2:0);
Dcl-S wBaseRate Packed(9:4);
Dcl-S wSpotRate Packed(9:4);
Dcl-S wForwardRate Packed(9:4);
Dcl-S wCrossRate Packed(9:4);
Dcl-S wBidRate Packed(9:4);
Dcl-S wAskRate Packed(9:4);
Dcl-S wMidRate Packed(9:4);
Dcl-S wSpread Packed(9:4);
Dcl-S wMargin Packed(9:4);
Dcl-S wCommission Packed(9:4);
Dcl-S wMarkup Packed(9:4);
Dcl-S wDiscount Packed(9:4);
Dcl-S wPremium Packed(9:4);
Dcl-S wVolatility Packed(9:4);
Dcl-S wBeta Packed(9:4);
Dcl-S wAlpha Packed(9:4);
Dcl-S wGamma Packed(9:4);
Dcl-S wDelta Packed(9:4);
Dcl-S wTheta Packed(9:4);
Dcl-S wVega Packed(9:4);
Dcl-S wRho Packed(9:4);
Dcl-S wMultiplier Packed(9:4);
Dcl-S wDivisor Packed(9:4);
Dcl-S wExponent Packed(3:0);
Dcl-S wPower Packed(15:2);
Dcl-S wRoot Packed(15:2);
Dcl-S wLogarithm Packed(15:2);
Dcl-S wExponential Packed(15:2);
Dcl-S wSine Packed(15:2);
Dcl-S wCosine Packed(15:2);
Dcl-S wTangent Packed(15:2);
Dcl-S wArcSine Packed(15:2);
Dcl-S wArcCosine Packed(15:2);
Dcl-S wArcTangent Packed(15:2);
Dcl-S wHyperbolic Packed(15:2);
Dcl-S wAbsolute Packed(15:2);
Dcl-S wCeiling Packed(15:2);
Dcl-S wFloor Packed(15:2);
Dcl-S wRound Packed(15:2);
Dcl-S wTruncate Packed(15:2);
Dcl-S wModulo Packed(15:2);
Dcl-S wRemainder Packed(15:2);
Dcl-S wQuotient Packed(15:2);
Dcl-S wProduct Packed(15:2);
Dcl-S wSum Packed(15:2);
Dcl-S wDifference Packed(15:2);
Dcl-S wAverage Packed(15:2);
Dcl-S wMedian Packed(15:2);
Dcl-S wMode Packed(15:2);
Dcl-S wRange Packed(15:2);
Dcl-S wVariance Packed(15:2);
Dcl-S wStdDeviation Packed(15:2);
Dcl-S wCovariance Packed(15:2);
Dcl-S wCorrelation Packed(9:4);
Dcl-S wRegression Packed(9:4);
Dcl-S wSlope Packed(9:4);
Dcl-S wIntercept Packed(15:2);
Dcl-S wRSquared Packed(9:4);
Dcl-S wPValue Packed(9:4);
Dcl-S wTStatistic Packed(9:4);
Dcl-S wZScore Packed(9:4);
Dcl-S wConfidence Packed(9:4);
Dcl-S wSignificance Packed(9:4);
Dcl-S wProbability Packed(9:4);
Dcl-S wLikelihood Packed(9:4);
Dcl-S wOddsRatio Packed(9:4);
Dcl-S wRiskRatio Packed(9:4);
Dcl-S wHazardRatio Packed(9:4);
Dcl-S wUtilArray Packed(15:2) Dim(20);
Dcl-S wRateMatrix Packed(9:4) Dim(10:10);
Dcl-S wTempValue1 Packed(15:2);
Dcl-S wTempValue2 Packed(15:2);
Dcl-S wTempValue3 Packed(15:2);
Dcl-S wCalcValue1 Packed(15:2);
Dcl-S wCalcValue2 Packed(15:2);
Dcl-S wCalcValue3 Packed(15:2);
Dcl-S wValidFlag Ind;
Dcl-S wErrorFlag Ind;
Dcl-S wWarningFlag Ind;

Exec Sql
  Declare C1 Cursor For
  Select SEQNBR, CURRCODE, BASERATE, SPOTRATE,
         FORWARDRATE, BIDRATE, ASKRATE, SPREAD
  From CURRENCYRATES
  Where CURRCODE = :pCurrencyCode
    And EFFECTDATE <= Current Date
  Order By EFFECTDATE Desc
  Fetch First 1 Row Only
  For Read Only;

Exec Sql
  Declare C2 Cursor For
  Select SYSNAME, HOSTNAME, IPADDR, MACADDR,
         DOMAIN, PROTOCOL, SERVERPORT
  From SYSTEMCONFIG
  Where ACTIVE = 'Y'
  Fetch First 1 Row Only
  For Read Only;

wValidFlag = *Off;
wErrorFlag = *Off;
wWarningFlag = *Off;
wSequenceNbr = 0;
wRandomNbr = 0;
wChecksum = 0;
wMultiplier = 1.0000;
wDivisor = 1.0000;
wArrayIndex = 1;
wSum = 0;
pExchangeRate = 1.0000;

pProcessDate = %Date();
pProcessTime = %Time();
wTimestamp = %Timestamp();

wYear = %Subdt(pProcessDate:*Years);
wMonth = %Subdt(pProcessDate:*Months);
wDay = %Subdt(pProcessDate:*Days);
wHour = %Subdt(pProcessTime:*Hours);
wMinute = %Subdt(pProcessTime:*Minutes);
wSecond = %Subdt(pProcessTime:*Seconds);

wDayOfWeek = %Rem(%Diff(pProcessDate:Date('0001-01-01'):*Days):7) + 1;
wDayOfYear = %Diff(pProcessDate:Date(%Char(wYear)+'-01-01'):*Days) + 1;

If wMonth <= 3;
  wQuarter = 1;
ElseIf wMonth <= 6;
  wQuarter = 2;
ElseIf wMonth <= 9;
  wQuarter = 3;
Else;
  wQuarter = 4;
EndIf;

wIsLeapYear = *Off;
If %Rem(wYear:4) = 0;
  If %Rem(wYear:100) = 0;
    If %Rem(wYear:400) = 0;
      wIsLeapYear = *On;
    EndIf;
  Else;
    wIsLeapYear = *On;
  EndIf;
EndIf;

wIsWeekend = *Off;
If wDayOfWeek = 1 Or wDayOfWeek = 7;
  wIsWeekend = *On;
EndIf;

wJobName = 'QPADEV0001';
wJobUser = 'QPGMR';
wJobNumber = '123456';

wSequenceNbr = (%Int(wYear) * 10000000) + 
               (%Int(wMonth) * 100000) + 
               (%Int(wDay) * 1000) + 
               %Int(wHour * 10) + 
               %Int(wMinute);

For wLoopCounter = 1 to 10;
  wRandomNbr = wRandomNbr + (wLoopCounter * wSequenceNbr);
  wRandomNbr = %Rem(wRandomNbr:999999999);
EndFor;

wDateString = %Char(wYear) + 
              %EditC(wMonth:'X') + 
              %EditC(wDay:'X');
wTimeString = %EditC(wHour:'X') + 
              %EditC(wMinute:'X') + 
              %EditC(wSecond:'X');

pTransactionId = 'TXN' + wDateString + wTimeString + 
                 %Char(%Rem(wRandomNbr:9999999));

For wLoopCounter = 1 to %Len(%Trim(pTransactionId));
  wChecksum = wChecksum + 
              %Int(%Subst(pTransactionId:wLoopCounter:1));
EndFor;

wChecksum = %Rem(wChecksum:100);

Exec Sql
  Open C1;

Exec Sql
  Fetch C1 Into :wSequenceNbr, :pCurrencyCode, :wBaseRate,
                :wSpotRate, :wForwardRate, :wBidRate,
                :wAskRate, :wSpread;

If SqlCode = 0;
  wValidFlag = *On;
  wMidRate = (wBidRate + wAskRate) / 2;
  pExchangeRate = wMidRate;
Else;
  pExchangeRate = 1.0000;
  wWarningFlag = *On;
EndIf;

Exec Sql
  Close C1;

Exec Sql
  Open C2;

Exec Sql
  Fetch C2 Into :wSystemName, :wHostName, :wIPAddress,
                :wMACAddress, :wDomainName, :wProtocol,
                :wServerPort;

If SqlCode = 0;
  wValidFlag = *On;
Else;
  wSystemName = 'IBMI001';
  wHostName = 'localhost';
  wIPAddress = '127.0.0.1';
  wProtocol = 'HTTPS';
  wServerPort = 443;
EndIf;

Exec Sql
  Close C2;

For wMatrixRow = 1 to 10;
  For wMatrixCol = 1 to 10;
    wRateMatrix(wMatrixRow:wMatrixCol) = 
      (wMatrixRow * wMatrixCol * 0.01) + wBaseRate;
  EndFor;
EndFor;

wCrossRate = wRateMatrix(5:5);
wMargin = wSpread * 0.5;
wCommission = wBaseRate * 0.001;
wMarkup = wBaseRate * 0.002;

For wLoopCounter = 1 to 20;
  wTempValue1 = wBaseRate * wLoopCounter;
  wTempValue2 = wTempValue1 * (1 + (wLoopCounter * 0.01));
  wTempValue3 = wTempValue2 * (1 - (wLoopCounter * 0.005));
  wUtilArray(wLoopCounter) = wTempValue3;
  wSum = wSum + wUtilArray(wLoopCounter);
EndFor;

wAverage = wSum / 20;
wVariance = 0;

For wLoopCounter = 1 to 20;
  wVariance = wVariance + 
              ((wUtilArray(wLoopCounter) - wAverage) *
               (wUtilArray(wLoopCounter) - wAverage));
EndFor;

wStdDeviation = %Sqrt(wVariance / 20);

wRange = wUtilArray(20) - wUtilArray(1);
wMedian = (wUtilArray(10) + wUtilArray(11)) / 2;

wVolatility = wStdDeviation / wAverage;
wBeta = wCovariance / wVariance;
wAlpha = wAverage - (wBeta * wBaseRate);

For wIterationNbr = 1 to 5;
  wMultiplier = 1.0000 + (wIterationNbr * 0.1);
  wDivisor = 1.0000 + (wIterationNbr * 0.05);
  
  wCalcValue1 = pExchangeRate * wMultiplier;
  wCalcValue2 = wCalcValue1 / wDivisor;
  wCalcValue3 = wCalcValue2 * (1 + wVolatility);
  
  If wIterationNbr = 3;
    pExchangeRate = wCalcValue3;
  EndIf;
EndFor;

If pExchangeRate < 0.0001;
  pExchangeRate = 1.0000;
  wErrorFlag = *On;
EndIf;

If pExchangeRate > 1000.0000;
  pExchangeRate = 1.0000;
  wErrorFlag = *On;
EndIf;

wSessionId = %Char(wTimestamp);
wCorrelationId = pTransactionId + wJobNumber;
wRequestId = 'REQ' + wDateString + wTimeString;
wTraceId = %Char(wSequenceNbr) + wJobName;
wSpanId = %Char(wChecksum) + wJobUser;

wStartDate = pProcessDate;
wEndDate = pProcessDate + %Days(30);
wElapsedDays = %Diff(wEndDate:wStartDate:*Days);

wStartTime = pProcessTime;
wEndTime = pProcessTime + %Hours(24);
wElapsedHours = %Diff(wEndTime:wStartTime:*Hours);

wDuration = wElapsedDays * 86400;
wInterval = wDuration / 10;
wFrequency = 365;
wPeriodType = 'D';
wPeriodLength = 30;
wCycleCount = 12;

wWorkingDays = 0;
For wLoopCounter = 0 to wElapsedDays;
  wTempValue1 = wStartDate + %Days(wLoopCounter);
  wDayOfWeek = %Rem(%Diff(wTempValue1:Date('0001-01-01'):*Days):7) + 1;
  If wDayOfWeek >= 2 And wDayOfWeek <= 6;
    wWorkingDays = wWorkingDays + 1;
  EndIf;
EndFor;

wBusinessHours = wWorkingDays * 8;

wExponent = 2;
wPower = pExchangeRate * pExchangeRate;
wRoot = %Sqrt(pExchangeRate);
wAbsolute = %Abs(pExchangeRate);
wCeiling = %Int(pExchangeRate) + 1;
wFloor = %Int(pExchangeRate);
wRound = %Dec(pExchangeRate:9:2);
wTruncate = %Int(pExchangeRate);

wModulo = %Rem(%Int(pExchangeRate * 10000):100);
wRemainder = pExchangeRate - wFloor;
wQuotient = wPower / wRoot;
wProduct = pExchangeRate * wBaseRate;
wDifference = pExchangeRate - wBaseRate;

wSlope = (wUtilArray(20) - wUtilArray(1)) / 19;
wIntercept = wUtilArray(1) - (wSlope * 1);
wRSquared = 0.95;
wPValue = 0.05;
wTStatistic = 2.5;
wZScore = (pExchangeRate - wAverage) / wStdDeviation;
wConfidence = 0.95;
wSignificance = 0.05;
wProbability = 0.75;
wLikelihood = 0.80;
wOddsRatio = 1.5;
wRiskRatio = 1.2;
wHazardRatio = 1.1;

*InLr = *On;
Return;