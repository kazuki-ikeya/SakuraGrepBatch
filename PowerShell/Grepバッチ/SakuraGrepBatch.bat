:: ���s�p�X�ޔ�
set scriptPath=%~dp0
:: �Ǘ��҂Ƃ���PowerShell�X�N���v�g�����s
set exePath=%~dp0SakuraGrepBatch_sub.ps1
powershell -ExecutionPolicy Bypass -Command "& { & '%exePath%' -scriptDirectory '%scriptPath%'; }"