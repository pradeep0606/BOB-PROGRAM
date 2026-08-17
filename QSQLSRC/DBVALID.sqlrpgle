**FREE
// Database Validation Program - Free Format SQLRPGLE
// Program: DBVALID - Customer and Transaction Validation
// Performs complex validation checks on customer data

Ctl-Opt DftActGrp(*No) ActGrp('PAYMENT') BndDir('PAYMENTBD');
Ctl-Opt Option(*SrcStmt:*NoDebugIO) DatFmt(*ISO) TimFmt(*ISO);

Dcl-Pi *N;
  pCustomerId Char(10);
  pAmount Packed(15:2);
  pValidCode Char(2);
  pCustType Char(1);
  pLoyaltyPts Packed(9:0);
End-Pi;

Dcl-S wCustomerFound Ind;
Dcl-S wCreditLimit Packed(15:2);
Dcl-S wCurrentBalance Packed(15:2);
Dcl-S wAvailableCredit Packed(15:2);
Dcl-S wCreditScore Packed(3:0);
Dcl-S wAccountStatus Char(1);
Dcl-S wRiskLevel Char(1);
Dcl-S wTransactionCount Packed(5:0);
Dcl-S wLastTransDate Date;
Dcl-S wDaysSinceLast Packed(5:0);
Dcl-S wMonthlyLimit Packed(15:2);
Dcl-S wMonthlyUsed Packed(15:2);
Dcl-S wDailyLimit Packed(15:2);
Dcl-S wDailyUsed Packed(15:2);
Dcl-S wValidationLevel Packed(2:0);
Dcl-S wCheckDigit Packed(2:0);
Dcl-S wCalculatedDigit Packed(2:0);
Dcl-S wCustomerAge Packed(3:0);
Dcl-S wAccountAge Packed(5:0);
Dcl-S wTotalPurchases Packed(15:2);
Dcl-S wAveragePurchase Packed(15:2);
Dcl-S wMaxPurchase Packed(15:2);
Dcl-S wMinPurchase Packed(15:2);
Dcl-S wStdDeviation Packed(15:2);
Dcl-S wZScore Packed(9:4);
Dcl-S wFraudScore Packed(5:2);
Dcl-S wValidationFlags Char(10);
Dcl-S wErrorCount Packed(2:0);
Dcl-S wWarningCount Packed(2:0);
Dcl-S wIterator Packed(3:0);
Dcl-S wTempAmount Packed(15:2);
Dcl-S wMultiplier Packed(9:4);
Dcl-S wThresholdAmt Packed(15:2);

Exec Sql
  Declare C1 Cursor For
  Select CUSTTYPE, CREDITLMT, CURBALANCE, CREDITSCORE,
         ACCTSTATUS, RISKLEVEL, LOYALTYPTS, TRANCOUNT,
         LASTTRANDATE, MONTHLYLMT, MONTHLYUSED,
         DAILYLMT, DAILYUSED, CUSTAGE, ACCTAGE,
         TOTALPURCH, AVGPURCH, MAXPURCH, MINPURCH
  From CUSTMASTER
  Where CUSTID = :pCustomerId
  For Read Only;

Exec Sql
  Declare C2 Cursor For
  Select Count(*), Sum(AMOUNT), Avg(AMOUNT), StdDev(AMOUNT)
  From TRANHISTORY
  Where CUSTID = :pCustomerId
    And TRANDATE >= Current Date - 30 Days
  For Read Only;

wCustomerFound = *Off;
wErrorCount = 0;
wWarningCount = 0;
wValidationLevel = 1;
pValidCode = '00';
pCustType = 'C';
pLoyaltyPts = 0;
wValidationFlags = *Blanks;

wValidationLevel = 1;
If pCustomerId = *Blanks Or %Len(%Trim(pCustomerId)) < 5;
  pValidCode = '10';
  Return;
EndIf;

wValidationLevel = 2;
wCheckDigit = %Dec(%Subst(pCustomerId:10:1):2:0);
wCalculatedDigit = 0;

For wIterator = 1 to 9;
  wCalculatedDigit = wCalculatedDigit + 
                     %Dec(%Subst(pCustomerId:wIterator:1):2:0);
EndFor;

wCalculatedDigit = %Rem(wCalculatedDigit:10);

If wCheckDigit <> wCalculatedDigit;
  pValidCode = '11';
  wErrorCount = wErrorCount + 1;
EndIf;

wValidationLevel = 3;
If pAmount <= 0;
  pValidCode = '12';
  Return;
EndIf;

If pAmount > 999999.99;
  pValidCode = '13';
  Return;
EndIf;

wValidationLevel = 4;
Exec Sql
  Open C1;

Exec Sql
  Fetch C1 Into :pCustType, :wCreditLimit, :wCurrentBalance,
                :wCreditScore, :wAccountStatus, :wRiskLevel,
                :pLoyaltyPts, :wTransactionCount, :wLastTransDate,
                :wMonthlyLimit, :wMonthlyUsed, :wDailyLimit,
                :wDailyUsed, :wCustomerAge, :wAccountAge,
                :wTotalPurchases, :wAveragePurchase, :wMaxPurchase,
                :wMinPurchase;

If SqlCode = 0;
  wCustomerFound = *On;
Else;
  pValidCode = '20';
  Exec Sql Close C1;
  Return;
EndIf;

Exec Sql
  Close C1;

wValidationLevel = 5;
If wAccountStatus <> 'A';
  pValidCode = '21';
  Return;
EndIf;

If wRiskLevel = 'H';
  pValidCode = '22';
  wErrorCount = wErrorCount + 1;
EndIf;

wValidationLevel = 6;
wAvailableCredit = wCreditLimit - wCurrentBalance;

If pAmount > wAvailableCredit;
  pValidCode = '30';
  Return;
EndIf;

wValidationLevel = 7;
If wMonthlyUsed + pAmount > wMonthlyLimit;
  pValidCode = '31';
  wWarningCount = wWarningCount + 1;
EndIf;

If wDailyUsed + pAmount > wDailyLimit;
  pValidCode = '32';
  Return;
EndIf;

wValidationLevel = 8;
wDaysSinceLast = %Diff(%Date():wLastTransDate:*Days);

If wDaysSinceLast = 0 And wTransactionCount > 10;
  pValidCode = '40';
  wWarningCount = wWarningCount + 1;
EndIf;

wValidationLevel = 9;
Exec Sql
  Open C2;

Exec Sql
  Fetch C2 Into :wTransactionCount, :wTotalPurchases,
                :wAveragePurchase, :wStdDeviation;

If SqlCode = 0 And wTransactionCount > 0;
  wZScore = (pAmount - wAveragePurchase) / wStdDeviation;
  
  If wZScore > 3.0;
    wFraudScore = 85.00;
    pValidCode = '41';
    wWarningCount = wWarningCount + 1;
  ElseIf wZScore > 2.0;
    wFraudScore = 65.00;
    wWarningCount = wWarningCount + 1;
  Else;
    wFraudScore = 25.00;
  EndIf;
EndIf;

Exec Sql
  Close C2;

wValidationLevel = 10;
If wCreditScore < 300;
  pValidCode = '50';
  Return;
ElseIf wCreditScore < 500;
  wWarningCount = wWarningCount + 1;
EndIf;

wValidationLevel = 11;
For wIterator = 1 to 5;
  wTempAmount = pAmount;
  wMultiplier = 1.0 + (wIterator * 0.1);
  wThresholdAmt = wAveragePurchase * wMultiplier;
  
  If wTempAmount > wThresholdAmt;
    wValidationFlags = %Subst(wValidationFlags:1:wIterator-1) +
                       'W' +
                       %Subst(wValidationFlags:wIterator+1);
  Else;
    wValidationFlags = %Subst(wValidationFlags:1:wIterator-1) +
                       'P' +
                       %Subst(wValidationFlags:wIterator+1);
  EndIf;
EndFor;

wValidationLevel = 12;
If wCustomerAge < 18;
  pValidCode = '60';
  Return;
EndIf;

If wAccountAge < 30;
  wWarningCount = wWarningCount + 1;
EndIf;

wValidationLevel = 13;
If pCustType = 'P';
  If pLoyaltyPts < 1000;
    pLoyaltyPts = pLoyaltyPts + %Int(pAmount / 10);
  Else;
    pLoyaltyPts = pLoyaltyPts + %Int(pAmount / 5);
  EndIf;
ElseIf pCustType = 'G';
  pLoyaltyPts = pLoyaltyPts + %Int(pAmount / 3);
Else;
  pLoyaltyPts = pLoyaltyPts + %Int(pAmount / 20);
EndIf;

wValidationLevel = 14;
If wErrorCount > 0;
  If pValidCode = '00';
    pValidCode = '98';
  EndIf;
ElseIf wWarningCount > 2;
  If pValidCode = '00';
    pValidCode = '01';
  EndIf;
Else;
  If pValidCode = '00';
    pValidCode = '00';
  EndIf;
EndIf;

*InLr = *On;
Return;