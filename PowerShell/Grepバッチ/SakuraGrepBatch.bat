:: 実行パス退避
set scriptPath=%~dp0
:: 管理者としてPowerShellスクリプトを実行
set exePath=%~dp0SakuraGrepBatch_sub.ps1
powershell -ExecutionPolicy Bypass -Command "& { & '%exePath%' -scriptDirectory '%scriptPath%'; }"