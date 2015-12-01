//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftImport: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var filenamefield: UITextField!
    @IBOutlet weak var fileimporthistoryview: UITextView!
    
    let filemanager:NSFileManager = NSFileManager()
    let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
    let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    let backgournd = UIImageView()
    let backgourndimage = UIImage(named: "../images/SIbackgournd.jpeg")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テキストフィールドの設定
        filenamefield.delegate = self
        filenamefield.returnKeyType = .Done
        
        //テキストビューの編集を無効化
        fileimporthistoryview.editable = false
        
        showhistory()
        
        backgournd.image = backgourndimage
        backgournd.frame = CGRectMake(0.0, 65.0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(backgournd)
        self.view.sendSubviewToBack(backgournd)
        
        if(DBmethod().FilePathTmpGet() != ""){
            filenamefield.text = DBmethod().FilePathTmpGet().lastPathComponent
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //取り込むボタンを押したら動作
    @IBAction func xlsximport(sender: AnyObject) {
        if(filenamefield.text != ""){
            let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
            let filemanager = NSFileManager()
            
            if(filemanager.fileExistsAtPath(Libralypath+"/"+filenamefield.text!)){       //入力したファイル名が既に存在する場合
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
                            try filemanager.removeItemAtPath(self.Libralypath+"/"+self.filenamefield.text!)
                            try filemanager.moveItemAtPath(Inboxpath+self.filenamefield.text!, toPath: self.Libralypath+"/"+self.filenamefield.text!)
                            self.InboxFileCountsDBMinusOne()
                            self.dismissViewControllerAnimated(true, completion: nil)
                            self.appDelegate.filesavealert = true
                            self.ShiftImportHistoryDBadd(NSDate(), importname: self.filenamefield.text!)
                        }catch{
                            print(error)
                        }
                })
                
                alert.addAction(cancelAction)
                alert.addAction(updateAction)
                presentViewController(alert, animated: true, completion: nil)
            }else{      //入力したファイル名が被ってない場合
                do{
                    try filemanager.moveItemAtPath(Inboxpath+filename, toPath: Libralypath+"/"+filenamefield.text!)
                    self.InboxFileCountsDBMinusOne()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    appDelegate.filesavealert = true
                    ShiftImportHistoryDBadd(NSDate(), importname: filenamefield.text!)
                }catch{
                    print(error)
                }
            }
            self.showhistory()
            
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
            self.InboxFileCountsDBMinusOne()
        }catch{
            print(error)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //InboxFileCountsの数を1つ減らす
    func InboxFileCountsDBMinusOne(){
        let InboxFileCountDBRecord = InboxFileCountDB()
        InboxFileCountDBRecord.id = 0
        InboxFileCountDBRecord.counts = DBmethod().InboxFileCountsGet()-1
        DBmethod().AddandUpdate(InboxFileCountDBRecord)
    }
    
    //キーボードの完了(改行)を押したらキーボードを閉じる
    func textFieldShouldReturn(textfield: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return true
    }
    
    //取り込み履歴を追加する
    func ShiftImportHistoryDBadd(importdate: NSDate, importname: String){
        //日付のフォーマットを設定
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        //取り込み履歴へのレコード追加
        let ShiftImportHistoryDBRecord = ShiftImportHistoryDB()
        if(DBmethod().DBRecordCount(ShiftImportHistoryDB) == 0){
            ShiftImportHistoryDBRecord.id = 0
        }else{
            ShiftImportHistoryDBRecord.id = DBmethod().DBRecordCount(ShiftImportHistoryDB)
        }
        ShiftImportHistoryDBRecord.date = dateFormatter.stringFromDate(importdate)
        ShiftImportHistoryDBRecord.name = importname
        DBmethod().AddandUpdate(ShiftImportHistoryDBRecord)        
    }
    
    func showhistory(){
        //履歴の表示
        let importhistoryarray = DBmethod().ShiftImportHistoryDBGet()
        for(var i = importhistoryarray.count-1; i >= 0; i--){
            fileimporthistoryview.text = fileimporthistoryview.text + importhistoryarray[i].date + "             " + importhistoryarray[i].name + "\n"
        }

    }
}
