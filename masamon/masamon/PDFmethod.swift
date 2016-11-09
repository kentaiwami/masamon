//
//  PDFmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/08/13.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

/**
 *  pdfから抽出したテキスト情報を格納する構造体
 */
struct CharInfo {
    var text = ""
    var x = 0.0
    var y = 0.0
    var size = 0.0
}

/**
 *  1日分のシフト名とx座標を格納する構造体
 */
struct OneDayShift {
    var text = ""
    var x = 0.0
}


class PDFmethod: UIViewController {
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    let tolerance_y = 3.0                         //同じ行と判定させるための許容誤差
    let tolerance_x = 7.0                         //1日ごとのリミット値の許容誤差
    
    let tolerance_onedayshift_x = 10.0            //x座標が近いOneDayShift同士の許容誤差
    
    var dayattendanceArray:[String] = []          //出勤スタッフをスタッフ名：シフト名でまとめた配列
    
    var coordinated:[[String]] = []               //セルのマージ処理後のシフト体制名だけが記録された配列

    var staffnameArray:[String] = []              //取り込んだシフトに出現するスタッフ名を記録した配列

    //シフトの年月
    var shiftyearmonth:(year: Int, startcoursmonth: Int, startcoursmonthyear: Int, endcoursmonth: Int, endcoursmonthyear: Int) = (0,0,0,0,0)
    
    /**
     実行用のメソッド
     */
    func RunPDFmethod() {
        //初回実行時
        if dayattendanceArray.count == 0 {
            let charinfoArray = GetPDFGlyphInfo()
            
            let removed_overlap = RemoveOverlapArray(charinfoArray)
            var sorted = SortcharinfoArray(removed_overlap)
            
            //各配列のY座標の平均値を求める
            var YaverageArray: [Double] = []
            for i in 0..<sorted.count {
                YaverageArray.append(Get_Y_Average(sorted[i]))
            }
            
            let unioned = UnionArrayByY(YaverageArray, charinfoArrays: sorted)
            
            let days_charinfo = GetDaysCharInfo(unioned)
            
            var removed_unnecessary = RemoveUnnecessaryLines(unioned)
            
            let shiftyearmonthAndlength = GetShiftYearMonth(GetLineText(removed_unnecessary[0]))
            removed_unnecessary.removeAtIndex(0)
            
            let limitArray = GetLimitArray(days_charinfo, length: shiftyearmonthAndlength.length)
            let results_GetSplitShiftAllStaffByDay = GetSplitShiftAllStaffByDay(removed_unnecessary, limit: limitArray)
            
            staffnameArray = results_GetSplitShiftAllStaffByDay.staffnameArray
            
            coordinated = CoordinateMergedCell(removed_unnecessary, splitshiftArrays: results_GetSplitShiftAllStaffByDay.onedayshiftArrays)
            
            appDelegate.unknownshiftname = CheckUnknownShiftName(coordinated)
            
            dayattendanceArray = GetTheDayStaffAttendance(staffnameArray, splitshiftArrays: coordinated)
            
            shiftyearmonth = shiftyearmonthAndlength.0

        //2回目(スキップするとこっちを実行)
        }else {
            if appDelegate.skipshiftname != "" {
                coordinated = ReplaceSkipShiftName(coordinated)
            }
            appDelegate.unknownshiftname = CheckUnknownShiftName(coordinated)
            dayattendanceArray = GetTheDayStaffAttendance(staffnameArray, splitshiftArrays: coordinated)
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
        path = DBmethod().FilePathTmpGet()
//        path = NSBundle.mainBundle().pathForResource("8.11〜", ofType: "pdf")!
        
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
     
     - parameter charinfoArrays: CharInfoを格納した2次元配列
     
     - returns: テキストは完全一致,y座標は近似している配列(余分に存在する配列)を削除した配列
     */
    func RemoveOverlapArray(charinfoArrays: [[CharInfo]]) -> [[CharInfo]] {
        
        var removedcharinfoArray = charinfoArrays
        var matchKeyArray: [Int] = []               //比較対象元(添字が小さい)
        var matchValueArray: [Int] = []             //比較対象先(添字が大きい)
        var match_count = 0
        
        //テキストが重複している配列の中身を検出する
        for i in 0..<charinfoArrays.count - 1 {
            for j in i+1..<charinfoArrays.count {
                if charinfoArrays[i].count == charinfoArrays[j].count {
                    for k in 0..<charinfoArrays[i].count {
                        let charinfo1 = charinfoArrays[i][k]
                        let charinfo2 = charinfoArrays[j][k]
                        if charinfo1.text == charinfo2.text {
                            match_count += 1
                        }else {
                            break
                        }
                    }

                    //テキストが全て一致したかを判断する
                    if match_count == charinfoArrays[i].count {
                        matchKeyArray.append(i)
                        matchValueArray.append(j)
                    }
                    match_count = 0
                }
            }
        }
        
        //matchkey,value配列からY座標の平均値が全く異なるものを外す処理
        for i in (0..<matchKeyArray.count).reverse() {
            let key_Yave = Get_Y_Average(charinfoArrays[matchKeyArray[i]])
            let value_Yave = Get_Y_Average(charinfoArrays[matchValueArray[i]])
            
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
     
     - parameter charinfoArrays: ソートを行いたいCharInfoが格納された2次元配列
     
     - returns: ソート後のCharInfoが格納された2次元配列
     */
    func SortcharinfoArray(charinfoArrays: [[CharInfo]]) -> [[CharInfo]] {
        var sorted = charinfoArrays
        
        sorted.sortInPlace { $0[0].y > $1[0].y }
        
        for i in 0..<sorted.count {
            sorted[i].sortInPlace { $0.x < $1.x }
        }
        
        return sorted
    }
    
    
    /**
     引数で渡された配列のy座標の平均を求めて返す
     
     - parameter charinfoArray: y座標の平均を求めたいCharInfoが格納された1次元配列
     
     - returns: y座標の平均値
     */
    func Get_Y_Average(charinfoArray: [CharInfo]) -> Double {
        var sum = 0.0
        for i in 0..<charinfoArray.count {
            sum += charinfoArray[i].y
        }
        
        return (sum/Double(charinfoArray.count))
    }
    
    
    /**
     平均値の配列をもとに誤差許容範囲内同士の配列を結合する関数
     
     - parameter aveArray: 平均値が格納された1次元配列(aveArray[i]の値はcharinfo[i]の平均値)
     - parameter charinfoArrays: CharInfoが格納された2次元配列
     
     - returns: y座標が近似している配列を結合した2次元配列
     */
    func UnionArrayByY(aveArray: [Double], charinfoArrays: [[CharInfo]]) -> [[CharInfo]]{
        var unionedArray = charinfoArrays
        var pivot_index = 0
        var pivot = 0.0
        
        var grouping: [[Int]] = [[]]
        var grouping_index = 0
        
        //aveArrayの値が近いもの同士を記録する
        for i in 0..<charinfoArrays.count - 1 {
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
     
     - parameter charinfoArrays: 表示したいCharInfoが格納された2次元配列
     */
    func ShowAllcharinfoArray(charinfoArrays: [[CharInfo]]) {
        for i in 0..<charinfoArrays.count {
            print(String(i) + ": ", terminator: "")
            for j in 0..<charinfoArrays[i].count {
                let charinfo = charinfoArrays[i][j]
                print(charinfo.text, terminator: "")
            }
            print("")
        }
    }
    
    
    /**
     CharInfoの1オブジェクトを受け取ってテキストを結合した文字列を取得する
     
     - parameter charinfoArray: 結合した文字列を取得したいCharInfoオブジェクト
     
     - returns: 結合した文字列
     */
    func GetLineText(charinfoArray: [CharInfo]) -> String {
        var linetext = ""
        for i in 0..<charinfoArray.count {
            linetext += charinfoArray[i].text
        }
        
        return linetext
    }
    
    
    /**
     日付だけが記述されている行を取り出す
     
     - parameter charinfoArrays: 同じ行の結合が完了したcharinfo2次元配列
     
     - returns: 日付が記述されているcharinfo1次元配列
     */
    func GetDaysCharInfo(charinfoArrays: [[CharInfo]]) -> [CharInfo] {
        for i in 0..<charinfoArrays.count {
            var count = 0
            for j in 0..<charinfoArrays[i].count {
                let charinfo = charinfoArrays[i][j]
                if Int(charinfo.text) == nil {
                    break
                }else{
                    count += 1
                }
                
                if count == charinfoArrays[i].count {
                    return charinfoArrays[i]
                }
            }
        }
        
        return charinfoArrays[0]
    }
    
    
    /**
     不要な行の削除をする
     
     - parameter charinfoArrays: 不要な行が含まれたCharInfoを格納している2次元配列
     
     - returns: 不要な行を削除したCharInfoを格納している2次元配列
     */
    func RemoveUnnecessaryLines(charinfoArrays: [[CharInfo]]) -> [[CharInfo]] {
        var removed = charinfoArrays
        var pivot_index = 0
        
        //平成xx年度の行を見つける
        for i in 0..<charinfoArrays.count {
            let linetext = GetLineText(charinfoArrays[i])
            
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
     
     - parameter charinfodaysArray: 日付のCharInfoが格納された1次元配列
     - parameter length: 1クールの最大日数
     - returns: 1日ごとのリミット値(x座標)が格納されたDouble1次元配列
     */
    func GetLimitArray(charinfodaysArray: [CharInfo], length: Int) -> [Double] {
        var limitArray:[Double] = []
        var day = 11
        var index = -1
        
        for _ in 0..<length {
            switch day {
            case 10...length:
                index += 2
                limitArray.append(charinfodaysArray[index].x)
                
            case 1...9:
                index += 1
                limitArray.append(charinfodaysArray[index].x)
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
     
     - parameter charinfoArrays: スタッフのシフトが記述された行が格納されたcharinfo2次元配列
     - parameter limit: 1日ごとのx座標のリミット値が格納されたDouble次元配列
     
     - returns: スタッフごとにシフト名を格納したOneDayShift2次元配列
                シフトに出現するスタッフ名を格納したString1次元配列
     */
    func GetSplitShiftAllStaffByDay(charinfoArrays: [[CharInfo]], limit:[Double]) -> (onedayshiftArrays: [[OneDayShift]], staffnameArray: [String]) {
        var splitdayshift: [[OneDayShift]] = []
        var staffnameArray: [String] = []
        
        let staffnumber = DBmethod().StaffNumberGet()
        let staffnameDBArray = DBmethod().StaffNameArrayGet()

        //登録したスタッフの人数分だけループする
        for i in 0..<staffnumber - 1 {
            var staffname_candidature: [String:Int] = [:]

            splitdayshift.append([])
            var staffname = ""
            let one_person_charinfo = charinfoArrays[i]
            let one_person_textline = GetLineText(one_person_charinfo)
            
            //名前の場所を記録
            for j in 0..<staffnameDBArray!.count {
                let staffname_range = one_person_textline.rangeOfString(staffnameDBArray![j])
                if staffname_range != nil {
                    
                    staffname_candidature[staffnameDBArray![j]] = one_person_textline.startIndex.distanceTo(staffname_range!.startIndex)
                }
            }
            
            //候補が複数ある場合はstartindexが一番小さいスタッフ名を採用する
            let keys: Array = Array(staffname_candidature.keys)
            let values: Array = Array(staffname_candidature.values)
            if staffname_candidature.count == 1 {
                staffname = keys[0]
                staffnameArray.append(staffname)
            }else if staffname_candidature.count > 1 {
                let minvalue = values.minElement()
                for (key,value) in staffname_candidature {
                    if minvalue! == value {
                        staffname = key;
                        staffnameArray.append(staffname)
                        break
                    }
                }
            }
            
            print(i)
            print(staffname_candidature)
            
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
                var onedayshifttext = ""
                var sum_x = 0.0
                
                //1日ごとのリミット値を超えない限り文字を連結する
                while current_shift_x <= limit_x + tolerance_x {
                    onedayshifttext += current_shift_text
                    sum_x += current_shift_x
                    
                    current_shift_index += 1
                    current_shift_x = one_person_charinfo[current_shift_index].x
                    current_shift_text = one_person_charinfo[current_shift_index].text
                }
                
                //連結した文字が複数の場合はx座標を平均値にする
                let ave_x = sum_x/Double(onedayshifttext.characters.count)
                
                var onedayshift = OneDayShift()
                onedayshift.text = onedayshifttext
                onedayshift.x = ave_x
                splitdayshift[i].append(onedayshift)
            }
        }
        return (splitdayshift,staffnameArray)
    }
    
    
    /**
     OneDayShiftが等しいかを確認する
     
     - parameter obj1: 比較するOneDayShiftオブジェクト
     - parameter obj2: 比較するOneDayShiftオブジェクト
     
     - returns: 等しいならtrue、等しくないならfalse
     */
    func EqualOneDayShift(obj1: OneDayShift, obj2: OneDayShift) -> Bool {
        if (obj1.text == obj2.text) && (obj1.x == obj2.x) {
            return true
        }else {
            return false
        }
    }
    
    /**
     結合されたセルを判定して、配列に内容を反映させる
     ex.) 配列が"遅","研","修"となっており、研修が結合されている場合は"遅","研修","研修"に修正する
     
     - parameter charinfoArrays:   CharInfoが格納された2次元配列
     - parameter splitshift: 1日ごとのシフトに分割したOneDayShift2次元配列
     
     - returns: 結合修正済みの2次元配列
     */
    func CoordinateMergedCell(charinfoArrays: [[CharInfo]], splitshiftArrays: [[OneDayShift]]) -> [[String]] {
        var splitshiftArrays = splitshiftArrays
        var coordinatedArray:[[String]] = []
        var current_onedayshiftArray:[OneDayShift] = []
        var next_onedayshiftArray:[OneDayShift] = []
        
        for i in 0..<splitshiftArrays.count {
            //x座標が近いonedayshift同士を記録する
            for j in 0..<splitshiftArrays[i].count - 1 {
                let oneday_next = splitshiftArrays[i][j+1]
                let oneday_current = splitshiftArrays[i][j]
                
                if oneday_next.x - oneday_current.x < tolerance_onedayshift_x {
                    current_onedayshiftArray.append(oneday_current)
                    next_onedayshiftArray.append(oneday_next)
                }
            }
            
            //x座標が近いと判断されたOneDayShiftオブジェクトを削除＆削除位置を記録する
            var current_obj_index = -1
            var next_obj_index = -1
            for j in 0..<next_onedayshiftArray.count {
                let current_obj = current_onedayshiftArray[j]
                let next_obj = next_onedayshiftArray[j]
                
                for k in (0..<splitshiftArrays[i].count).reverse() {
                    if EqualOneDayShift(current_obj, obj2: splitshiftArrays[i][k]) {
                        current_obj_index = k
                    }
                    
                    if EqualOneDayShift(next_obj, obj2: splitshiftArrays[i][k]) {
                        next_obj_index = k
                    }
                    
                    if current_obj_index != -1 && next_obj_index != -1 {
                        splitshiftArrays[i].removeAtIndex(next_obj_index)
                        splitshiftArrays[i].removeAtIndex(current_obj_index)
                        break
                    }
                }
                
                //削除したOneDayShiftを結合して挿入する
                let combine_text = current_obj.text + next_obj.text
                let ave_x = (current_obj.x + next_obj.x)/2.0
                var new_onedayshift = OneDayShift()
                new_onedayshift.text = combine_text
                new_onedayshift.x = ave_x
                splitshiftArrays[i].insert(new_onedayshift, atIndex: current_obj_index)
                splitshiftArrays[i].insert(new_onedayshift, atIndex: next_obj_index)
            }
            current_onedayshiftArray.removeAll()
            next_onedayshiftArray.removeAll()
        }
        
        //Stringの2次元配列に格納する
        for i in 0..<splitshiftArrays.count {
            coordinatedArray.append([])
            for j in 0..<splitshiftArrays[i].count {
                let splitshift = splitshiftArrays[i][j]
                coordinatedArray[i].append(splitshift.text)
            }
        }
        
        return coordinatedArray
    }
    
    
    /**
     データベースに登録されていないシフト名を1次元配列で返す
     
     - parameter splitshiftArrays: 1日ごとスタッフごとに分割されたシフトを格納した2次元配列
     
     - returns: 登録されていないシフト名を格納した1次元配列
     */
    func CheckUnknownShiftName(splitshiftArrays: [[String]]) -> [String] {
        var unknown_shiftArray:[String] = []
        
        for i in 0..<splitshiftArrays.count {
            for j in 0..<splitshiftArrays[i].count {
                let search_result = DBmethod().SearchShiftSystem(splitshiftArrays[i][j])
                
                if search_result == nil && unknown_shiftArray.indexOf(splitshiftArrays[i][j]) == nil {
                    unknown_shiftArray.append(splitshiftArrays[i][j])
                }
            }
        }
        
        unknown_shiftArray.removeObject("")
        
        return unknown_shiftArray
    }
    
    
    /**
     その日出勤するスタッフを、スタッフ名:シフト名……のように配列に格納する
     
     - parameter staffnameArray:   取り込んだPDFファイルに出現するスタッフ名が格納されたString1次元配列
     - parameter splitshiftArrays: 1日ごとに分けたシフト名が格納されたString2次元配列
     
     - returns: 日にちごとに分けたその日出勤するスタッフごとにまとめた1次元配列
     */
    func GetTheDayStaffAttendance(staffnameArray: [String], splitshiftArrays: [[String]]) -> [String] {
        var splitattendanceArray :[String] = []
        var dayshift = ""
        
        //splitshiftArraysを[i][j]と[i+1][j][1+2][j]と縦方向に同時にアクセス
        for i in 0..<splitshiftArrays[0].count {
            for j in 0..<splitshiftArrays.count {
                let staffshift = splitshiftArrays[j][i]
                let staffname = staffnameArray[j]
                let holidayarray = DBmethod().ShiftSystemNameArrayGetByGroudid(6)
                if(staffshift != ""){
                    if(holidayarray.contains(staffshift) == false){
                        dayshift += staffname + ":" + staffshift + ","
                    }
                }
            }
            splitattendanceArray.append(dayshift)
            dayshift = ""
        }
        
        return splitattendanceArray
    }
    
    
    /**
     スキップされたシフト体制名を検索して不明に置き換える
     
     - parameter coordinatedArrays: 結合処理済みのシフト体制名だけが格納された2次元配列
     
     - returns: スキップされたシフト体制名を不明に置き換えた後のcoordinatedArrays
     */
    func ReplaceSkipShiftName(coordinatedArrays: [[String]]) -> [[String]] {
        var replaced_coordinatedArrays = coordinatedArrays
        for i in 0..<coordinatedArrays.count {
            for j in 0..<coordinatedArrays[i].count {
                replaced_coordinatedArrays[i][j] = replaced_coordinatedArrays[i][j].stringByReplacingOccurrencesOfString(appDelegate.skipshiftname, withString: "不明")
            }
        }
        
        appDelegate.skipshiftname = ""
        
        return replaced_coordinatedArrays
    }
    
    
    /**
     データベースへ取り込んだシフトを格納する
     
     - parameter update:     上書きならtrue、新規ならfalse
     - parameter importname: 取り込み時のファイル名+拡張子
     - parameter importpath: 取り込んだファイルのフルパス
     */
    func RegistDataBase(update: Bool, importname: String, importpath: String) {
        var date = 11
        var flag = 0
        var shiftdetailarray = List<ShiftDetailDB>()

        //1クールが全部で何日間あるかを判断するため
        let monthrange = CommonMethod().GetShiftCoursMonthRange(shiftyearmonth.startcoursmonthyear, shiftstartmonth: shiftyearmonth.startcoursmonth)
        
        var shiftdetaildbrecordcount = DBmethod().DBRecordCount(ShiftDetailDB)
        let shiftdbrecordcount = DBmethod().DBRecordCount(ShiftDB)
        
        for i in 0 ..< dayattendanceArray.count{
            let shiftdbrecord = ShiftDB()
            let shiftdetaildbrecord = ShiftDetailDB()
            
            if update {
                let existshiftdb = DBmethod().SearchShiftDB(importname)
                
                shiftdbrecord.id = existshiftdb.id        //取り込みが上書きの場合は使われているidをそのまま使う
                shiftdbrecord.year = existshiftdb.year
                shiftdbrecord.month = existshiftdb.month
                
                shiftdetaildbrecord.id = existshiftdb.shiftdetail[i].id
                shiftdetaildbrecord.day = existshiftdb.shiftdetail[i].day
                
                switch(flag){
                case 0:         //11日〜30(31)日までの場合
                    shiftdetaildbrecord.year = shiftyearmonth.startcoursmonthyear
                    shiftdetaildbrecord.month = shiftyearmonth.startcoursmonth
                    date += 1
                    
                    if(date > monthrange.length){
                        date = 1
                        flag = 1
                    }
                    
                case 1:         //11日〜月末日までの場合
                    shiftdetaildbrecord.year = shiftyearmonth.endcoursmonthyear
                    shiftdetaildbrecord.month = shiftyearmonth.endcoursmonth
                    date += 1
                    
                default:
                    break
                }
                
                
                shiftdetaildbrecord.staff = dayattendanceArray[i]
                shiftdetaildbrecord.shiftDBrelationship = DBmethod().SearchShiftDB(importname)
                
                DBmethod().AddandUpdate(shiftdetaildbrecord, update: true)
                
            }else{
                
                shiftdbrecord.id = shiftdbrecordcount
                
                shiftdbrecord.year = 0
                shiftdbrecord.month = 0
                shiftdbrecord.shiftimportname = importname
                shiftdbrecord.shiftimportpath = importpath
                shiftdbrecord.salaly = 0
                
                shiftdetaildbrecord.id = shiftdetaildbrecordcount
                shiftdetaildbrecordcount += 1
                
                shiftdetaildbrecord.day = date
                
                switch(flag){
                case 0:         //11日〜月末日までの場合
                    shiftdetaildbrecord.year = shiftyearmonth.startcoursmonthyear
                    shiftdetaildbrecord.month = shiftyearmonth.startcoursmonth
                    date += 1
                    
                    if(date > monthrange.length){
                        date = 1
                        flag = 1
                    }
                    
                case 1:         //1日〜10日までの場合
                    shiftdetaildbrecord.year = shiftyearmonth.endcoursmonthyear
                    shiftdetaildbrecord.month = shiftyearmonth.endcoursmonth
                    date += 1
                    
                default:
                    break
                }
                
                shiftdetaildbrecord.staff = dayattendanceArray[i]
                shiftdetaildbrecord.shiftDBrelationship = shiftdbrecord
                
                //すでに記録してあるListを取得して後ろに現在の記録を追加する
                for i in 0 ..< shiftdetailarray.count{
                    shiftdbrecord.shiftdetail.append(shiftdetailarray[i])
                }
                shiftdbrecord.shiftdetail.append(shiftdetaildbrecord)
                
                let ID = shiftdbrecord.id
                
                DBmethod().AddandUpdate(shiftdbrecord, update: true)
                DBmethod().AddandUpdate(shiftdetaildbrecord, update: true)
                shiftdetailarray = DBmethod().ShiftDBRelationArrayGet(ID)
            }
            
        }
    }
    
    
    /**
     入力したユーザ名の月給を計算して結果をデータベースへ格納する
     
     - parameter importname: 取り込み時のファイル名+拡張子
     */
    func UserMonthlySalaryRegist(importname: String){
        var usershift:[String] = []
        
        let username = DBmethod().UserNameGet()
        let holiday = DBmethod().ShiftSystemNameArrayGetByGroudid(6)      //休暇のシフト体制を取得
        
        //1クール分行う
        for i in 0 ..< dayattendanceArray.count{
            
            var dayshift = ""
            
            let nsstring = dayattendanceArray[i] as NSString
            if(nsstring.containsString(username)){
                
                let userlocation = nsstring.rangeOfString(username).location
                
                var index = dayattendanceArray[i].startIndex.advancedBy(userlocation + username.characters.count + 1)
                
                while(String(dayattendanceArray[i][index]) != ","){
                    dayshift += String(dayattendanceArray[i][index])
                    index = index.successor()
                }
                
                if(holiday.contains(dayshift) == false){      //holiday以外なら
                    usershift.append(dayshift)
                }
            }
        }
        
        //月給の計算をする
        var monthlysalary = 0.0
        let houlypayrecord = DBmethod().HourlyPayRecordGet()
        
        for i in 0 ..< usershift.count{
            
            let shiftsystem = DBmethod().SearchShiftSystem(usershift[i])
            if(shiftsystem![0].endtime <= houlypayrecord[0].timeto){
                monthlysalary = monthlysalary + (shiftsystem![0].endtime - shiftsystem![0].starttime - 1) * Double(houlypayrecord[0].pay)
            }else{
                //22時以降の給与を先に計算
                let latertime = shiftsystem![0].endtime - houlypayrecord[0].timeto
                monthlysalary = monthlysalary + latertime * Double(houlypayrecord[1].pay)
                
                monthlysalary = monthlysalary + (shiftsystem![0].endtime - latertime - shiftsystem![0].starttime - 1) * Double(houlypayrecord[0].pay)
            }
        }
        
        //データベースへ記録上書き登録
        let newshiftdbsalalyadd = ShiftDB()                                 //月給を追加するための新規インスタンス
        let oldshiftdbsalalynone = DBmethod().SearchShiftDB(importname)     //月給がデフォルト値で登録されているShiftDBオブジェクト
        
        newshiftdbsalalyadd.id = oldshiftdbsalalynone.id
        
        for i in 0 ..< oldshiftdbsalalynone.shiftdetail.count{
            newshiftdbsalalyadd.shiftdetail.append(oldshiftdbsalalynone.shiftdetail[i])
        }
        
        newshiftdbsalalyadd.shiftimportname = oldshiftdbsalalynone.shiftimportname
        newshiftdbsalalyadd.shiftimportpath = oldshiftdbsalalynone.shiftimportpath
        newshiftdbsalalyadd.salaly = Int(monthlysalary)
        newshiftdbsalalyadd.year = shiftyearmonth.year
        newshiftdbsalalyadd.month = shiftyearmonth.endcoursmonth
        
        DBmethod().AddandUpdate(newshiftdbsalalyadd, update: true)
    }
}
