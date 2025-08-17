**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-s regional   char(10);
dcl-s country    char(3);
dcl-s tradeid    char(10);
dcl-s product    char(20);
dcl-s currency   char(3);
dcl-s amount     packed(15:2);

// Sample records
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('APAC', 'JPN', 'T0001', 'Electronics', 'JPY', 100000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('APAC', 'CHN', 'T0002', 'Apparel', 'CNY', 50000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('EMEA', 'FRA', 'T0003', 'Wine', 'EUR', 20000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('EMEA', 'DEU', 'T0004', 'Auto Parts', 'EUR', 75000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('AMERICAS', 'USA', 'T0005', 'Software', 'USD', 120000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('AMERICAS', 'BRA', 'T0006', 'Coffee', 'BRL', 30000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('APAC', 'IND', 'T0007', 'Textiles', 'INR', 40000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('EMEA', 'GBR', 'T0008', 'Pharmaceuticals', 'GBP', 90000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('AMERICAS', 'CAN', 'T0009', 'Lumber', 'CAD', 60000.00);
exec sql insert into TRADE (REGIONAL, COUNTRY, TRADEID, PRODUCT, CURRENCY, AMOUNT) values ('APAC', 'AUS', 'T0010', 'Minerals', 'AUD', 80000.00);

*inlr = *on;
return;
