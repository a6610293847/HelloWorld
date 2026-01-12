# HelloWorld Workspace Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         HelloWorld Trading System                            │
│                         IBM i / RPG Application                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Component Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              DATA LAYER                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐                 │
│  │   SPT.PF    │      │   FWD.PF    │      │  TRADE.PF   │                 │
│  │  (Spot      │      │  (Forward   │      │  (General   │                 │
│  │   Trades)   │      │   Trades)   │      │   Trades)   │                 │
│  └─────────────┘      └─────────────┘      └─────────────┘                 │
│                                                                               │
│  Record Format:        Record Format:        Record Format:                  │
│  - SPTR               - FWDR                 - TRADEREC                      │
│  - Regional (10A)     - Regional (10A)       - Regional (10A)                │
│  - Country (3A)       - Country (3A)         - Country (3A)                  │
│  - Trade ID (10A)     - Trade ID (10A)       - Trade ID (10A)                │
│  - Type (20A)         - Type (20A)           - Product (20A)                 │
│  - Currency1 (3A)     - Currency1 (3A)       - Currency (3A)                 │
│  - Currency2 (3A)     - Currency2 (3A)       - Amount (15,2)                 │
│  - Amount (15,2)      - Amount (15,2)                                        │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                           PROCESSING LAYER                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  testdata.sqlrpgle - Test Data Generator                               │ │
│  │  ────────────────────────────────────────────────────────────────────  │ │
│  │  Purpose: Populate SPT and FWD files with sample FX trading data       │ │
│  │  • Inserts 10 records into SPT (Spot Trades)                           │ │
│  │  • Inserts 10 records into FWD (Forward/Swap/Option Trades)            │ │
│  │  • Covers 10 global regions with various currency pairs                │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  TRADESQL.rpgle - TRADE File Data Generator                            │ │
│  │  ────────────────────────────────────────────────────────────────────  │ │
│  │  Purpose: Populate TRADE file with sample general trade data           │ │
│  │  • Inserts 10 records covering APAC, EMEA, AMERICAS regions            │ │
│  │  • Various product types (Electronics, Wine, Software, etc.)           │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  tradeprc.rpgle - Trade Summary Report Generator (ENHANCED)            │ │
│  │  ────────────────────────────────────────────────────────────────────  │ │
│  │  Purpose: Generate consolidated trade summary from SPT and FWD files   │ │
│  │                                                                         │ │
│  │  Subroutines:                                                           │ │
│  │  • SR998: Initialize arrays, date/time, totals                         │ │
│  │  • SR100: Print report header with region/country                      │ │
│  │  • SR200: Process SPT records, accumulate by product type              │ │
│  │  • SR300: Process FWD records, accumulate by product type              │ │
│  │  • SR700: Print detail lines and footer with totals                    │ │
│  │                                                                         │ │
│  │  Features:                                                              │ │
│  │  • Groups trades by product type (up to 50 types)                      │ │
│  │  • Calculates count and amount per product type                        │ │
│  │  • Generates grand totals                                              │ │
│  │  • Outputs to TRADER1 printer file                                     │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  tradeprcc.rpgle - Trade Summary Report (Reference Implementation)     │ │
│  │  ────────────────────────────────────────────────────────────────────  │ │
│  │  Purpose: Complete reference implementation of trade summary report    │ │
│  │  • Same functionality as tradeprc.rpgle                                │ │
│  │  • Used as template for enhancement                                    │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  TRADECNT.rpgle - Trade Count Report by Hierarchy                      │ │
│  │  ────────────────────────────────────────────────────────────────────  │ │
│  │  Purpose: Generate hierarchical trade count report from TRADE file     │ │
│  │                                                                         │ │
│  │  Features:                                                              │ │
│  │  • Counts trades by Product, Country, and Region                       │ │
│  │  • Hierarchical break logic (Product → Country → Region)               │ │
│  │  • Prints subtotals at each level                                      │ │
│  │  • Generates grand total                                               │ │
│  │  • Outputs to TRADEREP printer file                                    │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                            OUTPUT LAYER                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  trader1.prtf - Trade Summary Report Format                          │    │
│  │  ───────────────────────────────────────────────────────────────────│    │
│  │                                                                       │    │
│  │  Record Formats:                                                      │    │
│  │  ┌──────────────────────────────────────────────────────────────┐   │    │
│  │  │ HEADER                                                        │   │    │
│  │  │ • Title: "Trade Summary Report"                              │   │    │
│  │  │ • Regional (10A)                                             │   │    │
│  │  │ • Country Code (3A)                                          │   │    │
│  │  │ • Report Date (8A)                                           │   │    │
│  │  │ • Report Time (6A)                                           │   │    │
│  │  │ • Column Headers: PRODUCT TYPE, TRADE COUNT, TRADE AMOUNT    │   │    │
│  │  └──────────────────────────────────────────────────────────────┘   │    │
│  │                                                                       │    │
│  │  ┌──────────────────────────────────────────────────────────────┐   │    │
│  │  │ DETAIL                                                        │   │    │
│  │  │ • Product Type (20A)                                         │   │    │
│  │  │ • Trade Count (10,0)                                         │   │    │
│  │  │ • Trade Amount (15,2)                                        │   │    │
│  │  └──────────────────────────────────────────────────────────────┘   │    │
│  │                                                                       │    │
│  │  ┌──────────────────────────────────────────────────────────────┐   │    │
│  │  │ FOOTER                                                        │   │    │
│  │  │ • Label: "Total"                                             │   │    │
│  │  │ • Total Trade Count (10,0)                                   │   │    │
│  │  │ • Total Trade Amount (15,2)                                  │   │    │
│  │  │ • End Message: "*** End of Report ***"                       │   │    │
│  │  └──────────────────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌──────────────────┐
│  testdata.       │
│  sqlrpgle        │──┐
└──────────────────┘  │
                      │    ┌─────────┐         ┌──────────────┐
                      ├───▶│ SPT.PF  │────┐    │              │
                      │    └─────────┘    │    │              │
                      │                   ├───▶│ tradeprc.    │
                      │    ┌─────────┐    │    │ rpgle        │
                      └───▶│ FWD.PF  │────┘    │              │
                           └─────────┘         │              │
                                               └──────┬───────┘
                                                      │
                                                      ▼
                                               ┌──────────────┐
                                               │ trader1.prtf │
                                               │ (Report)     │
                                               └──────────────┘

┌──────────────────┐
│  TRADESQL.       │
│  rpgle           │──┐
└──────────────────┘  │
                      │    ┌──────────┐        ┌──────────────┐
                      └───▶│ TRADE.PF │───────▶│ TRADECNT.    │
                           └──────────┘        │ rpgle        │
                                               └──────┬───────┘
                                                      │
                                                      ▼
                                               ┌──────────────┐
                                               │ TRADEREP     │
                                               │ (Report)     │
                                               └──────────────┘
```

## File Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│                     Physical Files (Database)                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  SPT.PF ◄────────── testdata.sqlrpgle (Populates)              │
│    │                                                             │
│    └──────────────► tradeprc.rpgle (Reads)                      │
│                                                                  │
│  FWD.PF ◄────────── testdata.sqlrpgle (Populates)              │
│    │                                                             │
│    └──────────────► tradeprc.rpgle (Reads)                      │
│                                                                  │
│  TRADE.PF ◄──────── TRADESQL.rpgle (Populates)                 │
│    │                                                             │
│    └──────────────► TRADECNT.rpgle (Reads)                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Printer Files (Reports)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  trader1.prtf ◄──── tradeprc.rpgle (Writes)                     │
│                     tradeprcc.rpgle (Writes)                     │
│                                                                  │
│  TRADEREP ◄──────── TRADECNT.rpgle (Writes)                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Program Execution Flow

### tradeprc.rpgle Execution Sequence

```
START
  │
  ├─► SR998: Initialization
  │   ├─ Get system date/time
  │   ├─ Initialize totals (WTOTCOUNT, WTOTAMOUNT)
  │   └─ Clear arrays (TYPE, COUNT, AMOUNT)
  │
  ├─► SR100: Report Heading
  │   ├─ Read first SPT or FWD record for region/country
  │   ├─ Open TRADER1 printer file
  │   └─ Write HEADER record
  │
  ├─► SR200: Process SPT Records
  │   ├─ Loop through all SPT records
  │   ├─ For each record:
  │   │   ├─ Find/create product type in array
  │   │   ├─ Increment count for product type
  │   │   ├─ Add amount to product type total
  │   │   └─ Update grand totals
  │   └─ End loop
  │
  ├─► SR300: Process FWD Records
  │   ├─ Loop through all FWD records
  │   ├─ For each record:
  │   │   ├─ Find/create product type in array
  │   │   ├─ Increment count for product type
  │   │   ├─ Add amount to product type total
  │   │   └─ Update grand totals
  │   └─ End loop
  │
  ├─► SR700: Report End
  │   ├─ Loop through product type arrays
  │   │   └─ Write DETAIL record for each product type
  │   ├─ Write FOOTER record with grand totals
  │   └─ Display "End of Report" message
  │
  └─► END (Set *INLR = *ON)
```

### TRADECNT.rpgle Execution Sequence

```
START
  │
  ├─► *INZSR: Initialization
  │   └─ Print report headings
  │
  ├─► Main Loop: Process TRADE Records
  │   ├─ Read TRADE record
  │   ├─ Check for Region break → Print region subtotal
  │   ├─ Check for Country break → Print country subtotal
  │   ├─ Check for Product break → Print product subtotal
  │   ├─ Increment counters (Product, Country, Region, Total)
  │   └─ Loop until EOF
  │
  ├─► Print Final Subtotals
  │   ├─ Print last product subtotal
  │   ├─ Print last country subtotal
  │   └─ Print last region subtotal
  │
  ├─► Print Grand Total
  │
  └─► END (Set LR = *ON)
```

## Key Features by Component

### Data Generation Programs
- **testdata.sqlrpgle**: FX trading test data (SPT/FWD)
- **TRADESQL.rpgle**: General trade test data (TRADE)

### Reporting Programs
- **tradeprc.rpgle**: Product type summary with totals
- **tradeprcc.rpgle**: Reference implementation
- **TRADECNT.rpgle**: Hierarchical count report

### Database Files
- **SPT.PF**: Spot trades (7 fields)
- **FWD.PF**: Forward/Swap/Option trades (7 fields)
- **TRADE.PF**: General trades (6 fields)

### Report Formats
- **trader1.prtf**: Formatted summary report (Header/Detail/Footer)
- **TRADEREP**: Hierarchical count report

## Technology Stack

```
┌─────────────────────────────────────────┐
│  Language: RPG IV (ILE RPG)             │
│  SQL: Embedded SQL (SQLRPGLE)           │
│  Platform: IBM i (AS/400)               │
│  Database: DB2 for i                    │
│  File Types: Physical Files (.PF)       │
│  Print Files: Printer Files (.PRTF)     │
└─────────────────────────────────────────┘
```

---
*Generated: 2026-01-07*
*Workspace: c:/swtool/BOB/HelloWorld*