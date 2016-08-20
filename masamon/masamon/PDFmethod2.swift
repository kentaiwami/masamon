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
    
    let tolerance_y = 3.0                         //同じ行と判定させるための許容誤差
    let tolerance_x = 7.0
    
    /**
     実行用のメソッド
     */
    func RunPDFmethod() {
        //スタッフ名が登録されている場合のみ処理を進める
        if CheckStaffNameDB() == true {
            
            let charinfoArray = GetPDFGlyphInfo()
            
            let removed_overlap = RemoveOverlapArray(charinfoArray)
            var sorted = SortcharinfoArray(removed_overlap)
            
            //各配列のY座標の平均値を求める
            var YaverageArray: [Double] = []
            for i in 0..<sorted.count {
                YaverageArray.append(Get_Y_Average(sorted[i]))
            }
            
            let unioned = UnionArrayByY(YaverageArray, charinfo: sorted)
            
            let days_charinfo = GetDaysCharInfo(unioned)
            
            var removed_unnecessary = RemoveUnnecessaryLines(unioned)
            
            let shiftyearmonth = GetShiftYearMonth(GetLineText(removed_unnecessary[0]))
            removed_unnecessary.removeAtIndex(0)
            
            let limitArray = GetLimitArray(days_charinfo, length: shiftyearmonth.length)
            let splitshiftArray = GetSplitShiftAllStaffByDay(removed_unnecessary, limit: limitArray)
            
            let coordinated = CoordinateMergedCell(removed_unnecessary, splitshift: splitshiftArray)
            
        }
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
                
                if !(prev_y-tolerance_y...prev_y+tolerance_y ~= tet.y()) {
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
            if !(value_Yave-tolerance_y...value_Yave+tolerance_y ~= key_Yave) {
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
            if (pivot-tolerance_y...pivot+tolerance_y ~= aveArray[i+1]) {
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
     日付だけが記述されている行を取り出す
     
     - parameter charinfo: 同じ行の結合が完了したcharinfo2次元配列
     
     - returns: 日付が記述されているcharinfo1次元配列
     */
    func GetDaysCharInfo(charinfoArray: [[CharInfo]]) -> [CharInfo] {
        for i in 0..<charinfoArray.count {
            var count = 0
            for j in 0..<charinfoArray[i].count {
                let charinfo = charinfoArray[i][j]
                if Int(charinfo.text) == nil {
                    break
                }else{
                    count += 1
                }
                
                if count == charinfoArray[i].count {
                    return charinfoArray[i]
                }
            }
        }
        
        return charinfoArray[0]
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
        
        //各行にスタッフ名が含まれているかを検索して記録する
        let staffnameArray = DBmethod().StaffNameArrayGet()
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
        
        
        return removed
    }
    
    /**
     スタッフがデータベースに登録されているかチェック
     
     - returns: 1名でも登録されていたらtrue、未登録ならfalse
     */
    func CheckStaffNameDB() -> Bool {
        let number_of_people = DBmethod().StaffNameAllRecordGet()
        if number_of_people != nil {
            return true
        }else{
            //アラート表示
            let alert: UIAlertController = UIAlertController(title: "取り込みエラー", message: "設定画面でスタッフを登録して下さい", preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            
            alert.addAction(defaultAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
    }
    
    /**
     1クールが何日あるか、取り込んだシフトの年月を取得する
     
     - parameter text: 平成xx年度が記述された文字列
     
     - returns: year:                  シフトの年度(和暦)
                startcoursmonth:       10日〜30日(31日)までの月
                startcoursmonthyear:   10日〜30日(31日)までの年(和暦)
                endcoursmonth:         1日〜10日までの月
                endcoursmonthyear:     1日〜10日までの年(和暦)
                length:                1クールの日数
     */
    func GetShiftYearMonth(text: String) -> ((year: Int, startcoursmonth: Int, startcoursmonthyear: Int, endcoursmonth: Int, endcoursmonthyear: Int), length: Int){
        //1クールが全部で何日間あるかを判断するため
        let shiftyearandmonth = CommonMethod().JudgeYearAndMonth(text)
        let monthrange = CommonMethod().GetShiftCoursMonthRange(shiftyearandmonth.startcoursmonthyear, shiftstartmonth: shiftyearandmonth.startcoursmonth)
        let length = monthrange.length
        return (shiftyearandmonth,length)
    }
    
    
    /**
     1日ごとのリミット配列を取得する
     
     - parameter days: 日付のCharInfoが格納された1次元配列
     - parameter length: 1クールの最大日数
     - returns: 1日ごとのリミット値(x座標)が格納されたDouble1次元配列
     */
    func GetLimitArray(days: [CharInfo], length: Int) -> [Double] {
        var limitArray:[Double] = []
        var day = 11
        var index = -1
        
        for _ in 0..<length {
            switch day {
            case 10...length:
                index += 2
                limitArray.append(days[index].x)
                
            case 1...9:
                index += 1
                limitArray.append(days[index].x)
            default:
                break
            }
            
            if day < length {
                day += 1
            }else{
                day = 1
            }
        }
        
        return limitArray
    }
    
    /**
     全スタッフ分の1日ごとのシフトを取得する
     
     - parameter charinfo: スタッフのシフトが記述された行が格納されたcharinfo2次元配列
     - parameter limit: 1日ごとのx座標のリミット値が格納されたDouble次元配列
     
     - returns: スタッフごとにシフト名を格納したString2次元配列
     */
    func GetSplitShiftAllStaffByDay(charinfo: [[CharInfo]], limit:[Double]) -> [[String]]{
        var splitdayshift: [[String]] = []
        
        let staffnumber = DBmethod().StaffNumberGet()
        let staffnameDBArray = DBmethod().StaffNameArrayGet()

        //登録したスタッフの人数分だけループする
//        for i in 22..<23 {
        for i in 0..<staffnumber {
            splitdayshift.append([])
            var staffname = ""
            let one_person_charinfo = charinfo[i]
            let one_person_textline = GetLineText(one_person_charinfo)
            
            //名前検索
            for j in 0..<staffnameDBArray!.count {
                if one_person_textline.containsString(staffnameDBArray![j]) == true {
                    staffname = staffnameDBArray![j]
                    break
                }
            }
            
            //シフト文字の始まりの場所を記録する
            var shift_start = 0
            let staffname_end_char = staffname[staffname.endIndex.predecessor()]
            for j in 0..<one_person_charinfo.count {
                let text = one_person_charinfo[j].text
                
                if text == String(staffname_end_char) {
                    shift_start = j+1
                    break
                }
            }
            
            //リミット値を参考に1日ごとのシフトを抽出する
            var current_shift_index = shift_start
            for j in 0..<limit.count {
                let limit_x = limit[j]
                var current_shift_x = one_person_charinfo[current_shift_index].x
                var current_shift_text = one_person_charinfo[current_shift_index].text
                var oneday_shift = ""
                
                while current_shift_x <= limit_x + tolerance_x {
                    oneday_shift += current_shift_text
                    
                    current_shift_index += 1
                    current_shift_x = one_person_charinfo[current_shift_index].x
                    current_shift_text = one_person_charinfo[current_shift_index].text
                }
                
                splitdayshift[i].append(oneday_shift)
//                splitdayshift[0].append(oneday_shift)
            }
//            print(staffname)
//            print(splitdayshift[i])
//            print("**********************")
        }
        return splitdayshift
    }
    
    
    /**
     結合されたセルを判定して、配列に内容を反映させる
     ex.) 配列が"遅","研","修"となっており、研修が結合されている場合は"遅","研修","研修"に修正する
     
     - parameter charinfo:   CharInfoが格納された2次元配列
     - parameter splitshift: 1日ごとのシフトに分割したString2次元配列
     
     - returns: 結合修正済みの2次元配列
     */
    func CoordinateMergedCell(charinfo: [[CharInfo]], splitshift: [[String]]) -> [[String]] {
        var coordinatedArray = splitshift
        
        //        for i in 0..<charinfo.count {
        //            let test1 = charinfo[i]
        //            for j in 0..<test1.count - 1 {
        //                let ABC = test1[j+1].x - test1[j].x
        //                if ABC > 20.0 {
        //                    let t1 = test1[j+1].text
        //                    let t = test1[j].text
        //                    print(GetLineText(charinfo[i]))
        //                    print(t + " " + t1 + " " + String(ABC))
        //                    print("")
        //                }
        //            }
        //        }

        return coordinatedArray
    }
}
