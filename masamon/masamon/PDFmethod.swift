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
    
    //スタッフのシフトを日にちごとに分けたArrayを返す
    func SplitDayShiftGet(var staffarray: Array<String>) -> Array<String>{
        
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
        
        var position = 0            //先頭から何文字の場所から読み取るかを管理
        
        //スタッフの人数分(配列の最後まで)繰り返す
        for(var i = 1; i < staffarray.count; i++){
            
//            var daycounter = 0
//            var staffnametmp = ""
            var staffarraytmp = ""
            
            staffarray[i] = staffarray[i].stringByReplacingOccurrencesOfString(" ", withString: "")
            staffarray[i] = staffarray[i].stringByReplacingOccurrencesOfString("　", withString: "")
            
            //TODO: 2番目から読み取り開始
            staffarraytmp = staffarray[i]
            if(i < 9){
                position = 1
            }else{
                position = 2
            }
            print(staffarraytmp[staffarraytmp.startIndex.advancedBy(position)])
            //TODO: シフト体制の文字でない限りtmpへの連結を行う
            //TODO: 上記ループを抜けたらシフト体制(holiday)以外であればdayshiftarrayへ記録
            //TODO: 記録したらdaycounterを1アップ
            //TODO: holydayにあった場合は記録をせずdaycounterを上げる
//            print(staffarray[i])
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        return dayshiftarray
    }
}
