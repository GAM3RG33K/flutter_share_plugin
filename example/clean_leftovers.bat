@echo off
setlocal
echo cleaning iOS left over build files...
set "directories=.\ios\Flutter\App.framework\ .\ios\Flutter\Flutter.framework\ .\ios\.symlinks .\ios\Frameworks"
set "files=.\ios\Flutter\Generated.xcconfig .\ios\Flutter\app.flx .\ios\ServiceDefinitions.json"
echo cleaning directories...
(
 for %%i in (%directories%) do (
  @RD /S /Q %%i
  echo(%%i
  echo()
)
echo cleaning files...
(
 for %%i in (%files%) do (
  @DEL /S /Q %%i
  echo(%%i
  echo()
)