//
//  FileBrowse.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/05/06.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import QuickLook

class FileBrowse: UIViewController, QLPreviewControllerDataSource{

    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ql = QLPreviewController()
        ql.dataSource = self
        
        ql.view.frame = CGRectMake(0, 64, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(ql.view)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.title = appDelegate.selectedcellname
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {

        let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
        let filePath = Libralypath + "/" + appDelegate.selectedcellname
        
        let doc = NSURL(fileURLWithPath: filePath)
        return doc
    }

    @IBAction func TapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
