//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftImport: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var textfield: UITextField!
    
    let filemanager:NSFileManager = NSFileManager()
    let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
    let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    let backgournd = UIImageView()
    let backgourndimage = UIImage(named: "../images/SIbackgournd.jpeg")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textfield.delegate = self
        textfield.returnKeyType = .Done
        
        backgournd.image = backgourndimage
        backgournd.frame = CGRectMake(0.0, 65.0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(backgournd)
        self.view.sendSubviewToBack(backgournd)
        
        if(DBmethod().FilePathTmpGet() != ""){
            textfield.text = DBmethod().FilePathTmpGet().lastPathComponent
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //取り込むボタンを押したら動作
    @IBAction func xlsximport(sender: AnyObject) {
        if(textfield.text != ""){
            let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
            let filemanager = NSFileManager()
            
            if(filemanager.fileExistsAtPath(Libralypath+"/"+textfield.text!)){       //入力したファイル名が既に存在する場合
                //アラートを表示して上書きかキャンセルかを選択させる
                let alert:UIAlertController = UIAlertController(title:"取り込みエラー",
                    message: "既に同じファイル名が存在します",
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル",
                    style: UIAlertActionStyle.Cancel,
                    handler:{
                        (action:UIAlertAction!) -> Void in
                })
                let updateAction:UIAlertAction = UIAlertAction(title: "上書き",
                    style: UIAlertActionStyle.Default,
                    handler:{
                        (action:UIAlertAction!) -> Void in
                        do{
                            try filemanager.removeItemAtPath(self.Libralypath+"/"+self.textfield.text!)
                            try filemanager.moveItemAtPath(Inboxpath+self.textfield.text!, toPath: self.Libralypath+"/"+self.textfield.text!)
                            self.InboxFileCountsMinusOne()
                            self.dismissViewControllerAnimated(true, completion: nil)
                            self.appDelegate.filesavealert = true
                        }catch{
                            print(error)
                        }
                })
                
                alert.addAction(cancelAction)
                alert.addAction(updateAction)
                presentViewController(alert, animated: true, completion: nil)
            }else{      //入力したファイル名が被ってない場合
                do{
                    try filemanager.moveItemAtPath(Inboxpath+filename, toPath: Libralypath+"/"+textfield.text!)
                    self.InboxFileCountsMinusOne()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    appDelegate.filesavealert = true
                }catch{
                    print(error)
                }
            }
        }else{      //テキストフィールドが空の場合
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
    
    func textFieldShouldReturn(aaa: UITextField) -> Bool {
        aaa.resignFirstResponder()
        return true
    }
}
