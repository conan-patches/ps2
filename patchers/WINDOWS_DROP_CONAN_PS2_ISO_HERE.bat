@echo off

rem #
rem #  _ \  __|  __|__ __|
rem #  |  |(    (_ |   |
rem # ___/\___|\___|  _|
rem #
rem # https://github.com/conan-patches

set EXPECTED_ISO_SHA1SUM=0b083120da3565d649f3e27c328f89c33a9c05c1

echo DETECTIVE CONAN PS2 PATCHER
echo ===========================

echo [*] Applying patch to file
echo %~1

echo [*] Finding current patcher directory
set PATCHER_CWD=%~dp0
echo %PATCHER_CWD:~0,-1%

set PATCHED_ISO=%PATCHER_CWD%CONAN_PS2_ENGLISH_PATCHED_1.0.0.iso
echo %PATCHED_ISO%

echo [*] Finding patching data
set PATCHDATA=%PATCHER_CWD%patching_data\PS2_DCGT_EN_1.0.0
echo %PATCHDATA%

if not exist "%PATCHDATA%" (
    echo [-] Missing or corrupt patching data.
    pause
    exit 1
)

echo [*] Computing hash on received file
"%PATCHER_CWD%patching_utils\7z.exe" h -scrcSHA1 "%~1" | find /i "%EXPECTED_ISO_SHA1SUM%"
if errorlevel 1 (
    echo [-] Invalid ISO. SHA1SUM must match "%EXPECTED_ISO_SHA1SUM%".
    echo     Please ensure that you provided the correct file and that you dumped
    echo     your disc correctly.
    pause
    exit 1
)

echo [*] Valid ISO confirmed

set PATCHER_TEMP=%PATCHER_CWD%temp
set PATCHER_PATCHED_TEMP=%PATCHER_CWD%temp/patched
set PATCHER_PATCHED_TEMP_DATA=%PATCHER_CWD%temp/patched/DATA

echo [*] Creating temp directory
echo %PATCHER_TEMP%

if not exist "%PATCHER_TEMP%" mkdir "%PATCHER_TEMP%"
if not exist "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\" mkdir "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\"
if not exist "%PATCHER_PATCHED_TEMP_DATA%" mkdir "%PATCHER_PATCHED_TEMP_DATA%"

echo [*] Extracting ISO file
"%PATCHER_CWD%patching_utils\7z.exe" x -y "%~1" -o"%PATCHER_TEMP%" | find /i "Everything is Ok"
if errorlevel 1 (
    echo [-] Could not extract ISO.
    echo     Please ensure that you have enough available disk space ^(>6 GB^)
    pause
    exit 1
)

echo [*] ISO file extracted

echo [*] Patching extracted files

"%PATCHER_CWD%patching_utils\zstd.exe" --long=30 --force --decompress --patch-from "%PATCHER_TEMP%/SLPS_254.26" "%PATCHDATA%/ISOHEADER.zstd" -o "%PATCHER_PATCHED_TEMP%/ISOHEADER"
"%PATCHER_CWD%patching_utils\zstd.exe" --long=30 --force --decompress --patch-from "%PATCHER_TEMP%/SLPS_254.26" "%PATCHDATA%/SLPS_254.26.zstd" -o "%PATCHER_PATCHED_TEMP%/SLPS_254.26"

for %%d in (MOVIE, DMAP, SOUND, 2DMAP, EXTRA, STATUS, PIECE, SYSTEM, TITLE, MODULES, ROOT) do (
    "%PATCHER_CWD%patching_utils\zstd.exe" --long=30 --force --decompress --patch-from "%PATCHER_TEMP%/DATA/%%d.DAT" "%PATCHDATA%/DATA/%%d.DAT.zstd" -o "%PATCHER_PATCHED_TEMP%/DATA/%%d.DAT"
    "%PATCHER_CWD%patching_utils\zstd.exe" --long=30 --force --decompress --patch-from "%PATCHER_TEMP%/DATA/%%d.HED" "%PATCHDATA%/DATA/%%d.HED.zstd" -o "%PATCHER_PATCHED_TEMP%/DATA/%%d.HED"
)

echo [*] Delete some temporary files to save space

del "%PATCHER_TEMP%\DATA\*.DAT

echo [*] Preparing build

call:create_slack "%PATCHER_PATCHED_TEMP%\SYSTEM.CNF.slack" 1991
call:create_slack "%PATCHER_PATCHED_TEMP%\DI..slack" 1920
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\SUBDIR.HED.slack" 1980
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES.HED.slack" 1212
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\DMAP.HED.slack" 324
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MOVIE.HED.slack" 1544
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\SOUND.HED.slack" 1612
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\STATUS.HED.slack" 644
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\SYSTEM.HED.slack" 424
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\ROOT.HED.slack" 1784
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\2DMAP.HED.slack" 1152
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\PIECE.HED.slack" 292
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\EXTRA.HED.slack" 312
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\TITLE.HED.slack" 948
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\EZMIDI.IRX.slack" 1011
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\IOPRP300.IMG.slack" 1135
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\LIBSD.IRX.slack" 11
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MCMAN.IRX.slack" 75
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MCSERV.IRX.slack" 807
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MODHSYN.IRX.slack" 451
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MODMIDI.IRX.slack" 587
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MODSEIN.IRX.slack" 847
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MODSESQ.IRX.slack" 619
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\PADMAN.IRX.slack" 1307
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\SDRDRV.IRX.slack" 1079
call:create_slack "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\SIO2MAN.IRX.slack" 1551

echo [*] Building patched iso

copy /b "%PATCHER_PATCHED_TEMP%\ISOHEADER"^
 + "%PATCHER_TEMP%\SYSTEM.CNF"^
 + "%PATCHER_PATCHED_TEMP%\SYSTEM.CNF.slack"^
 + "%PATCHER_PATCHED_TEMP%\SLPS_254.26"^
 + "%PATCHER_TEMP%\DI."^
 + "%PATCHER_PATCHED_TEMP%\DI..slack"^
 + "%PATCHER_TEMP%\DATA\SUBDIR.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\SUBDIR.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\DMAP.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\DMAP.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\DMAP.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MOVIE.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MOVIE.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MOVIE.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\SOUND.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\SOUND.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\SOUND.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\STATUS.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\STATUS.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\STATUS.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\SYSTEM.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\SYSTEM.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\SYSTEM.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\ROOT.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\ROOT.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\ROOT.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\2DMAP.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\2DMAP.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\2DMAP.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\PIECE.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\PIECE.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\PIECE.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\EXTRA.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\EXTRA.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\EXTRA.HED.slack"^
 + "%PATCHER_PATCHED_TEMP%\DATA\TITLE.DAT"^
 + "%PATCHER_PATCHED_TEMP%\DATA\TITLE.HED"^
 + "%PATCHER_PATCHED_TEMP%\DATA\TITLE.HED.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\EZMIDI.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\EZMIDI.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\IOPRP300.IMG"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\IOPRP300.IMG.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\LIBSD.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\LIBSD.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\MCMAN.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MCMAN.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\MCSERV.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MCSERV.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\MODHSYN.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MODHSYN.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\MODMIDI.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MODMIDI.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\MODSEIN.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MODSEIN.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\MODSESQ.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\MODSESQ.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\PADMAN.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\PADMAN.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\SDRDRV.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\SDRDRV.IRX.slack"^
 + "%PATCHER_TEMP%\DATA\MODULES\IRX\SIO2MAN.IRX"^
 + "%PATCHER_PATCHED_TEMP%\DATA\MODULES\IRX\SIO2MAN.IRX.slack"^
 "%PATCHED_ISO%"

echo [*] Cleaning temp directory

rmdir /S /Q "%PATCHER_TEMP%"

echo [*] Build success. Thank you for using this patcher.
echo %PATCHED_ISO%


pause

exit

:create_slack
if exist "%~1" del "%~1"
fsutil file createnew "%~1" "%~2"
goto:eof


