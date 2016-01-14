//
//  PDFmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/08.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class PDFmethod: UIViewController {
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    //PDF内にある年月とスタッフのシフトを全て抽出する
    func AllTextGet() -> Array<String>{
        
        var pdftextarray: [String] = []
        var lineIndex = 1
        
        //        let documentsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path: NSString
        path = NSBundle.mainBundle().pathForResource("sample2", ofType: "pdf")!
        //        let globaloptlist: String = String(format: "searchpath={{%@} {%@/extractor_ios.app} {%@/extractor_ios.app/resource/cmap}}", arguments: [documentsDir,NSHomeDirectory(),NSHomeDirectory()])
        
        let tet = TET()
        //  tet.set_option(globaloptlist)
        
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
        
        
        //        for(var i = 0; i < pdftextarray.count; i++){
        //            print(pdftextarray[i])
        //        }
        
        return pdftextarray
    }
    
    /*スタッフ1人分のテキストを受け取ってスタッフ名のみを返す関数
    stafftext => スタッフ名とシフトが記述されているテキスト
    i         => ループの回数(stafftextの先頭についている数値)
    */
    func GetStaffName(stafftext: String, i: Int) -> String{
        
        //もし、データベースに登録しているスタッフ名があった場合はそれを返す
        if(DBmethod().StaffNameArrayGet() != nil){
            let staffnamearray = DBmethod().StaffNameArrayGet()
            for(var i = 0; i < staffnamearray!.count; i++){
                if(stafftext.containsString(staffnamearray![i])){
                    return staffnamearray![i]
                }
            }
        }
        
        
        var staffname = ""
        var position = 0
        let holidaynamearray: [String] = DBmethod().HolidayNameGet()
        var holidaynametopcharacter: [String] = []
        let shiftsystemnamearray: [String] = DBmethod().ShiftSystemNameArrayGet()
        var shiftsystemnametopcharacter: [String] = []
        
        //勤務シフト名の先頭文字だけを取り出すループ処理
        for(var i = 0; i < shiftsystemnamearray.count; i++){
            let startindex = shiftsystemnamearray[i].startIndex
            let shiftsystemnametmp = shiftsystemnamearray[i]
            let topcharactertmp = shiftsystemnametmp[startindex]
            
            shiftsystemnametopcharacter.append(String(topcharactertmp))
        }
        
        //休暇のシフト名の先頭文字だけを取り出すループ処理
        for(var i = 0; i < holidaynamearray.count; i++){
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

            //勤務シフト体制にある文字が検出されたらループを抜けるパターン
            for(var i = 0; i < shiftsystemnametopcharacter.count; i++){
                if(String(getcharacterstaffname).containsString(shiftsystemnametopcharacter[i])){
                    return staffname
                }
            }
            
            //休暇シフト体制にある文字が検出されたらループを抜けるパターン
            for(var i = 0; i < holidaynametopcharacter.count; i++){
                if(String(getcharacterstaffname).containsString(holidaynametopcharacter[i])){
                    return staffname
                }
            }
            
            staffname = staffname + String(getcharacterstaffname)
            position += 1
            getcharacterstaffname = stafftext[stafftext.startIndex.advancedBy(position)]
        }

        return staffname
    }
    
    //受け取ったシフト体制の場所を配列にして返す関数
    func GetShiftPositionArray(staffarraysstring: NSString, shiftname: String) -> Array<Int>{
        var shiftnamelocation: [Int] = []
        var searchrange = NSMakeRange(0, staffarraysstring.length)
        var searchresult = staffarraysstring.rangeOfString(shiftname, options: NSStringCompareOptions.CaseInsensitiveSearch, range: searchrange)
        
        while(searchresult.location != NSNotFound){
            if(searchresult.location != NSNotFound){
                
                shiftnamelocation.append(searchresult.location)
                
                searchrange = NSMakeRange(searchresult.location + searchresult.length, staffarraysstring.length-(searchresult.location + searchresult.length))
                
                searchresult = staffarraysstring.rangeOfString(shiftname, options: NSStringCompareOptions.CaseInsensitiveSearch, range: searchrange)
            }
            searchrange = NSMakeRange(0, staffarraysstring.length)
        }
        
        return shiftnamelocation
    }
    
    //指定したシフト体制を削除した文字列を返す関数
    func GetRemoveSetShiftName(staffarraysstring: NSString, shiftname: String) -> String{
        var removedshiftstring = ""
        
        removedshiftstring = staffarraysstring.stringByReplacingOccurrencesOfString(shiftname, withString: "")
        removedshiftstring = removedshiftstring.stringByReplacingOccurrencesOfString("M", withString: "")
        removedshiftstring = removedshiftstring.stringByReplacingOccurrencesOfString("カ", withString: "")
        
        return removedshiftstring
    }
    
    //受け取った数値の中で一番小さい値のシフト体制を返す関数
    func GetMinShiftPosition(early: Int, center1: Int, center2: Int, center3: Int, late: Int, holiday: Int, other: Int) -> String{
        var shiftname = ""
        let dict: [String:Int] = ["早":early, "中1":center1, "中2":center2, "中3":center3, "遅": late, "休":holiday, "他":other]
        
        var values : Array = Array(dict.values)
        values = values.sort()
        
        for (key, value) in dict {
            if(values[0] == value){
                shiftname = key
                break
            }
        }
        
        return shiftname
    }
    
    //受け取った配列の重複要素を削除した配列を返す
    func GetRemoveOverlapElementArray(array: Array<Int>) -> Array<Int>{
        let set = NSOrderedSet(array: array)
        let result = set.array as! [Int]
        
        return result
    }
    
    //各配列の要素数を受け取り、要素数が1以上のシフトグループのシフト文字を配列にして返す
    func GetWillRemoveShiftName(early: Int, center1: Int, center2: Int, center3: Int, late: Int, holiday: Int, other: Int) -> Array<String>{
        var array: [String] = []
        var arraytmp: [String] = []
        
        if(early != 0){
            let earlyshiftarray = DBmethod().ShiftSystemNameArrayGetByGroudid(0)
            for(var i = 0; i < earlyshiftarray.count; i++){
                array.append(earlyshiftarray[i].name)
            }
        }
        
        if(center1 != 0){
            let center1shiftarray = DBmethod().ShiftSystemNameArrayGetByGroudid(1)
            for(var i = 0; i < center1shiftarray.count; i++){
                array.append(center1shiftarray[i].name)
            }
        }
        
        if(center2 != 0){
            let center2shiftarray = DBmethod().ShiftSystemNameArrayGetByGroudid(2)
            for(var i = 0; i < center2shiftarray.count; i++){
                array.append(center2shiftarray[i].name)
            }
        }
        
        if(center3 != 0){
            let center3shiftarray = DBmethod().ShiftSystemNameArrayGetByGroudid(3)
            for(var i = 0; i < center3shiftarray.count; i++){
                array.append(center3shiftarray[i].name)
            }
        }
        
        if(late != 0){
            let lateshiftarray = DBmethod().ShiftSystemNameArrayGetByGroudid(4)
            for(var i = 0; i < lateshiftarray.count; i++){
                array.append(lateshiftarray[i].name)
            }
        }
        
        //休暇を示す文字を追加
        if(holiday != 0){
            arraytmp = DBmethod().HolidayNameArrayGet()
            for(var i = 0; i < arraytmp.count; i++){
                array.append(arraytmp[i])
            }
        }
        
        //その他を示す文字を追加
        if(other != 0){
            let lateshiftarray = DBmethod().ShiftSystemNameArrayGetByGroudid(5)
            for(var i = 0; i < lateshiftarray.count; i++){
                array.append(lateshiftarray[i].name)
            }
        }
        
        return array
    }
    
    
    //スタッフのシフトを日にちごとに分けたArrayを返す
    func SplitDayShiftGet(var staffarray: Array<String>, controller: UIViewController) -> Array<String>{
        
        //データを削除して初期化する
        appDelegate.errorstaffname.removeAll()
        appDelegate.errorshiftname.removeAll()
        
        var dayshiftarray: [String] = []        //1日ごとのシフトを記録
        
        //1クールが全部で何日間あるかを判断するため
        let shiftyearandmonth = Shiftmethod().JudgeYearAndMonth(staffarray[0])
        
        let shiftnsdate = MonthlySalaryShow().DateSerial(MonthlySalaryShow().Changecalendar(shiftyearandmonth.year, calender: "JP"), month: shiftyearandmonth.startcoursmonth, day: 1)
        let c = NSCalendar.currentCalendar()
        let monthrange = c.rangeOfUnit([NSCalendarUnit.Day],  inUnit: [NSCalendarUnit.Month], forDate: shiftnsdate)
        
        //先に空要素を1クール分追加しておく
        for(var i = 0; i < monthrange.length; i++){
            dayshiftarray.append("")
        }
        
        //スタッフの人数分(配列の最後まで)繰り返す
//        for(var i = 18; i < 19; i++){

        for(var i = 1; i < staffarray.count; i++){
        
            var staffname = ""
            var staffarraytmp = ""
            
            var earlyshiftlocationarray: [Int] = []
            var center1shiftlocationarray: [Int] = []
            var center2shiftlocationarray: [Int] = []
            var center3shiftlocationarray: [Int] = []
            var lateshiftlocationarray: [Int] = []
            var holidayshiftlocationarray: [Int] = []       //公,夏,有の場所を記録
            var othershiftlocationarray: [Int] = []
            
            staffarray[i] = staffarray[i].stringByReplacingOccurrencesOfString(" ", withString: "")
            staffarray[i] = staffarray[i].stringByReplacingOccurrencesOfString("　", withString: "")
            
            //スタッフ名の抽出
            staffname = self.GetStaffName(staffarray[i], i: i)
//            print(staffname)
            staffarraytmp = staffarray[i]
            
            /*抽出したスタッフ名(マネージャーのMは除く)が1文字以下or4文字以上ならエラーとして記録
            　エラーでなければシフトの出現場所を配列に格納していく
            */
            let removem = staffname.stringByReplacingOccurrencesOfString("M", withString: "")
            if(removem.characters.count <= 1 || removem.characters.count >= 4){
                appDelegate.errorstaffname.append(staffarraytmp)
            }else{
                //スタッフ名を正しく認識しているがエラーとして記録されている場合は削除する
                for(var i = 0; i < appDelegate.errorstaffname.count; i++){
                    let errorstaffnametext = appDelegate.errorstaffname[i]
                    
                    if(errorstaffnametext.containsString(staffname)){
                        appDelegate.errorstaffname.removeAtIndex(i)
                        break
                    }
                }
                
                let staffarraytmpnsstring = staffarraytmp as NSString
                
                
                //シフト体制の分だけループを回し、各ループでスタッフ1人分のシフト出現場所を記録する
                for(var i = 0; i < DBmethod().DBRecordCount(ShiftSystemDB); i++){
                    let shiftname = DBmethod().ShiftSystemNameGet(i)
                    switch(shiftname.groupid){
                    case 0:
                        earlyshiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                        
                    case 1:
                        center1shiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                        
                    case 2:
                        center2shiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                        
                    case 3:
                        center3shiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                        
                    case 4:
                        lateshiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                        
                    default:
                        othershiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                    }
                }
                
                //休みを検出して場所を配列へ代入
                let holiday = DBmethod().HolidayNameArrayGet()      //休暇のシフト体制を取得
                for(var i = 0; i < holiday.count; i++){
                    holidayshiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: holiday[i])
                }
            }
            
            //重複した要素を削除する
            earlyshiftlocationarray = GetRemoveOverlapElementArray(earlyshiftlocationarray)
            center1shiftlocationarray = GetRemoveOverlapElementArray(center1shiftlocationarray)
            center2shiftlocationarray = GetRemoveOverlapElementArray(center2shiftlocationarray)
            center3shiftlocationarray = GetRemoveOverlapElementArray(center3shiftlocationarray)
            lateshiftlocationarray = GetRemoveOverlapElementArray(lateshiftlocationarray)
            holidayshiftlocationarray = GetRemoveOverlapElementArray(holidayshiftlocationarray)
            othershiftlocationarray = GetRemoveOverlapElementArray(othershiftlocationarray)
            
            //中番で重なって検索に引っかかってしまった分を差し引きする
            var removevaluearray: [Int] = []
            for(var i = 0; i < center1shiftlocationarray.count; i++){
                
                if(center2shiftlocationarray.contains(center1shiftlocationarray[i])){
                    removevaluearray.append(center1shiftlocationarray[i])
                }
                
                if(center3shiftlocationarray.contains(center1shiftlocationarray[i])){
                    removevaluearray.append(center1shiftlocationarray[i])
                }
            }
            
            for(var i = 0; i < removevaluearray.count; i++){
                center1shiftlocationarray.removeObject(removevaluearray[i])
            }
            
            
            //要素数を比較して正しくシフト体制を認識できているかチェックする
            var count = 0
            count = earlyshiftlocationarray.count + center1shiftlocationarray.count + center2shiftlocationarray.count + center3shiftlocationarray.count + lateshiftlocationarray.count + holidayshiftlocationarray.count + othershiftlocationarray.count

            if(count == monthrange.length){
                
                //正しく取り込めているが、シフト認識エラーとして記録されて残っている要素があれば削除する
                if let _ = appDelegate.errorshiftname[staffname] {
                    appDelegate.errorshiftname.removeValueForKey(staffname)
                }
                
                
                earlyshiftlocationarray = earlyshiftlocationarray.sort()
                center1shiftlocationarray = center1shiftlocationarray.sort()
                center2shiftlocationarray = center2shiftlocationarray.sort()
                center3shiftlocationarray = center3shiftlocationarray.sort()
                lateshiftlocationarray = lateshiftlocationarray.sort()
                holidayshiftlocationarray = holidayshiftlocationarray.sort()
                othershiftlocationarray = othershiftlocationarray.sort()
                
                //各配列に識別子を追加する
                earlyshiftlocationarray.append(99999)
                center1shiftlocationarray.append(99999)
                center2shiftlocationarray.append(99999)
                center3shiftlocationarray.append(99999)
                lateshiftlocationarray.append(99999)
                holidayshiftlocationarray.append(99999)
                othershiftlocationarray.append(99999)
                
                //日付分のループを開始
                for(var i = 0; i < monthrange.length; i++){
                    let dayshift = self.GetMinShiftPosition(earlyshiftlocationarray[0], center1: center1shiftlocationarray[0], center2: center2shiftlocationarray[0], center3: center3shiftlocationarray[0], late: lateshiftlocationarray[0], holiday: holidayshiftlocationarray[0], other: othershiftlocationarray[0])
                    
                    dayshiftarray[i] += staffname + ":" + dayshift + ","
                    
                    switch(dayshift){
                    case "早":
                        earlyshiftlocationarray.removeAtIndex(0)
                        
                    case "中1":
                        center1shiftlocationarray.removeAtIndex(0)
                        
                    case "中2":
                        center2shiftlocationarray.removeAtIndex(0)
                        
                    case "中3":
                        center3shiftlocationarray.removeAtIndex(0)
                        
                    case "遅":
                        lateshiftlocationarray.removeAtIndex(0)
                        
                    case "休":
                        holidayshiftlocationarray.removeAtIndex(0)
                        
                    case "他":
                        othershiftlocationarray.removeAtIndex(0)
                        
                    default:
                        break
                    }
                }
            //認識できないシフト名があった場合
            }else{
                
                let successshiftnamearray = self.GetWillRemoveShiftName(earlyshiftlocationarray.count, center1: center1shiftlocationarray.count, center2: center2shiftlocationarray.count, center3: center3shiftlocationarray.count, late: lateshiftlocationarray.count, holiday: holidayshiftlocationarray.count, other: othershiftlocationarray.count)
                
                var messagetext = staffarraytmp
                
                for(var i = 0; i < successshiftnamearray.count; i++){
                    messagetext = self.GetRemoveSetShiftName(messagetext, shiftname: successshiftnamearray[i])
                }
                
                appDelegate.errorshiftname[staffname] = messagetext
            }
        }
        
//        print(dayshiftarray)
        return dayshiftarray
    }
}

