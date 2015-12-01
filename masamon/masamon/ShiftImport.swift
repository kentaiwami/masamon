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
    let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
    let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
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
            let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
            let filemanager = NSFileManager()
            
            if(filemanager.fileExistsAtPath(Libralypath+"/"+textfield.text!)){       //入力したファイル名が既に存在する場合
                //TODO: アラートを表示して上書きかキャンセルかを選択させる
                let alert:UIAlertController = UIAlertController(title:"取り込みエラー",
                    message: "既に同じファイル名が存在します",
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル",
                    style: UIAlertActionStyle.Cancel,
                    handler:{
                        (action:UIAlertAction!) -> Void in
                        print("Cancel")
                })
                
                let updateAction:UIAlertAction = UIAlertAction(title: "上書き",
                    style: UIAlertActionStyle.Default,
                    handler:{
                        (action:UIAlertAction!) -> Void in
                        print("updateAction")
                })
                
                alert.addAction(cancelAction)
                alert.addAction(updateAction)
                presentViewController(alert, animated: true, completion: nil)
            }else{
                do{
                    try filemanager.moveItemAtPath(Inboxpath+filename, toPath: Libralypath+"/"+textfield.text!)
                    self.InboxFileCountsMinusOne()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    appDelegate.filesavealert = true
                }catch{
                    print(error)
                }
            }
        }else{
            let alertController = UIAlertController(title: "取り込みエラー", message: "ファイル名を入力して下さい", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //キャンセルボタンをタップしたら動作
    @IBAction func cancel(sender: AnyObject) {
        let inboxpath = documentspath + "/Inbox/"   //Inboxまでのパス
        
        //コピーしたファイルの削除
        do{
            try filemanager.removeItemAtPath(inboxpath + filename)
            self.InboxFileCountsMinusOne()
        }catch{
            print(error)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //InboxFileCountsの数を1つ減らす
    func InboxFileCountsMinusOne(){
        let InboxFileCountRecord = InboxFileCount()
        InboxFileCountRecord.id = 0
        InboxFileCountRecord.counts = DBmethod().InboxFileCountsGet()-1
        DBmethod().AddandUpdate(InboxFileCountRecord)
    }
}
