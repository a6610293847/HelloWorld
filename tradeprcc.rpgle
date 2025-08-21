     H*  1. NO.         CHANG001
     H*     DATE        2023-10-01
     H*     AMENDMENT   Process SPT TRADE file
     H*     AUTHOR      John Doe
     H*  2. NO.         CHANG002
     H*     DATE        2023-10-02
     H*     AMENDMENT   Insert FWD TRADE records
     H*     AUTHOR      Jane Smith
     H*
     H*  SUBROUTINE SUMMARY
     H*
     H*  SUBROUTINE    FUNCTION
     H*  ----------    --------
     H*    SR100       Report Heading Processing
     H*    SR200       Process SPT records
     H*    SR300       Process FWD records
     H*    SR700       Report End Processing
     H*    SR998       Initialization
     F/EJECT
     FSPT       IF   E           K DISK
     F*
     FFWD       IF   E           K DISK
     F*
     FTRADER1   O    E             PRINTER USROPN
     F*
     D*****************************************************
     D*  Work Fields                                      *
     D*****************************************************
     D WREGION         S             10A
     D WCOUNTRY        S              3A
     D WREGN           S             10A
     D WRPTDATE        S              8A
     D WRPTTIME        S              6P 0
     D WTYPE           S             20A
     D WCOUNT          S             10I 0
     D WAMOUNT         S             15P 0
     D WTOTCOUNT       S             10I 0
     D WTOTAMOUNT      S             15P 2
     D WIDX            S              3I 0
     D WMAX            C                   CONST(50)
     D TYPE            S             20A   DIM(WMAX)
     D COUNT           S             10I 0 DIM(WMAX)
     D AMOUNT          S             15P 2 DIM(WMAX)
     D MAXPAIR         C                   CONST(50)
     D REGN            S             10A   DIM(MAXPAIR)
     D CNTY            S              3A   DIM(MAXPAIR)
     D PAIRCNT         S              3I 0
     D 
     D
     D*
     C*****************************************************
     C*  Main Program                                     *
     C*****************************************************
     C*
     C*    Initialization
     C                   EXSR      SR998                                         Initialization
     C*
     C                   EXSR      SR100                                         Report Heading Processing
     C                   EXSR      SR200                                         Process SPT records
     C                   EXSR      SR300                                         Process FWD records
     C*
     C                   EXSR      SR700                                         Report End Processing   
     C*
     C                   MOVE      *ON           *INLR        
     C                   RETURN  
     C/EJECT
     C*****************************************************
     C*  Subroutine SR100 - Report Heading Processing     *
     C*****************************************************
     C/SPACE 3
     C     SR100         BEGSR   
     C     *START        SETLL     SPT
     C                   READ      SPT
     C                   IF        NOT %EOF(SPT)
     C                   MOVEL     AAREGI        WREGION
     C                   MOVEL     AACTYC        WCOUNTRY
     C                   ELSE
     C     *START        SETLL     FWD
     C                   READ      FWD
     C                   IF        NOT  %EOF(FWD)
     C                   MOVEL     ABREGI        WREGION
     C                   MOVEL     ABCTYC        WCOUNTRY
     C                   ENDIF
     C                   ENDIF
     C* Write Header
     C                   OPEN      TRADER1
     C                   WRITE     HEADER
     C     SR100E        ENDSR
     C/EJECT
     C*****************************************************
     C*  Subroutine SR200 - Process SPT Records           *
     C*****************************************************
     C/SPACE 3
     C     SR200         BEGSR   
     C     *START        SETLL     SPT
     C                   READ      SPT
     C                   DOW       NOT  %EOF(SPT)
     C* Find product type in array
     C                   Z-ADD     0             WIDX
     C                   FOR       WIDX = 1 TO WMAX
     C                   IF        TYPE(WIDX) = *BLANK OR TYPE(WIDX) = AATYPE
     C                   LEAVE
     C                   ENDIF
     C                   ENDFOR
     C* IF new type, store it
     C                   IF        TYPE(WIDX) = *BLANK
     C                   MOVEL     AATYPE        TYPE(WIDX)
     C                   ENDIF
     C* Accumulate count and amount
     C                   ADD       1             COUNT(WIDX)
     C                   ADD       AAMONT        AMOUNT(WIDX)
     C                   ADD       1             WTOTCOUNT
     C                   ADD       AAMONT        WTOTAMOUNT
     C                   READ      SPT
     C                   ENDDO
     C     SR200E        ENDSR
     C/EJECT
     C*****************************************************
     C*  Subroutine SR300 - Process FWD Records           *
     C*****************************************************
     C/SPACE 3
     C     SR300         BEGSR   
     C     *START        SETLL     FWD
     C                   READ      FWD
     C                   DOW       NOT  %EOF(FWD)
     C* Find product type in array
     C                   Z-ADD     0             WIDX
     C                   FOR       WIDX = 1 TO WMAX
     C                   IF        TYPE(WIDX) = *BLANK OR TYPE(WIDX) = AATYPE
     C                   LEAVE
     C                   ENDIF
     C                   ENDFOR
     C* IF new type, store it
     C                   IF        TYPE(WIDX) = *BLANK
     C                   MOVEL     ABTYPE        TYPE(WIDX)
     C                   ENDIF
     C* Accumulate count and amount
     C                   ADD       1             COUNT(WIDX)
     C                   ADD       ABMONT        AMOUNT(WIDX)
     C                   ADD       1             WTOTCOUNT
     C                   ADD       ABMONT        WTOTAMOUNT
     C                   READ      FWD
     C                   ENDDO
     C     SR300E        ENDSR
     C/EJECT
     C*****************************************************
     C*  Subroutine SR700 - Report End Processing         *
     C*****************************************************
     C/SPACE 3
     C     SR700         BEGSR
     C* Print detail lines for each product typ
     C                   FOR       WIDX = 1 TO WMAX
     C                   IF        TYPE(WIDX) <> *BLANK
     C                   MOVEL     TYPE(WIDX)    DTYPE
     C                   Z-ADD     COUNT(WIDX)   DCOUNT
     C                   Z-ADD     AMOUNT(WIDX)  DAMOUNT
     C                   WRITE     DETAIL
     C                   ENDIF
     C                   ENDFOR
     C* Print footer
     C                   Z-ADD     WTOTCOUNT     TOTCOUNT
     C                   Z-ADD     WTOTAMOUNT    TOTAMOUNT
     C                   WRITE     FOOTER
     C     SR700E        ENDSR
     C/EJECT
     C*****************************************************
     C*  Subroutine SR998 - Initialization                *
     C*****************************************************
     C/SPACE 3
     C     SR998         BEGSR   
     C* Get system date and time
     C                   MOVEL     *DATE         WRPTDATE
     C                   TIME                    WRPTTIME
     C* Initialize totals
     C                   Z-ADD     0             WTOTCOUNT
     C                   Z-ADD     0             WTOTAMOUNT
     C* Clear arrays
     C                   CLEAR                   TYPE
     C                   CLEAR                   COUNT
     C                   CLEAR                   AMOUNT
     C     SR998E        ENDSR
     C/EJECT
