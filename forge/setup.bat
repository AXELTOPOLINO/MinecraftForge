echo off
pushd .. >nul

  rmdir /S /Q src
  rmdir /S /Q src_base
  rmdir /S /Q src_work

  cmd /C decompile.bat

  pushd src >nul
    ..\runtime\bin\python\python_mcp ..\forge\lfcr.py ..\forge\modLoaderMP.patch ..\forge\modLoaderMP-win.patch
    ..\runtime\bin\applydiff.exe -uf -p2 < ..\forge\modLoaderMP-win.patch
    ..\runtime\bin\python\python_mcp ..\forge\lfcr.py ..\forge\mlprop.patch ..\forge\mlprop-win.patch
    ..\runtime\bin\applydiff.exe -uf -p1 < ..\forge\mlprop-win.patch
    rm ../forge/mlprop-win.patch ../forge/modLoaderMP-win.patch
  popd >nul

  cmd /C updatemd5.bat

  mkdir src_base
  mkdir src_work

  xcopy /Y /E /Q src\* src_base
  xcopy /Y /E /Q src\* src_work

  pushd src_work >nul
    @setlocal enabledelayedexpansion
    @echo off
  
    set PATH=..\forge\bin;%PATH%
    echo Applying patches
    for /f %%i in ('find ../forge/patches -type f') do (
      set file=%%i
      rem Have to do this to filter out .svn entries
      if /I "!file:~-6!" EQU ".patch" (
        ..\runtime\bin\python\python_mcp ..\forge\lfcr.py %%i ..\forge\temp.patch
        ..\runtime\bin\applydiff.exe -uf -p2 -i ..\forge\temp.patch
	rm ../forge/temp.patch >nul 1>nul
      )
    )
  popd >nul
popd >nul
echo finished
pause
