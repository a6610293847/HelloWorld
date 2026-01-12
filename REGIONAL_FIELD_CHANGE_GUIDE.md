# Regional Field Enhancement Guide
## Change Request: Expand Regional from 10 to 15 Characters

**Date:** 2026-01-09  
**Analyst:** IBM Bob  
**Workspace:** c:/swtool/BOB/HelloWorld

---

## Quick Reference

**Change:** Regional field 10A → 15A  
**Affected Files:** 3 physical files, 5 programs, 1 printer file  
**Risk Level:** MEDIUM-HIGH  
**Estimated Effort:** 5-7 hours  
**Complexity:** Higher than Trade ID change (field is displayed in reports)

---

## Impact Analysis

### Affected Physical Files

| File | Record Format | Field Name | Current | New | Impact |
|------|---------------|------------|---------|-----|--------|
| **spt.pf** | SPTR | AAREGI | 10A | 15A | HIGH |
| **fwd.pf** | FWDR | ABREGI | 10A | 15A | HIGH |
| **TRADE.pf** | TRADEREC | REGIONAL | 10A | 15A | HIGH |

### Affected Programs

| Program | Field Usage | Impact Level | Changes Required |
|---------|-------------|--------------|------------------|
| **testdata.sqlrpgle** | Hardcoded values | MEDIUM | Update test data values |
| **TRADESQL.rpgle** | Variable declaration + values | MEDIUM | Update variable + test data |
| **tradeprc.rpgle** | Reads & displays in header | **HIGH** | Update work fields |
| **tradeprcc.rpgle** | Reads & displays in header | **HIGH** | Update work fields |
| **TRADECNT.rpgle** | Reads & displays in report | **HIGH** | Update work fields |

### Affected Report Files

| File | Field Usage | Impact Level | Changes Required |
|------|-------------|--------------|------------------|
| **trader1.prtf** | HEADER record displays REGIONAL | **HIGH** | Update field definition |

### Current Regional Values

**SPT/FWD Files:**
```
REGION01, REGION02, REGION03, ..., REGION10 (8 characters)
```

**TRADE File:**
```
APAC, EMEA, AMERICAS (4-8 characters)
```

---

## Detailed Impact by Component

### 1. Physical Files (HIGH IMPACT)

#### spt.pf
```dds
Current:
     A            AAREGI        10A         COLHDG('Regional')

Proposed:
     A            AAREGI        15A         COLHDG('Regional')
```

#### fwd.pf
```dds
Current:
     A            ABREGI        10A         COLHDG('Regional')

Proposed:
     A            ABREGI        15A         COLHDG('Regional')
```

#### TRADE.pf
```dds
Current:
      A    REGIONAL      10A         COLHDG('Regional')

Proposed:
      A    REGIONAL      15A         COLHDG('Regional')
```

**Impact:**
- Record length increases by 5 bytes per file
- Existing data will be right-padded with blanks
- All programs must be recompiled
- Indexes on Regional field (if any) must be rebuilt

### 2. Report File (HIGH IMPACT)

#### trader1.prtf

**Current:**
```dds
     A          R HEADER
     A                                     1'Trade Summary Report'
     A                                      SPACEA(1)
     A            REGIONAL      10A        5
     A                                      TEXT('Regional')
```

**Proposed:**
```dds
     A          R HEADER
     A                                     1'Trade Summary Report'
     A                                      SPACEA(1)
     A            REGIONAL      15A        5
     A                                      TEXT('Regional')
```

**Impact:**
- Report layout may need adjustment
- Field position may shift other fields
- Consider column alignment

### 3. Programs with Work Fields (HIGH IMPACT)

#### tradeprc.rpgle & tradeprcc.rpgle

**Current Work Fields:**
```rpgle
     D WREGION         S             10A
     D WREGN           S             10A
     D REGN            S             10A   DIM(MAXPAIR)
```

**Proposed:**
```rpgle
     D WREGION         S             15A
     D WREGN           S             15A
     D REGN            S             15A   DIM(MAXPAIR)
```

**Code Changes Required:**
```rpgle
Line 75:  C                   MOVEL     AAREGI        WREGION
Line 81:  C                   MOVEL     ABREGI        WREGION
```

**Impact:**
- Work field declarations must be updated
- MOVEL operations will work correctly (left-justified)
- Report header will display full 15 characters

#### TRADECNT.rpgle

**Current Work Fields:**
```rpgle
D REGN        S             10A
D REGN_OLD    S             10A
```

**Proposed:**
```rpgle
D REGN        S             15A
D REGN_OLD    S             15A
```

**Code Changes Required:**
```rpgle
Line 21:  C                   EVAL      REGN = REGIONAL
Line 42:  C                   EVAL      REGN_OLD = REGN
```

**Impact:**
- Work field declarations must be updated
- EVAL operations will work correctly
- Report output will display full 15 characters

### 4. Data Generation Programs (MEDIUM IMPACT)

#### testdata.sqlrpgle

**Current Test Data:**
```rpgle
fwdData(1) = *ALL'REGION01' : 'USA' : 'TRD0000001' : ...
fwdData(2) = *ALL'REGION02' : 'JPN' : 'TRD0000002' : ...
```

**Proposed Test Data:**
```rpgle
fwdData(1) = *ALL'NORTH-AMERICA' : 'USA' : 'TRD0000001' : ...
fwdData(2) = *ALL'ASIA-PACIFIC' : 'JPN' : 'TRD0000002' : ...
fwdData(3) = *ALL'EUROPE-WEST' : 'GBR' : 'TRD0000003' : ...
```

**Impact:**
- Array declarations use LIKE, so they auto-adjust
- Test data values should demonstrate new 15-character capability
- Consider meaningful regional names

#### TRADESQL.rpgle

**Current:**
```rpgle
dcl-s regional   char(10);

exec sql insert into TRADE (...) values ('APAC', 'JPN', ...);
exec sql insert into TRADE (...) values ('EMEA', 'FRA', ...);
exec sql insert into TRADE (...) values ('AMERICAS', 'USA', ...);
```

**Proposed:**
```rpgle
dcl-s regional   char(15);

exec sql insert into TRADE (...) values ('ASIA-PACIFIC', 'JPN', ...);
exec sql insert into TRADE (...) values ('EUROPE-MIDEAST', 'FRA', ...);
exec sql insert into TRADE (...) values ('NORTH-AMERICA', 'USA', ...);
```

**Impact:**
- Variable declaration must be updated
- Test data should use descriptive 15-character names
- SQL statements will work with new size

---

## Step-by-Step Implementation Guide

### Phase 1: Preparation (1 hour)

#### Step 1.1: Backup Everything
```bash
# Backup physical files
SAVOBJ OBJ(SPT FWD TRADE) LIB(YOURLIB) DEV(*SAVF) SAVF(YOURLIB/BACKUP)

# Backup source files
SAVOBJ OBJ(QRPGLESRC QDDSSRC) LIB(YOURLIB) DEV(*SAVF) SAVF(YOURLIB/SRCBACKUP)
```

#### Step 1.2: Document Current State
```sql
-- Record current data samples
SELECT AAREGI, COUNT(*) FROM SPT GROUP BY AAREGI;
SELECT ABREGI, COUNT(*) FROM FWD GROUP BY ABREGI;
SELECT REGIONAL, COUNT(*) FROM TRADE GROUP BY REGIONAL;
```

#### Step 1.3: Create Test Environment
```bash
# Copy to test library
CRTLIB LIB(TESTLIB)
CPYF FROMFILE(YOURLIB/SPT) TOFILE(TESTLIB/SPT) CRTFILE(*YES)
CPYF FROMFILE(YOURLIB/FWD) TOFILE(TESTLIB/FWD) CRTFILE(*YES)
CPYF FROMFILE(YOURLIB/TRADE) TOFILE(TESTLIB/TRADE) CRTFILE(*YES)
```

### Phase 2: Update File Definitions (1 hour)

#### Step 2.1: Update spt.pf
```dds
     A          R SPTR 
     A            AAREGI        15A         COLHDG('Regional')
     A            AACTYC         3A         COLHDG('Country' 'Code')
     A            AATRID        30A         COLHDG('Trade' 'ID')
     A            AATYPE        20A         COLHDG('Product')
     A            AACYPC         3A         COLHDG('Currency1')
     A            AACCYC         3A         COLHDG('Currency2')
     A            AAMONT        15S 2       COLHDG('Amount')
```

#### Step 2.2: Update fwd.pf
```dds
     A          R FWDR 
     A            ABREGI        15A         COLHDG('Regional')
     A            ABCTYC         3A         COLHDG('Country' 'Code')
     A            ABTRID        30A         COLHDG('Trade' 'ID')
     A            ABTYPE        20A         COLHDG('Product')
     A            ABCYPC         3A         COLHDG('Currency1')
     A            ABCCYC         3A         COLHDG('Currency2')
     A            ABMONT        15S 2       COLHDG('Amount')
```

#### Step 2.3: Update TRADE.pf
```dds
      A          R TRADEREC
      A    REGIONAL      15A         COLHDG('Regional')
      A    COUNTRY        3A         COLHDG('Country' 'Code')
      A    TRADEID       30A         COLHDG('Trade' 'ID')
      A    PRODUCT       20A         COLHDG('Product')
      A    CURRENCY       3A         COLHDG('Currency')
      A    AMOUNT        15S 2       COLHDG('Amount')
```

### Phase 3: Recreate Physical Files (1.5 hours)

#### Option A: Using SQL ALTER TABLE (Recommended)
```sql
-- For each file, alter the column
ALTER TABLE SPT ALTER COLUMN AAREGI SET DATA TYPE CHAR(15);
ALTER TABLE FWD ALTER COLUMN ABREGI SET DATA TYPE CHAR(15);
ALTER TABLE TRADE ALTER COLUMN REGIONAL SET DATA TYPE CHAR(15);

-- Verify changes
SELECT * FROM QSYS2.SYSCOLUMNS 
WHERE TABLE_NAME IN ('SPT', 'FWD', 'TRADE') 
  AND COLUMN_NAME IN ('AAREGI', 'ABREGI', 'REGIONAL');
```

#### Option B: File Recreation (If ALTER not available)
```sql
-- For SPT file:
-- 1. Save data
CREATE TABLE SPT_BACKUP AS (SELECT * FROM SPT) WITH DATA;

-- 2. Drop old file
DROP TABLE SPT;

-- 3. Recreate with new DDS (compile spt.pf)
CRTPF FILE(YOURLIB/SPT) SRCFILE(YOURLIB/QDDSSRC)

-- 4. Restore data (Regional will be padded)
INSERT INTO SPT SELECT * FROM SPT_BACKUP;

-- 5. Verify
SELECT COUNT(*) FROM SPT;

-- Repeat for FWD and TRADE
```

### Phase 4: Update Report File (30 minutes)

#### Step 4.1: Update trader1.prtf
```dds
     A          R HEADER
     A                                     1'Trade Summary Report'
     A                                      SPACEA(1)
     A            REGIONAL      15A        5
     A                                      TEXT('Regional')
     A            COUNTRY        3A       25
     A                                      TEXT('Country Code')
     A            RPTDATE        8A       34
     A                                      TEXT('Report Date')
     A            RPTTIME        6A       46
     A                                      TEXT('Report Time')    
     A                                      SPACEA(1)
     A                                     5'PRODUCT TYPE'
     A                                    26'TRADE COUNT'
     A                                    40'TRADE AMOUNT'
     A                                      SPACEA(1)
     A
     A          R DETAIL
     A            DTYPE         20A        5
     A            DCOUNT        10S 0     26
     A            DAMOUNT       15S 2     40
     A
     A          R FOOTER
     A                                      SPACEB(1)
     A                                     5'Total'
     A            TOTCOUNT      10S 0     26
     A                                     TEXT('Total Trade Count')
     A            TOTAMOUNT     15S 2     40
     A                                     TEXT('Total Trade Amount')
     A                                     5'*** End of Report ***'
```

#### Step 4.2: Compile Report File
```bash
CRTPRTF FILE(YOURLIB/TRADER1) SRCFILE(YOURLIB/QDDSSRC)
```

### Phase 5: Update Programs (2 hours)

#### Step 5.1: Update tradeprc.rpgle
```rpgle
     D*****************************************************
     D*  Work Fields                                      *
     D*****************************************************
     D WREGION         S             15A
     D WCOUNTRY        S              3A
     D WREGN           S             15A
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
     D REGN            S             15A   DIM(MAXPAIR)
     D CNTY            S              3A   DIM(MAXPAIR)
     D PAIRCNT         S              3I 0
```

#### Step 5.2: Update tradeprcc.rpgle
Same changes as tradeprc.rpgle (lines 29, 31, 45)

#### Step 5.3: Update TRADECNT.rpgle
```rpgle
D REGN        S             15A
D CNTRY       S              3A
D PROD        S             20A
D REGN_OLD    S             15A
D CNTRY_OLD   S              3A
D PROD_OLD    S             20A
```

#### Step 5.4: Update testdata.sqlrpgle
```rpgle
// Populate sample data for FWD with 15-character regional names
fwdData(1) = *ALL'NORTH-AMERICA' : 'USA' : 'TRD-2026-USA-FX-FWD-000001' : 'FX Forward' : 'USD' : 'EUR' : 100000.00;
fwdData(2) = *ALL'ASIA-PACIFIC' : 'JPN' : 'TRD-2026-JPN-FX-SWP-000002' : 'FX Swap'    : 'JPY' : 'USD' : 200000.00;
fwdData(3) = *ALL'EUROPE-WEST' : 'GBR' : 'TRD-2026-GBR-FX-OPT-000003' : 'FX Option'  : 'GBP' : 'USD' : 150000.00;
fwdData(4) = *ALL'ASIA-PACIFIC' : 'AUS' : 'TRD-2026-AUS-FX-FWD-000004' : 'FX Forward' : 'AUD' : 'NZD' : 120000.00;
fwdData(5) = *ALL'ASIA-PACIFIC' : 'SGP' : 'TRD-2026-SGP-FX-SWP-000005' : 'FX Swap'    : 'SGD' : 'USD' : 130000.00;
fwdData(6) = *ALL'ASIA-PACIFIC' : 'CHN' : 'TRD-2026-CHN-FX-OPT-000006' : 'FX Option'  : 'CNY' : 'USD' : 110000.00;
fwdData(7) = *ALL'ASIA-PACIFIC' : 'IND' : 'TRD-2026-IND-FX-FWD-000007' : 'FX Forward' : 'INR' : 'USD' : 90000.00;
fwdData(8) = *ALL'NORTH-AMERICA' : 'CAN' : 'TRD-2026-CAN-FX-SWP-000008' : 'FX Swap'    : 'CAD' : 'USD' : 80000.00;
fwdData(9) = *ALL'SOUTH-AMERICA' : 'BRA' : 'TRD-2026-BRA-FX-OPT-000009' : 'FX Option'  : 'BRL' : 'USD' : 70000.00;
fwdData(10)= *ALL'AFRICA-SOUTH' : 'ZAF' : 'TRD-2026-ZAF-FX-FWD-000010' : 'FX Forward' : 'ZAR' : 'USD' : 60000.00;

// Populate sample data for SPT
sptData(1) = *ALL'NORTH-AMERICA' : 'USA' : 'TRD-2026-USA-SPOT-000101'   : 'Spot Trade' : 'USD' : 'EUR' : 50000.00;
sptData(2) = *ALL'ASIA-PACIFIC' : 'JPN' : 'TRD-2026-JPN-SPOT-000102'   : 'Spot Trade' : 'JPY' : 'USD' : 60000.00;
sptData(3) = *ALL'EUROPE-WEST' : 'GBR' : 'TRD-2026-GBR-SPOT-000103'   : 'Spot Trade' : 'GBP' : 'USD' : 70000.00;
sptData(4) = *ALL'ASIA-PACIFIC' : 'AUS' : 'TRD-2026-AUS-SPOT-000104'   : 'Spot Trade' : 'AUD' : 'NZD' : 80000.00;
sptData(5) = *ALL'ASIA-PACIFIC' : 'SGP' : 'TRD-2026-SGP-SPOT-000105'   : 'Spot Trade' : 'SGD' : 'USD' : 90000.00;
sptData(6) = *ALL'ASIA-PACIFIC' : 'CHN' : 'TRD-2026-CHN-SPOT-000106'   : 'Spot Trade' : 'CNY' : 'USD' : 100000.00;
sptData(7) = *ALL'ASIA-PACIFIC' : 'IND' : 'TRD-2026-IND-SPOT-000107'   : 'Spot Trade' : 'INR' : 'USD' : 110000.00;
sptData(8) = *ALL'NORTH-AMERICA' : 'CAN' : 'TRD-2026-CAN-SPOT-000108'   : 'Spot Trade' : 'CAD' : 'USD' : 120000.00;
sptData(9) = *ALL'SOUTH-AMERICA' : 'BRA' : 'TRD-2026-BRA-SPOT-000109'   : 'Spot Trade' : 'BRL' : 'USD' : 130000.00;
sptData(10)= *ALL'AFRICA-SOUTH' : 'ZAF' : 'TRD-2026-ZAF-SPOT-000110'   : 'Spot Trade' : 'ZAR' : 'USD' : 140000.00;
```

#### Step 5.5: Update TRADESQL.rpgle
```rpgle
**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-s regional   char(15);
dcl-s country    char(3);
dcl-s tradeid    char(30);
dcl-s product    char(20);
dcl-s currency   char(3);
dcl-s amount     packed(15:2);

// Sample records with 15-character regional names
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('ASIA-PACIFIC', 'JPN', 'TRD-2026-APAC-JPN-ELEC-0001', 'Electronics', 'JPY', 100000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('ASIA-PACIFIC', 'CHN', 'TRD-2026-APAC-CHN-APPR-0002', 'Apparel', 'CNY', 50000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('EUROPE-WEST', 'FRA', 'TRD-2026-EMEA-FRA-WINE-0003', 'Wine', 'EUR', 20000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('EUROPE-WEST', 'DEU', 'TRD-2026-EMEA-DEU-AUTO-0004', 'Auto Parts', 'EUR', 75000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('NORTH-AMERICA', 'USA', 'TRD-2026-AMER-USA-SOFT-0005', 'Software', 'USD', 120000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('SOUTH-AMERICA', 'BRA', 'TRD-2026-AMER-BRA-COFF-0006', 'Coffee', 'BRL', 30000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('ASIA-PACIFIC', 'IND', 'TRD-2026-APAC-IND-TEXT-0007', 'Textiles', 'INR', 40000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('EUROPE-WEST', 'GBR', 'TRD-2026-EMEA-GBR-PHAR-0008', 'Pharmaceuticals', 'GBP', 90000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('NORTH-AMERICA', 'CAN', 'TRD-2026-AMER-CAN-LUMB-0009', 'Lumber', 'CAD', 60000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) 
  values ('ASIA-PACIFIC', 'AUS', 'TRD-2026-APAC-AUS-MINE-0010', 'Minerals', 'AUD', 80000.00);

*inlr = *on;
return;
```

#### Step 5.6: Compile All Programs
```bash
# Compile in order
CRTRPGMOD MODULE(YOURLIB/TRADEPRC) SRCFILE(YOURLIB/QRPGLESRC)
CRTPGM PGM(YOURLIB/TRADEPRC) MODULE(YOURLIB/TRADEPRC)

CRTRPGMOD MODULE(YOURLIB/TRADEPRCC) SRCFILE(YOURLIB/QRPGLESRC)
CRTPGM PGM(YOURLIB/TRADEPRCC) MODULE(YOURLIB/TRADEPRCC)

CRTRPGMOD MODULE(YOURLIB/TRADECNT) SRCFILE(YOURLIB/QRPGLESRC)
CRTPGM PGM(YOURLIB/TRADECNT) MODULE(YOURLIB/TRADECNT)

CRTSQLRPGI OBJ(YOURLIB/TESTDATA) SRCFILE(YOURLIB/QRPGLESRC)
CRTSQLRPGI OBJ(YOURLIB/TRADESQL) SRCFILE(YOURLIB/QRPGLESRC)
```

### Phase 6: Testing (1.5 hours)

#### Step 6.1: Clear Test Data
```sql
DELETE FROM SPT;
DELETE FROM FWD;
DELETE FROM TRADE;
```

#### Step 6.2: Generate New Test Data
```bash
# Run data generators
CALL TESTDATA
CALL TRADESQL
```

#### Step 6.3: Verify Data
```sql
-- Check SPT data
SELECT AAREGI, AATRID, AATYPE FROM SPT;

-- Check FWD data
SELECT ABREGI, ABTRID, ABTYPE FROM FWD;

-- Check TRADE data
SELECT REGIONAL, TRADEID, PRODUCT FROM TRADE;

-- Verify field lengths
SELECT LENGTH(AAREGI) AS SPT_LEN FROM SPT FETCH FIRST 1 ROW ONLY;
SELECT LENGTH(ABREGI) AS FWD_LEN FROM FWD FETCH FIRST 1 ROW ONLY;
SELECT LENGTH(REGIONAL) AS TRADE_LEN FROM TRADE FETCH FIRST 1 ROW ONLY;
```

#### Step 6.4: Test Reports
```bash
# Run report programs
CALL TRADEPRC
CALL TRADECNT

# Review spool files
WRKSPLF
```

#### Step 6.5: Validate Report Output
- Check that Regional field displays correctly (15 characters)
- Verify no truncation
- Confirm report alignment is correct
- Validate totals are accurate

### Phase 7: Documentation (30 minutes)

#### Step 7.1: Update Documentation
- Update WORKSPACE_DIAGRAM.md with new field sizes
- Update README.md with change notes
- Document new Regional naming standards

#### Step 7.2: Create Change Log
```markdown
## Change Log - Regional Field Enhancement

**Date:** 2026-01-09
**Change:** Regional field expanded from 10A to 15A

**Files Modified:**
- spt.pf (AAREGI)
- fwd.pf (ABREGI)
- TRADE.pf (REGIONAL)
- trader1.prtf (REGIONAL)
- tradeprc.rpgle (work fields)
- tradeprcc.rpgle (work fields)
- TRADECNT.rpgle (work fields)
- testdata.sqlrpgle (test data)
- TRADESQL.rpgle (variable + test data)

**New Regional Names:**
- NORTH-AMERICA (15 chars)
- SOUTH-AMERICA (15 chars)
- ASIA-PACIFIC (13 chars)
- EUROPE-WEST (12 chars)
- AFRICA-SOUTH (12 chars)
```

---

## Recommended Regional Names

### Standard 15-Character Regional Names
```
NORTH-AMERICA   (15 chars) - USA, Canada, Mexico
SOUTH-AMERICA   (15 chars) - Brazil, Argentina, Chile
ASIA-PACIFIC    (13 chars) - Japan, China, Australia, Singapore, India
EUROPE-WEST     (12 chars) - UK, France, Germany
EUROPE-EAST     (12 chars) - Poland, Czech Republic
MIDDLE-EAST     (12 chars) - UAE, Saudi Arabia
AFRICA-NORTH    (13 chars) - Egypt, Morocco
AFRICA-SOUTH    (13 chars) - South Africa
```

---

## Implementation Checklist

### Pre-Implementation
- [ ] Backup all physical files
- [ ] Backup all source code
- [ ] Create test environment
- [ ] Document current Regional values
- [ ] Review and approve this guide

### File Changes
- [ ] Update spt.pf definition (AAREGI: 10A → 15A)
- [ ] Update fwd.pf definition (ABREGI: 10A → 15A)
- [ ] Update TRADE.pf definition (REGIONAL: 10A → 15A)
- [ ] Update trader1.prtf (REGIONAL: 10A → 15A)
- [ ] Recreate or alter physical files
- [ ] Compile report file

### Program Changes
- [ ] Update tradeprc.rpgle work fields (3 fields)
- [ ] Update tradeprcc.rpgle work fields (3 fields)
- [ ] Update TRADECNT.rpgle work fields (2 fields)
- [ ] Update testdata.sqlrpgle test data (20 values)
- [ ] Update TRADESQL.rpgle variable + data (11 items)
- [ ] Compile all programs

### Testing
- [ ] Clear test data
- [ ] Run testdata.sqlrpgle
- [ ] Run TRADESQL.rpgle
- [ ] Verify data in all files
- [ ] Run tradeprc.rpgle report
- [ ] Run TRADECNT.rpgle report
- [ ] Validate report output
- [ ] Check for truncation issues
- [ ] Verify totals accuracy

### Post-Implementation
- [ ] Update documentation
- [ ] Create change log
- [ ] Communicate changes to users
- [ ] Monitor system for issues
- [ ] Archive old test data

---

## Rollback Plan

If issues arise:

### Immediate Rollback
```sql
-- Restore from backup
RSTOBJ OBJ(SPT FWD TRADE) SAVLIB(YOURLIB) DEV(*SAVF) SAVF(YOURLIB/BACKUP)
RSTOBJ OBJ(QRPGLESRC QDDSSRC) SAVLIB(YOURLIB) DEV(*SAVF) SAVF(YOURLIB/SRCBACKUP)
```

### Recompile Original Programs
```bash
# Recompile all programs with original source
CRTRPGMOD MODULE(YOURLIB/TRADEPRC) SRCFILE(YOURLIB/QRPGLESRC)
CRTPGM PGM(YOURLIB/TRADEPRC) MODULE(YOURLIB/TRADEPRC)
# Repeat for all programs
```

### Verify System
```bash
# Test all programs
CALL TESTDATA
CALL TRADEPRC
CALL TRADECNT
```

---

## Key Differences from Trade ID Change

| Aspect | Trade ID Change | Regional Change |
|--------|----------------|-----------------|
| **Complexity** | Lower | Higher |
| **Report Impact** | None (not displayed) | High (displayed in header) |
| **Work Fields** | None | Multiple programs |
| **Report File** | No changes | Must update |
| **Testing** | Simpler | More extensive |
| **Risk** | Medium | Medium-High |

---

## Common Pitfalls to Avoid

1. **Forgetting Report File:** trader1.prtf must be updated
2. **Work Field Mismatches:** All work fields must match new size
3. **Test Data Length:** Use full 15 characters to test properly
4. **Report Alignment:** Check column positions after change
5. **Incomplete Recompile:** All programs must be recompiled
6. **Missing Backup:** Always backup before making changes

---

## Success Criteria

✓ All physical files updated to 15A  
✓ All programs compile without errors  
✓ Reports display full 15-character Regional names  
✓ No data truncation  
✓ No report alignment issues  
✓ All tests pass  
✓ Documentation updated  

---

## Conclusion

Changing the Regional field from 10 to 15 characters is more complex than the Trade ID change because:
1. Regional is displayed in reports (requires report file update)
2. Multiple programs have work fields that must be updated
3. More extensive testing is required

However, with careful planning and execution following this guide, the change can be implemented successfully with minimal risk.

**Estimated Total Time:** 5-7 hours  
**Recommended Approach:** Implement in test environment first, validate thoroughly, then promote to production

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-09  
**Status:** Implementation Guide