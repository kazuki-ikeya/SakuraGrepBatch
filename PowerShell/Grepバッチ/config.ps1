param ([string]$scriptDirectory)

# ---- 以下、基本設定 ----

# targetDir：Grepしたいフォルダ（絶対パスまたは相対パス指定）
$targetDir="..\..\Grep対象ファイル"

# isTargetDirRelationPath：Grepしたいフォルダで相対パス指定しているか（1:している、0:していない）
$isTargetDirRelationPath=1
if ($isTargetDirRelationPath -eq 1) {
	# 絶対パスに変換する（tsvファイル出力時の結果に影響する）
	$targetDir = Join-Path -Path $scriptDirectory -ChildPath $targetDir
	$targetDir = Convert-Path $targetDir
}

# grepMode：検索・置換実行切替（S:検索、R:置換）
$grepMode="R"

# 基本拡張子（ファイル未設定時の値。標準：*.*;）
$baseFileExtention="*.txt*;"

# isOutLogTsv：Grep結果をTSV形式に出力する（1:TSV形式に加工した結果を出力、0:標準のサクラエディタのGrep結果を出力）
# tsvのためタブ文字は半角スペースに変換される。
$isOutLogTsv=1

# convertedTabString：Tab文字を変換したときの文字列
$convertedTabString=" "

# isOutputReplacedResult：置換想定結果の出力（1:する、0:しない）
$isOutputReplacedResult=1

# サクラエディタGrep標準設定
$baseGrepOption="SL"

# サクラエディタコマンドラインオプション
# 詳細はhttps://sakura-editor.github.io/help/HLP000109.html参照
# S : サブフォルダーからも検索
# L : 大文字と小文字を区別
# R : 正規表現
# P : 該当行を出力／未指定時は該当部分だけ出力
# W : 単語単位で探す
# 1|2|3 : 結果出力形式。1か2か3のどれかを指定します。(1=ノーマル、2=ファイル毎、3=結果のみ)
# K : -GCODE=99と同じ意味です。互換性のためだけに残されています。
# F : ファイル毎最初のみ(検索のみ)
# B : ベースフォルダー表示
# G : フォルダー毎に表示
# X : Grep実行後カレントディレクトリを移動しない
# C : (置換)クリップボードから貼り付け (sakura:2.2.0.0以降)
# O : (置換)バックアップ作成 (sakura:2.2.0.0以降)
# U : 標準出力に出力し、Grep画面にデータを表示しない コマンドラインからパイプやリダイレクトを指定することで結果を利用できます。(sakura:2.2.0.0以降)
# H : ヘッダー・フッターを出力しない(sakura:2.2.0.0以降)


# ---- 以下、詳細設定 ----

# isOutLogTsvHeader：TSV形式時のヘッダーを出力する（1:出力、0:出力しない）
$isOutLogTsvHeader=0

# キーワードファイル名
$keywordsFile = "keywords.tsv"


# ---- 以下、変更不可設定 ----

# systemGrepOption（サクラエディタ実行時の基本オプション）
$systemGrepOption="1XPU"
# TSV形式時、ヘッダーフッターを出力しない
if ($isOutLogTsv -eq 1) {
	$systemGrepOption = "H" + $systemGrepOption
}