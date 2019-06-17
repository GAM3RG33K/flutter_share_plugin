set currentDir=%cd%
for %%d in ("%currentDir%") do set "dirName=%%~nxd"
echo %currentDir%
echo %dirName%
flutter clean && 7z a -tzip %dirName%.zip .
pause
