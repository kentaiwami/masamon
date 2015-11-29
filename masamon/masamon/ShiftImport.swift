//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftImport: UIViewController{

    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var Label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        //アプリがアクティブになったとき
        notificationCenter.addObserver(self,selector: "ShiftImportViewActived",name:UIApplicationDidBecomeActiveNotification,object: nil)
        
        if(DBmethod().FilePathTmpGet().isEmpty){
            Label.text = "nil"
        }else{
            Label.text = DBmethod().FilePathTmpGet()
        }
        
        
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "取り込む", style: UIBarButtonItemStyle.Plain, target: self, action: "xlsximport:")
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel:")
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        self.navigationItem.setRightBarButtonItems([rightBarButtonItem], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func ShiftImportViewActived(){
        Label.text = DBmethod().FilePathTmpGet()
    }
    
    func xlsximport(sender: UIButton){
        
    }
    
    func cancel(sender: UIButton){
        
    }
}
