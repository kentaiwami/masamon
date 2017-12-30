//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import Eureka

class ShiftImport: FormViewController, UIWebViewDelegate{
    
    let filemanager:FileManager = FileManager()
    let documentspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let Libralypath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
    let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var myWebView = UIWebView()
    var myIndiator = UIActivityIndicatorView()

    var filename_new = ""
    var staff_count_new = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーの設定
        let cancel_button = UIBarButtonItem(image: UIImage(named: "icon_cancel"), style: .plain, target: self, action: #selector(self.TapCancelButton(sender:)))
        let do_import_button = UIBarButtonItem(image: UIImage(named: "icon_import"), style: .plain, target: self, action: #selector(self.TapDoImportButton(sender:)))
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.setLeftBarButton(cancel_button, animated: true)
        self.navigationItem.setRightBarButton(do_import_button, animated: true)
        
        
        if DBmethod().FilePathTmpGet() != "" {
            filename_new = DBmethod().FilePathTmpGet().lastPathComponent
        }
        
        if DBmethod().DBRecordCount(StaffNumberDB.self) != 0 {
            staff_count_new = DBmethod().StaffNumberGet()
        }
        
        CreateForm()
        
        // PDFを開くためのWebViewを生成.
        myWebView = UIWebView(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 400))
        myWebView.delegate = self
        myWebView.scalesPageToFit = true
        
        // URLReqestを生成.
        let documentspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let Inboxpath = documentspath + "/Inbox/"
        let filePath = Inboxpath + filename_new

//        let myPDFurl = URL(fileURLWithPath: filePath)
//        let myRequest = URLRequest(url: myPDFurl)
        
        // ページ読み込み中に表示させるインジケータを生成.
//        myIndiator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//        myIndiator.center = self.view.center
//        myIndiator.hidesWhenStopped = true
//        myIndiator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        // WebViewのLoad開始.
//        myWebView.loadRequest(myRequest)
        
        // viewにWebViewを追加.
//        self.view.addSubview(myWebView)
    }
    
    func CreateForm() {
        let RuleRequired_M = "必須項目です"
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        form +++ Section()
            <<< TextRow() {
                $0.title = "ファイル名"
                $0.value = filename_new
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "name"
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = RuleRequired_M
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            
            
            <<< IntRow(){
                $0.title = "従業員の人数"
                $0.value = staff_count_new
                $0.tag = "count"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = RuleRequired_M
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
        }
    }
    
    @objc func TapCancelButton(sender: UIButton) {
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
    
    @objc func TapDoImportButton(sender: UIButton) {
        var err_count = 0
        for row in form.allRows {
            err_count = row.validate().count
        }
        
        if err_count == 0 {
            if DBmethod().DBRecordCount(UserNameDB.self) == 0 || DBmethod().DBRecordCount(HourlyPayDB.self) == 0 {
                self.present(Utility().GetStandardAlert(title: "エラー", message: "先に設定画面で情報の登録をして下さい", b_title: "OK"),animated: true, completion: nil)
            }else {
                DoImport()
            }
        }else {
            self.present(Utility().GetStandardAlert(title: "エラー", message: "必須項目を入力してください", b_title: "OK"),animated: true, completion: nil)
        }
    }
    
    func DoImport() {
        //DBにスタッフの人数を保存
        let staff_count = form.values()["count"] as! Int
        let staffnumberrecord = StaffNumberDB()
        staffnumberrecord.id = 0
        staffnumberrecord.number = staff_count
        DBmethod().AddandUpdate(staffnumberrecord, update: true)
        
        //ファイル名を更新
        filename_new = form.values()["name"] as! String
        
        //ファイル形式がpdfの場合
        if filename.contains(".pdf") || filename.contains(".PDF") {
            if filename_new != "" {
                let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
                let filemanager = FileManager()
                
                if filemanager.fileExists(atPath: Libralypath+"/"+filename_new) {       //入力したファイル名が既に存在する場合
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
                                                                        try filemanager.removeItem(atPath: self.Libralypath+"/"+self.filename_new)
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
            if filename_new != "" {
                let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
                
                let filemanager = FileManager()
                
                if filemanager.fileExists(atPath: Libralypath+"/"+filename_new) {       //入力したファイル名が既に存在する場合
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
                                                                        try filemanager.removeItem(atPath: self.Libralypath+"/"+self.filename_new)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            try filemanager.moveItem(atPath: Inboxpath+self.filename, toPath: self.Libralypath+"/"+filename_new)

        }catch{
            print(error)
        }
        self.appDelegate.filesavealert = true
        self.appDelegate.filename = filename_new
        self.appDelegate.update = update

        DBmethod().InitRecordInboxFileCountDB()

        //DBへパスを記録
        let filepathrecord = FilePathTmpDB()
        filepathrecord.id = 0
        filepathrecord.path = self.Libralypath+"/"+filename_new as NSString
        DBmethod().AddandUpdate(filepathrecord,update: true)
    }
}
