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
    
    let filemanager:FileManager = FileManager()
    let documentspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let Libralypath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
    let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    var myWebView = UIWebView()
    var myPDFurl =  URL()
    var myRequest = URLRequest()
    var myIndiator = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "../images/SIbackground.png")!)
        
        //テキストフィールドの設定
        filenamefield.delegate = self
        filenamefield.returnKeyType = .done
        staffnumberfield.delegate = self
        staffnumberfield.returnKeyType = .done
        staffnumberfield.keyboardType = .numberPad
        
        if DBmethod().FilePathTmpGet() != "" {
            filenamefield.text = DBmethod().FilePathTmpGet().lastPathComponent
        }
        
        if DBmethod().DBRecordCount(StaffNumberDB) != 0 {
            staffnumberfield.text = String(DBmethod().StaffNumberGet())
        }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let salalyButton = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ShiftImport.TapDoneButton(_:)))

        let numberpadtoolBar = UIToolbar()
        numberpadtoolBar.barStyle = UIBarStyle.default
        numberpadtoolBar.isTranslucent = true
        numberpadtoolBar.sizeToFit()
        numberpadtoolBar.setItems([flexSpace,salalyButton], animated: false)
        numberpadtoolBar.isUserInteractionEnabled = true
        staffnumberfield.inputAccessoryView = numberpadtoolBar
        
        // PDFを開くためのWebViewを生成.
        myWebView = UIWebView(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 400))
        myWebView.delegate = self
        myWebView.scalesPageToFit = true
        
        // URLReqestを生成.
        let documentspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
        let filePath = Inboxpath + filenamefield.text!

        myPDFurl = URL(fileURLWithPath: filePath)
        myRequest = URLRequest(url: myPDFurl)
        
        // ページ読み込み中に表示させるインジケータを生成.
        myIndiator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndiator.center = self.view.center
        myIndiator.hidesWhenStopped = true
        myIndiator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
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
    @IBAction func xlsximport(_ sender: AnyObject) {
        
        //設定が登録されていない場合
        if DBmethod().DBRecordCount(UserNameDB) == 0 || DBmethod().DBRecordCount(HourlyPayDB) == 0 {
            let alertController = UIAlertController(title: "取り込みエラー", message: "先に設定画面で情報の登録をして下さい", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }else{
            //ファイル形式がpdfの場合
            if filename.contains(".pdf") || filename.contains(".PDF") {
                if filenamefield.text != "" {
                    let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
                    let filemanager = FileManager()
                    
                    if filemanager.fileExists(atPath: Libralypath+"/"+filenamefield.text!) {       //入力したファイル名が既に存在する場合
                        //アラートを表示して上書きかキャンセルかを選択させる
                        let alert:UIAlertController = UIAlertController(title:"取り込みエラー",
                            message: "既に同じファイル名が存在します",
                            preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル",
                            style: UIAlertActionStyle.cancel,
                            handler:{
                                (action:UIAlertAction!) -> Void in
                        })
                        let updateAction:UIAlertAction = UIAlertAction(title: "上書き",
                            style: UIAlertActionStyle.default,
                            handler:{
                                (action:UIAlertAction!) -> Void in

                                do{
                                    try filemanager.removeItem(atPath: self.Libralypath+"/"+self.filenamefield.text!)
                                    self.FileSaveAndMove(Inboxpath, update: true)
                                }catch{
                                    print(error)
                                }
                                self.dismiss(animated: true, completion: nil)
                        })
                        
                        alert.addAction(cancelAction)
                        alert.addAction(updateAction)
                        present(alert, animated: true, completion: nil)
                    }else{      //入力したファイル名が被ってない場合
                        self.FileSaveAndMove(Inboxpath, update: false)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }else{
                if filenamefield.text != "" {
                    let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
                    
                    let filemanager = FileManager()
                    
                    if filemanager.fileExists(atPath: Libralypath+"/"+filenamefield.text!) {       //入力したファイル名が既に存在する場合
                        //アラートを表示して上書きかキャンセルかを選択させる
                        let alert:UIAlertController = UIAlertController(title:"取り込みエラー",
                            message: "既に同じファイル名が存在します",
                            preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル",
                            style: UIAlertActionStyle.cancel,
                            handler:{
                                (action:UIAlertAction!) -> Void in
                        })
                        let updateAction:UIAlertAction = UIAlertAction(title: "上書き",
                            style: UIAlertActionStyle.default,
                            handler:{
                                (action:UIAlertAction!) -> Void in

                                do{
                                    try filemanager.removeItem(atPath: self.Libralypath+"/"+self.filenamefield.text!)
                                    self.FileSaveAndMove(Inboxpath, update: true)
                                }catch{
                                    print(error)
                                }
                                
                                self.dismiss(animated: true, completion: nil)
                        })
                        
                        alert.addAction(cancelAction)
                        alert.addAction(updateAction)
                        present(alert, animated: true, completion: nil)
                    }else{      //入力したファイル名が被ってない場合
                        self.FileSaveAndMove(Inboxpath, update: false)
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }else{      //テキストフィールドが空の場合
                    let alertController = UIAlertController(title: "取り込みエラー", message: "ファイル名を入力して下さい", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    //キャンセルボタンをタップしたら動作
    @IBAction func cancel(_ sender: AnyObject) {
        let inboxpath = documentspath + "/Inbox/"   //Inboxまでのパス
        
        //コピーしたファイルの削除
        do{
            try filemanager.removeItem(atPath: inboxpath + filename)
            DBmethod().InitRecordInboxFileCountDB()
        }catch{
            print(error)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //キーボードの完了(改行)を押したらキーボードを閉じる
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return true
    }
        
    func startAnimation() {
        
        // NetworkActivityIndicatorを表示.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // UIACtivityIndicatorを表示.
        if !myIndiator.isAnimating {
            myIndiator.startAnimating()
        }
        
        // viewにインジケータを追加.
        self.view.addSubview(myIndiator)
    }
    
    func stopAnimation() {
        // NetworkActivityIndicatorを非表示.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // UIACtivityIndicatorを非表示.
        if myIndiator.isAnimating {
            myIndiator.stopAnimating()
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        startAnimation()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        stopAnimation()
    }
    
    func FileSaveAndMove(_ Inboxpath: String, update: Bool){
        do{
            try filemanager.moveItem(atPath: Inboxpath+self.filename, toPath: self.Libralypath+"/"+self.filenamefield.text!)

        }catch{
            print(error)
        }
        self.appDelegate.filesavealert = true
        self.appDelegate.filename = self.filenamefield.text!
        self.appDelegate.update = update

        DBmethod().InitRecordInboxFileCountDB()

        //DBへパスを記録
        let filepathrecord = FilePathTmpDB()
        filepathrecord.id = 0
        filepathrecord.path = self.Libralypath+"/"+self.filenamefield.text!
        DBmethod().AddandUpdate(filepathrecord,update: true)
    }
    
    func TapDoneButton(_ sender: UIButton){
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
