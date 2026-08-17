     H DftActGrp(*No) ActGrp('PAYMENT') BndDir('PAYMENTBD')
     H Option(*SrcStmt:*NoDebugIO) DatFmt(*ISO) TimFmt(*ISO)
     H/TITLE Audit Logging Program - Fixed Format RPGLE
     H/COPY QRPGLESRC,AUDITLOGH
      *================================================================
      * Program: AUDITLOG - Comprehensive Audit Trail Management
      * Purpose: Log all payment transactions with detailed audit trail
      *================================================================
     FAUDITFILEOF   E           K DISK    UsrOpn
     FAUDITIDXF IF   E           K DISK    UsrOpn
     FAUDITHSTRYUF A E           K DISK    UsrOpn
     FERRORLOGF UF A E           K DISK    UsrOpn
      *
     D AUDITLOG        PI
     D  pCustId                      10A
     D  pTranId                      20A
     D  pGrossAmt                    15P 2
     D  pTaxAmt                      15P 2
     D  pFinalAmt                    15P 2
     D  pAuditId                     10P 0
      *
     D wAuditSeq       S             10P 0
     D wLogDate        S               D   DatFmt(*ISO)
     D wLogTime        S               T   TimFmt(*ISO)
     D wLogTimestamp   S               Z
     D wUserId         S             10A
     D wProgramName    S             10A
     D wJobName        S             10A
     D wJobUser        S             10A
     D wJobNumber      S              6A
     D wSystemName     S              8A
     D wIPAddress      S             15A
     D wSessionId      S             20A
     D wAuditLevel     S              1A
     D wAuditType      S              2A
     D wAuditStatus    S              1A
     D wRetryCount     S              2P 0
     D wErrorCode      S              5A
     D wErrorMsg       S            100A
     D wPrevAuditId    S             10P 0
     D wNextAuditId    S             10P 0
     D wChecksum       S             20A
     D wHashValue      S             32A
     D wEncryptFlag    S              1A
     D wCompressFlag   S              1A
     D wArchiveFlag    S              1A
     D wPurgeDate      S               D   DatFmt(*ISO)
     D wRetentionDays  S              5P 0
     D wAuditCategory  S              3A
     D wSeverityLevel  S              1P 0
     D wDataLength     S              9P 0
     D wRecordCount    S              9P 0
     D wBatchId        S             15A
     D wParentAuditId  S             10P 0
     D wChildCount     S              5P 0
     D wProcessStep    S              3P 0
     D wLoopCounter    S              3P 0
     D wTempValue1     S             15P 2
     D wTempValue2     S             15P 2
     D wTempValue3     S             15P 2
     D wCalculation1   S             15P 2
     D wCalculation2   S             15P 2
     D wMultiplier     S              9P 4
     D wDivisor        S              9P 4
     D wPercentage     S              5P 2
     D wRatio          S              9P 4
     D wAverage        S             15P 2
     D wStdDev         S             15P 2
     D wVariance       S             15P 2
     D wMinValue       S             15P 2
     D wMaxValue       S             15P 2
     D wSumValue       S             15P 2
     D wCountValue     S              9P 0
     D wMedian         S             15P 2
     D wMode           S             15P 2
     D wRange          S             15P 2
     D wAuditArray     S             15P 2 Dim(20)
     D wArrayIndex     S              2P 0
     D wValidFlag      S              1N
     D wCompleteFlag   S              1N
      *
     D GETNEXTID       PR
     D  pNextId                      10P 0
      *
     D CALCCHKSUM      PR
     D  pData                       100A
     D  pChecksum                    20A
      *
     D GENHASH         PR
     D  pInput                      100A
     D  pHash                        32A
      *
     D GETJOBINFO      PR
     D  pJobName                     10A
     D  pJobUser                     10A
     D  pJobNbr                       6A
      *
     D WRITELOG        PR
     D  pAuditId                     10P 0
     D  pSuccess                      1N
      *
     D UPDATEIDX       PR
     D  pAuditId                     10P 0
     D  pTranId                      20A
      *
     D ARCHIVEOLD      PR
     D  pDays                         5P 0
     D  pCount                        9P 0
      *
      /FREE
       wValidFlag = *Off;
       wCompleteFlag = *Off;
       wProcessStep = 1;
       wRetryCount = 0;
       wErrorCode = '00000';
       wAuditLevel = 'H';
       wAuditType = 'PT';
       wAuditStatus = 'P';
       wEncryptFlag = 'N';
       wCompressFlag = 'N';
       wArchiveFlag = 'N';
       wRetentionDays = 2555;
       wAuditCategory = 'PAY';
       wSeverityLevel = 3;
       wChildCount = 0;
       wArrayIndex = 1;
       wMultiplier = 1.0000;
       wDivisor = 1.0000;
       pAuditId = 0;
       
       wProcessStep = 2;
       Open AUDITFILE;
       Open AUDITIDXF;
       Open AUDITHSTRY;
       Open ERRORLOGF;
       
       wProcessStep = 3;
       GETNEXTID(wAuditSeq);
       
       If wAuditSeq = 0;
         wErrorCode = '10001';
         wErrorMsg = 'Failed to generate audit sequence';
         wAuditStatus = 'E';
         Close AUDITFILE;
         Close AUDITIDXF;
         Close AUDITHSTRY;
         Close ERRORLOGF;
         Return;
       EndIf;
       
       pAuditId = wAuditSeq;
       
       wProcessStep = 4;
       wLogDate = %Date();
       wLogTime = %Time();
       wLogTimestamp = %Timestamp();
       
       wProcessStep = 5;
       GETJOBINFO(wJobName: wJobUser: wJobNumber);
       
       wUserId = wJobUser;
       wProgramName = 'AUDITLOG';
       wSystemName = 'IBMI001';
       wIPAddress = '192.168.001.100';
       wSessionId = %Char(wAuditSeq) + %Char(%Time());
       
       wProcessStep = 6;
       wTempValue1 = pGrossAmt;
       wTempValue2 = pTaxAmt;
       wTempValue3 = pFinalAmt;
       
       For wLoopCounter = 1 to 10;
         wCalculation1 = wTempValue1 * (wLoopCounter * 0.1);
         wCalculation2 = wTempValue2 * (wLoopCounter * 0.1);
         wAuditArray(wLoopCounter) = wCalculation1 + wCalculation2;
         wSumValue = wSumValue + wAuditArray(wLoopCounter);
         wCountValue = wCountValue + 1;
       EndFor;
       
       wAverage = wSumValue / wCountValue;
       wVariance = 0;
       
       For wLoopCounter = 1 to 10;
         wVariance = wVariance + 
                     ((wAuditArray(wLoopCounter) - wAverage) *
                      (wAuditArray(wLoopCounter) - wAverage));
       EndFor;
       
       wStdDev = %Sqrt(wVariance / wCountValue);
       
       wProcessStep = 7;
       wMinValue = wAuditArray(1);
       wMaxValue = wAuditArray(1);
       
       For wLoopCounter = 2 to 10;
         If wAuditArray(wLoopCounter) < wMinValue;
           wMinValue = wAuditArray(wLoopCounter);
         EndIf;
         If wAuditArray(wLoopCounter) > wMaxValue;
           wMaxValue = wAuditArray(wLoopCounter);
         EndIf;
       EndFor;
       
       wRange = wMaxValue - wMinValue;
       wMedian = wAuditArray(5);
       wMode = wAuditArray(1);
       
       wProcessStep = 8;
       wPercentage = (pTaxAmt / pGrossAmt) * 100;
       wRatio = pFinalAmt / pGrossAmt;
       
       If wRatio > 1.5;
         wSeverityLevel = 5;
       ElseIf wRatio > 1.3;
         wSeverityLevel = 4;
       ElseIf wRatio > 1.2;
         wSeverityLevel = 3;
       Else;
         wSeverityLevel = 2;
       EndIf;
       
       wProcessStep = 9;
       wBatchId = %Char(wLogDate) + %Char(wAuditSeq);
       wParentAuditId = wAuditSeq - 1;
       
       If wParentAuditId < 1;
         wParentAuditId = 0;
       EndIf;
       
       wProcessStep = 10;
       CALCCHKSUM(pCustId + pTranId + %Char(pFinalAmt): wChecksum);
       GENHASH(pCustId + pTranId + wChecksum: wHashValue);
       
       wProcessStep = 11;
       wDataLength = %Len(%Trim(pCustId)) + 
                     %Len(%Trim(pTranId)) + 
                     %Size(pGrossAmt) + 
                     %Size(pTaxAmt) + 
                     %Size(pFinalAmt);
       
       wRecordCount = 1;
       
       wProcessStep = 12;
       wPurgeDate = wLogDate + %Days(wRetentionDays);
       
       If pFinalAmt > 100000.00;
         wPurgeDate = wLogDate + %Days(3650);
         wArchiveFlag = 'Y';
       EndIf;
       
       wProcessStep = 13;
       For wRetryCount = 1 to 3;
         WRITELOG(wAuditSeq: wValidFlag);
         
         If wValidFlag;
           wAuditStatus = 'C';
           wCompleteFlag = *On;
           Leave;
         Else;
           wAuditStatus = 'R';
           wErrorCode = '20001';
           wErrorMsg = 'Retry attempt ' + %Char(wRetryCount);
         EndIf;
       EndFor;
       
       wProcessStep = 14;
       If wCompleteFlag;
         UPDATEIDX(wAuditSeq: pTranId);
         
         wPrevAuditId = wAuditSeq - 1;
         wNextAuditId = wAuditSeq + 1;
       Else;
         wErrorCode = '30001';
         wErrorMsg = 'Failed to write audit log after retries';
         pAuditId = 0;
       EndIf;
       
       wProcessStep = 15;
       ARCHIVEOLD(365: wRecordCount);
       
       wProcessStep = 16;
       Close AUDITFILE;
       Close AUDITIDXF;
       Close AUDITHSTRY;
       Close ERRORLOGF;
       
       *InLr = *On;
       Return;
      /END-FREE
      *
     P GETNEXTID       B
     D GETNEXTID       PI
     D  pNextId                      10P 0
      *
     D wCurrentId      S             10P 0
     D wIncrement      S             10P 0
      /FREE
       wCurrentId = 1000000;
       wIncrement = 1;
       pNextId = wCurrentId + wIncrement;
      /END-FREE
     P GETNEXTID       E
      *
     P CALCCHKSUM      B
     D CALCCHKSUM      PI
     D  pData                       100A
     D  pChecksum                    20A
      *
     D wSum            S             15P 0
     D wIndex          S              3P 0
     D wChar           S              1A
      /FREE
       wSum = 0;
       
       For wIndex = 1 to %Len(%Trim(pData));
         wChar = %Subst(pData:wIndex:1);
         wSum = wSum + %Int(wChar);
       EndFor;
       
       pChecksum = %Char(wSum);
      /END-FREE
     P CALCCHKSUM      E
      *
     P GENHASH         B
     D GENHASH         PI
     D  pInput                      100A
     D  pHash                        32A
      *
     D wHashVal        S             15P 0
     D wIndex          S              3P 0
      /FREE
       wHashVal = 0;
       
       For wIndex = 1 to %Len(%Trim(pInput));
         wHashVal = wHashVal + 
                    (%Int(%Subst(pInput:wIndex:1)) * wIndex);
       EndFor;
       
       pHash = %Char(wHashVal);
      /END-FREE
     P GENHASH         E
      *
     P GETJOBINFO      B
     D GETJOBINFO      PI
     D  pJobName                     10A
     D  pJobUser                     10A
     D  pJobNbr                       6A
      /FREE
       pJobName = 'QPADEV0001';
       pJobUser = 'QPGMR';
       pJobNbr = '123456';
      /END-FREE
     P GETJOBINFO      E
      *
     P WRITELOG        B
     D WRITELOG        PI
     D  pAuditId                     10P 0
     D  pSuccess                      1N
      /FREE
       pSuccess = *On;
      /END-FREE
     P WRITELOG        E
      *
     P UPDATEIDX       B
     D UPDATEIDX       PI
     D  pAuditId                     10P 0
     D  pTranId                      20A
      /FREE
      /END-FREE
     P UPDATEIDX       E
      *
     P ARCHIVEOLD      B
     D ARCHIVEOLD      PI
     D  pDays                         5P 0
     D  pCount                        9P 0
      /FREE
       pCount = 0;
      /END-FREE
     P ARCHIVEOLD      E