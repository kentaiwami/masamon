//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftImport: UIViewController{
    
    @IBOutlet weak var Label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(DBmethod().FilePathTmpGet() == ""){
            Label.text = "nil"
        }else{
            Label.text = DBmethod().FilePathTmpGet() as String
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func ShiftImportViewActived(){
        Label.text = DBmethod().FilePathTmpGet() as String
    }
    
    func xlsximport(sender: UIButton){
        //まだ未定
    }
    
    //メモ: file:///private/var/mobile/Containers/Data/Application/1F4788A9-5CD0-4521-95D4-85272141FBDC/Documents/Inbox/2015CSR_FData-11.xlsx
    
    @IBAction func cancel(sender: AnyObject) {
        //TODO: コピーしたファイルの削除を実装
        let filemanager:NSFileManager = NSFileManager()
        let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let inboxpath = documentspath + "/Inbox/"
        let loc = inboxpath.rangeOfString("Inbox/")

//        print(loc!)
//        print(loc!.startIndex)
//        print(loc!.endIndex)
        
        print(DBmethod().FilePathTmpGet().lastPathComponent)
        
//        print("origin filepath=>" + (DBmethod().FilePathTmpGet() as String))
//        print(filemanager.fileExistsAtPath(inboxpath + "2015CSR_FData-10.xlsx"))
        
        do{
            try filemanager.removeItemAtPath(inboxpath + "2015CSR_FData-10.xlsx")
        }catch{
            print("FileRemove Error")
        }
        self.dismissViewControllerAnimated(true, completion: nil)

    }
}
