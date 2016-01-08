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
        
        //        let text: String = "hogehoge\npiyopiyp\nfugafuga"
        
        var lineIndex = 1
        
        let skiplineIndexArray = [1,2,3]
        
        //１行ごとに文字列を抜き出す
        pdftext.enumerateLines{
            line, stop in
            
            if(skiplineIndexArray.contains(lineIndex) != true){          //skiplineIndexArrayに含まれていなければ処理をする
                print("\(lineIndex) : \(line)")
            }
            lineIndex += 1
        }
        
    }
}
