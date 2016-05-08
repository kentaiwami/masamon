//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import QuickLook

class ShiftImport: UIViewController,UITextFieldDelegate,QLPreviewControllerDataSource{
    
    @IBOutlet weak var filenamefield: UITextField!
    @IBOutlet weak var lasttimeimportlabel: UILabel!
    
    let filemanager:NSFileManager = NSFileManager()
    let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
    let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "../images/SIbackground.png")!)
        
        //テキストフィールドの設定
        filenamefield.delegate = self
        filenamefield.returnKeyType = .Done
        
        if DBmethod().FilePathTmpGet() != "" {
            filenamefield.text = DBmethod().FilePathTmpGet().lastPathComponent
        }
        
        //QLpreviewを表示させる
        let ql = QLPreviewController()
        ql.dataSource  = self
        ql.view.frame = CGRectMake(0, self.view.frame.height/2-70, self.view.frame.width, 400)
        self.view.addSubview(ql.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //取り込むボタンを押したら動作
    @IBAction func xlsximport(sender: AnyObject) {
        
        //設定が登録されていない場合
        if DBmethod().DBRecordCount(UserNameDB) == 0 {
            let alertController = UIAlertController(title: "取り込みエラー", message: "先に設定画面で情報の登録をして下さい", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        }else{
            //ファイル形式がpdfの場合
            if filename.containsString(".pdf") || filename.containsString(".PDF") {
                if filenamefield.text != "" {
                    let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
                    let filemanager = NSFileManager()
                    
                    if filemanager.fileExistsAtPath(Libralypath+"/"+filenamefield.text!) {       //入力したファイル名が既に存在する場合
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
                                    self.FileSaveAndMove(Inboxpath, update: true)
                                }catch{
                                    print(error)
                                }
                                self.dismissViewControllerAnimated(true, completion: nil)
                        })
                        
                        alert.addAction(cancelAction)
                        alert.addAction(updateAction)
                        presentViewController(alert, animated: true, completion: nil)
                    }else{      //入力したファイル名が被ってない場合
                        self.FileSaveAndMove(Inboxpath, update: false)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }else{
                if filenamefield.text != "" {
                    let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
                    
                    let filemanager = NSFileManager()
                    
                    if filemanager.fileExistsAtPath(Libralypath+"/"+filenamefield.text!) {       //入力したファイル名が既に存在する場合
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
                                    self.FileSaveAndMove(Inboxpath, update: true)
                                }catch{
                                    print(error)
                                }
                                
                                self.dismissViewControllerAnimated(true, completion: nil)
                        })
                        
                        alert.addAction(cancelAction)
                        alert.addAction(updateAction)
                        presentViewController(alert, animated: true, completion: nil)
                    }else{      //入力したファイル名が被ってない場合
                        self.FileSaveAndMove(Inboxpath, update: false)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                }else{      //テキストフィールドが空の場合
                    let alertController = UIAlertController(title: "取り込みエラー", message: "ファイル名を入力して下さい", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    presentViewController(alertController, animated: true, completion: nil)
                }
            }
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
        DBmethod().AddandUpdate(InboxFileCountDBRecord,update: true)
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
        if DBmethod().DBRecordCount(ShiftImportHistoryDB) == 0 {
            ShiftImportHistoryDBRecord.id = 0
        }else{
            ShiftImportHistoryDBRecord.id = DBmethod().DBRecordCount(ShiftImportHistoryDB)
        }
        ShiftImportHistoryDBRecord.date = dateFormatter.stringFromDate(importdate)
        ShiftImportHistoryDBRecord.name = importname
        DBmethod().AddandUpdate(ShiftImportHistoryDBRecord,update: true)
    }
    
    //プレビューでの表示数
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
        return 1
    }
    
    //プレビューで表示するファイルの設定
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem{

        if DBmethod().DBRecordCount(ShiftImportHistoryDB) == 0 {
            lasttimeimportlabel.text = "前回の取り込み: なし"
            let mainbundle = NSBundle.mainBundle()
            let url = mainbundle.pathForResource("no_data", ofType: "png")!
            let doc = NSURL(fileURLWithPath: url)
            return doc
            
        }else{
            let shiftimporthistorylast = DBmethod().ShiftImportHistoryDBLastGet()
            lasttimeimportlabel.text = "前回の取り込み：「" + shiftimporthistorylast.name + "」"
            let url = Libralypath + "/" + shiftimporthistorylast.name
            let doc = NSURL(fileURLWithPath: url)
            return doc
        }
    }
    
    func FileSaveAndMove(Inboxpath: String, update: Bool){
        do{
            try filemanager.moveItemAtPath(Inboxpath+self.filename, toPath: self.Libralypath+"/"+self.filenamefield.text!)

        }catch{
            print(error)
        }
        self.appDelegate.filesavealert = true
        self.appDelegate.filename = self.filenamefield.text!
        self.appDelegate.update = update

        self.InboxFileCountsDBMinusOne()

        //DBへパスを記録
        let filepathrecord = FilePathTmpDB()
        filepathrecord.id = 0
        filepathrecord.path = self.Libralypath+"/"+self.filenamefield.text!
        DBmethod().AddandUpdate(filepathrecord,update: true)
        
        self.ShiftImportHistoryDBadd(NSDate(), importname: self.filenamefield.text!)


    }
}