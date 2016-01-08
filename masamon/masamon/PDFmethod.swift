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
        
        let path: NSString
        path = NSBundle.mainBundle().pathForResource("sample2", ofType: "pdf")!
        
        let tet = TET()
        let document = tet.open_document(path as String, optlist: "")
        
        // print("BBB=>" + String(BBB))
        
        
        let page = tet.open_page(document, pagenumber: 1, optlist: "granularity=page")
        
        //  print("CCC=>" + String(CCC))
        
        
        let pdftext = tet.get_text(page)
        //  print(DDD)
        
        var lineIndex = 1
        
        //   let skiplineIndexArray = [5,6,7,8,9,10,12,13,14,42,43,44,45,46,47,48]
        
        
        //"平成"が出るまで1行ずつ読み飛ばしをする
        pdftext.enumerateLines{
            line, stop in
            
            let judgeheisei = line.substringToIndex(line.startIndex.successor().successor())
            
            if(judgeheisei == "平成"){
                print("\(lineIndex) : \(line)")
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
                    print("\(lineIndex) : \(line)")
                    lineIndex = nowIndex
                    stop = true
                }else{
                    nowIndex += 1
                }
            }
        }

        //"2"が出るまで1行ずつ読みとばしをする(店長の次に現れるスタッフは先頭文字が2のため)
        nowIndex = 0
        
        pdftext.enumerateLines{
            line, stop in
            
            if(nowIndex < lineIndex){      //店長を見つけた行まで進める
                nowIndex += 1
            }else{
                let judgehtopcharacter = line.substringToIndex(line.startIndex.successor())
                
                if(judgehtopcharacter == "2"){
                    print("\(lineIndex) : \(line)")
                    stop = true
                }else{
                    nowIndex += 1
                }
            }
        }
        
        //"2"が出た後はスタッフの数だけ行数を取り込む
        
    }
}
