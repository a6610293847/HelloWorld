** Sample SQLRPGLE program to insert 10 records into FWD and SPT files **
** Assumes both files are externally described and available in the library list **

ctl-opt dftactgrp(*no) actgrp(*caller);

exec sql include fwd;
exec sql include spt;

// Sample data arrays
DCL-S fwdData like(FWDR) dim(10) inz(*LIKEDS);
DCL-S sptData like(SPTR) dim(10) inz(*LIKEDS);

// Populate sample data for FWD
fwdData(1) = *ALL'REGION01' : 'USA' : 'TRD0000001' : 'FX Forward' : 'USD' : 'EUR' : 100000.00;
fwdData(2) = *ALL'REGION02' : 'JPN' : 'TRD0000002' : 'FX Swap'    : 'JPY' : 'USD' : 200000.00;
fwdData(3) = *ALL'REGION03' : 'GBR' : 'TRD0000003' : 'FX Option'  : 'GBP' : 'USD' : 150000.00;
fwdData(4) = *ALL'REGION04' : 'AUS' : 'TRD0000004' : 'FX Forward' : 'AUD' : 'NZD' : 120000.00;
fwdData(5) = *ALL'REGION05' : 'SGP' : 'TRD0000005' : 'FX Swap'    : 'SGD' : 'USD' : 130000.00;
fwdData(6) = *ALL'REGION06' : 'CHN' : 'TRD0000006' : 'FX Option'  : 'CNY' : 'USD' : 110000.00;
fwdData(7) = *ALL'REGION07' : 'IND' : 'TRD0000007' : 'FX Forward' : 'INR' : 'USD' : 90000.00;
fwdData(8) = *ALL'REGION08' : 'CAN' : 'TRD0000008' : 'FX Swap'    : 'CAD' : 'USD' : 80000.00;
fwdData(9) = *ALL'REGION09' : 'BRA' : 'TRD0000009' : 'FX Option'  : 'BRL' : 'USD' : 70000.00;
fwdData(10)= *ALL'REGION10' : 'ZAF' : 'TRD0000010' : 'FX Forward' : 'ZAR' : 'USD' : 60000.00;

// Populate sample data for SPT
sptData(1) = *ALL'REGION01' : 'USA' : 'TRD0000101' : 'Spot Trade' : 'USD' : 'EUR' : 50000.00;
sptData(2) = *ALL'REGION02' : 'JPN' : 'TRD0000102' : 'Spot Trade' : 'JPY' : 'USD' : 60000.00;
sptData(3) = *ALL'REGION03' : 'GBR' : 'TRD0000103' : 'Spot Trade' : 'GBP' : 'USD' : 70000.00;
sptData(4) = *ALL'REGION04' : 'AUS' : 'TRD0000104' : 'Spot Trade' : 'AUD' : 'NZD' : 80000.00;
sptData(5) = *ALL'REGION05' : 'SGP' : 'TRD0000105' : 'Spot Trade' : 'SGD' : 'USD' : 90000.00;
sptData(6) = *ALL'REGION06' : 'CHN' : 'TRD0000106' : 'Spot Trade' : 'CNY' : 'USD' : 100000.00;
sptData(7) = *ALL'REGION07' : 'IND' : 'TRD0000107' : 'Spot Trade' : 'INR' : 'USD' : 110000.00;
sptData(8) = *ALL'REGION08' : 'CAN' : 'TRD0000108' : 'Spot Trade' : 'CAD' : 'USD' : 120000.00;
sptData(9) = *ALL'REGION09' : 'BRA' : 'TRD0000109' : 'Spot Trade' : 'BRL' : 'USD' : 130000.00;
sptData(10)= *ALL'REGION10' : 'ZAF' : 'TRD0000110' : 'Spot Trade' : 'ZAR' : 'USD' : 140000.00;

// Insert FWD data
for i = 1 to 10;
  exec sql insert into fwd values(:fwdData(i));
endfor;

// Insert SPT data
for i = 1 to 10;
  exec sql insert into spt values(:sptData(i));
endfor;

*inlr = *on;
return;
