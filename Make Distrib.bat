@echo off

PATH=c:\cygwin\bin;%PATH%;

del BBtray.zip
del BBtray-SSL.zip

upx -9 bbtray.exe

c:\cygwin\bin\echo -ne "BBtray, by Deluan Cotts.\r\n\r\nSee Readme.txt for install instructions". | zip -z -9 BBtray.zip @distrib.lst
c:\cygwin\bin\echo -ne "BBtray, by Deluan Cotts.\r\n\r\nSee Readme.txt for install instructions". | zip -z -9 BBtray-SSL.zip @distrib-ssl.lst