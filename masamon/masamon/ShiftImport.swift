//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftImport: UIViewController,UITextFieldDelegate,UIWebViewDelegate{
    
    @IBOutlet weak var filenamefield: UITextField!
    @IBOutlet weak var staffnumberfield: UITextField!
    @IBOutlet weak var quickfilelabel: UILabel!
    @IBOutlet weak var StaffNumberLabel: UILabel!
    
    let filemanager:NSFileManager = NSFileManager()
    let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
    let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    var myWebView = UIWebView()
    var myPDFurl =  NSURL()
    var myRequest = NSURLRequest()
    var myIndiator = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "../images/SIbackground.png")!)
        
        //テキストフィールドの設定
        filenamefield.delegate = self
        filenamefield.returnKeyType = .Done
        staffnumberfield.delegate = self
        staffnumberfield.returnKeyType = .Done
        staffnumberfield.keyboardType = .NumberPad
        
        if DBmethod().FilePathTmpGet() != "" {
            filenamefield.text = DBmethod().FilePathTmpGet().lastPathComponent
        }
        
        if DBmethod().DBRecordCount(StaffNumberDB) != 0 {
            staffnumberfield.text = String(DBmethod().StaffNumberGet())
        }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let salalyButton = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ShiftImport.TapDoneButton(_:)))

        let numberpadtoolBar = UIToolbar()
        numberpadtoolBar.barStyle = UIBarStyle.Default
        numberpadtoolBar.translucent = true
        numberpadtoolBar.sizeToFit()
        numberpadtoolBar.setItems([flexSpace,salalyButton], animated: false)
        numberpadtoolBar.userInteractionEnabled = true
        staffnumberfield.inputAccessoryView = numberpadtoolBar
        
        // PDFを開くためのWebViewを生成.
        myWebView = UIWebView(frame: CGRectMake(0, self.view.frame.height/2, self.view.frame.width, 400))
        myWebView.delegate = self
        myWebView.scalesPageToFit = true
        
        // URLReqestを生成.
        let documentspath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
        let filePath = Inboxpath + filenamefield.text!

        myPDFurl = NSURL.fileURLWithPath(filePath)
        myRequest = NSURLRequest(URL: myPDFurl)
        
        // ページ読み込み中に表示させるインジケータを生成.
        myIndiator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        myIndiator.center = self.view.center
        myIndiator.hidesWhenStopped = true
        myIndiator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // WebViewのLoad開始.
        myWebView.loadRequest(myRequest)
        
        // viewにWebViewを追加.
        self.view.addSubview(myWebView)

        
        quickfilelabel.text = "取り込み予定のファイル"
        StaffNumberLabel.text = "スタッフ人数"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //取り込むボタンを押したら動作
    @IBAction func xlsximport(sender: AnyObject) {
        
        //設定が登録されていない場合
        if DBmethod().DBRecordCount(UserNameDB) == 0 || DBmethod().DBRecordCount(HourlyPayDB) == 0 {
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
        
    func startAnimation() {
        
        // NetworkActivityIndicatorを表示.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // UIACtivityIndicatorを表示.
        if !myIndiator.isAnimating() {
            myIndiator.startAnimating()
        }
        
        // viewにインジケータを追加.
        self.view.addSubview(myIndiator)
    }
    
    func stopAnimation() {
        // NetworkActivityIndicatorを非表示.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // UIACtivityIndicatorを非表示.
        if myIndiator.isAnimating() {
            myIndiator.stopAnimating()
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        startAnimation()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        stopAnimation()
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
    }
    
    func TapDoneButton(sender: UIButton){
        //スタッフ人数に値が入っていれば上書きする
        if staffnumberfield.text != "" {
            let staffnumberrecord = StaffNumberDB()
            staffnumberrecord.id = 0
            staffnumberrecord.number = Int(staffnumberfield.text!)!
            DBmethod().AddandUpdate(staffnumberrecord, update: true)
        }

        staffnumberfield.resignFirstResponder()
    }
}
