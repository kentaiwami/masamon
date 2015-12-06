//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftImport: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var filenamefield: UITextField!
    @IBOutlet weak var fileimporthistorytable: UITableView!
    
    let filemanager:NSFileManager = NSFileManager()
    let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
    let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    var tableviewcelltext: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "../images/SIbackground.png")!)
        
        //蝶々を設置
        setbutterfly()
        
        //線を引く
        let splitline = UIView()
        splitline.frame = CGRectMake(self.view.frame.width/2-55, self.view.frame.height/2-75, 0.5, 300.0)
        splitline.backgroundColor = UIColor.grayColor()
        splitline.alpha = 0.5
        self.view.addSubview(splitline)
        
        
        //テーブルビューの設定
        fileimporthistorytable.delegate = self
        fileimporthistorytable.dataSource = self
        
        //テキストフィールドの設定
        filenamefield.delegate = self
        filenamefield.returnKeyType = .Done
        
        //テーブルビューに最新順から追加していく
        let importhistoryarray = DBmethod().ShiftImportHistoryDBGet()
        for(var i = importhistoryarray.count-1; i >= 0; i--){
            tableviewcelltext.append(importhistoryarray[i].date + "             " + importhistoryarray[i].name)
        }
        
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
                            
                            ShiftRegister().ShiftDBRegist(self.filenamefield.text!, importpath: self.Libralypath+"/"+self.filenamefield.text!)
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
                    
                    ShiftRegister().ShiftDBRegist(filenamefield.text!, importpath: Libralypath+"/"+filenamefield.text!)
                }catch{
                    print(error)
                }
            }
            //配列の中身を削除してから入れ直す
            tableviewcelltext.removeAll()
            settableviewcell()
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
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableviewcelltext.count
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        if(tableviewcelltext.isEmpty){
            return cell
        }else{
            cell.textLabel?.text = tableviewcelltext[indexPath.row]
            return cell
        }
    }
    
    //テーブルビューの選択を禁止する
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    //テーブルビューのセルに値を設定する
    func settableviewcell(){
        let importhistoryarray = DBmethod().ShiftImportHistoryDBGet()
        for(var i = importhistoryarray.count-1; i >= 0; i--){
            tableviewcelltext.append(importhistoryarray[i].date + "             " + importhistoryarray[i].name)
        }
    }

    func setbutterfly(){
        let imagepath = ["../images/butterfly1.png","../images/butterfly2.png"]
        let position:[[Int]] = [[Int(self.view.frame.width-50),Int(self.view.frame.height/2-120)],[60,Int(self.view.frame.height-40)]]
        let theta = [30.0,-30.0]
        
        //蝶々の設置
        for(var i = 0; i < 2; i++){
            let view = UIImageView()
            let image = UIImage(named: imagepath[i])
            view.image = image
            view.frame = CGRectMake(0, 0, 100, 100)
            view.layer.position = CGPoint(x: position[i][0], y: position[i][1])
            view.contentMode = UIViewContentMode.ScaleAspectFit
            // radianで回転角度を指定(30度)する.
            let angle:CGFloat = CGFloat((theta[i] * M_PI) / 180.0)
            
            // 回転用のアフィン行列を生成する.
            view.transform = CGAffineTransformMakeRotation(angle)
            self.view.addSubview(view)
            
        }
    }
}