     H DftActGrp(*No) ActGrp('PAYMENT') BndDir('PAYMENTBD')
     H Option(*SrcStmt:*NoDebugIO) DatFmt(*ISO) TimFmt(*ISO)
     H/TITLE Payment Processing Program - Fixed Format RPGLE
     H/COPY QRPGLESRC,PYMTPROCH
      *================================================================
      * Program: PYMTPROC - Payment Gateway Integration & Processing
      * Purpose: Process payments through multiple gateways
      *================================================================
     FPAYMENTDBUF A E           K DISK    UsrOpn
     FPYMTQUEUEUF A E           K DISK    UsrOpn
     FPYMTHISTRYUF A E           K DISK    UsrOpn
     FGATEWAYCFGIF   E           K DISK    UsrOpn
     FRETRYLOGF UF A E           K DISK    UsrOpn
      *
     D PYMTPROC        PI
     D  pCustId                      10A
     D  pAmount                      15P 2
     D  pPayMethod                    2A
     D  pTranId                      20A
     D  pProcFee                     15P 2
      *
     D wGatewayId      S              5A
     D wGatewayName    S             30A
     D wGatewayURL     S            100A
     D wGatewayPort    S              5P 0
     D wGatewayStatus  S              1A
     D wAuthToken      S             50A
     D wSessionToken   S             40A
     D wEncryptKey     S             32A
     D wRequestId      S             25A
     D wResponseCode   S              4A
     D wResponseMsg    S            200A
     D wApprovalCode   S             10A
     D wReferenceNbr   S             20A
     D wBatchNumber    S             10A
     D wSettlementId   S             15A
     D wProcessDate    S               D   DatFmt(*ISO)
     D wProcessTime    S               T   TimFmt(*ISO)
     D wProcessStamp   S               Z
     D wRetryCount     S              2P 0
     D wMaxRetries     S              2P 0
     D wRetryDelay     S              5P 0
     D wTimeoutSecs    S              5P 0
     D wPriorityLevel  S              1P 0
     D wQueuePosition  S              9P 0
     D wProcessStatus  S              2A
     D wErrorCode      S              6A
     D wErrorMessage   S            250A
     D wWarningCode    S              4A
     D wWarningMsg     S            100A
     D wCardType       S              2A
     D wCardNumber     S             16A
     D wCardExpiry     S              4A
     D wCardCVV        S              4A
     D wCardHolder     S             50A
     D wBillingAddr    S            100A
     D wBillingCity    S             30A
     D wBillingState   S              2A
     D wBillingZip     S             10A
     D wBillingCountry S              3A
     D wShippingAddr   S            100A
     D wShippingCity   S             30A
     D wShippingState  S              2A
     D wShippingZip    S             10A
     D wIPAddress      S             15A
     D wDeviceId       S             20A
     D wBrowserInfo    S             50A
     D wGeoLocation    S             30A
     D wFraudScore     S              5P 2
     D wRiskLevel      S              1A
     D wAuthMethod     S              2A
     D wAuthStatus     S              1A
     D w3DSecure       S              1A
     D wCVVMatch       S              1A
     D wAVSMatch       S              1A
     D wVelocityCheck  S              1A
     D wAmountAuth     S             15P 2
     D wAmountCapture  S             15P 2
     D wAmountRefund   S             15P 2
     D wAmountVoid     S             15P 2
     D wBalanceBefore  S             15P 2
     D wBalanceAfter   S             15P 2
     D wAvailCredit    S             15P 2
     D wHoldAmount     S             15P 2
     D wReserveAmount  S             15P 2
     D wFeeAmount      S             15P 2
     D wTaxOnFee       S             15P 2
     D wNetAmount      S             15P 2
     D wGrossAmount    S             15P 2
     D wExchangeRate   S              9P 4
     D wCurrencyCode   S              3A
     D wBaseCurrency   S              3A
     D wConvertedAmt   S             15P 2
     D wRoundingAdj    S             15P 2
     D wIterator       S              3P 0
     D wLoopCounter    S              3P 0
     D wStepNumber     S              3P 0
     D wPhaseNumber    S              2P 0
     D wStageCode      S              2A
     D wCheckpoint     S              5A
     D wMilestone      S              3P 0
     D wProgressPct    S              5P 2
     D wElapsedTime    S              9P 0
     D wStartTime      S               T   TimFmt(*ISO)
     D wEndTime        S               T   TimFmt(*ISO)
     D wDuration       S              9P 0
     D wTempValue1     S             15P 2
     D wTempValue2     S             15P 2
     D wTempValue3     S             15P 2
     D wCalcResult1    S             15P 2
     D wCalcResult2    S             15P 2
     D wCalcResult3    S             15P 2
     D wMultiplier     S              9P 4
     D wDivisor        S              9P 4
     D wPercentage     S              5P 2
     D wRatio          S              9P 4
     D wFactor         S              9P 4
     D wCoefficient    S              9P 4
     D wExponent       S              3P 0
     D wBase           S             15P 2
     D wPower          S             15P 2
     D wSquareRoot     S             15P 2
     D wAbsoluteVal    S             15P 2
     D wMinValue       S             15P 2
     D wMaxValue       S             15P 2
     D wAverage        S             15P 2
     D wMedian         S             15P 2
     D wStdDeviation   S             15P 2
     D wVariance       S             15P 2
     D wSumValues      S             15P 2
     D wCountValues    S              9P 0
     D wPymtArray      S             15P 2 Dim(15)
     D wArrayIndex     S              2P 0
     D wMatrixData     S             15P 2 Dim(5:5)
     D wRowIdx         S              1P 0
     D wColIdx         S              1P 0
     D wValidFlag      S              1N
     D wSuccessFlag    S              1N
     D wCompleteFlag   S              1N
     D wPendingFlag    S              1N
     D wErrorFlag      S              1N
     D wWarningFlag    S              1N
      *
     D INITGATEWAY     PR
     D  pMethod                       2A
     D  pGatewayId                    5A
     D  pStatus                       1A
      *
     D AUTHENTICATE    PR
     D  pGatewayId                    5A
     D  pToken                       50A
     D  pSuccess                      1N
      *
     D VALIDATECARD    PR
     D  pCardNbr                     16A
     D  pExpiry                       4A
     D  pCVV                          4A
     D  pValid                        1N
      *
     D CHECKFRAUD      PR
     D  pCustId                      10A
     D  pAmount                      15P 2
     D  pScore                        5P 2
     D  pRisk                         1A
      *
     D AUTHORIZE       PR
     D  pAmount                      15P 2
     D  pAuthCode                    10A
     D  pSuccess                      1N
      *
     D CAPTURE         PR
     D  pAuthCode                    10A
     D  pAmount                      15P 2
     D  pRefNbr                      20A
     D  pSuccess                      1N
      *
     D SETTLEMENT      PR
     D  pRefNbr                      20A
     D  pBatchNbr                    10A
     D  pSettleId                    15A
      *
     D UPDATEBALANCE   PR
     D  pCustId                      10A
     D  pAmount                      15P 2
     D  pType                         1A
      *
     D LOGPAYMENT      PR
     D  pTranId                      20A
     D  pStatus                       2A
      *
     D RETRYPAYMENT    PR
     D  pTranId                      20A
     D  pRetry                        2P 0
     D  pSuccess                      1N
      *
      /FREE
       wValidFlag = *Off;
       wSuccessFlag = *Off;
       wCompleteFlag = *Off;
       wPendingFlag = *Off;
       wErrorFlag = *Off;
       wWarningFlag = *Off;
       wStepNumber = 1;
       wPhaseNumber = 1;
       wRetryCount = 0;
       wMaxRetries = 3;
       wRetryDelay = 5000;
       wTimeoutSecs = 30;
       wProcessStatus = 'IP';
       wErrorCode = '000000';
       wArrayIndex = 1;
       wSumValues = 0;
       wCountValues = 0;
       wMultiplier = 1.0000;
       wDivisor = 1.0000;
       wExchangeRate = 1.0000;
       wCurrencyCode = 'USD';
       wBaseCurrency = 'USD';
       
       wStartTime = %Time();
       wProcessDate = %Date();
       wProcessTime = %Time();
       wProcessStamp = %Timestamp();
       
       wStepNumber = 2;
       Open PAYMENTDB;
       Open PYMTQUEUE;
       Open PYMTHISTRY;
       Open GATEWAYCFG;
       Open RETRYLOGF;
       
       wStepNumber = 3;
       INITGATEWAY(pPayMethod: wGatewayId: wGatewayStatus);
       
       If wGatewayStatus <> 'A';
         wErrorCode = '100001';
         wErrorMessage = 'Gateway not available';
         wErrorFlag = *On;
         wProcessStatus = 'ER';
         Close PAYMENTDB;
         Close PYMTQUEUE;
         Close PYMTHISTRY;
         Close GATEWAYCFG;
         Close RETRYLOGF;
         Return;
       EndIf;
       
       wStepNumber = 4;
       AUTHENTICATE(wGatewayId: wAuthToken: wValidFlag);
       
       If Not wValidFlag;
         wErrorCode = '100002';
         wErrorMessage = 'Authentication failed';
         wErrorFlag = *On;
         wProcessStatus = 'ER';
         Close PAYMENTDB;
         Close PYMTQUEUE;
         Close PYMTHISTRY;
         Close GATEWAYCFG;
         Close RETRYLOGF;
         Return;
       EndIf;
       
       wStepNumber = 5;
       wCardNumber = '4111111111111111';
       wCardExpiry = '1225';
       wCardCVV = '123';
       wCardHolder = 'TEST CUSTOMER';
       
       VALIDATECARD(wCardNumber: wCardExpiry: wCardCVV: wValidFlag);
       
       If Not wValidFlag;
         wErrorCode = '100003';
         wErrorMessage = 'Invalid card details';
         wErrorFlag = *On;
         wProcessStatus = 'ER';
         Close PAYMENTDB;
         Close PYMTQUEUE;
         Close PYMTHISTRY;
         Close GATEWAYCFG;
         Close RETRYLOGF;
         Return;
       EndIf;
       
       wStepNumber = 6;
       CHECKFRAUD(pCustId: pAmount: wFraudScore: wRiskLevel);
       
       If wRiskLevel = 'H';
         wWarningCode = '2001';
         wWarningMsg = 'High fraud risk detected';
         wWarningFlag = *On;
       EndIf;
       
       If wFraudScore > 80.00;
         wErrorCode = '100004';
         wErrorMessage = 'Transaction blocked - fraud';
         wErrorFlag = *On;
         wProcessStatus = 'BL';
         Close PAYMENTDB;
         Close PYMTQUEUE;
         Close PYMTHISTRY;
         Close GATEWAYCFG;
         Close RETRYLOGF;
         Return;
       EndIf;
       
       wStepNumber = 7;
       wGrossAmount = pAmount;
       wFeeAmount = pProcFee;
       wTaxOnFee = wFeeAmount * 0.18;
       wNetAmount = wGrossAmount + wFeeAmount + wTaxOnFee;
       
       For wIterator = 1 to 10;
         wTempValue1 = wNetAmount * (wIterator * 0.1);
         wTempValue2 = wTempValue1 * 1.05;
         wTempValue3 = wTempValue2 * 0.98;
         wPymtArray(wIterator) = wTempValue3;
         wSumValues = wSumValues + wPymtArray(wIterator);
         wCountValues = wCountValues + 1;
       EndFor;
       
       wAverage = wSumValues / wCountValues;
       wVariance = 0;
       
       For wIterator = 1 to 10;
         wVariance = wVariance + 
                     ((wPymtArray(wIterator) - wAverage) *
                      (wPymtArray(wIterator) - wAverage));
       EndFor;
       
       wStdDeviation = %Sqrt(wVariance / wCountValues);
       
       wStepNumber = 8;
       For wRowIdx = 1 to 5;
         For wColIdx = 1 to 5;
           wMatrixData(wRowIdx:wColIdx) = 
             (wRowIdx * wColIdx * wNetAmount * 0.01);
         EndFor;
       EndFor;
       
       wCalcResult1 = wMatrixData(3:3);
       wCalcResult2 = wMatrixData(2:4);
       wCalcResult3 = wMatrixData(4:2);
       
       wStepNumber = 9;
       wAmountAuth = wNetAmount;
       
       For wRetryCount = 1 to wMaxRetries;
         AUTHORIZE(wAmountAuth: wApprovalCode: wSuccessFlag);
         
         If wSuccessFlag;
           wAuthStatus = 'A';
           Leave;
         Else;
           wAuthStatus = 'D';
           wPendingFlag = *On;
         EndIf;
       EndFor;
       
       If Not wSuccessFlag;
         wErrorCode = '100005';
         wErrorMessage = 'Authorization failed';
         wErrorFlag = *On;
         wProcessStatus = 'DE';
         RETRYPAYMENT(pTranId: wRetryCount: wValidFlag);
         Close PAYMENTDB;
         Close PYMTQUEUE;
         Close PYMTHISTRY;
         Close GATEWAYCFG;
         Close RETRYLOGF;
         Return;
       EndIf;
       
       wStepNumber = 10;
       wAmountCapture = wAmountAuth;
       
       CAPTURE(wApprovalCode: wAmountCapture: 
               wReferenceNbr: wSuccessFlag);
       
       If Not wSuccessFlag;
         wErrorCode = '100006';
         wErrorMessage = 'Capture failed';
         wErrorFlag = *On;
         wProcessStatus = 'CF';
         Close PAYMENTDB;
         Close PYMTQUEUE;
         Close PYMTHISTRY;
         Close GATEWAYCFG;
         Close RETRYLOGF;
         Return;
       EndIf;
       
       wStepNumber = 11;
       SETTLEMENT(wReferenceNbr: wBatchNumber: wSettlementId);
       
       wStepNumber = 12;
       UPDATEBALANCE(pCustId: wNetAmount: 'D');
       
       wStepNumber = 13;
       wProcessStatus = 'CO';
       LOGPAYMENT(pTranId: wProcessStatus);
       
       wStepNumber = 14;
       wEndTime = %Time();
       wDuration = %Diff(wEndTime:wStartTime:*Seconds);
       
       wProgressPct = 100.00;
       wCompleteFlag = *On;
       
       wStepNumber = 15;
       Close PAYMENTDB;
       Close PYMTQUEUE;
       Close PYMTHISTRY;
       Close GATEWAYCFG;
       Close RETRYLOGF;
       
       *InLr = *On;
       Return;
      /END-FREE
      *
     P INITGATEWAY     B
     D INITGATEWAY     PI
     D  pMethod                       2A
     D  pGatewayId                    5A
     D  pStatus                       1A
      /FREE
       If pMethod = 'CC';
         pGatewayId = 'GTW01';
       ElseIf pMethod = 'DC';
         pGatewayId = 'GTW02';
       Else;
         pGatewayId = 'GTW03';
       EndIf;
       pStatus = 'A';
      /END-FREE
     P INITGATEWAY     E
      *
     P AUTHENTICATE    B
     D AUTHENTICATE    PI
     D  pGatewayId                    5A
     D  pToken                       50A
     D  pSuccess                      1N
      /FREE
       pToken = 'AUTH_TOKEN_' + pGatewayId + '_12345';
       pSuccess = *On;
      /END-FREE
     P AUTHENTICATE    E
      *
     P VALIDATECARD    B
     D VALIDATECARD    PI
     D  pCardNbr                     16A
     D  pExpiry                       4A
     D  pCVV                          4A
     D  pValid                        1N
      /FREE
       pValid = *On;
      /END-FREE
     P VALIDATECARD    E
      *
     P CHECKFRAUD      B
     D CHECKFRAUD      PI
     D  pCustId                      10A
     D  pAmount                      15P 2
     D  pScore                        5P 2
     D  pRisk                         1A
      /FREE
       pScore = 25.00;
       pRisk = 'L';
      /END-FREE
     P CHECKFRAUD      E
      *
     P AUTHORIZE       B
     D AUTHORIZE       PI
     D  pAmount                      15P 2
     D  pAuthCode                    10A
     D  pSuccess                      1N
      /FREE
       pAuthCode = 'AUTH123456';
       pSuccess = *On;
      /END-FREE
     P AUTHORIZE       E
      *
     P CAPTURE         B
     D CAPTURE         PI
     D  pAuthCode                    10A
     D  pAmount                      15P 2
     D  pRefNbr                      20A
     D  pSuccess                      1N
      /FREE
       pRefNbr = 'REF' + pAuthCode + '789';
       pSuccess = *On;
      /END-FREE
     P CAPTURE         E
      *
     P SETTLEMENT      B
     D SETTLEMENT      PI
     D  pRefNbr                      20A
     D  pBatchNbr                    10A
     D  pSettleId                    15A
      /FREE
       pBatchNbr = 'BATCH00001';
       pSettleId = 'SETTLE' + pBatchNbr;
      /END-FREE
     P SETTLEMENT      E
      *
     P UPDATEBALANCE   B
     D UPDATEBALANCE   PI
     D  pCustId                      10A
     D  pAmount                      15P 2
     D  pType                         1A
      /FREE
      /END-FREE
     P UPDATEBALANCE   E
      *
     P LOGPAYMENT      B
     D LOGPAYMENT      PI
     D  pTranId                      20A
     D  pStatus                       2A
      /FREE
      /END-FREE
     P LOGPAYMENT      E
      *
     P RETRYPAYMENT    B
     D RETRYPAYMENT    PI
     D  pTranId                      20A
     D  pRetry                        2P 0
     D  pSuccess                      1N
      /FREE
       pSuccess = *Off;
      /END-FREE
     P RETRYPAYMENT    E