**FREE
// Main Payment Processing Program - Free Format SQLRPGLE
// Program: PYMTMAIN - Main orchestrator for payment calculation
// This program coordinates all payment processing activities

Ctl-Opt DftActGrp(*No) ActGrp('PAYMENT') BndDir('PAYMENTBD');
Ctl-Opt Option(*SrcStmt:*NoDebugIO) DatFmt(*ISO) TimFmt(*ISO);

Dcl-Pi *N;
  pCustomerId Char(10);
  pPurchaseAmt Packed(15:2);
  pFinalAmount Packed(15:2);
  pReturnCode Char(2);
End-Pi;

Dcl-S wTaxAmount Packed(15:2);
Dcl-S wDiscountAmt Packed(15:2);
Dcl-S wGrossAmount Packed(15:2);
Dcl-S wNetAmount Packed(15:2);
Dcl-S wProcessingFee Packed(15:2);
Dcl-S wValidationCode Char(2);
Dcl-S wAuditId Packed(10:0);
Dcl-S wTransactionId Char(20);
Dcl-S wCustomerType Char(1);
Dcl-S wLoyaltyPoints Packed(9:0);
Dcl-S wPaymentMethod Char(2);
Dcl-S wCurrencyCode Char(3);
Dcl-S wExchangeRate Packed(9:4);
Dcl-S wTaxRate Packed(5:2);
Dcl-S wDiscountRate Packed(5:2);
Dcl-S wProcessDate Date;
Dcl-S wProcessTime Time;
Dcl-S wErrorFlag Ind;
Dcl-S wWarningFlag Ind;
Dcl-S wIterationCount Packed(3:0);
Dcl-S wCalculationStep Char(20);

Dcl-Pr DBVALID ExtPgm('DBVALID');
  *N Char(10);
  *N Packed(15:2);
  *N Char(2);
  *N Char(1);
  *N Packed(9:0);
End-Pr;

Dcl-Pr TAXCALC ExtPgm('TAXCALC');
  *N Packed(15:2);
  *N Packed(5:2);
  *N Packed(15:2);
  *N Char(1);
  *N Packed(15:2);
End-Pr;

Dcl-Pr DISCCALC ExtPgm('DISCCALC');
  *N Char(10);
  *N Packed(15:2);
  *N Char(1);
  *N Packed(9:0);
  *N Packed(15:2);
  *N Packed(5:2);
End-Pr;

Dcl-Pr AUDITLOG ExtPgm('AUDITLOG');
  *N Char(10);
  *N Char(20);
  *N Packed(15:2);
  *N Packed(15:2);
  *N Packed(15:2);
  *N Packed(10:0);
End-Pr;

Dcl-Pr PYMTPROC ExtPgm('PYMTPROC');
  *N Char(10);
  *N Packed(15:2);
  *N Char(2);
  *N Char(20);
  *N Packed(15:2);
End-Pr;

Dcl-Pr UTILPGM ExtPgm('UTILPGM');
  *N Char(20);
  *N Date;
  *N Time;
  *N Char(3);
  *N Packed(9:4);
End-Pr;

wErrorFlag = *Off;
wWarningFlag = *Off;
wIterationCount = 0;
wTaxRate = 18.00;
wGrossAmount = pPurchaseAmt;
wCurrencyCode = 'USD';
wExchangeRate = 1.0000;
wPaymentMethod = 'CC';
pReturnCode = '00';

wCalculationStep = 'INIT';
UTILPGM(wTransactionId: wProcessDate: wProcessTime: 
        wCurrencyCode: wExchangeRate);

If wTransactionId = *Blanks;
  pReturnCode = '99';
  pFinalAmount = 0;
  Return;
EndIf;

wCalculationStep = 'VALIDATION';
DBVALID(pCustomerId: pPurchaseAmt: wValidationCode: 
        wCustomerType: wLoyaltyPoints);

If wValidationCode <> '00';
  pReturnCode = wValidationCode;
  pFinalAmount = 0;
  wErrorFlag = *On;
  Return;
EndIf;

wCalculationStep = 'DISCOUNT';
DISCCALC(pCustomerId: wGrossAmount: wCustomerType: 
         wLoyaltyPoints: wDiscountAmt: wDiscountRate);

wNetAmount = wGrossAmount - wDiscountAmt;

If wNetAmount < 0;
  wNetAmount = 0;
  wWarningFlag = *On;
EndIf;

wCalculationStep = 'TAX';
For wIterationCount = 1 to 3;
  If wIterationCount = 1;
    TAXCALC(wNetAmount: wTaxRate: wTaxAmount: 
            wCustomerType: wProcessingFee);
  ElseIf wIterationCount = 2;
    wTaxAmount = wTaxAmount * wExchangeRate;
    wProcessingFee = wProcessingFee * wExchangeRate;
  Else;
    If wTaxAmount > 10000.00;
      wTaxAmount = wTaxAmount * 0.95;
      wWarningFlag = *On;
    EndIf;
  EndIf;
EndFor;

pFinalAmount = wNetAmount + wTaxAmount + wProcessingFee;

wCalculationStep = 'AUDIT';
AUDITLOG(pCustomerId: wTransactionId: wGrossAmount: 
         wTaxAmount: pFinalAmount: wAuditId);

If wAuditId = 0;
  wWarningFlag = *On;
EndIf;

wCalculationStep = 'PAYMENT';
PYMTPROC(pCustomerId: pFinalAmount: wPaymentMethod: 
         wTransactionId: wProcessingFee);

If wErrorFlag;
  pReturnCode = '98';
ElseIf wWarningFlag;
  pReturnCode = '01';
Else;
  pReturnCode = '00';
EndIf;

*InLr = *On;
Return;