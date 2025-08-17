FTRADE     IF   E           K DISK
FTRADEREP  O    F   132        PRINTER

D REGN        S             10A
D CNTRY       S              3A
D PROD        S             20A
D REGN_OLD    S             10A
D CNTRY_OLD   S              3A
D PROD_OLD    S             20A
D CNT_PROD    S              5I 0 INZ(0)
D CNT_CNTRY   S              5I 0 INZ(0)
D CNT_REGN    S              5I 0 INZ(0)
D CNT_TOTAL   S              5I 0 INZ(0)

C     *INZSR    BEGSR
C                   EXSR HEADINGS
C                   ENDSR

C                   READ      TRADE
C                   DOW NOT %EOF(TRADE)
C                   EVAL      REGN = REGIONAL
C                   EVAL      CNTRY = COUNTRY
C                   EVAL      PROD = PRODUCT

C                   IF REGN <> REGN_OLD AND CNT_REGN > 0
C                   EXSR PRINT_REGN
C                   ENDIF

C                   IF CNTRY <> CNTRY_OLD AND CNT_CNTRY > 0
C                   EXSR PRINT_CNTRY
C                   ENDIF

C                   IF PROD <> PROD_OLD AND CNT_PROD > 0
C                   EXSR PRINT_PROD
C                   ENDIF

C                   EVAL      CNT_PROD = CNT_PROD + 1
C                   EVAL      CNT_CNTRY = CNT_CNTRY + 1
C                   EVAL      CNT_REGN = CNT_REGN + 1
C                   EVAL      CNT_TOTAL = CNT_TOTAL + 1

C                   EVAL      REGN_OLD = REGN
C                   EVAL      CNTRY_OLD = CNTRY
C                   EVAL      PROD_OLD = PROD

C                   READ      TRADE
C                   ENDDO

C                   EXSR PRINT_PROD
C                   EXSR PRINT_CNTRY
C                   EXSR PRINT_REGN

C                   EXSR PRINT_TOTAL

C                   SETON                     LR

C     HEADINGS   BEGSR
C                   EXCEPT    HDR1
C                   ENDSR

C     PRINT_PROD BEGSR
C                   EXCEPT    PRODLINE
C                   EVAL      CNT_PROD = 0
C                   ENDSR

C     PRINT_CNTRY BEGSR
C                   EXCEPT    CNTRYLINE
C                   EVAL      CNT_CNTRY = 0
C                   ENDSR

C     PRINT_REGN BEGSR
C                   EXCEPT    REGNLINE
C                   EVAL      CNT_REGN = 0
C                   ENDSR

C     PRINT_TOTAL BEGSR
C                   EXCEPT    TOTALLINE
C                   ENDSR

O* Printer file output specs
O          E            HDR1      1
O                                           'Trade Report by Region, Country, Product'
O          E            PRODLINE  1
O                       PROD_OLD         CNT_PROD
O          E            CNTRYLINE 1
O                       CNTRY_OLD        CNT_CNTRY
O          E            REGNLINE  1
O                       REGN_OLD         CNT_REGN
O          E            TOTALLINE 1
O                                           'Total Trades:' CNT_TOTAL
