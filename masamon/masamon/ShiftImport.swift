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
    
    @IBAction func cancel(sender: AnyObject) {
        let filemanager:NSFileManager = NSFileManager()
        let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let inboxpath = documentspath + "/Inbox/"   //Inboxまでのパス
        let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
        
        //コピーしたファイルの削除
        do{
            try filemanager.removeItemAtPath(inboxpath + filename)
        }catch{
            print("FileRemove Error")
        }
        self.dismissViewControllerAnimated(true, completion: nil)

    }
}
