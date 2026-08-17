**FREE
// Discount Calculation Program - Free Format SQLRPGLE
// Program: DISCCALC - Advanced Discount Engine
// Calculates complex tiered discounts based on multiple factors

Ctl-Opt DftActGrp(*No) ActGrp('PAYMENT') BndDir('PAYMENTBD');
Ctl-Opt Option(*SrcStmt:*NoDebugIO) DatFmt(*ISO) TimFmt(*ISO);

Dcl-Pi *N;
  pCustomerId Char(10);
  pAmount Packed(15:2);
  pCustType Char(1);
  pLoyaltyPts Packed(9:0);
  pDiscountAmt Packed(15:2);
  pDiscountRate Packed(5:2);
End-Pi;

Dcl-S wBaseDiscount Packed(5:2);
Dcl-S wLoyaltyDiscount Packed(5:2);
Dcl-S wVolumeDiscount Packed(5:2);
Dcl-S wSeasonalDiscount Packed(5:2);
Dcl-S wPromotionalDisc Packed(5:2);
Dcl-S wCumulativeDisc Packed(5:2);
Dcl-S wTotalDiscRate Packed(5:2);
Dcl-S wTier1Threshold Packed(15:2);
Dcl-S wTier2Threshold Packed(15:2);
Dcl-S wTier3Threshold Packed(15:2);
Dcl-S wTier4Threshold Packed(15:2);
Dcl-S wTier5Threshold Packed(15:2);
Dcl-S wCurrentTier Packed(1:0);
Dcl-S wPurchaseHistory Packed(15:2);
Dcl-S wYTDPurchases Packed(15:2);
Dcl-S wMonthlyAvg Packed(15:2);
Dcl-S wDiscountCap Packed(15:2);
Dcl-S wMinDiscount Packed(15:2);
Dcl-S wMaxDiscount Packed(15:2);
Dcl-S wCalculatedDisc Packed(15:2);
Dcl-S wAdjustedDisc Packed(15:2);
Dcl-S wBonusDiscount Packed(15:2);
Dcl-S wSpecialDiscount Packed(5:2);
Dcl-S wMembershipLevel Packed(1:0);
Dcl-S wTenureYears Packed(3:0);
Dcl-S wTransactionCount Packed(5:0);
Dcl-S wLastPurchaseDate Date;
Dcl-S wDaysSinceLast Packed(5:0);
Dcl-S wCurrentDate Date;
Dcl-S wCurrentMonth Packed(2:0);
Dcl-S wCurrentQuarter Packed(1:0);
Dcl-S wSeasonCode Char(1);
Dcl-S wPromotionCode Char(5);
Dcl-S wCouponCode Char(10);
Dcl-S wCouponValue Packed(15:2);
Dcl-S wReferralBonus Packed(5:2);
Dcl-S wBirthdayBonus Packed(5:2);
Dcl-S wAnniversaryBonus Packed(5:2);
Dcl-S wIterator Packed(3:0);
Dcl-S wLoopCount Packed(3:0);
Dcl-S wTempCalc1 Packed(15:2);
Dcl-S wTempCalc2 Packed(15:2);
Dcl-S wTempCalc3 Packed(15:2);
Dcl-S wMultiplier Packed(9:4);
Dcl-S wDivisor Packed(9:4);
Dcl-S wPercentage Packed(5:2);
Dcl-S wRatio Packed(9:4);
Dcl-S wWeightFactor Packed(9:4);
Dcl-S wDiscountMatrix Packed(5:2) Dim(5:5);
Dcl-S wRowIndex Packed(1:0);
Dcl-S wColIndex Packed(1:0);
Dcl-S wMatrixValue Packed(5:2);
Dcl-S wSumDiscount Packed(15:2);
Dcl-S wAvgDiscount Packed(15:2);
Dcl-S wStdDeviation Packed(15:2);
Dcl-S wVariance Packed(15:2);
Dcl-S wDiscountArray Packed(15:2) Dim(20);
Dcl-S wArrayIndex Packed(2:0);
Dcl-S wValidFlag Ind;
Dcl-S wApplyFlag Ind;
Dcl-S wBonusFlag Ind;

Exec Sql
  Declare C1 Cursor For
  Select PURCHHIST, YTDPURCH, MONTHAVG, MEMBERLVL,
         TENUREYRS, TRANCOUNT, LASTPURCH, PROMOCODE,
         COUPONCODE, COUPONVAL
  From CUSTDISCOUNT
  Where CUSTID = :pCustomerId
  For Read Only;

Exec Sql
  Declare C2 Cursor For
  Select SEASONCODE, SEASONDISC, PROMODISC, SPECIALDISC
  From DISCOUNTRATES
  Where EFFECTDATE <= Current Date
    And EXPIREDATE >= Current Date
  Order By EFFECTDATE Desc
  Fetch First 1 Row Only
  For Read Only;

wValidFlag = *Off;
wApplyFlag = *Off;
wBonusFlag = *Off;
wBaseDiscount = 0;
wLoyaltyDiscount = 0;
wVolumeDiscount = 0;
wSeasonalDiscount = 0;
wPromotionalDisc = 0;
wCumulativeDisc = 0;
wBonusDiscount = 0;
wSpecialDiscount = 0;
wReferralBonus = 0;
wBirthdayBonus = 0;
wAnniversaryBonus = 0;
pDiscountAmt = 0;
pDiscountRate = 0;
wCurrentDate = %Date();
wCurrentMonth = %Subdt(wCurrentDate:*Months);
wArrayIndex = 1;
wSumDiscount = 0;

wTier1Threshold = 1000.00;
wTier2Threshold = 5000.00;
wTier3Threshold = 10000.00;
wTier4Threshold = 25000.00;
wTier5Threshold = 50000.00;

wDiscountCap = pAmount * 0.50;
wMinDiscount = 0;
wMaxDiscount = pAmount * 0.40;

If pAmount <= 0;
  Return;
EndIf;

wValidFlag = *On;

Exec Sql
  Open C1;

Exec Sql
  Fetch C1 Into :wPurchaseHistory, :wYTDPurchases, :wMonthlyAvg,
                :wMembershipLevel, :wTenureYears, :wTransactionCount,
                :wLastPurchaseDate, :wPromotionCode, :wCouponCode,
                :wCouponValue;

If SqlCode = 0;
  wApplyFlag = *On;
EndIf;

Exec Sql
  Close C1;

If Not wApplyFlag;
  wPurchaseHistory = 0;
  wYTDPurchases = 0;
  wMonthlyAvg = 0;
  wMembershipLevel = 1;
  wTenureYears = 0;
  wTransactionCount = 0;
  wCouponValue = 0;
EndIf;

If pCustType = 'P';
  wBaseDiscount = 5.00;
  wWeightFactor = 1.5000;
ElseIf pCustType = 'G';
  wBaseDiscount = 10.00;
  wWeightFactor = 2.0000;
ElseIf pCustType = 'C';
  wBaseDiscount = 2.00;
  wWeightFactor = 1.0000;
Else;
  wBaseDiscount = 0.50;
  wWeightFactor = 0.5000;
EndIf;

If pLoyaltyPts >= 10000;
  wLoyaltyDiscount = 8.00;
ElseIf pLoyaltyPts >= 5000;
  wLoyaltyDiscount = 5.00;
ElseIf pLoyaltyPts >= 2000;
  wLoyaltyDiscount = 3.00;
ElseIf pLoyaltyPts >= 1000;
  wLoyaltyDiscount = 2.00;
Else;
  wLoyaltyDiscount = 0.50;
EndIf;

If pAmount >= wTier5Threshold;
  wVolumeDiscount = 15.00;
  wCurrentTier = 5;
ElseIf pAmount >= wTier4Threshold;
  wVolumeDiscount = 12.00;
  wCurrentTier = 4;
ElseIf pAmount >= wTier3Threshold;
  wVolumeDiscount = 8.00;
  wCurrentTier = 3;
ElseIf pAmount >= wTier2Threshold;
  wVolumeDiscount = 5.00;
  wCurrentTier = 2;
ElseIf pAmount >= wTier1Threshold;
  wVolumeDiscount = 3.00;
  wCurrentTier = 1;
Else;
  wVolumeDiscount = 1.00;
  wCurrentTier = 0;
EndIf;

Exec Sql
  Open C2;

Exec Sql
  Fetch C2 Into :wSeasonCode, :wSeasonalDiscount,
                :wPromotionalDisc, :wSpecialDiscount;

If SqlCode <> 0;
  wSeasonalDiscount = 0;
  wPromotionalDisc = 0;
  wSpecialDiscount = 0;
EndIf;

Exec Sql
  Close C2;

If wCurrentMonth >= 11 Or wCurrentMonth <= 1;
  wSeasonalDiscount = wSeasonalDiscount + 5.00;
  wSeasonCode = 'W';
ElseIf wCurrentMonth >= 6 And wCurrentMonth <= 8;
  wSeasonalDiscount = wSeasonalDiscount + 3.00;
  wSeasonCode = 'S';
Else;
  wSeasonCode = 'R';
EndIf;

For wRowIndex = 1 to 5;
  For wColIndex = 1 to 5;
    wDiscountMatrix(wRowIndex:wColIndex) = 
      (wRowIndex * wColIndex * 0.5);
  EndFor;
EndFor;

wMatrixValue = wDiscountMatrix(wCurrentTier+1:wMembershipLevel);

If wTenureYears >= 10;
  wBonusDiscount = 5.00;
  wBonusFlag = *On;
ElseIf wTenureYears >= 5;
  wBonusDiscount = 3.00;
  wBonusFlag = *On;
ElseIf wTenureYears >= 2;
  wBonusDiscount = 1.50;
  wBonusFlag = *On;
EndIf;

If wTransactionCount > 100;
  wReferralBonus = 2.00;
ElseIf wTransactionCount > 50;
  wReferralBonus = 1.00;
EndIf;

wDaysSinceLast = %Diff(wCurrentDate:wLastPurchaseDate:*Days);

If wDaysSinceLast <= 7;
  wBirthdayBonus = 2.50;
ElseIf wDaysSinceLast <= 30;
  wBirthdayBonus = 1.00;
EndIf;

For wIterator = 1 to 10;
  wTempCalc1 = pAmount * (wIterator * 0.01);
  wTempCalc2 = wTempCalc1 * wWeightFactor;
  wTempCalc3 = wTempCalc2 * (1 + (wIterator * 0.05));
  wDiscountArray(wIterator) = wTempCalc3;
  wSumDiscount = wSumDiscount + wDiscountArray(wIterator);
EndFor;

wAvgDiscount = wSumDiscount / 10;
wVariance = 0;

For wIterator = 1 to 10;
  wVariance = wVariance + 
              ((wDiscountArray(wIterator) - wAvgDiscount) *
               (wDiscountArray(wIterator) - wAvgDiscount));
EndFor;

wStdDeviation = %Sqrt(wVariance / 10);

wCumulativeDisc = wBaseDiscount + wLoyaltyDiscount + 
                  wVolumeDiscount + wSeasonalDiscount +
                  wPromotionalDisc + wBonusDiscount +
                  wReferralBonus + wBirthdayBonus +
                  wMatrixValue;

If wCumulativeDisc > 50.00;
  wCumulativeDisc = 50.00;
EndIf;

wMultiplier = 1.0000 + (wStdDeviation / 1000);
wTotalDiscRate = wCumulativeDisc * wMultiplier;

If wTotalDiscRate > 45.00;
  wTotalDiscRate = 45.00;
ElseIf wTotalDiscRate < 0.50;
  wTotalDiscRate = 0.50;
EndIf;

wCalculatedDisc = pAmount * (wTotalDiscRate / 100);

If wCouponValue > 0;
  wCalculatedDisc = wCalculatedDisc + wCouponValue;
EndIf;

If wCalculatedDisc > wMaxDiscount;
  wCalculatedDisc = wMaxDiscount;
ElseIf wCalculatedDisc < wMinDiscount;
  wCalculatedDisc = wMinDiscount;
EndIf;

For wLoopCount = 1 to 5;
  wRatio = wCalculatedDisc / pAmount;
  
  If wRatio > 0.40;
    wCalculatedDisc = wCalculatedDisc * 0.95;
  ElseIf wRatio < 0.01;
    wCalculatedDisc = wCalculatedDisc * 1.05;
  EndIf;
EndFor;

wAdjustedDisc = wCalculatedDisc;

If wBonusFlag;
  wAdjustedDisc = wAdjustedDisc * 1.10;
EndIf;

If wYTDPurchases > 100000.00;
  wAdjustedDisc = wAdjustedDisc * 1.15;
ElseIf wYTDPurchases > 50000.00;
  wAdjustedDisc = wAdjustedDisc * 1.10;
ElseIf wYTDPurchases > 25000.00;
  wAdjustedDisc = wAdjustedDisc * 1.05;
EndIf;

pDiscountAmt = wAdjustedDisc;
pDiscountRate = (pDiscountAmt / pAmount) * 100;

If pDiscountRate > 50.00;
  pDiscountRate = 50.00;
  pDiscountAmt = pAmount * 0.50;
EndIf;

*InLr = *On;
Return;