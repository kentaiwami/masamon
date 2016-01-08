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
        path = NSBundle.mainBundle().pathForResource("sample", ofType: "pdf")!
        
        let tet = TET()
        let document = tet.open_document(path as String, optlist: "")
        
        // print("BBB=>" + String(BBB))
        
        
        let page = tet.open_page(document, pagenumber: 1, optlist: "granularity=page")
        
        //  print("CCC=>" + String(CCC))
        
        
        let pdftext = tet.get_text(page)
        //  print(DDD)
        
        var lineIndex = 1
        
     //   let skiplineIndexArray = [5,6,7,8,9,10,12,13,14,42,43,44,45,46,47,48]
        
        var judgeheiseifalg = true      //平成を見つけるまでtrue
        
        //１行ごとに文字列を抜き出す
        pdftext.enumerateLines{
            line, stop in
            
            //"平成"が出るまで行読み飛ばしをする
            if(judgeheiseifalg){
                let judgeheisei = line.substringToIndex(line.startIndex.successor().successor())
                
                if(judgeheisei == "平成"){
                    judgeheiseifalg = false
                    print("\(lineIndex) : \(line)")
                }
            }
            
            //"平成"を見つけていたら"店長"が出るまで行読みとばしをする
            if(judgeheiseifalg == false){
                if((line.rangeOfString("店長")) != nil){
                    print("\(lineIndex) : \(line)")
                }
            }
//            print("\(lineIndex) : \(line)")
            
            lineIndex += 1
        }
        
    }
}
