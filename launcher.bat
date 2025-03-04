@echo off
setlocal enabledelayedexpansion
title Ultimate Kids Game Launcher
color 0A

:: Set all paths to be relative to the launcher location
set "ROOT_DIR=%~dp0"
set "GAMES_DIR=%ROOT_DIR%games"
set "GBA_DIR=%ROOT_DIR%gba"
set "EMULATORS_DIR=%ROOT_DIR%emulators"
set "FAV_DIR=%ROOT_DIR%favorites"
set "SAVE_DIR=%ROOT_DIR%saves"
set "TEMP_DIR=%ROOT_DIR%temp"
set "ISO_DIR=%ROOT_DIR%iso"

:: Create required directories
if not exist "%GAMES_DIR%" mkdir "%GAMES_DIR%"
if not exist "%GBA_DIR%" mkdir "%GBA_DIR%"
if not exist "%EMULATORS_DIR%" mkdir "%EMULATORS_DIR%"
if not exist "%FAV_DIR%" mkdir "%FAV_DIR%"
if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"
if not exist "%SAVE_DIR%\dos" mkdir "%SAVE_DIR%\dos"
if not exist "%SAVE_DIR%\gba" mkdir "%SAVE_DIR%\gba"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%ISO_DIR%" mkdir "%ISO_DIR%"

:: Look for DOSBox-X specifically
set "DOSBOX_FOUND=false"
set "DOSBOX_PATH="

:: Check for DOSBox-X in emulators folder (might be named differently)
for %%f in ("%EMULATORS_DIR%\dosbox-x.exe" "%EMULATORS_DIR%\dosbox*.exe") do (
    if exist "%%~f" (
        set "DOSBOX_FOUND=true"
        set "DOSBOX_PATH=%%~f"
    )
)

:: Find GBA emulator - using simple approach
set "GBA_EMU_FOUND=false"
set "GBA_EMU_PATH="
set "GBA_EMU_NAME="

:: Try to find any GBA emulator (with common extensions) in the emulators folder
for %%e in (VisualBoyAdvance.exe mGBA.exe VBA.exe vbam.exe) do (
    if exist "%EMULATORS_DIR%\%%e" (
        set "GBA_EMU_FOUND=true"
        set "GBA_EMU_PATH=%EMULATORS_DIR%\%%e"
        set "GBA_EMU_NAME=%%~ne"
    )
)

:: Only if not found, look in common installation locations
if "%GBA_EMU_FOUND%"=="false" (
    for %%p in (
        "%ProgramFiles%\VisualBoyAdvance\VisualBoyAdvance.exe"
        "%ProgramFiles(x86)%\VisualBoyAdvance\VisualBoyAdvance.exe"
        "%ProgramFiles%\mGBA\mGBA.exe"
        "%ProgramFiles(x86)%\mGBA\mGBA.exe"
    ) do (
        if exist "%%~p" (
            set "GBA_EMU_FOUND=true"
            set "GBA_EMU_PATH=%%~p"
            set "GBA_EMU_NAME=%%~np"
        )
    )
)

:: Look for 7-Zip or similar unzip tool
set "UNZIP_FOUND=false"
set "UNZIP_PATH="

:: Check for 7-Zip in emulators folder
if exist "%EMULATORS_DIR%\7z.exe" (
    set "UNZIP_FOUND=true"
    set "UNZIP_PATH=%EMULATORS_DIR%\7z.exe"
) else (
    :: Check in system paths
    for %%p in (
        "%ProgramFiles%\7-Zip\7z.exe"
        "%ProgramFiles(x86)%\7-Zip\7z.exe"
        "%windir%\system32\tar.exe"
    ) do (
        if exist "%%~p" (
            set "UNZIP_FOUND=true"
            set "UNZIP_PATH=%%~p"
        )
    )
)

:: Create or check for DOSBox-X configuration with auto-save support
set "DOSBOX_CONF=%EMULATORS_DIR%\dosbox-x.conf"
if not exist "%DOSBOX_CONF%" (
    echo ; DOSBox-X configuration for Kids Game Launcher > "%DOSBOX_CONF%"
    echo [sdl] >> "%DOSBOX_CONF%"
    echo fullscreen=true >> "%DOSBOX_CONF%"
    echo [dosbox] >> "%DOSBOX_CONF%"
    echo captures=%SAVE_DIR%\dos\captures >> "%DOSBOX_CONF%"
    echo [autosave] >> "%DOSBOX_CONF%"
    echo autosave=true >> "%DOSBOX_CONF%"
    echo ; Saves automatically every 3 minutes >> "%DOSBOX_CONF%"
    echo autosave.interval=180 >> "%DOSBOX_CONF%"
    echo autosave.dir=%SAVE_DIR%\dos >> "%DOSBOX_CONF%"
)

:: =================== MAIN MENU ===================
:MainMenu
cls
echo ========================================================
echo             ULTIMATE KIDS GAME LAUNCHER
echo ========================================================
echo.

:: Count games (including subfolders and ZIP files, but filtering non-game files)
set "DOS_COUNT=0"
for /r "%GAMES_DIR%" %%f in (*.exe *.com *.bat) do (
    :: Skip common non-game files
    set "SKIP_FILE=false"
    
    :: Exclude common non-game executables by name
    for %%n in (install setup config unins remove update setup_wizard readme help register) do (
        if /i "%%~nf"=="%%n" set "SKIP_FILE=true"
    )
    
    :: Also check if name contains these strings
    echo "%%~nf" | findstr /i "install setup config unins remove update setup_ readme help register _setup" >nul
    if not errorlevel 1 set "SKIP_FILE=true"
    
    if "!SKIP_FILE!"=="false" set /a "DOS_COUNT+=1"
)

:: Count potential DOS games in ZIP archives
set "DOS_ZIP_COUNT=0"
for /r "%GAMES_DIR%" %%f in (*.zip) do (
    set "SKIP_FILE=false"
    
    :: Skip ZIPs with non-game-like names
    echo "%%~nf" | findstr /i "update patch save install setup" >nul
    if not errorlevel 1 set "SKIP_FILE=true"
    
    if "!SKIP_FILE!"=="false" set /a "DOS_ZIP_COUNT+=1"
)

:: Count ISO files
set "ISO_COUNT=0"
for /r "%ISO_DIR%" %%f in (*.iso *.bin *.cue *.img *.ccd) do (
    set /a "ISO_COUNT+=1"
)

set "GBA_COUNT=0"
for /r "%GBA_DIR%" %%f in (*.gba) do (
    :: Skip if filename suggests it's not a ROM
    set "SKIP_FILE=false"
    
    :: Skip if it contains these strings
    echo "%%~nf" | findstr /i "update patch save" >nul
    if not errorlevel 1 set "SKIP_FILE=true"
    
    if "!SKIP_FILE!"=="false" set /a "GBA_COUNT+=1"
)

:: Count GBA games in ZIP archives
set "GBA_ZIP_COUNT=0"
for /r "%GBA_DIR%" %%f in (*.zip) do (
    set "SKIP_FILE=false"
    
    :: Skip ZIPs with non-game-like names
    echo "%%~nf" | findstr /i "update patch save install setup" >nul
    if not errorlevel 1 set "SKIP_FILE=true"
    
    if "!SKIP_FILE!"=="false" set /a "GBA_ZIP_COUNT+=1"
)

set /a "TOTAL_DOS_COUNT=%DOS_COUNT%+%DOS_ZIP_COUNT%"
set /a "TOTAL_GBA_COUNT=%GBA_COUNT%+%GBA_ZIP_COUNT%"

echo Found %TOTAL_DOS_COUNT% DOS games (%DOS_COUNT% direct, %DOS_ZIP_COUNT% in ZIP files)
echo Found %TOTAL_GBA_COUNT% GBA ROMs (%GBA_COUNT% direct, %GBA_ZIP_COUNT% in ZIP files)
echo Found %ISO_COUNT% CD-ROM ISOs
echo.

:: Check emulator status
if "%DOSBOX_FOUND%"=="true" (
    echo DOSBox-X: READY
) else (
    echo DOSBox-X: NOT FOUND! Please add DOSBox-X.exe to your emulators folder.
)

if "%GBA_EMU_FOUND%"=="true" (
    echo GBA Emulator: READY [%GBA_EMU_NAME%]
) else (
    echo GBA Emulator: NOT FOUND! GBA games won't work.
)

if "%UNZIP_FOUND%"=="true" (
    echo ZIP Support: READY
) else (
    echo ZIP Support: LIMITED - Add 7z.exe to your emulators folder for full ZIP support
)

echo.
echo Menu Options:
echo 1. Play DOS Games
echo 2. Play GBA Games 
echo 3. Play CD-ROM Games
echo 4. View Favorites
echo 5. Manage Saved Games
echo 6. Exit
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto DOSGames
if "%choice%"=="2" goto GBAGames
if "%choice%"=="3" goto ISOGames
if "%choice%"=="4" goto Favorites
if "%choice%"=="5" goto ManageSaves
if "%choice%"=="6" goto Exit

echo Invalid choice. Press any key to continue...
pause >nul
goto MainMenu
:: =================== DOS GAMES ===================
:DOSGames
cls
echo ========================================================
echo                     DOS GAMES
echo ========================================================
echo.

if "%DOSBOX_FOUND%"=="false" (
    echo DOSBox-X is not found in your emulators folder!
    echo.
    echo To play DOS games, you need DOSBox-X.exe in:
    echo %EMULATORS_DIR%
    echo.
    echo Press any key to return to the main menu...
    pause >nul
    goto MainMenu
)

:: List all DOS games (including subfolders, but filtering non-game files)
set "GAME_NUM=0"

:: First list regular executable files
for /r "%GAMES_DIR%" %%f in (*.exe *.com *.bat) do (
    :: Skip common non-game files
    set "SKIP_FILE=false"
    
    :: Exclude common non-game executables by name
    for %%n in (install setup config unins remove update setup_wizard readme help register) do (
        if /i "%%~nf"=="%%n" set "SKIP_FILE=true"
    )
    
    :: Also check if name contains these strings
    echo "%%~nf" | findstr /i "install setup config unins remove update setup_ readme help register _setup" >nul
    if not errorlevel 1 set "SKIP_FILE=true"
    
    if "!SKIP_FILE!"=="false" (
        set /a "GAME_NUM+=1"
        set "GAME_PATH[!GAME_NUM!]=%%~dpnxf"
        set "GAME_NAME[!GAME_NUM!]=%%~nf"
        set "GAME_FILE[!GAME_NUM!]=%%~nxf"
        set "GAME_DIR[!GAME_NUM!]=%%~dpf"
        set "GAME_TYPE[!GAME_NUM!]=EXE"
        
        :: Display name with subfolder if not in main games folder
        set "DISPLAY_NAME=%%~nf"
        set "REL_PATH=%%~dpf"
        set "REL_PATH=!REL_PATH:%GAMES_DIR%\=!"
        if not "!REL_PATH!"=="!GAMES_DIR!" (
            if not "!REL_PATH!"=="" (
                set "DISPLAY_NAME=[!REL_PATH:~0,-1!] %%~nf"
            )
        )
        
        :: Check if save exists and add indicator
        set "SAVE_EXISTS="
        if exist "%SAVE_DIR%\dos\!GAME_NAME[%GAME_NUM%]!\*.sav" set "SAVE_EXISTS=[SAVE]"
        
        echo !GAME_NUM!. !DISPLAY_NAME! !SAVE_EXISTS!
    )
)

:: Then list ZIP files potentially containing DOS games
for /r "%GAMES_DIR%" %%f in (*.zip) do (
    set "SKIP_FILE=false"
    
    :: Skip ZIPs with non-game-like names
    echo "%%~nf" | findstr /i "update patch save install setup" >nul
    if not errorlevel 1 set "SKIP_FILE=true"
    
    if "!SKIP_FILE!"=="false" (
        set /a "GAME_NUM+=1"
        set "GAME_PATH[!GAME_NUM!]=%%~dpnxf"
        set "GAME_NAME[!GAME_NUM!]=%%~nf"
        set "GAME_FILE[!GAME_NUM!]=%%~nxf"
        set "GAME_DIR[!GAME_NUM!]=%%~dpf"
        set "GAME_TYPE[!GAME_NUM!]=ZIP"
        
        :: Display name with subfolder if not in main games folder
        set "DISPLAY_NAME=%%~nf [ZIP]"
        set "REL_PATH=%%~dpf"
        set "REL_PATH=!REL_PATH:%GAMES_DIR%\=!"
        if not "!REL_PATH!"=="!GAMES_DIR!" (
            if not "!REL_PATH!"=="" (
                set "DISPLAY_NAME=[!REL_PATH:~0,-1!] %%~nf [ZIP]"
            )
        )
        
        :: Check if save exists and add indicator
        set "SAVE_EXISTS="
        if exist "%SAVE_DIR%\dos\!GAME_NAME[%GAME_NUM%]!\*.sav" set "SAVE_EXISTS=[SAVE]"
        
        echo !GAME_NUM!. !DISPLAY_NAME! !SAVE_EXISTS!
    )
)

if %GAME_NUM% equ 0 (
    echo No DOS games found in the games folder.
    echo Please add some games to: %GAMES_DIR%
    echo.
    echo Press any key to return to the main menu...
    pause >nul
    goto MainMenu
)

echo.
echo 0. Return to main menu
echo F. Mark game as favorite
echo.

set /p game_choice="Enter game number to play: "

if "%game_choice%"=="0" goto MainMenu
if /i "%game_choice%"=="F" goto MarkDOSFavorite

:: Validate input
set /a game_num=%game_choice% 2>nul
if %game_num% lss 1 goto DOSGames
if %game_num% gtr %GAME_NUM% goto DOSGames

:: Launch the selected DOS game with DOSBox-X
cls
echo ========================================================
echo                   LAUNCHING GAME
echo ========================================================
echo.
echo Launching: !GAME_NAME[%game_num%]!
echo Path: !GAME_PATH[%game_num%]!
echo Using DOSBox-X from: %DOSBOX_PATH%
echo.

:: Check if it's a ZIP file that needs extraction
if "!GAME_TYPE[%game_num%]!"=="ZIP" (
    echo Extracting game files from ZIP...
    
    :: Create temporary directory for extraction
    set "EXTRACT_DIR=%TEMP_DIR%\!GAME_NAME[%game_num%]!"
    if exist "!EXTRACT_DIR!" rmdir /s /q "!EXTRACT_DIR!"
    mkdir "!EXTRACT_DIR!"
    
    :: Use PowerShell for extraction
    powershell -command "Expand-Archive -LiteralPath '!GAME_PATH[%game_num%]!' -DestinationPath '!EXTRACT_DIR!' -Force"
    
    echo Extraction complete. Finding main executable...
    
    :: List all files for debugging
    echo Files found in extraction:
    dir /b /s "!EXTRACT_DIR!" | findstr /i "\.exe \.com \.bat"
    echo.
    
    :: Find ANY executable in the extracted folder (not just common names)
    set "FOUND_EXE=false"
    set "EXTRACT_EXE="
    set "EXTRACT_SUBDIR="
    
    :: Use a more comprehensive approach to find a suitable executable
    :: First pass: Look for .exe files in root directory that aren't common utilities
    for %%f in ("!EXTRACT_DIR!\*.exe") do (
        if "!FOUND_EXE!"=="false" (
            :: Skip known setup/utility executables
            set "UTILITY=false"
            for %%u in (setup install config unins readme) do (
                if /i "%%~nf"=="%%u" set "UTILITY=true"
            )
            
            :: If not a utility, use it
            if "!UTILITY!"=="false" (
                set "FOUND_EXE=true"
                set "EXTRACT_EXE=%%~nxf"
                set "EXTRACT_SUBDIR=%%~dpf"
                echo Found game executable: %%~nxf in root folder
            )
        )
    )
    
    :: Second pass: Look for .exe files in any subfolder if not found yet
    if "!FOUND_EXE!"=="false" (
        for /r "!EXTRACT_DIR!" %%f in (*.exe) do (
            if "!FOUND_EXE!"=="false" (
                :: Skip known setup files
                set "UTILITY=false"
                for %%u in (setup install config unins readme help) do (
                    if /i "%%~nf"=="%%u" set "UTILITY=true"
                )
                
                :: Also check if name contains these strings
                echo "%%~nf" | findstr /i "setup install config unins readme help" >nul
                if not errorlevel 1 set "UTILITY=true"
                
                :: If not a utility, use it
                if "!UTILITY!"=="false" (
                    set "FOUND_EXE=true"
                    set "EXTRACT_EXE=%%~nxf"
                    set "EXTRACT_SUBDIR=%%~dpf"
                    echo Found game executable: %%~nxf in subfolder
                )
            )
        )
    )
    
    :: Try .com files as a last resort
    if "!FOUND_EXE!"=="false" (
        for /r "!EXTRACT_DIR!" %%f in (*.com) do (
            if "!FOUND_EXE!"=="false" (
                set "FOUND_EXE=true"
                set "EXTRACT_EXE=%%~nxf"
                set "EXTRACT_SUBDIR=%%~dpf"
                echo Found executable: %%~nxf
            )
        )
    )
    
    if "!FOUND_EXE!"=="false" (
        echo No executable found in the ZIP archive.
        echo.
        echo Files in extracted folder:
        dir /s /b "!EXTRACT_DIR!"
        echo.
        echo Press any key to return to the game list...
        pause >nul
        goto DOSGames
    )
    
    echo Auto-save is enabled. Game will auto-save every 3 minutes.
    echo Press CTRL+F4 for quick save or F9 for quick load during gameplay.
    echo.
    echo When you're done playing, the launcher will return.
    echo.
    timeout /t 3 >nul
    
    :: Create a game-specific save folder if needed
    set "GAME_SAVE_DIR=%SAVE_DIR%\dos\!GAME_NAME[%game_num%]!"
    if not exist "%GAME_SAVE_DIR%" mkdir "%GAME_SAVE_DIR%"
    
    :: Remove quotes from paths to avoid syntax errors
    set "MOUNT_PATH=!EXTRACT_SUBDIR!"
    set "MOUNT_PATH=!MOUNT_PATH:"=!"
    
    :: Launch DOSBox with proper command line
    "%DOSBOX_PATH%" -conf "%DOSBOX_CONF%" -c "mount c \"!EXTRACT_SUBDIR!\"" -c "c:" -c "!EXTRACT_EXE!" -savedir "%GAME_SAVE_DIR%"
    
) else (
    :: Regular executable file
    echo Auto-save is enabled. Game will auto-save every 3 minutes.
    echo Press CTRL+F4 for quick save or F9 for quick load during gameplay.
    echo.
    echo When you're done playing, the launcher will return.
    echo.
    timeout /t 3 >nul
    
    :: Create a game-specific save folder if needed
    set "GAME_SAVE_DIR=%SAVE_DIR%\dos\!GAME_NAME[%game_num%]!"
    if not exist "%GAME_SAVE_DIR%" mkdir "%GAME_SAVE_DIR%"
    
    :: Remove quotes from paths to avoid syntax errors
    set "MOUNT_PATH=!GAME_DIR[%game_num%]!"
    set "MOUNT_PATH=!MOUNT_PATH:"=!"
    set "GAME_EXEC=!GAME_FILE[%game_num%]!"
    
    :: Launch DOSBox with correct command line
    "%DOSBOX_PATH%" -conf "%DOSBOX_CONF%" -c "mount c \"!MOUNT_PATH!\"" -c "c:" -c "!GAME_EXEC!" -savedir "%GAME_SAVE_DIR%"
)

echo Game finished! Press any key to return to the menu...
pause >nul
goto MainMenu

:: =================== MARK DOS FAVORITE ===================
:MarkDOSFavorite
cls
echo ========================================================
echo                 MARK FAVORITE DOS GAME
echo ========================================================
echo.

echo Select a game to mark as favorite:
echo.

for /l %%i in (1,1,%GAME_NUM%) do (
    :: Display name with subfolder if not in main games folder
    set "DISPLAY_NAME=!GAME_NAME[%%i]!"
    set "REL_PATH=!GAME_DIR[%%i]!"
    set "REL_PATH=!REL_PATH:%GAMES_DIR%\=!"
    if not "!REL_PATH!"=="!GAMES_DIR!" (
        if not "!REL_PATH!"=="" (
            set "DISPLAY_NAME=[!REL_PATH:~0,-1!] !GAME_NAME[%%i]!"
        )
    )
    
    :: Add [ZIP] indicator for ZIP files
    if "!GAME_TYPE[%%i]!"=="ZIP" (
        set "DISPLAY_NAME=!DISPLAY_NAME! [ZIP]"
    )
    
    echo %%i. !DISPLAY_NAME!
)

echo.
echo 0. Return to games list
echo.

set /p fav_choice="Enter game number: "

if "%fav_choice%"=="0" goto DOSGames

:: Validate input
set /a fav_num=%fav_choice% 2>nul
if %fav_num% lss 1 goto MarkDOSFavorite
if %fav_num% gtr %GAME_NUM% goto MarkDOSFavorite

:: Add to favorites
if not exist "%FAV_DIR%\favorites.txt" (
    echo ; FAVORITES > "%FAV_DIR%\favorites.txt"
)

:: Create a link to the game in the favorites file
echo DOS:!GAME_NAME[%fav_num%]!=!GAME_PATH[%fav_num%]!>> "%FAV_DIR%\favorites.txt"

echo.
echo Game marked as favorite!
timeout /t 2 >nul
goto DOSGames
:: =================== ISO GAMES ===================
:ISOGames
cls
echo ========================================================
echo                   CD-ROM ISO GAMES
echo ========================================================
echo.

if "%DOSBOX_FOUND%"=="false" (
    echo DOSBox-X is not found in your emulators folder!
    echo.
    echo To play CD-ROM games, you need DOSBox-X.exe in:
    echo %EMULATORS_DIR%
    echo.
    echo Press any key to return to the main menu...
    pause >nul
    goto MainMenu
)

:: List all ISO files
set "ISO_NUM=0"
for /r "%ISO_DIR%" %%f in (*.iso *.bin *.cue *.img *.ccd) do (
    set /a "ISO_NUM+=1"
    set "ISO_PATH[!ISO_NUM!]=%%~dpnxf"
    set "ISO_NAME[!ISO_NUM!]=%%~nf"
    set "ISO_FILE[!ISO_NUM!]=%%~nxf"
    set "ISO_DIR[!ISO_NUM!]=%%~dpf"
    set "ISO_EXT[!ISO_NUM!]=%%~xf"
    
    :: Display name with subfolder if not in main ISO folder
    set "DISPLAY_NAME=%%~nf [%%~xf]"
    set "REL_PATH=%%~dpf"
    set "REL_PATH=!REL_PATH:%ISO_DIR%\=!"
    if not "!REL_PATH!"=="!ISO_DIR!" (
        if not "!REL_PATH!"=="" (
            set "DISPLAY_NAME=[!REL_PATH:~0,-1!] %%~nf [%%~xf]"
        )
    )
    
    :: Check if save exists and add indicator
    set "SAVE_EXISTS="
    if exist "%SAVE_DIR%\dos\!ISO_NAME[%ISO_NUM%]!\*.sav" set "SAVE_EXISTS=[SAVE]"
    
    echo !ISO_NUM!. !DISPLAY_NAME! !SAVE_EXISTS!
)

if %ISO_NUM% equ 0 (
    echo No ISO files found in the iso folder.
    echo Please add some CD-ROM images to: %ISO_DIR%
    echo.
    echo Press any key to return to the main menu...
    pause >nul
    goto MainMenu
)

echo.
echo 0. Return to main menu
echo F. Mark ISO as favorite
echo.

set /p iso_choice="Enter number to play: "

if "%iso_choice%"=="0" goto MainMenu
if /i "%iso_choice%"=="F" goto MarkISOFavorite

:: Validate input
set /a iso_num=%iso_choice% 2>nul
if %iso_num% lss 1 goto ISOGames
if %iso_num% gtr %ISO_NUM% goto ISOGames

:: Launch the selected ISO with DOSBox-X
cls
echo ========================================================
echo                 LAUNCHING CD-ROM GAME
echo ========================================================
echo.
echo Launching: !ISO_NAME[%iso_num%]!!ISO_EXT[%iso_num%]!
echo Path: !ISO_PATH[%iso_num%]!
echo Using DOSBox-X from: %DOSBOX_PATH%
echo.
echo Auto-save is enabled. Game will auto-save every 3 minutes.
echo Press CTRL+F4 for quick save or F9 for quick load during gameplay.
echo.
echo When you're done playing, the launcher will return.
echo.
timeout /t 3 >nul

:: Create a game-specific save folder if needed
set "ISO_SAVE_DIR=%SAVE_DIR%\dos\!ISO_NAME[%iso_num%]!"
if not exist "%ISO_SAVE_DIR%" mkdir "%ISO_SAVE_DIR%"

:: Create temporary C: drive directory if it doesn't exist
set "TEMP_C_DIR=%TEMP_DIR%\!ISO_NAME[%iso_num%]!"
if not exist "!TEMP_C_DIR!" mkdir "!TEMP_C_DIR!"

:: Some CD-ROM games have their own executables to look for
set "ISO_AUTOEXEC="
:: Common CD-ROM autorun names
for %%e in (autorun.exe setup.exe install.exe game.exe main.exe !ISO_NAME[%iso_num%]!.exe) do (
    set "CHECK_PATH=!ISO_DIR!\!ISO_NAME[%iso_num%]!\%%e"
    if exist "!CHECK_PATH!" (
        set "ISO_AUTOEXEC=%%e"
    )
)

:: Remove quotes from paths to avoid syntax errors
set "ISO_CLEAN_PATH=!ISO_PATH[%iso_num%]!"
set "ISO_CLEAN_PATH=!ISO_CLEAN_PATH:"=!"

:: Mount both the CD drive and create a C: drive
echo Mounting ISO as CD-ROM drive...

:: Use imgmount for all disc images
"%DOSBOX_PATH%" -conf "%DOSBOX_CONF%" -c "mount c \"!TEMP_C_DIR!\"" -c "imgmount d \"!ISO_CLEAN_PATH!\" -t iso" -c "d:" -c "dir" -savedir "%ISO_SAVE_DIR%"

echo Game finished! Press any key to return to the menu...
pause >nul
goto MainMenu

:: =================== MARK ISO FAVORITE ===================
:MarkISOFavorite
cls
echo ========================================================
echo                 MARK FAVORITE CD-ROM
echo ========================================================
echo.

echo Select a CD-ROM to mark as favorite:
echo.

for /l %%i in (1,1,%ISO_NUM%) do (
    :: Display name with subfolder if not in main ISO folder
    set "DISPLAY_NAME=!ISO_NAME[%%i]!"
    set "REL_PATH=!ISO_DIR[%%i]!"
    set "REL_PATH=!REL_PATH:%ISO_DIR%\=!"
    if not "!REL_PATH!"=="!ISO_DIR!" (
        if not "!REL_PATH!"=="" (
            set "DISPLAY_NAME=[!REL_PATH:~0,-1!] !ISO_NAME[%%i]!"
        )
    )
    
    echo %%i. !DISPLAY_NAME! [!ISO_EXT[%%i]!]
)

echo.
echo 0. Return to ISO list
echo.

set /p fav_choice="Enter ISO number: "

if "%fav_choice%"=="0" goto ISOGames

:: Validate input
set /a fav_num=%fav_choice% 2>nul
if %fav_num% lss 1 goto MarkISOFavorite
if %fav_num% gtr %ISO_NUM% goto MarkISOFavorite

:: Add to favorites
if not exist "%FAV_DIR%\favorites.txt" (
    echo ; FAVORITES > "%FAV_DIR%\favorites.txt"
)

:: Create a link to the ISO in the favorites file
echo ISO:!ISO_NAME[%fav_num%]!=!ISO_PATH[%fav_num%]!>> "%FAV_DIR%\favorites.txt"

echo.
echo CD-ROM marked as favorite!
timeout /t 2 >nul
goto ISOGames

:: =================== GBA GAMES ===================
:GBAGames
cls
echo ========================================================
echo                     GBA GAMES
echo ========================================================
echo.

if "%GBA_EMU_FOUND%"=="false" (
    echo No GBA emulator found!
    echo.
    echo To play GBA games, you need a GBA emulator in:
    echo %EMULATORS_DIR%
    echo.
    echo Supported emulators: VisualBoyAdvance.exe, mGBA.exe
    echo.
    echo Press any key to return to the main menu...
    pause >nul
    goto MainMenu
)

:: List all GBA ROMs (including subfolders and ZIP files, filtering non-ROM files)
set "ROM_NUM=0"

:: First list regular GBA files
for /r "%GBA_DIR%" %%f in (*.gba) do (
    :: Skip if filename suggests it's not a ROM
    set "SKIP_FILE=false"
    
    :: Skip if it contains these strings
    echo "%%~nf" | findstr /i "update patch save" >nul
    if not errorlevel 1 set "SKIP_FILE=true"
    
    if "!SKIP_FILE!"=="false" (
        set /a "ROM_NUM+=1"
        set "ROM_PATH[!ROM_NUM!]=%%~dpnxf"
        set "ROM_NAME[!ROM_NUM!]=%%~nf"
        set "ROM_FILE[!ROM_NUM!]=%%~nxf"
        set "ROM_DIR[!ROM_NUM!]=%%~dpf"
        set "ROM_TYPE[!ROM_NUM!]=GBA"
        
        :: Display name with subfolder if not in main GBA folder
        set "DISPLAY_NAME=%%~nf"
        set "REL_PATH=%%~dpf"
        set "REL_PATH=!REL_PATH:%GBA_DIR%\=!"
        if not "!REL_PATH!"=="!GBA_DIR!" (
            if not "!REL_PATH!"=="" (
                set "DISPLAY_NAME=[!REL_PATH:~0,-1!] %%~nf"
            )
        )
        
        :: Check if save exists and add indicator
        set "SAVE_EXISTS="
        if exist "%SAVE_DIR%\gba\!ROM_NAME[%ROM_NUM%]!.sav" set "SAVE_EXISTS=[SAVE]"
        
        echo !ROM_NUM!. !DISPLAY_NAME! !SAVE_EXISTS!
    )
)

:: Then list ZIP files potentially containing GBA ROMs
for /r "%GBA_DIR%" %%f in (*.zip) do (
    set "SKIP_FILE=false"
    
    :: Skip ZIPs with non-game-like names
    echo "%%~nf" | findstr /i "update patch save" >nul
    if not errorlevel 1 set "SKIP_FILE=true"
    
    if "!SKIP_FILE!"=="false" (
        set /a "ROM_NUM+=1"
        set "ROM_PATH[!ROM_NUM!]=%%~dpnxf"
        set "ROM_NAME[!ROM_NUM!]=%%~nf"
        set "ROM_FILE[!ROM_NUM!]=%%~nxf"
        set "ROM_DIR[!ROM_NUM!]=%%~dpf"
        set "ROM_TYPE[!ROM_NUM!]=ZIP"
        
        :: Display name with subfolder if not in main GBA folder
        set "DISPLAY_NAME=%%~nf [ZIP]"
        set "REL_PATH=%%~dpf"
        set "REL_PATH=!REL_PATH:%GBA_DIR%\=!"
        if not "!REL_PATH!"=="!GBA_DIR!" (
            if not "!REL_PATH!"=="" (
                set "DISPLAY_NAME=[!REL_PATH:~0,-1!] %%~nf [ZIP]"
            )
        )
        
        :: Check if save exists and add indicator
        set "SAVE_EXISTS="
        if exist "%SAVE_DIR%\gba\!ROM_NAME[%ROM_NUM%]!.sav" set "SAVE_EXISTS=[SAVE]"
        
        echo !ROM_NUM!. !DISPLAY_NAME! !SAVE_EXISTS!
    )
)

if %ROM_NUM% equ 0 (
    echo No GBA ROMs found in the gba folder.
    echo Please add some GBA ROMs to: %GBA_DIR%
    echo.
    echo Press any key to return to the main menu...
    pause >nul
    goto MainMenu
)

echo.
echo 0. Return to main menu
echo F. Mark ROM as favorite
echo.

set /p rom_choice="Enter ROM number to play: "

if "%rom_choice%"=="0" goto MainMenu
if /i "%rom_choice%"=="F" goto MarkGBAFavorite

:: Validate input
set /a rom_num=%rom_choice% 2>nul
if %rom_num% lss 1 goto GBAGames
if %rom_num% gtr %ROM_NUM% goto GBAGames

:: Launch the selected GBA ROM
cls
echo ========================================================
echo                 LAUNCHING GBA GAME
echo ========================================================
echo.
echo Launching: !ROM_NAME[%rom_num%]!
echo Path: !ROM_PATH[%rom_num%]!
echo Using emulator: %GBA_EMU_PATH%
echo.

:: Check if it's a ZIP file
if "!ROM_TYPE[%rom_num%]!"=="ZIP" (
    :: For ZIP files, we have two options:
    :: 1. Extract and run the GBA file (works with all emulators)
    :: 2. Pass the ZIP directly (works with some emulators like mGBA)
    
    :: Check if we should try direct ZIP loading based on emulator
    set "DIRECT_ZIP=false"
    if /i "%GBA_EMU_NAME%"=="mGBA" set "DIRECT_ZIP=true"
    
    if "!DIRECT_ZIP!"=="true" (
        echo This emulator supports direct ZIP loading. Launching from ZIP...
        
        :: Create save directory if it doesn't exist
        if not exist "%SAVE_DIR%\gba" mkdir "%SAVE_DIR%\gba"
        
        :: Determine emulator-specific save options
        set "SAVE_ARGS="
        
        if /i "%GBA_EMU_NAME%"=="mGBA" (
            set "SAVE_ARGS=-s "%SAVE_DIR%\gba\!ROM_NAME[%rom_num%]!.sav""
        )
        
        echo.
        echo Save files will be stored in:
        echo %SAVE_DIR%\gba\
        echo.
        echo When you're done playing, close the emulator window.
        echo.
        timeout /t 3 >nul
        
        :: Launch the emulator with the ZIP file directly
        start "" "%GBA_EMU_PATH%" !SAVE_ARGS! "!ROM_PATH[%rom_num%]!"
        
    ) else (
        echo Extracting ROM from ZIP archive...
        
        :: Create temporary directory for extraction
        set "EXTRACT_DIR=%TEMP_DIR%\!ROM_NAME[%rom_num%]!"
        if exist "!EXTRACT_DIR!" rmdir /s /q "!EXTRACT_DIR!"
        mkdir "!EXTRACT_DIR!"
        
        :: Use PowerShell for most reliable extraction
        echo Using PowerShell to extract files...
        powershell -command "Expand-Archive -LiteralPath '!ROM_PATH[%rom_num%]!' -DestinationPath '!EXTRACT_DIR!' -Force"
        
        echo Extraction complete. Searching for GBA ROMs...
        echo.
        
        :: Debug output - list the contents of extracted directory
        echo Files found in extraction directory:
        dir /b "!EXTRACT_DIR!" 
        echo.
        
        :: Find GBA ROM in the extracted directory
        set "FOUND_ROM=false"
        set "EXTRACT_ROM="
        
        :: First try ROM with same name as ZIP
        if exist "!EXTRACT_DIR!\!ROM_NAME[%rom_num%]!.gba" (
            set "FOUND_ROM=true"
            set "EXTRACT_ROM=!EXTRACT_DIR!\!ROM_NAME[%rom_num%]!.gba"
            echo Found matching GBA ROM: !ROM_NAME[%rom_num%]!.gba
        )
        
        :: If not found, search all subdirectories
        if "!FOUND_ROM!"=="false" (
            for /r "!EXTRACT_DIR!" %%g in (*.gba) do (
                if "!FOUND_ROM!"=="false" (
                    set "FOUND_ROM=true"
                    set "EXTRACT_ROM=%%~dpnxg"
                    echo Found GBA ROM: %%~nxg
                )
            )
        )
        
        if "!FOUND_ROM!"=="false" (
            echo No GBA ROM found in the ZIP archive.
            echo Contents of extracted folder:
            dir /s /b "!EXTRACT_DIR!"
            echo.
            echo Press any key to return to the ROM list...
            pause >nul
            goto GBAGames
        )
        
        :: Create save directory if it doesn't exist
        if not exist "%SAVE_DIR%\gba" mkdir "%SAVE_DIR%\gba"
        
        :: Determine emulator-specific save options
        set "SAVE_ARGS="
        
        if /i "%GBA_EMU_NAME%"=="VisualBoyAdvance" (
            set "SAVE_ARGS=--battery-dir "%SAVE_DIR%\gba""
        ) else if /i "%GBA_EMU_NAME%"=="mGBA" (
            set "SAVE_ARGS=-s "%SAVE_DIR%\gba\!ROM_NAME[%rom_num%]!.sav""
        ) else if /i "%GBA_EMU_NAME%"=="VBA" (
            set "SAVE_ARGS=--battery-dir "%SAVE_DIR%\gba""
        )
        
        echo.
        echo Save files will be stored in:
        echo %SAVE_DIR%\gba\
        echo.
        echo When you're done playing, close the emulator window.
        echo.
        timeout /t 3 >nul
        
        :: Launch the emulator with the extracted ROM
        start "" "%GBA_EMU_PATH%" !SAVE_ARGS! "!EXTRACT_ROM!"
    )
    
) else (
    :: Regular GBA file
    :: Create save directory if it doesn't exist
    if not exist "%SAVE_DIR%\gba" mkdir "%SAVE_DIR%\gba"
    
    :: Determine emulator-specific save options
    set "SAVE_ARGS="
    
    if /i "%GBA_EMU_NAME%"=="VisualBoyAdvance" (
        set "SAVE_ARGS=--battery-dir "%SAVE_DIR%\gba""
    ) else if /i "%GBA_EMU_NAME%"=="mGBA" (
        set "SAVE_ARGS=-s "%SAVE_DIR%\gba\!ROM_NAME[%rom_num%]!.sav""
    ) else if /i "%GBA_EMU_NAME%"=="VBA" (
        set "SAVE_ARGS=--battery-dir "%SAVE_DIR%\gba""
    )
    
    echo Save files will be stored in:
    echo %SAVE_DIR%\gba\
    echo.
    echo When you're done playing, close the emulator window.
    echo.
    timeout /t 3 >nul
    
    :: Start the emulator with the full path and save args
    start "" "%GBA_EMU_PATH%" !SAVE_ARGS! "!ROM_PATH[%rom_num%]!"
)

echo Game launched! Press any key to return to the menu...
pause >nul
goto MainMenu
:: =================== MARK GBA FAVORITE ===================
:MarkGBAFavorite
cls
echo ========================================================
echo                MARK FAVORITE GBA GAME
echo ========================================================
echo.

echo Select a ROM to mark as favorite:
echo.

for /l %%i in (1,1,%ROM_NUM%) do (
    :: Display name with subfolder if not in main GBA folder
    set "DISPLAY_NAME=!ROM_NAME[%%i]!"
    set "REL_PATH=!ROM_DIR[%%i]!"
    set "REL_PATH=!REL_PATH:%GBA_DIR%\=!"
    if not "!REL_PATH!"=="!GBA_DIR!" (
        if not "!REL_PATH!"=="" (
            set "DISPLAY_NAME=[!REL_PATH:~0,-1!] !ROM_NAME[%%i]!"
        )
    )
    
    :: Add [ZIP] indicator for ZIP files
    if "!ROM_TYPE[%%i]!"=="ZIP" (
        set "DISPLAY_NAME=!DISPLAY_NAME! [ZIP]"
    )
    
    echo %%i. !DISPLAY_NAME!
)

echo.
echo 0. Return to ROMs list
echo.

set /p fav_choice="Enter ROM number: "

if "%fav_choice%"=="0" goto GBAGames

:: Validate input
set /a fav_num=%fav_choice% 2>nul
if %fav_num% lss 1 goto MarkGBAFavorite
if %fav_num% gtr %ROM_NUM% goto MarkGBAFavorite

:: Add to favorites
if not exist "%FAV_DIR%\favorites.txt" (
    echo ; FAVORITES > "%FAV_DIR%\favorites.txt"
)

:: Create a link to the ROM in the favorites file
echo GBA:!ROM_NAME[%fav_num%]!=!ROM_PATH[%fav_num%]!>> "%FAV_DIR%\favorites.txt"

echo.
echo GBA ROM marked as favorite!
timeout /t 2 >nul
goto GBAGames

:: =================== MANAGE SAVES ===================
:ManageSaves
cls
echo ========================================================
echo                    MANAGE SAVED GAMES
echo ========================================================
echo.

set "DOS_SAVES=0"
for /r "%SAVE_DIR%\dos" %%f in (*.sav) do (
    set /a "DOS_SAVES+=1"
)

set "GBA_SAVES=0"
for /r "%SAVE_DIR%\gba" %%f in (*.sav) do (
    set /a "GBA_SAVES+=1"
)

echo Found %DOS_SAVES% DOS/ISO saved games and %GBA_SAVES% GBA saves
echo.
echo 1. Manage DOS/ISO Saves
echo 2. Manage GBA Saves
echo 0. Return to main menu
echo.

set /p save_choice="Enter your choice: "

if "%save_choice%"=="0" goto MainMenu
if "%save_choice%"=="1" goto ManageDOSSaves
if "%save_choice%"=="2" goto ManageGBASaves

echo Invalid choice. Press any key to continue...
pause >nul
goto ManageSaves

:: =================== MANAGE DOS SAVES ===================
:ManageDOSSaves
cls
echo ========================================================
echo                  MANAGE DOS/ISO SAVES
echo ========================================================
echo.

if %DOS_SAVES% equ 0 (
    echo No DOS or ISO saved games found.
    echo.
    echo Press any key to return to the manage saves menu...
    pause >nul
    goto ManageSaves
)

:: List all DOS saves
set "SAVE_NUM=0"
for /r "%SAVE_DIR%\dos" %%f in (*.sav) do (
    set /a "SAVE_NUM+=1"
    set "SAVE_PATH[!SAVE_NUM!]=%%~dpnxf"
    set "SAVE_NAME[!SAVE_NUM!]=%%~nf"
    echo !SAVE_NUM!. !SAVE_NAME[%SAVE_NUM%]!
)

echo.
echo D. Delete a save
echo 0. Return to manage saves menu
echo.

set /p dos_save_choice="Enter your choice: "

if "%dos_save_choice%"=="0" goto ManageSaves
if /i "%dos_save_choice%"=="D" goto DeleteDOSSave

echo Invalid choice. Press any key to continue...
pause >nul
goto ManageDOSSaves

:: =================== DELETE DOS SAVE ===================
:DeleteDOSSave
cls
echo ========================================================
echo                    DELETE DOS SAVE
echo ========================================================
echo.

echo Select a save to delete:
echo.

for /l %%i in (1,1,%SAVE_NUM%) do (
    echo %%i. !SAVE_NAME[%%i]!
)

echo.
echo 0. Return to DOS saves menu
echo.

set /p del_choice="Enter save number to delete: "

if "%del_choice%"=="0" goto ManageDOSSaves

:: Validate input
set /a del_num=%del_choice% 2>nul
if %del_num% lss 1 goto DeleteDOSSave
if %del_num% gtr %SAVE_NUM% goto DeleteDOSSave

echo.
echo Are you sure you want to delete !SAVE_NAME[%del_num%]!?
echo This cannot be undone!
echo.
set /p confirm="Type YES to confirm: "

if /i "%confirm%"=="YES" (
    del "!SAVE_PATH[%del_num%]!"
    echo.
    echo Save deleted!
) else (
    echo.
    echo Deletion cancelled.
)

timeout /t 2 >nul
goto ManageDOSSaves

:: =================== MANAGE GBA SAVES ===================
:ManageGBASaves
cls
echo ========================================================
echo                    MANAGE GBA SAVES
echo ========================================================
echo.

if %GBA_SAVES% equ 0 (
    echo No GBA saved games found.
    echo.
    echo Press any key to return to the manage saves menu...
    pause >nul
    goto ManageSaves
)

:: List all GBA saves
set "SAVE_NUM=0"
for /r "%SAVE_DIR%\gba" %%f in (*.sav) do (
    set /a "SAVE_NUM+=1"
    set "SAVE_PATH[!SAVE_NUM!]=%%~dpnxf"
    set "SAVE_NAME[!SAVE_NUM!]=%%~nf"
    echo !SAVE_NUM!. !SAVE_NAME[%SAVE_NUM%]!
)

echo.
echo D. Delete a save
echo 0. Return to manage saves menu
echo.

set /p gba_save_choice="Enter your choice: "

if "%gba_save_choice%"=="0" goto ManageSaves
if /i "%gba_save_choice%"=="D" goto DeleteGBASave

echo Invalid choice. Press any key to continue...
pause >nul
goto ManageGBASaves

:: =================== DELETE GBA SAVE ===================
:DeleteGBASave
cls
echo ========================================================
echo                    DELETE GBA SAVE
echo ========================================================
echo.

echo Select a save to delete:
echo.

for /l %%i in (1,1,%SAVE_NUM%) do (
    echo %%i. !SAVE_NAME[%%i]!
)

echo.
echo 0. Return to GBA saves menu
echo.

set /p del_choice="Enter save number to delete: "

if "%del_choice%"=="0" goto ManageGBASaves

:: Validate input
set /a del_num=%del_choice% 2>nul
if %del_num% lss 1 goto DeleteGBASave
if %del_num% gtr %SAVE_NUM% goto DeleteGBASave

echo.
echo Are you sure you want to delete !SAVE_NAME[%del_num%]!?
echo This cannot be undone!
echo.
set /p confirm="Type YES to confirm: "

if /i "%confirm%"=="YES" (
    del "!SAVE_PATH[%del_num%]!"
    echo.
    echo Save deleted!
) else (
    echo.
    echo Deletion cancelled.
)

timeout /t 2 >nul
goto ManageGBASaves

:: =================== FAVORITES ===================
:Favorites
cls
echo ========================================================
echo                    FAVORITES
echo ========================================================
echo.

if not exist "%FAV_DIR%\favorites.txt" (
    echo You don't have any favorites yet!
    echo.
    echo To add favorites:
    echo 1. Go to "Play DOS Games", "Play GBA Games" or "Play CD-ROM Games"
    echo 2. Press F and select a game to mark as favorite
    echo.
    echo Press any key to return to the main menu...
    pause >nul
    goto MainMenu
)

:: Count favorites
set "FAV_COUNT=0"
set "DOS_FAV_COUNT=0"
set "GBA_FAV_COUNT=0"
set "ISO_FAV_COUNT=0"

for /f "tokens=1,* delims==" %%a in ('type "%FAV_DIR%\favorites.txt"') do (
    if not "%%a:~0,1"==";" (
        set /a "FAV_COUNT+=1"
        set "FAV_TYPE[!FAV_COUNT!]=%%a"
        set "FAV_PATH[!FAV_COUNT!]=%%b"
        
        for /f "tokens=1,2 delims=:" %%x in ("%%a") do (
            set "FAV_GAME_TYPE[!FAV_COUNT!]=%%x"
            set "FAV_GAME_NAME[!FAV_COUNT!]=%%y"
        )
        
        if "!FAV_GAME_TYPE[%FAV_COUNT%]!"=="DOS" (
            set /a "DOS_FAV_COUNT+=1"
        ) else if "!FAV_GAME_TYPE[%FAV_COUNT%]!"=="GBA" (
            set /a "GBA_FAV_COUNT+=1"
        ) else if "!FAV_GAME_TYPE[%FAV_COUNT%]!"=="ISO" (
            set /a "ISO_FAV_COUNT+=1"
        )
    )
)

if %FAV_COUNT% equ 0 (
    echo No favorites found!
    echo.
    echo Press any key to return to the main menu...
    pause >nul
    goto MainMenu
)

echo Your Favorite Games:
echo.

:: Display DOS game favorites first
if %DOS_FAV_COUNT% gtr 0 (
    echo DOS GAMES:
    echo.
    
    set "COUNTER=0"
    for /l %%i in (1,1,%FAV_COUNT%) do (
        if "!FAV_GAME_TYPE[%%i]!"=="DOS" (
            set /a "COUNTER+=1"
            
            :: Check if save exists and add indicator
            set "SAVE_EXISTS="
            if exist "%SAVE_DIR%\dos\!FAV_GAME_NAME[%%i]!\*.sav" set "SAVE_EXISTS=[SAVE]"
            
            :: Check if it's a ZIP file
            set "IS_ZIP="
            if "!FAV_PATH[%%i]:~-4!"==".zip" set "IS_ZIP=[ZIP]"
            
            echo D!COUNTER!. !FAV_GAME_NAME[%%i]! !IS_ZIP! !SAVE_EXISTS!
        )
    )
    
    echo.
)

:: Display GBA ROM favorites
if %GBA_FAV_COUNT% gtr 0 (
    echo GBA GAMES:
    echo.
    
    set "COUNTER=0"
    for /l %%i in (1,1,%FAV_COUNT%) do (
        if "!FAV_GAME_TYPE[%%i]!"=="GBA" (
            set /a "COUNTER+=1"
            
            :: Check if save exists and add indicator
            set "SAVE_EXISTS="
            if exist "%SAVE_DIR%\gba\!FAV_GAME_NAME[%%i]!.sav" set "SAVE_EXISTS=[SAVE]"
            
            :: Check if it's a ZIP file
            set "IS_ZIP="
            if "!FAV_PATH[%%i]:~-4!"==".zip" set "IS_ZIP=[ZIP]"
            
            echo G!COUNTER!. !FAV_GAME_NAME[%%i]! !IS_ZIP! !SAVE_EXISTS!
        )
    )
    
    echo.
)

:: Display ISO favorites
if %ISO_FAV_COUNT% gtr 0 (
    echo CD-ROM GAMES:
    echo.
    
    set "COUNTER=0"
    for /l %%i in (1,1,%FAV_COUNT%) do (
        if "!FAV_GAME_TYPE[%%i]!"=="ISO" (
            set /a "COUNTER+=1"
            
            :: Check if save exists and add indicator
            set "SAVE_EXISTS="
            if exist "%SAVE_DIR%\dos\!FAV_GAME_NAME[%%i]!\*.sav" set "SAVE_EXISTS=[SAVE]"
            
            :: Get file extension
            for %%x in ("!FAV_PATH[%%i]!") do set "ISO_EXT=[%%~xx]"
            
            echo I!COUNTER!. !FAV_GAME_NAME[%%i]! !ISO_EXT! !SAVE_EXISTS!
        )
    )
    
    echo.
)

echo Enter D# to play a DOS game favorite (e.g., D1)
echo Enter G# to play a GBA game favorite (e.g., G1)
echo Enter I# to play a CD-ROM favorite (e.g., I1)
echo Or enter 0 to return to main menu
echo.

set /p fav_choice="Enter choice: "

if "%fav_choice%"=="0" goto MainMenu
:: Parse the choice - DOS game
set "PREFIX=%fav_choice:~0,1%"
set "NUMBER=%fav_choice:~1%"

if /i "%PREFIX%"=="D" (
    set /a num=%NUMBER% 2>nul
    
    if %num% lss 1 goto Favorites
    if %num% gtr %DOS_FAV_COUNT% goto Favorites
    
    :: Find the corresponding DOS game
    set "COUNTER=0"
    set "TARGET_PATH="
    set "TARGET_NAME="
    set "TARGET_DIR="
    set "IS_ZIP=false"
    
    for /l %%i in (1,1,%FAV_COUNT%) do (
        if "!FAV_GAME_TYPE[%%i]!"=="DOS" (
            set /a "COUNTER+=1"
            if !COUNTER! equ %num% (
                set "TARGET_PATH=!FAV_PATH[%%i]!"
                set "TARGET_NAME=!FAV_GAME_NAME[%%i]!"
                for %%p in ("!TARGET_PATH!") do set "TARGET_DIR=%%~dpp"
                for %%p in ("!TARGET_PATH!") do set "TARGET_FILE=%%~nxp"
                
                :: Check if it's a ZIP file
                if "!TARGET_PATH:~-4!"==".zip" set "IS_ZIP=true"
            )
        )
    )
    
    :: Check if file exists
    if not exist "!TARGET_PATH!" (
        echo Error: Game file not found at !TARGET_PATH!
        echo.
        echo Press any key to return to favorites...
        pause >nul
        goto Favorites
    )
    
    :: Launch the favorite DOS game with DOSBox-X
    cls
    echo ========================================================
    echo                LAUNCHING FAVORITE DOS GAME
    echo ========================================================
    echo.
    echo Launching: !TARGET_NAME!
    echo Path: !TARGET_PATH!
    echo Using DOSBox-X from: %DOSBOX_PATH%
    echo.
    
    :: Create a game-specific save folder if needed
    set "GAME_SAVE_DIR=%SAVE_DIR%\dos\!TARGET_NAME!"
    if not exist "%GAME_SAVE_DIR%" mkdir "%GAME_SAVE_DIR%"
    
    :: Check if it's a ZIP file that needs extraction
    if "!IS_ZIP!"=="true" (
        echo Extracting game files from ZIP...
        
        :: Create temporary directory for extraction
        set "EXTRACT_DIR=%TEMP_DIR%\!TARGET_NAME!"
        if exist "!EXTRACT_DIR!" rmdir /s /q "!EXTRACT_DIR!"
        mkdir "!EXTRACT_DIR!"
        
        :: Use PowerShell for extraction
        powershell -command "Expand-Archive -LiteralPath '!TARGET_PATH!' -DestinationPath '!EXTRACT_DIR!' -Force"
        
        echo Extraction complete. Finding main executable...
        
        :: List all files for debugging
        echo Files found in extraction:
        dir /b /s "!EXTRACT_DIR!" | findstr /i "\.exe \.com \.bat"
        echo.
        
        :: Find ANY executable in the extracted folder (not just common names)
        set "FOUND_EXE=false"
        set "EXTRACT_EXE="
        set "EXTRACT_SUBDIR="
        
        :: Use a more comprehensive approach to find a suitable executable
        :: First pass: Look for .exe files in root directory that aren't common utilities
        for %%f in ("!EXTRACT_DIR!\*.exe") do (
            if "!FOUND_EXE!"=="false" (
                :: Skip known setup/utility executables
                set "UTILITY=false"
                for %%u in (setup install config unins readme) do (
                    if /i "%%~nf"=="%%u" set "UTILITY=true"
                )
                
                :: If not a utility, use it
                if "!UTILITY!"=="false" (
                    set "FOUND_EXE=true"
                    set "EXTRACT_EXE=%%~nxf"
                    set "EXTRACT_SUBDIR=%%~dpf"
                    echo Found game executable: %%~nxf in root folder
                )
            )
        )
        
        :: Second pass: Look for .exe files in any subfolder if not found yet
        if "!FOUND_EXE!"=="false" (
            for /r "!EXTRACT_DIR!" %%f in (*.exe) do (
                if "!FOUND_EXE!"=="false" (
                    :: Skip known setup files
                    set "UTILITY=false"
                    for %%u in (setup install config unins readme help) do (
                        if /i "%%~nf"=="%%u" set "UTILITY=true"
                    )
                    
                    :: Also check if name contains these strings
                    echo "%%~nf" | findstr /i "setup install config unins readme help" >nul
                    if not errorlevel 1 set "UTILITY=true"
                    
                    :: If not a utility, use it
                    if "!UTILITY!"=="false" (
                        set "FOUND_EXE=true"
                        set "EXTRACT_EXE=%%~nxf"
                        set "EXTRACT_SUBDIR=%%~dpf"
                        echo Found game executable: %%~nxf in subfolder
                    )
                )
            )
        )
        
        :: Try .com files as a last resort
        if "!FOUND_EXE!"=="false" (
            for /r "!EXTRACT_DIR!" %%f in (*.com) do (
                if "!FOUND_EXE!"=="false" (
                    set "FOUND_EXE=true"
                    set "EXTRACT_EXE=%%~nxf"
                    set "EXTRACT_SUBDIR=%%~dpf"
                    echo Found executable: %%~nxf
                )
            )
        )
        
        if "!FOUND_EXE!"=="false" (
            echo No executable found in the ZIP archive.
            echo.
            echo Files in extracted folder:
            dir /s /b "!EXTRACT_DIR!"
            echo.
            echo Press any key to return to favorites...
            pause >nul
            goto Favorites
        )
        
        echo Auto-save is enabled. Game will auto-save every 3 minutes.
        echo Press CTRL+F4 for quick save or F9 for quick load during gameplay.
        echo.
        echo When you're done playing, the launcher will return.
        echo.
        timeout /t 3 >nul
        
        :: Remove quotes from paths to avoid syntax errors
        set "MOUNT_PATH=!EXTRACT_SUBDIR!"
        set "MOUNT_PATH=!MOUNT_PATH:"=!"
        
        :: Launch DOSBox with proper command line
        "%DOSBOX_PATH%" -conf "%DOSBOX_CONF%" -c "mount c \"!EXTRACT_SUBDIR!\"" -c "c:" -c "!EXTRACT_EXE!" -savedir "%GAME_SAVE_DIR%"
        
    ) else (
        :: Regular executable file
        echo Auto-save is enabled. Game will auto-save every 3 minutes.
        echo Press CTRL+F4 for quick save or F9 for quick load during gameplay.
        echo.
        echo When you're done playing, the launcher will return.
        echo.
        timeout /t 3 >nul
        
        :: Remove quotes from paths to avoid syntax errors
        set "MOUNT_PATH=!TARGET_DIR!"
        set "MOUNT_PATH=!MOUNT_PATH:"=!"
        set "GAME_EXEC=!TARGET_FILE!"
        
        :: Launch DOSBox with correct command line
        "%DOSBOX_PATH%" -conf "%DOSBOX_CONF%" -c "mount c \"!MOUNT_PATH!\"" -c "c:" -c "!GAME_EXEC!" -savedir "%GAME_SAVE_DIR%"
    )
    
    echo Game finished! Press any key to return to the menu...
    pause >nul
    goto MainMenu
)

:: Parse the choice - GBA game
if /i "%PREFIX%"=="G" (
    set /a num=%NUMBER% 2>nul
    
    if %num% lss 1 goto Favorites
    if %num% gtr %GBA_FAV_COUNT% goto Favorites
    
    :: Find the corresponding GBA ROM
    set "COUNTER=0"
    set "TARGET_PATH="
    set "TARGET_NAME="
    set "IS_ZIP=false"
    
    for /l %%i in (1,1,%FAV_COUNT%) do (
        if "!FAV_GAME_TYPE[%%i]!"=="GBA" (
            set /a "COUNTER+=1"
            if !COUNTER! equ %num% (
                set "TARGET_PATH=!FAV_PATH[%%i]!"
                set "TARGET_NAME=!FAV_GAME_NAME[%%i]!"
                
                :: Check if it's a ZIP file
                if "!TARGET_PATH:~-4!"==".zip" set "IS_ZIP=true"
            )
        )
    )
    
    :: Check if file exists
    if not exist "!TARGET_PATH!" (
        echo Error: ROM file not found at !TARGET_PATH!
        echo.
        echo Press any key to return to favorites...
        pause >nul
        goto Favorites
    )
    
    :: Check for GBA emulator
    if "%GBA_EMU_FOUND%"=="false" (
        echo No GBA emulator found!
        echo.
        echo Press any key to return to favorites...
        pause >nul
        goto Favorites
    )
    
    :: Launch the favorite GBA ROM
    cls
    echo ========================================================
    echo                LAUNCHING FAVORITE GBA GAME
    echo ========================================================
    echo.
    echo Launching: !TARGET_NAME!
    echo Path: !TARGET_PATH!
    echo Using emulator: %GBA_EMU_PATH%
    echo.
    
    :: Check if it's a ZIP file
    if "!IS_ZIP!"=="true" (
        :: For ZIP files, try emulator's direct ZIP support if available
        set "DIRECT_ZIP=false"
        if /i "%GBA_EMU_NAME%"=="mGBA" set "DIRECT_ZIP=true"
        
        if "!DIRECT_ZIP!"=="true" (
            echo This emulator supports direct ZIP loading. Launching from ZIP...
            
            :: Create save directory if it doesn't exist
            if not exist "%SAVE_DIR%\gba" mkdir "%SAVE_DIR%\gba"
            
            :: Determine emulator-specific save options
            set "SAVE_ARGS="
            
            if /i "%GBA_EMU_NAME%"=="mGBA" (
                set "SAVE_ARGS=-s "%SAVE_DIR%\gba\!TARGET_NAME!.sav""
            )
            
            echo.
            echo Save files will be stored in:
            echo %SAVE_DIR%\gba\
            echo.
            echo When you're done playing, close the emulator window.
            echo.
            timeout /t 3 >nul
            
            :: Launch the emulator with the ZIP file directly
            start "" "%GBA_EMU_PATH%" !SAVE_ARGS! "!TARGET_PATH!"
            
        ) else (
            echo Extracting ROM from ZIP archive...
            
            :: Create temporary directory for extraction
            set "EXTRACT_DIR=%TEMP_DIR%\!TARGET_NAME!"
            if exist "!EXTRACT_DIR!" rmdir /s /q "!EXTRACT_DIR!"
            mkdir "!EXTRACT_DIR!"
            
            :: Use PowerShell for most reliable extraction
            echo Using PowerShell to extract files...
            powershell -command "Expand-Archive -LiteralPath '!TARGET_PATH!' -DestinationPath '!EXTRACT_DIR!' -Force"
            
            echo Extraction complete. Searching for GBA ROMs...
            echo.
            
            :: Debug output - list the contents of extracted directory
            echo Files found in extraction directory:
            dir /b "!EXTRACT_DIR!" 
            echo.
            
            :: Find GBA ROM in the extracted directory
            set "FOUND_ROM=false"
            set "EXTRACT_ROM="
            
            :: First try ROM with same name as ZIP
            if exist "!EXTRACT_DIR!\!TARGET_NAME!.gba" (
                set "FOUND_ROM=true"
                set "EXTRACT_ROM=!EXTRACT_DIR!\!TARGET_NAME!.gba"
                echo Found matching GBA ROM: !TARGET_NAME!.gba
            )
            
            :: If not found, search all subdirectories
            if "!FOUND_ROM!"=="false" (
                for /r "!EXTRACT_DIR!" %%g in (*.gba) do (
                    if "!FOUND_ROM!"=="false" (
                        set "FOUND_ROM=true"
                        set "EXTRACT_ROM=%%~dpnxg"
                        echo Found GBA ROM: %%~nxg
                    )
                )
            )
            
            if "!FOUND_ROM!"=="false" (
                echo No GBA ROM found in the ZIP archive.
                echo Contents of extracted folder:
                dir /s /b "!EXTRACT_DIR!"
                echo.
                echo Press any key to return to favorites...
                pause >nul
                goto Favorites
            )
            
            :: Create save directory if it doesn't exist
            if not exist "%SAVE_DIR%\gba" mkdir "%SAVE_DIR%\gba"
            
            :: Determine emulator-specific save options
            set "SAVE_ARGS="
            
            if /i "%GBA_EMU_NAME%"=="VisualBoyAdvance" (
                set "SAVE_ARGS=--battery-dir "%SAVE_DIR%\gba""
            ) else if /i "%GBA_EMU_NAME%"=="mGBA" (
                set "SAVE_ARGS=-s "%SAVE_DIR%\gba\!TARGET_NAME!.sav""
            ) else if /i "%GBA_EMU_NAME%"=="VBA" (
                set "SAVE_ARGS=--battery-dir "%SAVE_DIR%\gba""
            )
            
            echo.
            echo Save files will be stored in:
            echo %SAVE_DIR%\gba\
            echo.
            echo When you're done playing, close the emulator window.
            echo.
            timeout /t 3 >nul
            
            :: Launch the emulator with the extracted ROM
            start "" "%GBA_EMU_PATH%" !SAVE_ARGS! "!EXTRACT_ROM!"
        )
    ) else (
        :: Regular GBA file
        :: Create save directory if it doesn't exist
        if not exist "%SAVE_DIR%\gba" mkdir "%SAVE_DIR%\gba"
        
        :: Determine emulator-specific save options
        set "SAVE_ARGS="
        
        if /i "%GBA_EMU_NAME%"=="VisualBoyAdvance" (
            set "SAVE_ARGS=--battery-dir "%SAVE_DIR%\gba""
        ) else if /i "%GBA_EMU_NAME%"=="mGBA" (
            set "SAVE_ARGS=-s "%SAVE_DIR%\gba\!TARGET_NAME!.sav""
        ) else if /i "%GBA_EMU_NAME%"=="VBA" (
            set "SAVE_ARGS=--battery-dir "%SAVE_DIR%\gba""
        )
        
        echo Save files will be stored in:
        echo %SAVE_DIR%\gba\
        echo.
        echo When you're done playing, close the emulator window.
        echo.
        timeout /t 3 >nul
        
        :: Launch with the emulator using the exact path
        start "" "%GBA_EMU_PATH%" !SAVE_ARGS! "!TARGET_PATH!"
    )
    
    echo Game launched! Press any key to return to the menu...
    pause >nul
    goto MainMenu
)

:: Parse the choice - ISO game
if /i "%PREFIX%"=="I" (
    set /a num=%NUMBER% 2>nul
    
    if %num% lss 1 goto Favorites
    if %num% gtr %ISO_FAV_COUNT% goto Favorites
    
    :: Find the corresponding ISO file
    set "COUNTER=0"
    set "TARGET_PATH="
    set "TARGET_NAME="
    set "TARGET_EXT="
    
    for /l %%i in (1,1,%FAV_COUNT%) do (
        if "!FAV_GAME_TYPE[%%i]!"=="ISO" (
            set /a "COUNTER+=1"
            if !COUNTER! equ %num% (
                set "TARGET_PATH=!FAV_PATH[%%i]!"
                set "TARGET_NAME=!FAV_GAME_NAME[%%i]!"
                for %%p in ("!TARGET_PATH!") do set "TARGET_EXT=%%~xp"
            )
        )
    )
    
    :: Check if file exists
    if not exist "!TARGET_PATH!" (
        echo Error: ISO file not found at !TARGET_PATH!
        echo.
        echo Press any key to return to favorites...
        pause >nul
        goto Favorites
    )
    
    :: Launch the ISO with DOSBox-X
    cls
    echo ========================================================
    echo                LAUNCHING FAVORITE CD-ROM GAME
    echo ========================================================
    echo.
    echo Launching: !TARGET_NAME!!TARGET_EXT!
    echo Path: !TARGET_PATH!
    echo Using DOSBox-X from: %DOSBOX_PATH%
    echo.
    echo Auto-save is enabled. Game will auto-save every 3 minutes.
    echo Press CTRL+F4 for quick save or F9 for quick load during gameplay.
    echo.
    echo When you're done playing, the launcher will return.
    echo.
    timeout /t 3 >nul
    
    :: Create a game-specific save folder if needed
    set "ISO_SAVE_DIR=%SAVE_DIR%\dos\!TARGET_NAME!"
    if not exist "%ISO_SAVE_DIR%" mkdir "%ISO_SAVE_DIR%"
    
    :: Create temporary C: drive directory if it doesn't exist
    set "TEMP_C_DIR=%TEMP_DIR%\!TARGET_NAME!"
    if not exist "!TEMP_C_DIR!" mkdir "!TEMP_C_DIR!"
    
    :: Remove quotes from paths to avoid syntax errors
    set "ISO_CLEAN_PATH=!TARGET_PATH!"
    set "ISO_CLEAN_PATH=!ISO_CLEAN_PATH:"=!"
    
    :: Use imgmount for all disc images (fixing the previous issue)
    "%DOSBOX_PATH%" -conf "%DOSBOX_CONF%" -c "mount c \"!TEMP_C_DIR!\"" -c "imgmount d \"!ISO_CLEAN_PATH!\" -t iso" -c "d:" -c "dir" -savedir "%ISO_SAVE_DIR%"
    
    echo Game finished! Press any key to return to the menu...
    pause >nul
    goto MainMenu
)

echo Invalid choice! Press any key to try again...
pause >nul
goto Favorites

:: =================== EXIT ===================
:Exit
cls
echo ========================================================
echo           THANKS FOR USING THE GAME LAUNCHER!
echo ========================================================
echo.
echo Goodbye! Have a great day!
echo.
timeout /t 3 >nul
exit
