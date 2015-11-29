//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftImport: Menu{

    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var Label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        //アプリがアクティブになったとき
        notificationCenter.addObserver(self,selector: "ShiftImportViewActived",name:UIApplicationDidBecomeActiveNotification,object: nil)
        
        print("[ShiftImport]   " + "PATH=>" + DBmethod().FilePathTmpGet())
        
        if(DBmethod().FilePathTmpGet().isEmpty){
            Label.text = "nil"
        }else{
            Label.text = DBmethod().FilePathTmpGet()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func ShiftImportViewActived(){
        Label.text = DBmethod().FilePathTmpGet()
    }
}
