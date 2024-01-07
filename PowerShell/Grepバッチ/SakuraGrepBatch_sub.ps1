param ([string]$scriptDirectory)

# スクリプトが配置されたディレクトリを取得
if ($scriptDirectory -eq "") {
	$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
}

# サクラエディタパス
$sakura="C:\Program Files (x86)\sakura\sakura.exe"

# コンフィグ読込
. "$scriptDirectory\config.ps1" -scriptDirectory $scriptDirectory

# Tsvファイルのパス
$filePath = Join-Path $scriptDirectory "$keywordsFile"


# 出力フォルダ
$outDir="$scriptDirectory"
$outLogDir="$scriptDirectory\logs"
New-Item -ItemType Directory -Path $outLogDir -ErrorAction SilentlyContinue
if ($isOutLogDetailTsv -eq 1) {
	New-Item -ItemType Directory -Path $outLogDir\tmp -ErrorAction SilentlyContinue
}

$timestamp = Get-Date -Format "yyyyMMddHHmmssffff"
$outTsvFile="greplog_$timestamp.tsv"
$outTsvPath="$outLogDir\$outTsvFile"
$outLogFile="greplog_$timestamp.log"
$outLogPath="$outLogDir\$outLogFile"
$outTmpLogDir="$outLogDir\tmp\$timestamp"
New-Item -ItemType Directory -Path $outTmpLogDir -ErrorAction SilentlyContinue

# 変換用変数群
$exeNo=0
$GREPNO=""
$GFOLDER=""
$GFILE=""
$GKEY=""
$GREPR=""
$GCODE=99

# ヘッダー出力
if (($isOutLogDetailTsv -eq 1) -And ($isOutLogTsvHeader -eq 1)) {
	$tsvHeader="No	フォルダ指定	ファイル指定	検索設定	検索文字列	フォルダ	ファイル名	行位置	文字コード	内容"
	# tsvに追記
	$tsvHeader | Add-Content -Path "$outTsvPath"
}

# Tsvファイルを読み込む
$data = Get-Content -Path $filePath | ConvertFrom-Csv -Delimiter "`t" -Header ("No", "TargetDir", "TargetFile", "GrepOption", "GrepKey", "GrepRepr")
foreach ($row in $data) {
	$exeNo+=1
	
	# パラメータ出力
	Write-Host "GREP条件：$row"
	
	# No
	$GREPNO=$row.No
	
	# フォルダ指定
	if ($row.TargetDir -eq "") {
		$GFOLDER="$targetDir"
	} else {
		$GFOLDER="$targetDir\$($row.TargetDir)"
	}
	
	# ファイル指定
	if ($row.TargetFile -eq "") {
		$GFILE="$baseFileExtention"
	} else {
		$GFILE="$($row.TargetFile)"
	}
	
	# 検索設定
	$GOPT="$systemGrepOption$baseGrepOption$($row.GrepOption)"
	
	
	# 検索文字列
	$GKEY="$($row.GrepKey)"
	# ダブルクォーテーションのエスケープ
	$GKEY = $GKEY -replace """", """"""
	
	if ($grepMode -eq "R") {
		# 置換文字列
		$GREPR="$($row.GrepRepr)"
		# ダブルクォーテーションのエスケープ
		$GREPR = $GREPR -replace """", """"""
	}
	
	# 詳細出力する場合、内容を加工する
	if ($isOutLogDetailTsv -eq 1) {
		# Tsv出力
		
		# tsvファイル
		$outTmpTsvFile="greplog_$exeNo.tsv"
		$outTmpTsvPath="$outTmpLogDir\$outTmpTsvFile"
		
		if ($grepMode -eq "R") {
			& $sakura -GREPMODE -GFOLDER="$GFOLDER" -GOPT="$GOPT" -GFILE="$GFILE" -GCODE="$GCODE" -GKEY="$GKEY" -GREPR="$GREPR" | Set-Content -Path "$outTmpTsvPath"
		} else {
			& $sakura -GREPMODE -GFOLDER="$GFOLDER" -GOPT="$GOPT" -GFILE="$GFILE" -GCODE="$GCODE" -GKEY="$GKEY" | Set-Content -Path "$outTmpTsvPath"
		}
		# 出力した結果を読込する
		$sakuraResult = Get-Content -Path "$outTmpTsvPath" -ErrorAction SilentlyContinue
		if ($sakuraResult -ne "") {
		
			# タブの除去
			$tsvGKEY="`t"
			$tsvGREPR=""
			$sakuraResult = $sakuraResult -replace $tsvGKEY, $tsvGREPR
			
			# tsv加工:タブ分割：拡張子
			$tsvGKEY="(\.[a-zA-Z]+(?=\([0-9]))"
			$tsvGREPR="`$1`t"
			$sakuraResult = $sakuraResult -replace $tsvGKEY, $tsvGREPR
			
			# tsv加工:タブ分割：ファイル（※拡張子の後に行う必要あり）
			$tsvGKEY="\\([^\\\t]*)\t"
			$tsvGREPR="`t`$1`t"
			$sakuraResult = $sakuraResult -replace $tsvGKEY, $tsvGREPR
			
			# tsv加工:タブ分割：行位置
			$tsvGKEY="(\t\(.+\))\s\s"
			$tsvGREPR="`$1`t"
			$sakuraResult = $sakuraResult -replace $tsvGKEY, $tsvGREPR
			
			# tsv加工:タブ分割：文字コード
			$tsvGKEY="(\t\[.+\]):\s"
			$tsvGREPR="`$1`t"
			$sakuraResult = $sakuraResult -replace $tsvGKEY, $tsvGREPR
			
			# tsv加工:実行情報追加（処理の最後に実行する）
			$outKeywords="$($row.No)	$($row.TargetDir)	$($row.TargetFile)	$($row.GrepOption)	$($row.GrepKey)	"
			$sakuraResult = $sakuraResult -replace [regex]::escape("$targetDir\"), "$outKeywords"
			
			# tsvに追記
			$sakuraResult | Add-Content -Path "$outTsvPath"
		}
		
	} else {
		# 標準log出力
		
		if ($grepMode -eq "R") {
			& $sakura -GREPMODE -GFOLDER="$GFOLDER" -GOPT="$GOPT" -GFILE="$GFILE" -GCODE="$GCODE" -GKEY="$GKEY" -GREPR="$GREPR" | Add-Content -Path "$outLogPath"
		} else {
			& $sakura -GREPMODE -GFOLDER="$GFOLDER" -GOPT="$GOPT" -GFILE="$GFILE" -GCODE="$GCODE" -GKEY="$GKEY" | Add-Content -Path "$outLogPath"
		}
	}
}



# Read-Host -Prompt "続行するには Enter キーを押してください..."