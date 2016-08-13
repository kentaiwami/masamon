//
//  PDFmethod2.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/08/13.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class PDFmethod2: UIViewController {
    
    func GetPDFGlyphInfo() -> String {
        let path: NSString
        //path = DBmethod().FilePathTmpGet()
        path = NSBundle.mainBundle().pathForResource("sampleshift", ofType: "pdf")!
        
        let tet = TET()
        let document = tet.open_document(path as String, optlist: "")
        let page = tet.open_page(document, pagenumber: 1, optlist: "granularity=word")
        var text = tet.get_text(page)
        
        //全テキストを検査するループ
        while(text != nil && text.characters.count > 0){
            print("[" + text + "]")
            while(tet.get_char_info(page) > 0){
                print("size=" + String(tet.fontsize()) + " x=" + String(tet.x()) + " y=" + String(tet.y()))
            }
            text = tet.get_text(page)
        }
        
        tet.close_page(page)
        tet.close_document(document)

        
        return "hoge"
    }
}
