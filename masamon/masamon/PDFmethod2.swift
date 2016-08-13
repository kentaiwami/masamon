//
//  PDFmethod2.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/08/13.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

//pdfから抽出したテキスト情報を格納するクラス
class CharInfo {
    var text = ""
    var x = 0.0
    var y = 0.0
    var size = 0.0
}

class PDFmethod2 {
    
    let tolerance = 3.0                         //同じ行と判定させるための許容誤差
    
    /****************************pdfのテキスト情報を2次元配列に行ごとに格納する******************************/
    func GetPDFGlyphInfo() -> [[CharInfo]] {
        var charinfoArray: [[CharInfo]] = []
        var prev_y = -99.99
        var currentArrayIndex = -1

        let path: NSString
        //path = DBmethod().FilePathTmpGet()
        path = NSBundle.mainBundle().pathForResource("7.11〜", ofType: "pdf")!
        
        let tet = TET()
        let document = tet.open_document(path as String, optlist: "")
        let page = tet.open_page(document, pagenumber: 1, optlist: "granularity=glyph")
        var text = tet.get_text(page)
        
        //全テキストを検査するループ
        while(text != nil && text.characters.count > 0){
//            print("[" + text + "]")
            while(tet.get_char_info(page) > 0){
//                print("size=" + String(tet.fontsize()) + " x=" + String(tet.x()) + " y=" + String(tet.y()))
                
                let charinfo = CharInfo()
                charinfo.text = text
                charinfo.size = tet.fontsize()
                charinfo.x = tet.x()
                charinfo.y = tet.y()
                
                if !(prev_y-tolerance...prev_y+tolerance ~= tet.y()) {
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
}
