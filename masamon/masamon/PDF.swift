//
//  PDF.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/05.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class PDF: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // PDFドキュメントの作成
        let path: NSString
        let url: NSURL
        
        path = NSBundle.mainBundle().pathForResource("sample", ofType: "pdf")!
        url = NSURL(fileURLWithPath: path as String)
        let document = CGPDFDocumentCreateWithURL(url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
