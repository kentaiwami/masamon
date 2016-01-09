//
//  PDFmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/08.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class PDFmethod: UIViewController {
    
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
        var staffname = ""
        var position = 0
        let othershiftsystem: [String] = ["公","研","出"]

        //スタッフ名の読み込みを開始する場所を決定
        if(i <= 9){
            position = 1
        }else{
            position = 2
        }
        
        //スタッフ名の抽出(シフト体制に含まれる文字が出るまで)
        var getcharacterstaffname = stafftext[stafftext.startIndex.advancedBy(position)]
        while(DBmethod().SearchShiftSystem(String(getcharacterstaffname)) == nil){
            
            if(othershiftsystem.contains(String(getcharacterstaffname))){         //ShiftSystemにない細かいのも検出するため
                break
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
    
    
    //スタッフのシフトを日にちごとに分けたArrayを返す
    func SplitDayShiftGet(var staffarray: Array<String>) -> Array<String>{
        
        var dayshiftarray: [String] = []        //1日ごとのシフトを記録
        var errorstaff: [String] = []           //スタッフ名の抽出がうまくいかなかったスタッフのシフトを記録
        
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
        for(var i = 2; i < 3; i++){
            
            var staffname = ""
            var staffarraytmp = ""
            
            var earlyshiftlocationarray: [Int] = []
            var center1shiftlocationarray: [Int] = []
            var center2shiftlocationarray: [Int] = []
            var center3shiftlocationarray: [Int] = []
            var lateshiftlocationarray: [Int] = []
            var holidayshiftlocationarray: [Int] = []       //公,夏,有の場所を記録
            var othershiftlocationarray: [Int] = []         //上記以外のシフトの場所を記録

            staffarray[i] = staffarray[i].stringByReplacingOccurrencesOfString(" ", withString: "")
            staffarray[i] = staffarray[i].stringByReplacingOccurrencesOfString("　", withString: "")
            
            //スタッフ名の抽出
            staffname = self.GetStaffName(staffarray[i], i: i)
            
            staffarraytmp = staffarray[i]
            
            /*抽出したスタッフ名(マネージャーのMは除く)が1文字以下or4文字以上ならエラーとして記録
            　エラーでなければシフトの出現場所を配列に格納していく
            */
            let removem = staffname.stringByReplacingOccurrencesOfString("M", withString: "")
            if(removem.characters.count <= 1 || removem.characters.count >= 4){
                errorstaff.append(staffarraytmp)
            }else{
                let staffarraytmpnsstring = staffarraytmp as NSString

                //シフト体制の分だけループを回し、各ループでスタッフ1人分のシフト出現場所を記録する
                for(var i = 0; i < DBmethod().DBRecordCount(ShiftSystem); i++){
                    let shiftname = DBmethod().ShiftSystemNameGet(i)
                    switch(i){
                    case 0...3:
                        earlyshiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname)
                        
                    case 4:
                        center1shiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname)
                        
                    case 5:
                        center2shiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname)
                        
                    case 6:
                        center3shiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname)
                        
                    case 7...9:
                        lateshiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname)
                        
                    default:
                        break
                    }
                }
                
                //休みを検出して場所を配列へ代入
                let holiday = ["公","夏","有"]
                for(var i = 0; i < holiday.count; i++){
                    holidayshiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: holiday[i])
                }
            }
            
            print(holidayshiftlocationarray)

        }
        return dayshiftarray
    }
}
