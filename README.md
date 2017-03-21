<img src="masamon/masamon/Assets.xcassets/AppIcon.appiconset/Icon120.png" align="right" />

まさもん
====

## 概要
シフト表のxlsxファイルやPDFファイルを取り込んで、月給の計算やシフトを1日単位で簡単に見ることができます。  
注)アプリ名は中身と全く関係ありません:bow:

## 注意事項
* サンプルファイル([PDF](https://github.com/kentaiwami/masamon/blob/master/masamon/sampleshift.pdf)もしくは[XLSX](https://github.com/kentaiwami/masamon/blob/master/masamon/sampleshift.xlsx))の形式でなければ動作しません。
* まさもんは.pdfか.xlsxにしか対応していません。
* まさもん起動後、画面遷移をせずにシェイクジェスチャーでムービー画面へと遷移しますが、個人情報を含んでいるため関連するファイルをignoreしています。そのため、シェイクジェスチャーを行うとアプリがクラッシュします。

## デモ
![demo](https://github.com/kentaiwami/masamon/blob/master/demo.gif)
## サポート情報
* Xcode 8.2
* iOS 10.2.1
* iPhone 6,6s
* Swift2.3
* サンプルファイル ([pdf](https://github.com/kentaiwami/masamon/blob/master/masamon/sampleshift.pdf) or [xlsx](https://github.com/kentaiwami/masamon/blob/master/masamon/sampleshift.xlsx))が必要

## 使い方
1. 設定画面 > ユーザの設定で日中,深夜,シフト関連の情報を登録します。
2. 取り込みたいシフトファイルを他アプリ(Safari,Line,Dropboxなど)で開いた状態からまさもんを開きます。
3. 取り込む際の名前を入力して取り込むをタップします。
4. インジケータが消えて取り込みが完了します。

## 使用しているライブラリ
* XlsxReaderWriter
* handMadeCalendarOfSwift
* Gradient Circular Progress
* TET
