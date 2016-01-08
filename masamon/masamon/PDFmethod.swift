//
//  PDFmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/08.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class PDFmethod: UIViewController {
    
    func AllTextGet(){
        
        var pdftextarray: [String] = []
        
        let path: NSString
        path = NSBundle.mainBundle().pathForResource("sample", ofType: "pdf")!
        
        let tet = TET()
        let document = tet.open_document(path as String, optlist: "")
        
        // print("BBB=>" + String(BBB))
        
        
        let page = tet.open_page(document, pagenumber: 1, optlist: "granularity=page")
        
        //  print("CCC=>" + String(CCC))
        
        
        let pdftext = tet.get_text(page)
        //  print(DDD)
        
        var lineIndex = 1
        
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
        let TEST = 29           //スタッフ人数テスト用変数
        
        pdftext.enumerateLines{
            line, stop in
            
            // if(staffcount <= DBmethod().StaffNumberGet()){
            if(staffcount <= TEST){
                if(nowIndex < lineIndex){      //店長を見つけた行まで進める
                    nowIndex += 1
                }else{
                    let judgehtopcharacter = line.substringToIndex(line.startIndex.successor())
                    
                    if(Int(judgehtopcharacter) != nil){         //先頭文字が数値の場合のみ
                        pdftextarray.append(line)
                        staffcount += 1
                    }
                }
            }else{
                stop = true
            }
        }
        
        for(var i = 0; i < pdftextarray.count; i++){
            //print(pdftextarray[i]+"\n")
        }
        
        print(Shiftmethod().JudgeYearAndMonth(pdftextarray[0]).year)
        print(Shiftmethod().JudgeYearAndMonth(pdftextarray[0]).startcoursmonth)
        print(Shiftmethod().JudgeYearAndMonth(pdftextarray[0]).endcoursmonth)
    }
}
