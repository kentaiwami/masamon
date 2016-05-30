//
//  PDFmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/08.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class PDFmethod: UIViewController {
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    //PDF内にある年月とスタッフのシフトを全て抽出する
    func AllTextGet() -> Array<String>{
        
        var pdftextarray: [String] = []
        var lineIndex = 1
        
        let path: NSString
        path = DBmethod().FilePathTmpGet()
        
        let tet = TET()
        
        let document = tet.open_document(path as String, optlist: "")
        let page = tet.open_page(document, pagenumber: 1, optlist: "granularity=page")
        let pdftext = tet.get_text(page)
        
        tet.close_page(page)
        tet.close_document(document)
        
        //"平成"が出るまで1行ずつ読み飛ばしをする
        pdftext.enumerateLines{
            line, stop in
            
            let judgeheisei = line.substringToIndex(line.startIndex.successor().successor())
            
            if(judgeheisei == "平成"){
                pdftextarray.append(line)
                stop = true
            }
            
            lineIndex += 1
        }
        
        //"店長"が出るまで1行ずつ読み飛ばしをする
        var nowIndex = 1
        
        pdftext.enumerateLines{
            line, stop in
            
            if(nowIndex < lineIndex){      //平成を見つけた行まで進める
                nowIndex += 1
            }else{
                if((line.rangeOfString("店長")) != nil){
                    pdftextarray.append(line)
                    lineIndex = nowIndex
                    stop = true
                }else{
                    nowIndex += 1
                }
            }
        }
        
        //スタッフの行を読み取る
        nowIndex = 0
        var staffcount = 0
        
        pdftext.enumerateLines{
            line, stop in
            
            if(nowIndex < lineIndex){      //店長を見つけた行まで進める
                nowIndex += 1
            }else{
                let judgehtopcharacter = line.substringToIndex(line.startIndex.successor())
                
                if(Int(judgehtopcharacter) != nil){         //先頭文字が数値の場合のみ
                    pdftextarray.append(line)
                    staffcount += 1
                }
            }
        }
        
        return pdftextarray
    }
    
    //スタッフのシフトを日にちごとに分けたArrayを返す
    func SplitDayShiftGet( staffarray: Array<String>) -> (shiftarray: Array<String>, shiftcours: (Int,Int,Int,Int,Int)){
        
        //データを削除して初期化する
        appDelegate.errorstaffnamepdf.removeAll()
        appDelegate.errorshiftnamepdf.removeAll()
        
        var dayshiftarray: [String] = []        //1日ごとのシフトを記録
        
        //1クールが全部で何日間あるかを判断するため
        let shiftyearandmonth = CommonMethod().JudgeYearAndMonth(staffarray[0])
        let monthrange = CommonMethod().GetShiftCoursMonthRange(shiftyearandmonth.startcoursmonthyear, shiftstartmonth: shiftyearandmonth.startcoursmonth)
        
        //先に空要素を1クール分追加しておく
        for _ in 0 ..< monthrange.length{
            dayshiftarray.append("")
        }
        
        //スタッフの人数分(配列の最後まで)繰り返す
        //                for i in 4..<5 {
        for i in 1 ..< staffarray.count{
            
            var staffname = ""
            var staffarraytmp = ""
            
            staffarraytmp = staffarray[i]
            
            //シフトの出現場所を記録する2次元配列の初期化
            var shiftlocationarray: [[Int]] = []
            for _ in 0 ..< 7{
                shiftlocationarray.append([])
            }
            
            //受け取った1名分のテキスト(1行)からスペースを削除する
            staffarraytmp = staffarraytmp.stringByReplacingOccurrencesOfString(" ", withString: "")
            staffarraytmp = staffarraytmp.stringByReplacingOccurrencesOfString("　", withString: "")
            
            //全角を半角に変更して上書きする
            staffarraytmp = staffarraytmp.hankakuOnly
            
            //スタッフ名の抽出
            staffname = self.GetStaffName(staffarraytmp, i: i)
            
            print(staffname)
            //スキップされたスタッフは取り込みを行わない
            if(appDelegate.skipstaff.contains(staffname)){
                //ループを抜けて次のループに移る
            }else{
                
                /*抽出したスタッフ名(マネージャーのMは除く)が1文字以下or4文字以上ならエラーとして記録
                 　エラーでなければシフトの出現場所を配列に格納していく
                 */
                let removem = staffname.stringByReplacingOccurrencesOfString("M", withString: "")
                
                if(removem.characters.count <= 1 || removem.characters.count >= 4){
                    appDelegate.errorstaffnamepdf.append(staffarraytmp)
                }else{
                    //スタッフ名を正しく認識しているがエラーとして記録されている場合は削除する
                    for i in 0 ..< appDelegate.errorstaffnamepdf.count{
                        let errorstaffnametext = appDelegate.errorstaffnamepdf[i]
                        
                        if(errorstaffnametext.containsString(staffname)){
                            appDelegate.errorstaffnamepdf.removeAtIndex(i)
                            break
                        }
                    }
                    
                    //シフト体制を文字列の長さ順に並び替えて配列に記録する
                    let shiftsystemnamearray = DBmethod().ShiftSystemNameArrayGet()
                    let desc_shiftname = self.GetDescStringArray(shiftsystemnamearray)
                    
                    //シフト体制の分だけループを回し、各ループでスタッフ1人分のシフト出現場所を記録する
                    var staffarraytmpnsstring = staffarraytmp as NSString
                    for i in 0 ..< DBmethod().DBRecordCount(ShiftSystemDB){
                        //TODO: 落ちる原因は不明
                        
                        //降順に並び替えたシフト体制名でDBへ問い合わせをしてレコードを取得する
                        let shiftsystemrecord = DBmethod().SearchShiftSystem(desc_shiftname[i])
                        
                        if shiftsystemrecord != nil {
                            let results = self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftsystemrecord![0].name)
                            shiftlocationarray[shiftsystemrecord![0].groupid] += results.positionarray
                            staffarraytmpnsstring = results.replacementstring
                        }
                    }
                }
                
                
                //重複した要素を削除する
                for i in 0 ..< shiftlocationarray.count{
                    shiftlocationarray[i] = self.GetRemoveOverlapElementArray(shiftlocationarray[i])
                }
                
                
                //配列をまたがって重複している要素を削除する
                for i in 0 ..< shiftlocationarray.count{
                    let resultsarray = self.GetRemoveOverlapElementAnotherArray(shiftlocationarray)
                    shiftlocationarray[i] = resultsarray[i]
                }
                
                //要素を昇順でソートする
                for i in 0 ..< shiftlocationarray.count{
                    shiftlocationarray[i] = shiftlocationarray[i].sort()
                }
                
                //スタッフ名にシフト名が含まれている場合に、カウントされてしまうため要素を削除する
                let includeshiftnamearray = CommonMethod().IncludeShiftNameInStaffName(staffname)
                if(includeshiftnamearray.count != 0){
                    
                    for i in 0 ..< includeshiftnamearray.count{
                        if(shiftlocationarray[includeshiftnamearray[i]].count != 0){
                            shiftlocationarray[includeshiftnamearray[i]].removeAtIndex(0)
                        }
                    }
                    
                }
                
                //1クール分のシフト文字以外のシフト名をカウントしてしまうので、範囲外の要素を削除する
                var index = staffarraytmp.startIndex
                var numeralcount = 0
                var removeflag = false
                
                while(index != staffarraytmp.endIndex.predecessor()){
                    
                    if(Int(String(staffarraytmp[index])) != nil){
                        numeralcount += 1
                    }else{
                        numeralcount = 0
                    }
                    
                    //数値の連続が5回以上なら数列として判断する
                    if(numeralcount >= 5){
                        index = index.advancedBy(-4)
                        removeflag = true
                        break
                    }
                    
                    index = index.successor()
                }
                
                
                if(removeflag){
                    for i in 0 ..< shiftlocationarray.count{
                        shiftlocationarray[i] = self.RemoveElementThanPivotIndex(shiftlocationarray[i], pivotindex: index, text: staffarraytmp)
                    }
                }
                
                
                //要素数を比較して正しくシフト体制を認識できているかチェックする
                var count = 0
                for i in 0 ..< shiftlocationarray.count{
                    count += shiftlocationarray[i].count
                }
                
                if(count == monthrange.length){
                    
                    //正しく取り込めているが、シフト認識エラーとして記録されて残っている要素があれば削除する
                    if let _ = appDelegate.errorshiftnamepdf[staffname] {
                        appDelegate.errorshiftnamepdf.removeValueForKey(staffname)
                    }
                    
                    
                    //各配列に識別子を追加する
                    for i in 0 ..< shiftlocationarray.count{
                        shiftlocationarray[i].append(99999)
                    }
                    
                    //日付分のループを開始
                    for i in 0 ..< monthrange.length{
                        
                        //シフトの位置が一番小さい値とそのシフト区分を取得する
                        let dayshift = self.GetMinShiftPositionAndGroup(shiftlocationarray)
                        
                        //シフトの名前をテキストから取得する
                        let staffshift = self.GetShiftNameFromOneLineText(staffarraytmp, sg: dayshift.shiftgroup, sp: dayshift.shiftposition)
                        
                        switch(dayshift.shiftgroup){
                        case "早":
                            shiftlocationarray[0].removeAtIndex(0)
                            
                        case "中1":
                            shiftlocationarray[1].removeAtIndex(0)
                            
                        case "中2":
                            shiftlocationarray[2].removeAtIndex(0)
                            
                        case "中3":
                            shiftlocationarray[3].removeAtIndex(0)
                            
                        case "遅":
                            shiftlocationarray[4].removeAtIndex(0)
                            
                        case "他":
                            shiftlocationarray[5].removeAtIndex(0)
                            
                        case "休":
                            shiftlocationarray[6].removeAtIndex(0)
                            
                        default:
                            break
                        }
                        
                        let holidayarray = DBmethod().ShiftSystemNameArrayGetByGroudid(6)
                        if(staffshift != ""){
                            if(holidayarray.contains(staffshift) == false){
                                dayshiftarray[i] += staffname + ":" + staffshift + ","
                            }
                        }
                    }
                    
                    //認識できないシフト名があった場合
                }else{
                    
                    let successshiftnamearray = self.GetWillRemoveShiftName(shiftlocationarray)
                    var messagetext = staffarraytmp
                    
                    for i in 0 ..< successshiftnamearray.count{
                        messagetext = self.GetRemoveSetShiftName(messagetext, shiftname: successshiftnamearray[i])
                    }
                    
                    appDelegate.errorshiftnamepdf[staffname] = messagetext
                }
            }
        }
        
        //        let file_name = "TEST.txt"
        //        let text = dayshiftarray[0]
        //
        //        if let dir : NSString = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true ).first {
        //
        //            let path_file_name = dir.stringByAppendingPathComponent(file_name)
        //
        //            do {
        //
        //                try text.writeToFile(path_file_name, atomically: false, encoding: NSUTF8StringEncoding )
        //
        //            } catch {
        //                //エラー処理
        //            }
        //        }
        
        return (dayshiftarray,shiftyearandmonth)
    }
    
    
    /*スタッフ1人分のテキストを受け取ってスタッフ名のみを返す関数
     stafftext => スタッフ名とシフトが記述されているテキスト
     i         => ループの回数(stafftextの先頭についている数値)
     */
    func GetStaffName(stafftext: String, i: Int) -> String{
        
        //もし、データベースに登録しているスタッフ名があった場合はそれを返す
        //店長(i=1)，役職以外のスタッフ(i > 4)の場合のみ登録されているスタッフ名を返す
        if(DBmethod().StaffNameArrayGet() != nil){
            let staffnamearray = DBmethod().StaffNameArrayGet()
            for j in 0 ..< staffnamearray!.count{
                if(stafftext.containsString(staffnamearray![j])){
                    
                    //登録しているスタッフ名にMが含まれている＆stafftextがマネージャーの分なら(DB：AさんM，シフト：AさんMMT*)
                    if staffnamearray![j].containsString("M") == true && i >= 2 && i <= 4{
                        return staffnamearray![j]
                        
                    //登録しているスタッフ名にMが含まれている＆stafftextがマネージャー以外なら(DB：AさんM，シフト：AさんMT*)
                    }else if staffnamearray![j].containsString("M") == true && !(i >= 2 && i <= 4) {
                        var ABC = staffnamearray![j]
                        ABC = ABC.stringByReplacingOccurrencesOfString("M", withString: "")
                        return ABC
                    
                    //登録しているスタッフ名にMが含まれていない＆stafftextがマネージャーの分なら(DB：Aさん，シフト：AさんMMT*)
                    }else if staffnamearray![j].containsString("M") == false && i >= 2 && i <= 4 {
                        return staffnamearray![j] + "M"
                    
                    //登録しているスタッフ名にMが含まれていない＆stafftextがマネージャー以外なら(DB：Aさん，シフト：AさんMT*)
                    }else if staffnamearray![j].containsString("M") == false && !(i >= 2 && i <= 4) {
                        return staffnamearray![j]
                    }
                }
            }
        }
        
        
        var staffname = ""
        var position = 0
        let holidaynamearray: [String] = DBmethod().ShiftSystemNameArrayGetByGroudid(6)
        var holidaynametopcharacter: [String] = []
        let shiftsystemnamearray: [String] = DBmethod().ShiftSystemNameArrayGet()
        var shiftsystemnametopcharacter: [String] = []
        
        //勤務シフト名の先頭文字だけを取り出すループ処理
        for i in 0 ..< shiftsystemnamearray.count{
            let startindex = shiftsystemnamearray[i].startIndex
            let shiftsystemnametmp = shiftsystemnamearray[i]
            let topcharactertmp = shiftsystemnametmp[startindex]
            
            shiftsystemnametopcharacter.append(String(topcharactertmp))
        }
        
        //休暇のシフト名の先頭文字だけを取り出すループ処理
        for i in 0 ..< holidaynamearray.count{
            let startindex = holidaynamearray[i].startIndex
            let holidaynametmp = holidaynamearray[i]
            let topcharactertmp = holidaynametmp[startindex]
            
            holidaynametopcharacter.append(String(topcharactertmp))
        }
        
        //スタッフ名の読み込みを開始する場所を決定
        if(i <= 9){
            position = 1
        }else{
            position = 2
        }
        
        //スタッフ名の抽出(シフト体制に含まれる文字が出るまで)
        var getcharacterstaffname = stafftext[stafftext.startIndex.advancedBy(position)]
        
        while(DBmethod().SearchShiftSystem(String(getcharacterstaffname)) == nil){
            let character = stafftext.startIndex.advancedBy(position)
            
            if(character == stafftext.endIndex.predecessor()){
                break
            }
            
            //マネージャーの場合はMが出るまで
            if i >= 2 && i <= 4{
                
                if(String(getcharacterstaffname).containsString("M")){
                    //                    print(staffname)
                    return staffname + "M"
                }
                
                //マネージャー以外の場合は以下のパターン
            }else {
                //勤務シフト体制にある文字が検出されたらループを抜けるパターン
                for i in 0 ..< shiftsystemnametopcharacter.count{
                    if(String(getcharacterstaffname).containsString(shiftsystemnametopcharacter[i])){
                        return staffname
                    }
                }
                
                //休暇シフト体制にある文字が検出されたらループを抜けるパターン
                for i in 0 ..< holidaynametopcharacter.count{
                    if(String(getcharacterstaffname).containsString(holidaynametopcharacter[i])){
                        return staffname
                    }
                }
            }
            
            
            staffname = staffname + String(getcharacterstaffname)
            position += 1
            getcharacterstaffname = stafftext[stafftext.startIndex.advancedBy(position)]
        }
        //        print(staffname)
        return staffname
    }
    
    //受け取ったシフト体制の場所を配列にして返す関数
    func GetShiftPositionArray(staffarraysstring: NSString, shiftname: String) -> (positionarray: Array<Int>, replacementstring: NSString){
        var staffstring = staffarraysstring
        var shiftnamelocation: [Int] = []
        let searchrange = NSMakeRange(0, staffstring.length)
        var searchresult = staffstring.rangeOfString(shiftname, options: NSStringCompareOptions.CaseInsensitiveSearch, range: searchrange)
        let number = shiftname.characters.count
        
        while(searchresult.location != NSNotFound){
            if(searchresult.location != NSNotFound){
                
                shiftnamelocation.append(searchresult.location)
                
                let replaceStartIndex = (staffstring as String).startIndex.advancedBy(searchresult.location)
                let replaceEndIndex = replaceStartIndex.advancedBy(number)
                var replacestring = ""
                
                for _ in 0..<number {
                    replacestring += "鬱"
                }
                
                let replacedstring = (staffstring as String).stringByReplacingCharactersInRange(replaceStartIndex..<replaceEndIndex, withString: replacestring)
                staffstring = replacedstring as NSString
                
                searchresult = staffstring.rangeOfString(shiftname, options: NSStringCompareOptions.CaseInsensitiveSearch, range: searchrange)
            }
        }
        
        return (shiftnamelocation,staffstring)
    }
    
    //指定したシフト体制を削除した文字列を返す関数
    func GetRemoveSetShiftName(staffarraysstring: NSString, shiftname: String) -> String{
        var removedshiftstring = ""
        
        removedshiftstring = staffarraysstring.stringByReplacingOccurrencesOfString(shiftname, withString: "")
        //        removedshiftstring = removedshiftstring.stringByReplacingOccurrencesOfString("M", withString: "")
        //        removedshiftstring = removedshiftstring.stringByReplacingOccurrencesOfString("カ", withString: "")
        
        return removedshiftstring
    }
    
    //受け取った数値の中で一番小さい値とシフト区分を返す関数
    func GetMinShiftPositionAndGroup(array: [[Int]]) -> (shiftgroup: String, shiftposition: Int){
        var sg = ""
        var sp = 0
        
        let dict: [String:Int] = ["早":array[0][0], "中1":array[1][0], "中2":array[2][0], "中3":array[3][0], "遅": array[4][0], "他":array[5][0], "休":array[6][0]]
        
        var values : Array = Array(dict.values)
        values = values.sort()
        
        for (key, value) in dict {
            
            if(values[0] == value){
                sg = key
                sp = value
                break
            }
        }
        
        return (sg, sp)
    }
    
    //受け取ったスタッフ1行分のテキストと位置情報からシフト名を取り出す関数
    func GetShiftNameFromOneLineText(text: String, sg: String, sp: Int) -> String{
        
        var result = ""
        var shiftnamearray: [String] = []
        var character = text[text.startIndex.advancedBy(sp)]
        
        //シフト区分によって比較対象にする配列の内容を変える処理
        switch(sg){
        case "早":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(0)
            for i in 0 ..< dbarray.count{
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "中1":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(1)
            for i in 0 ..< dbarray.count{
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "中2":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(2)
            for i in 0 ..< dbarray.count{
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "中3":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(3)
            for i in 0 ..< dbarray.count{
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "遅":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(4)
            for i in 0 ..< dbarray.count{
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "他":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(5)
            for i in 0 ..< dbarray.count{
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "休":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(6)
            for i in 0 ..< dbarray.count{
                shiftnamearray.append(dbarray[i].name)
            }
            
        default:
            break
        }
        
        var position_sp = sp
        for i in 0 ..< shiftnamearray.count{
            
            let tmp = shiftnamearray[i]
            var dbindex = tmp.startIndex
            
            while(dbindex != shiftnamearray[i].endIndex){
                
                if(tmp[dbindex] == character){
                    result += String(tmp[dbindex])
                    dbindex = dbindex.successor()
                    position_sp += 1
                    character = text[text.startIndex.advancedBy(position_sp)]
                }else{
                    result = ""
                    break
                }
            }
            
            if(result.characters.count == tmp.characters.count){
                return result
            }
        }
        
        return result
    }
    
    //受け取った配列の重複要素を削除した配列を返す
    func GetRemoveOverlapElementArray(array: Array<Int>) -> Array<Int>{
        let set = NSOrderedSet(array: array)
        let result = set.array as! [Int]
        
        return result
    }
    
    //文字列配列を文字列の多い順にソートして返す関数
    func GetDescStringArray(array: Array<String>) -> Array<String> {
        var dict: [String:Int] = [:]
        
        //文字列をkey、文字数をvalueとしてdictに保存していく
        for i in 0..<array.count {
            dict[array[i]] = array[i].characters.count
        }
        
        //dict内のvalueを取り出して、降順にソートする
        var sortedvalues : Array = Array(dict.values)
        sortedvalues = sortedvalues.sort().reverse()
        
        //文字数と一致するvalueを持っているkeyを配列に格納していく
        var sortedkeyarray: [String] = []
        for i in 0..<sortedvalues.count {
            for (key, value) in dict {
                if value == sortedvalues[i] {
                    sortedkeyarray.append(key)
                    dict[key] = nil
                    break
                }
            }
        }
        return sortedkeyarray
    }
    
    //各配列の要素数を受け取り、要素数が1以上のシフトグループのシフト文字を配列にして返す
    func GetWillRemoveShiftName(array: [[Int]]) -> Array<String>{
        var removeshiftnamearray: [String] = []
        
        for i in 0 ..< array.count{
            let count = array[i].count
            
            if(count != 0){
                let shiftarraytmp = DBmethod().ShiftSystemRecordArrayGetByGroudid(i)    //シフト体制をグループidで取得する
                var shiftnamearray: [String] = []
                
                //シフトの名前を配列に格納していく
                for j in 0..<shiftarraytmp.count {
                    shiftnamearray.append(shiftarraytmp[j].name)
                }
                
                //文字列が長い順に並び替える
                let desc_shiftnamearray = self.GetDescStringArray(shiftnamearray)
                
                
                for k in 0 ..< desc_shiftnamearray.count{
                    removeshiftnamearray.append(desc_shiftnamearray[k])
                }
            }
        }
        
        return removeshiftnamearray
    }
    
    
    //配列をまたがって重複している要素を削除する関数
    func GetRemoveOverlapElementAnotherArray(array: [[Int]]) -> ([Array<Int>]){
        
        var dict: [Int:Array<Int>] = [0:array[0], 1:array[1], 2:array[2], 3:array[3], 4: array[4], 5:array[5], 6:array[6]]
        
        let shiftsystemarray = DBmethod().ShiftSystemAllRecordGet()
        
        for i in 0 ..< DBmethod().DBRecordCount(ShiftSystemDB){
            
            let Record = DBmethod().ShiftSystemNameGet(i)
            
            for j in 0 ..< shiftsystemarray.count{
                
                if(shiftsystemarray[j].groupid != Record.groupid){
                    if(shiftsystemarray[j].name.characters.count > Record.name.characters.count){
                        if(shiftsystemarray[j].name.containsString(Record.name)){
                            let result = self.RemoveIntersectArrayToArray(dict[Record.groupid]!, comparisonarray: dict[shiftsystemarray[j].groupid]!)
                            dict.updateValue(result, forKey: Record.groupid)
                        }
                    }else{
                        if(Record.name.containsString(shiftsystemarray[j].name)){
                            let result = self.RemoveIntersectArrayToArray(dict[shiftsystemarray[j].groupid]!, comparisonarray: dict[Record.groupid]!)
                            dict.updateValue(result, forKey: shiftsystemarray[j].groupid)
                        }
                    }
                }
            }
        }
        
        var results: [Array<Int>] = []
        for i in 0 ..< array.count{
            results.append(dict[i]!)
        }
        
        return results
    }
    
    
    /*受け取った配列同士の重複を調べて処理後の配列を返す関数
     removedarray    => 文字数が少なく、要素が削除される側の配列
     comparisonarray => 文字数が多く、要素の削除のための比較用になる配列
     */
    func RemoveIntersectArrayToArray( removedarray: Array<Int>, comparisonarray: Array<Int>) -> Array<Int>{
        
        let setarray = Set(removedarray).intersect(comparisonarray)
        
        var resultsarray = removedarray
        for i in 0 ..< setarray.count{
            resultsarray.removeObject(setarray[setarray.startIndex.advancedBy(i)])
        }
        
        return resultsarray
    }
    
    //受け取ったpivotindexよりも大きいindexの要素は削除する関数
    func RemoveElementThanPivotIndex( array: Array<Int>, pivotindex: String.CharacterView.Index, text: String) -> Array<Int>{
        
        let index = text.startIndex
        var removeelement: [Int] = []
        
        for i in 0 ..< array.count{
            if(index.advancedBy(array[i]) >= pivotindex){
                removeelement.append(array[i])
            }
        }
        
        var resultsarray = array
        
        for i in 0 ..< removeelement.count{
            resultsarray.removeObject(removeelement[i])
        }
        
        return resultsarray
    }
    
    //データベースへ記録する関数
    func RegistDataBase(shiftarray: Array<String>, shiftcours: (y: Int,sm: Int,sy: Int,em: Int, ey: Int), importname: String, importpath: String, update: Bool){
        
        var date = 11
        var flag = 0
        var shiftdetailarray = List<ShiftDetailDB>()
        
        //1クールが全部で何日間あるかを判断するため
        let monthrange = CommonMethod().GetShiftCoursMonthRange(shiftcours.sy, shiftstartmonth: shiftcours.sm)
        
        var shiftdetaildbrecordcount = DBmethod().DBRecordCount(ShiftDetailDB)
        let shiftdbrecordcount = DBmethod().DBRecordCount(ShiftDB)
        
        if(appDelegate.errorshiftnamepdf.count == 0){
            
            for i in 0 ..< shiftarray.count{
                let shiftdbrecord = ShiftDB()
                let shiftdetaildbrecord = ShiftDetailDB()
                
                if(update){
                    let existshiftdb = DBmethod().SearchShiftDB(importname)
                    
                    shiftdbrecord.id = existshiftdb.id        //取り込みが上書きの場合は使われているidをそのまま使う
                    shiftdbrecord.year = existshiftdb.year
                    shiftdbrecord.month = existshiftdb.month
                    
                    shiftdetaildbrecord.id = existshiftdb.shiftdetail[i].id
                    shiftdetaildbrecord.day = existshiftdb.shiftdetail[i].day
                    
                    switch(flag){
                    case 0:         //11日〜30(31)日までの場合
                        shiftdetaildbrecord.year = shiftcours.sy
                        shiftdetaildbrecord.month = shiftcours.sm
                        date += 1
                        
                        if(date > monthrange.length){
                            date = 1
                            flag = 1
                        }
                        
                    case 1:         //11日〜月末日までの場合
                        shiftdetaildbrecord.year = shiftcours.ey
                        shiftdetaildbrecord.month = shiftcours.em
                        date += 1
                        
                    default:
                        break
                    }
                    
                    
                    shiftdetaildbrecord.staff = shiftarray[i]
                    shiftdetaildbrecord.shiftDBrelationship = DBmethod().SearchShiftDB(importname)
                    
                    //エラーがない時のみ記録を行う
                    if(appDelegate.errorshiftnamepdf.count == 0){
                        //                        print(String(shiftdetaildbrecord.year) + "  " + String(shiftdetaildbrecord.month))
                        
                        DBmethod().AddandUpdate(shiftdetaildbrecord, update: true)
                    }
                    
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
                        shiftdetaildbrecord.year = shiftcours.sy
                        shiftdetaildbrecord.month = shiftcours.sm
                        date += 1
                        
                        if(date > monthrange.length){
                            date = 1
                            flag = 1
                        }
                        
                    case 1:         //1日〜10日までの場合
                        shiftdetaildbrecord.year = shiftcours.ey
                        shiftdetaildbrecord.month = shiftcours.em
                        date += 1
                        
                    default:
                        break
                    }
                    
                    shiftdetaildbrecord.staff = shiftarray[i]
                    shiftdetaildbrecord.shiftDBrelationship = shiftdbrecord
                    
                    //すでに記録してあるListを取得して後ろに現在の記録を追加する
                    for i in 0 ..< shiftdetailarray.count{
                        shiftdbrecord.shiftdetail.append(shiftdetailarray[i])
                    }
                    shiftdbrecord.shiftdetail.append(shiftdetaildbrecord)
                    
                    let ID = shiftdbrecord.id
                    
                    //エラーがない場合のみ記録を行う
                    if(appDelegate.errorstaffnamepdf.count == 0 && appDelegate.errorshiftnamepdf.count == 0){
                        DBmethod().AddandUpdate(shiftdbrecord, update: true)
                        DBmethod().AddandUpdate(shiftdetaildbrecord, update: true)
                        shiftdetailarray = DBmethod().ShiftDBRelationArrayGet(ID)
                    }
                }
                
            }
        }
    }
    
    //入力したユーザ名の月給を計算して結果を記録する
    func UserMonthlySalaryRegist(shiftarray: Array<String>, shiftcours: (y: Int,sm: Int,sy: Int,em: Int, ey: Int), importname: String){
        var usershift:[String] = []
        
        let username = DBmethod().UserNameGet()
        let holiday = DBmethod().ShiftSystemNameArrayGetByGroudid(6)      //休暇のシフト体制を取得
        
        //1クール分行う
        for i in 0 ..< shiftarray.count{
            
            var dayshift = ""
            
            let nsstring = shiftarray[i] as NSString
            if(nsstring.containsString(username)){
                
                let userlocation = nsstring.rangeOfString(username).location
                
                var index = shiftarray[i].startIndex.advancedBy(userlocation + username.characters.count + 1)
                
                while(String(shiftarray[i][index]) != ","){
                    dayshift += String(shiftarray[i][index])
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
        newshiftdbsalalyadd.year = shiftcours.y
        newshiftdbsalalyadd.month = shiftcours.em
        
        DBmethod().AddandUpdate(newshiftdbsalalyadd, update: true)
    }
    
}

