@ECHO OFF
CLS
COLOR 8
TITLE=Auto Git Ask ChatGPT
ECHO.
SET MSG="Update (auto commit)"
ECHO.##### Git Status
git status
ECHO.
ECHO.
ECHO.##### Git Add Files
git add *
ECHO.
ECHO.##### Git Commit:
ECHO.
ECHO.	%MSG%:
ECHO.
rem git commit -m %MSG%
git commit
ECHO.
ECHO.
ECHO.##### Git Push:
COLOR 3
git push
COLOR 2
ECHO.
ECHO.
ECHO.##### Git Status
git branch
git status
ECHO.
ECHO.
ECHO.Successfully Done!
pause
