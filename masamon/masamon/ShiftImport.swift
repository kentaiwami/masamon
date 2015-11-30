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
    
    //取り込むボタンを押したら動作
    @IBAction func xlsximport(sender: AnyObject) {
        //TODO: 画面を閉じる
        //TODO: うすく表示するアラートを表示
        //TODO: アラートを消す
    }
    
    //キャンセルボタンをタップしたら動作
    @IBAction func cancel(sender: AnyObject) {
        let filemanager:NSFileManager = NSFileManager()
        let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let inboxpath = documentspath + "/Inbox/"   //Inboxまでのパス
        let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
        
        //コピーしたファイルの削除
        do{
            try filemanager.removeItemAtPath(inboxpath + filename)
            //データベースに記録しているファイル数を1減らして更新
            let InboxFileCountRecord = InboxFileCount()
            InboxFileCountRecord.id = 0
            InboxFileCountRecord.counts = DBmethod().InboxFileCountsGet()-1
            DBmethod().AddandUpdate(InboxFileCountRecord)
        }catch{
            print("FileRemove Error")
        }
        self.dismissViewControllerAnimated(true, completion: nil)

    }
}
