//
//  PDFmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/08.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class PDFmethod: UIViewController {
    
    func AAA(){
        
        let path: NSString
        path = NSBundle.mainBundle().pathForResource("sample", ofType: "pdf")!
        
        let AAA = TET()
        let BBB = AAA.open_document(path as String, optlist: "")
        
        print("BBB=>" + String(BBB))
        
        
        let CCC = AAA.open_page(BBB, pagenumber: 1, optlist: "granularity=page")
        
        print("CCC=>" + String(CCC))
        
        
        let DDD = AAA.get_text(CCC)
        print(DDD)
    }
}
