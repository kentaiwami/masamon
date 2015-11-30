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
    @IBOutlet weak var textfield: UITextField!

    let filemanager:NSFileManager = NSFileManager()
    let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(DBmethod().FilePathTmpGet() != ""){
            Label.text = DBmethod().FilePathTmpGet() as String
            textfield.text = DBmethod().FilePathTmpGet().lastPathComponent
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func ShiftImportViewActived(){
        Label.text = DBmethod().FilePathTmpGet() as String
    }
    
    //取り込むボタンを押したら動作
    @IBAction func xlsximport(sender: AnyObject) {
        if(textfield.text != ""){
            let inboxpath = documentspath + "/Inbox/"   //Inboxまでのパス
            let filemanager = NSFileManager()
            
            do{
                try filemanager.moveItemAtPath(inboxpath+filename, toPath: inboxpath+textfield.text!)
            }catch{
                print(error)
            }
            
        }else{
            let alertController = UIAlertController(title: "取り込みエラー", message: "ファイル名を入力して下さい", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        //TODO: 抽出したファイル名で保存しなおす(rename)
        //TODO: 画面を閉じる
        //TODO: うすく表示するアラートを表示
        //TODO: アラートを消す
    }
    
    //キャンセルボタンをタップしたら動作
    @IBAction func cancel(sender: AnyObject) {
        let inboxpath = documentspath + "/Inbox/"   //Inboxまでのパス
        
        //コピーしたファイルの削除
        do{
            try filemanager.removeItemAtPath(inboxpath + filename)
            //データベースに記録しているファイル数を1減らして更新
            let InboxFileCountRecord = InboxFileCount()
            InboxFileCountRecord.id = 0
            InboxFileCountRecord.counts = DBmethod().InboxFileCountsGet()-1
            DBmethod().AddandUpdate(InboxFileCountRecord)
        }catch{
            print(error)
        }
        self.dismissViewControllerAnimated(true, completion: nil)

    }
}
