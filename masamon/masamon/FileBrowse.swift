//
//  FileBrowseViewController.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/05/06.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import QuickLook

class FileBrowse: UIViewController, QLPreviewControllerDataSource{

    override func viewDidLoad() {
        super.viewDidLoad()

        let ql = QLPreviewController()
        ql.dataSource = self
        
        presentViewController(ql, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let mainbundle = NSBundle.mainBundle()
        let url = mainbundle.pathForResource("sampleshift", ofType: "pdf")!

        let doc = NSURL(fileURLWithPath: url)
        return doc
    }
}
