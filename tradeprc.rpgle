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
     D*
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
     C     SR100E        ENDSR
     C/EJECT
     C*****************************************************
     C*  Subroutine SR200 - Process SPT Records           *
     C*****************************************************
     C/SPACE 3
     C     SR200         BEGSR   
     C     SR200E        ENDSR
     C/EJECT
     C*****************************************************
     C*  Subroutine SR300 - Process FWD Records           *
     C*****************************************************
     C/SPACE 3
     C     SR300         BEGSR   
     C     SR300E        ENDSR
     C/EJECT
     C*****************************************************
     C*  Subroutine SR700 - Report End Processing         *
     C*****************************************************
     C/SPACE 3
     C     SR700         BEGSR   
     C     SR700E        ENDSR
     C/EJECT
     C*****************************************************
     C*  Subroutine SR998 - Initialization                *
     C*****************************************************
     C/SPACE 3
     C     SR998         BEGSR   
     C     SR998E        ENDSR
     C/EJECT
