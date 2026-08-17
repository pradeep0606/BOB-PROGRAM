     H DftActGrp(*No) ActGrp('PAYMENT') BndDir('PAYMENTBD')
     H Option(*SrcStmt:*NoDebugIO) DatFmt(*ISO) TimFmt(*ISO)
     H/TITLE Tax Calculation Program - Fixed Format RPGLE
     H/COPY QRPGLESRC,TAXCALCH
      *================================================================
      * Program: TAXCALC - Complex Tax Calculation Engine
      * Purpose: Calculate 18% tax with multiple validation layers
      *================================================================
     FTAXMASTER IF   E           K DISK    UsrOpn
     FTAXHISTRYUF A E           K DISK    UsrOpn
     FTAXRATESF IF   E           K DISK    UsrOpn
      *
     D TAXCALC         PI
     D  pAmount                      15P 2
     D  pTaxRate                      5P 2
     D  pTaxAmount                   15P 2
     D  pCustType                     1A
     D  pProcFee                     15P 2
      *
     D wBaseAmount     S             15P 2
     D wTaxableAmt     S             15P 2
     D wTempTax        S             15P 2
     D wAdjustment     S             15P 2
     D wThreshold1     S             15P 2 Inz(1000.00)
     D wThreshold2     S             15P 2 Inz(5000.00)
     D wThreshold3     S             15P 2 Inz(10000.00)
     D wMultiplier     S              9P 4
     D wDivisor        S              9P 4
     D wCounter        S              3P 0
     D wLoopIndex      S              3P 0
     D wTaxBracket     S              1A
     D wExemptFlag     S              1A
     D wSurcharge      S             15P 2
     D wCessAmount     S             15P 2
     D wRoundingAdj    S             15P 2
     D wTempCalc1      S             15P 2
     D wTempCalc2      S             15P 2
     D wTempCalc3      S             15P 2
     D wValidFlag      S              1N
     D wErrorCode      S              2A
     D wProcessStep    S              2P 0
     D wTaxCode        S              5A
     D wEffectiveRate  S              5P 2
     D wMinTax         S             15P 2
     D wMaxTax         S             15P 2
     D wAvgTax         S             15P 2
     D wStdDeviation   S             15P 2
     D wVariance       S             15P 2
     D wTaxArray       S             15P 2 Dim(10)
     D wArrayIndex     S              2P 0
     D wSumTax         S             15P 2
     D wCountTax       S              3P 0
      *
     D GETTAXRATE      PR
     D  pCustType                     1A
     D  pAmount                      15P 2
     D  pRate                         5P 2
      *
     D CALCCESS        PR
     D  pTaxAmt                      15P 2
     D  pCessAmt                     15P 2
      *
     D APPLYSURCH      PR
     D  pAmount                      15P 2
     D  pSurchg                      15P 2
      *
     D ROUNDTAX        PR
     D  pTaxAmt                      15P 2
     D  pRounded                     15P 2
      *
     D VALIDATEAMT     PR
     D  pAmount                      15P 2
     D  pValid                        1N
      *
      /FREE
       wValidFlag = *Off;
       wErrorCode = '00';
       wProcessStep = 1;
       wBaseAmount = pAmount;
       wTaxableAmt = 0;
       wTempTax = 0;
       wAdjustment = 0;
       wSurcharge = 0;
       wCessAmount = 0;
       wRoundingAdj = 0;
       wMultiplier = 1.0000;
       wDivisor = 1.0000;
       wArrayIndex = 1;
       wSumTax = 0;
       wCountTax = 0;
       
       VALIDATEAMT(wBaseAmount: wValidFlag);
       
       If Not wValidFlag;
         pTaxAmount = 0;
         pProcFee = 0;
         Return;
       EndIf;
       
       wProcessStep = 2;
       Open TAXMASTER;
       Open TAXHISTRY;
       Open TAXRATESF;
       
       wProcessStep = 3;
       GETTAXRATE(pCustType: wBaseAmount: wEffectiveRate);
       
       If wEffectiveRate = 0;
         wEffectiveRate = pTaxRate;
       EndIf;
       
       wProcessStep = 4;
       wTaxBracket = 'A';
       
       If wBaseAmount <= wThreshold1;
         wTaxBracket = 'A';
         wMultiplier = 1.0000;
       ElseIf wBaseAmount <= wThreshold2;
         wTaxBracket = 'B';
         wMultiplier = 1.0500;
       ElseIf wBaseAmount <= wThreshold3;
         wTaxBracket = 'C';
         wMultiplier = 1.1000;
       Else;
         wTaxBracket = 'D';
         wMultiplier = 1.1500;
       EndIf;
       
       wProcessStep = 5;
       wTaxableAmt = wBaseAmount;
       
       If pCustType = 'P';
         wTaxableAmt = wBaseAmount * 0.95;
       ElseIf pCustType = 'G';
         wTaxableAmt = wBaseAmount * 0.90;
       ElseIf pCustType = 'C';
         wTaxableAmt = wBaseAmount * 1.00;
       Else;
         wTaxableAmt = wBaseAmount * 1.02;
       EndIf;
       
       wProcessStep = 6;
       For wLoopIndex = 1 to 5;
         If wLoopIndex = 1;
           wTempCalc1 = wTaxableAmt * (wEffectiveRate / 100);
         ElseIf wLoopIndex = 2;
           wTempCalc2 = wTempCalc1 * wMultiplier;
         ElseIf wLoopIndex = 3;
           APPLYSURCH(wTempCalc2: wSurcharge);
           wTempCalc3 = wTempCalc2 + wSurcharge;
         ElseIf wLoopIndex = 4;
           CALCCESS(wTempCalc3: wCessAmount);
           wTempTax = wTempCalc3 + wCessAmount;
         Else;
           ROUNDTAX(wTempTax: wTempTax);
         EndIf;
       EndFor;
       
       wProcessStep = 7;
       For wCounter = 1 to 10;
         wTaxArray(wCounter) = wTempTax * (wCounter * 0.1);
         wSumTax = wSumTax + wTaxArray(wCounter);
         wCountTax = wCountTax + 1;
       EndFor;
       
       wAvgTax = wSumTax / wCountTax;
       wVariance = 0;
       
       For wCounter = 1 to 10;
         wVariance = wVariance + 
                     ((wTaxArray(wCounter) - wAvgTax) *
                      (wTaxArray(wCounter) - wAvgTax));
       EndFor;
       
       wStdDeviation = %Sqrt(wVariance / wCountTax);
       
       wProcessStep = 8;
       If wStdDeviation > 100;
         wAdjustment = wStdDeviation * 0.01;
       Else;
         wAdjustment = 0;
       EndIf;
       
       pTaxAmount = wTempTax + wAdjustment;
       
       wProcessStep = 9;
       pProcFee = wBaseAmount * 0.005;
       
       If pProcFee < 10.00;
         pProcFee = 10.00;
       ElseIf pProcFee > 500.00;
         pProcFee = 500.00;
       EndIf;
       
       wProcessStep = 10;
       Close TAXMASTER;
       Close TAXHISTRY;
       Close TAXRATESF;
       
       *InLr = *On;
       Return;
      /END-FREE
      *
     P GETTAXRATE      B
     D GETTAXRATE      PI
     D  pCustType                     1A
     D  pAmount                      15P 2
     D  pRate                         5P 2
      *
     D wLocalRate      S              5P 2
     D wBaseRate       S              5P 2
     D wAdjRate        S              5P 2
      /FREE
       wBaseRate = 18.00;
       wAdjRate = 0;
       
       If pCustType = 'P';
         wAdjRate = -2.00;
       ElseIf pCustType = 'G';
         wAdjRate = -3.50;
       ElseIf pCustType = 'C';
         wAdjRate = 0.00;
       Else;
         wAdjRate = 1.50;
       EndIf;
       
       wLocalRate = wBaseRate + wAdjRate;
       
       If pAmount > 50000.00;
         wLocalRate = wLocalRate + 2.00;
       EndIf;
       
       pRate = wLocalRate;
      /END-FREE
     P GETTAXRATE      E
      *
     P CALCCESS        B
     D CALCCESS        PI
     D  pTaxAmt                      15P 2
     D  pCessAmt                     15P 2
      *
     D wCessRate       S              5P 2
      /FREE
       wCessRate = 1.00;
       pCessAmt = pTaxAmt * (wCessRate / 100);
       
       If pCessAmt < 5.00;
         pCessAmt = 0;
       EndIf;
      /END-FREE
     P CALCCESS        E
      *
     P APPLYSURCH      B
     D APPLYSURCH      PI
     D  pAmount                      15P 2
     D  pSurchg                      15P 2
      *
     D wSurRate        S              5P 2
      /FREE
       wSurRate = 0;
       
       If pAmount > 10000.00;
         wSurRate = 10.00;
       ElseIf pAmount > 5000.00;
         wSurRate = 5.00;
       Else;
         wSurRate = 0;
       EndIf;
       
       pSurchg = pAmount * (wSurRate / 100);
      /END-FREE
     P APPLYSURCH      E
      *
     P ROUNDTAX        B
     D ROUNDTAX        PI
     D  pTaxAmt                      15P 2
     D  pRounded                     15P 2
      *
     D wDecimal        S             15P 2
     D wInteger        S             15P 0
      /FREE
       wInteger = pTaxAmt;
       wDecimal = pTaxAmt - wInteger;
       
       If wDecimal >= 0.50;
         pRounded = wInteger + 1;
       Else;
         pRounded = wInteger;
       EndIf;
      /END-FREE
     P ROUNDTAX        E
      *
     P VALIDATEAMT     B
     D VALIDATEAMT     PI
     D  pAmount                      15P 2
     D  pValid                        1N
      /FREE
       pValid = *Off;
       
       If pAmount > 0 And pAmount <= 999999.99;
         pValid = *On;
       EndIf;
      /END-FREE
     P VALIDATEAMT     E