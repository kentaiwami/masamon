//
//  PDFmethod2.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/08/13.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

/**
 *  pdfから抽出したテキスト情報を格納する構造体
 */
struct CharInfo {
    var text = ""
    var x = 0.0
    var y = 0.0
    var size = 0.0
}

class PDFmethod2: UIViewController {
    
    let tolerance = 3.0                         //同じ行と判定させるための許容誤差
    
    /**
     実行用のメソッド
     */
    func RunPDFmethod() {
        let charinfoArray = GetPDFGlyphInfo()
        
        let removed_overlap = RemoveOverlapArray(charinfoArray)
        var sorted = SortcharinfoArray(removed_overlap)

        //各配列のY座標の平均値を求める
        var YaverageArray: [Double] = []
        for i in 0..<sorted.count {
            YaverageArray.append(Get_Y_Average(sorted[i]))
        }
        
        let unioned = UnionArrayByY(YaverageArray, charinfo: sorted)
        
        let removed_unnecessary = RemoveUnnecessaryLines(unioned)
    }
    
    /**
     pdfのテキスト情報を2次元配列に行ごとに格納する
     
     - returns: y座標が近似しているCharInfo同士を2次元配列に格納したもの
     */
    func GetPDFGlyphInfo() -> [[CharInfo]] {
        var charinfoArray: [[CharInfo]] = []
        var prev_y = -99.99
        var currentArrayIndex = -1
        
        let path: NSString
        //path = DBmethod().FilePathTmpGet()
        path = NSBundle.mainBundle().pathForResource("8.11〜", ofType: "pdf")!
        
        let tet = TET()
        let document = tet.open_document(path as String, optlist: "")
        let page = tet.open_page(document, pagenumber: 1, optlist: "granularity=glyph")
        var text = tet.get_text(page)
        
        //全テキストを検査するループ
        while(text != nil && text.characters.count > 0){
            while(tet.get_char_info(page) > 0){
                
                var charinfo = CharInfo()
                charinfo.text = text.hankakuOnly
                charinfo.text = ReplaceHankakuSymbol(charinfo.text)
                charinfo.size = tet.fontsize()
                charinfo.x = tet.x()
                charinfo.y = tet.y()
                
                if !(prev_y-tolerance...prev_y+tolerance ~= tet.y()) {
                    prev_y = tet.y()
                    charinfoArray.append([])
                    currentArrayIndex += 1
                }
                
                charinfoArray[currentArrayIndex].append(charinfo)
                
            }
            text = tet.get_text(page)
        }
        
        tet.close_page(page)
        tet.close_document(document)
        
        return charinfoArray
    }
    
    
    /**
     
     - parameter text: 全角記号を半角記号に置き換える
     
     - returns: 半角記号に置き換えた後の文字列
     */
    func ReplaceHankakuSymbol(text: String) -> String {
        let pattern_zenkaku = ["（", "）", "／"]
        let pattern_hankaku = ["(", ")", "/"]

        var hankaku_text = text
        for i in 0..<pattern_hankaku.count {
            hankaku_text = hankaku_text.stringByReplacingOccurrencesOfString(pattern_zenkaku[i], withString: pattern_hankaku[i])
        }
        
        return hankaku_text
    }
    
    /**
     内容が重複している配列を削除する
     
     - parameter charinfoArray: CharInfoを格納した2次元配列
     
     - returns: テキストは完全一致,y座標は近似している配列(余分に存在する配列)を削除した配列
     */
    func RemoveOverlapArray(charinfoArray: [[CharInfo]]) -> [[CharInfo]] {
        
        var removedcharinfoArray = charinfoArray
        var matchKeyArray: [Int] = []               //比較対象元(添字が小さい)
        var matchValueArray: [Int] = []             //比較対象先(添字が大きい)
        var match_count = 0
        
        //テキストが重複している配列の中身を検出する
        for i in 0..<charinfoArray.count - 1 {
            for j in i+1..<charinfoArray.count {
                if charinfoArray[i].count == charinfoArray[j].count {
                    for k in 0..<charinfoArray[i].count {
                        let charinfo1 = charinfoArray[i][k]
                        let charinfo2 = charinfoArray[j][k]
                        if charinfo1.text == charinfo2.text {
                            match_count += 1
                        }else {
                            break
                        }
                    }

                    //テキストが全て一致したかを判断する
                    if match_count == charinfoArray[i].count {
                        matchKeyArray.append(i)
                        matchValueArray.append(j)
                    }
                    match_count = 0
                }
            }
        }
        
        //matchkey,value配列からY座標の平均値が全く異なるものを外す処理
        for i in (0..<matchKeyArray.count).reverse() {
            let key_Yave = Get_Y_Average(charinfoArray[matchKeyArray[i]])
            let value_Yave = Get_Y_Average(charinfoArray[matchValueArray[i]])
            
            //テキストは完全一致でもY座標が近似でない場合
            if !(value_Yave-tolerance...value_Yave+tolerance ~= key_Yave) {
                matchKeyArray.removeAtIndex(i)
                matchValueArray.removeAtIndex(i)
            }
        }
        
        //matchValueArray内の重複を削除
        let orderedSet = NSOrderedSet(array: matchValueArray)
        let removedArray = orderedSet.array as! [Int]
        matchValueArray = removedArray
        
        
        //重複と判断されたcharinfoArrayの添字をもとに削除する
        for i in (0..<matchValueArray.count).reverse() {
            removedcharinfoArray.removeAtIndex(matchValueArray[i])
        }
        
        return removedcharinfoArray
    }
    
    
    /**
     xは昇順，y座標は降順(PDFテキストの上から順)に並び替える
     
     - parameter charinfo: ソートを行いたいCharInfoが格納された2次元配列
     
     - returns: ソート後のCharInfoが格納された2次元配列
     */
    func SortcharinfoArray(charinfo: [[CharInfo]]) -> [[CharInfo]] {
        var sorted = charinfo
        
        sorted.sortInPlace { $0[0].y > $1[0].y }
        
        for i in 0..<sorted.count {
            sorted[i].sortInPlace { $0.x < $1.x }
        }
        
        return sorted
    }
    
    
    /**
     引数で渡された配列のy座標の平均を求めて返す
     
     - parameter charinfo: y座標の平均を求めたいCharInfoが格納された1次元配列
     
     - returns: y座標の平均値
     */
    func Get_Y_Average(charinfo: [CharInfo]) -> Double {
        var sum = 0.0
        for i in 0..<charinfo.count {
            sum += charinfo[i].y
        }
        
        return (sum/Double(charinfo.count))
    }
    
    
    /**
     平均値の配列をもとに誤差許容範囲内同士の配列を結合する関数
     
     - parameter aveArray: 平均値が格納された1次元配列(aveArray[i]の値はcharinfo[i]の平均値)
     - parameter charinfo: CharInfoが格納された2次元配列
     
     - returns: y座標が近似している配列を結合した2次元配列
     */
    func UnionArrayByY(aveArray: [Double], charinfo: [[CharInfo]]) -> [[CharInfo]]{
        var unionedArray = charinfo
        var pivot_index = 0
        var pivot = 0.0
        
        var grouping: [[Int]] = [[]]
        var grouping_index = 0
        
        //aveArrayの値が近いもの同士を記録する
        for i in 0..<charinfo.count - 1 {
            pivot = aveArray[pivot_index]
            if (pivot-tolerance...pivot+tolerance ~= aveArray[i+1]) {
                grouping[grouping_index].append(i)
                grouping[grouping_index].append(i+1)
            }else {
                pivot_index = i+1
                grouping_index += 1
                grouping.append([])
            }
        }
        
        //grouping内の空配列を削除する
        for i in (0..<grouping.count).reverse() {
            if grouping[i].isEmpty {
                grouping.removeAtIndex(i)
            }
        }
        
        //grouping内で重複している要素を削除
        for i in 0..<grouping.count {
            let groupingArray = grouping[i]
            let orderedSet = NSOrderedSet(array: groupingArray)
            let removedArray = orderedSet.array as! [Int]
            grouping[i] = removedArray
        }
        
        //groupingをもとにunionedArrayの配列同士を結合する
        for i in (0..<grouping.count).reverse() {
            for j in (0..<grouping[i].count - 1).reverse() {
                let index1 = grouping[i][j]
                let index2 = grouping[i][j+1]
                unionedArray[index1] += unionedArray[index2]
                unionedArray.removeAtIndex(index2)
            }
        }
        
        //順番を整える
        unionedArray = SortcharinfoArray(unionedArray)
        
        return unionedArray
    }
    

    /**
     CharInfoのテキストをわかりやすく表示するテスト関数
     
     - parameter charinfo: 表示したいCharInfoが格納された2次元配列
     */
    func ShowAllcharinfoArray(charinfo: [[CharInfo]]) {
        for i in 0..<charinfo.count {
            print(String(i) + ": ", terminator: "")
            for j in 0..<charinfo[i].count {
                let charinfo = charinfo[i][j]
                print(charinfo.text, terminator: "")
            }
            print("")
        }
    }
    
    
    /**
     CharInfoの1オブジェクトを受け取ってテキストを結合した文字列を取得する
     
     - parameter charinfo: 結合した文字列を取得したいCharInfoオブジェクト
     
     - returns: 結合した文字列
     */
    func GetLineText(charinfo: [CharInfo]) -> String {
        var linetext = ""
        for i in 0..<charinfo.count {
            linetext += charinfo[i].text
        }
        
        return linetext
    }
    
    
    /**
     不要な行の削除をする
     
     - parameter charinfo: 不要な行が含まれたCharInfoを格納している2次元配列
     
     - returns: 不要な行を削除したCharInfoを格納している2次元配列
     */
    func RemoveUnnecessaryLines(charinfo: [[CharInfo]]) -> [[CharInfo]] {
        var removed = charinfo
        var pivot_index = 0
        
        //平成xx年度の行を見つける
        for i in 0..<charinfo.count {
            let linetext = GetLineText(charinfo[i])
            
            if linetext.containsString("平成") {
                pivot_index = i
                break
            }
        }
        
        //平成xx年度の行より上の行を取り除く
        for i in (0..<pivot_index).reverse() {
            removed.removeAtIndex(i)
        }
        
        //スタッフ名が含まれている行を記録する
        let staffnameArray = DBmethod().StaffNameArrayGet()
        if staffnameArray == nil {
            //アラート表示
            let alert: UIAlertController = UIAlertController(title: "スタッフ登録エラー", message: "設定画面でスタッフを登録して下さい", preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            
            alert.addAction(defaultAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }else {
            //各行にスタッフ名が含まれているかを検索
            var contains_staffname_line:[Int] = []
            for i in 0..<removed.count {
                let linetext = GetLineText(removed[i])
                
                for j in 0..<staffnameArray!.count {
                    if linetext.containsString(staffnameArray![j]) {
                        contains_staffname_line.append(i)
                        break
                    }
                }
            }
            
            //スタッフ名が含まれていない行を削除
            for i in (1..<removed.count).reverse() {
                if contains_staffname_line.indexOf(i) == nil {
                    removed.removeAtIndex(i)
                }
            }
            
            //先頭文字が数字でない行を削除
            for i in (1..<removed.count).reverse() {
                if Int(removed[i][0].text) == nil {
                    removed.removeAtIndex(i)
                }
            }
        }
        
        return removed
    }
}
