//
//  ViewController.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class MonthlySalaryShow: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var testlabel: UILabel!
    let shiftdb = ShiftDB()
    let shiftdetaildb = ShiftDetailDB()
    var shiftlist: NSMutableArray = []
    var myUIPicker: UIPickerView = UIPickerView()
    @IBOutlet weak var SaralyLabel: UILabel!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    let alertview = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        NSTimer.scheduledTimerWithTimeInterval(1.0,target:self,selector:Selector("FileSaveSuccessfulAlertShow"),
            userInfo: nil, repeats: true);
        
        //アプリがアクティブになったとき
        notificationCenter.addObserver(self,selector: "MonthlySalaryShowViewActived",name:UIApplicationDidBecomeActiveNotification,object: nil)
        
        //print("fileURL=>" + appDelegate.fileURL)
        
        //        DBmethod().ShowDBpass()
        
        //PickerViewの追加
        myUIPicker.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 150.0)
        myUIPicker.delegate = self
        myUIPicker.dataSource = self
        self.view.addSubview(myUIPicker)
        
        //NSArrayへの追加
//        shiftlist = DBmethod().ShiftDBGet()
        if(DBmethod().DBRecordCount(ShiftDB) != 0){
            for(var i = DBmethod().DBRecordCount(ShiftDB)-1; i >= 0; i--){
                shiftlist.addObject(DBmethod().ShiftDBGet(i))
            }
            
            //pickerviewのデフォルト表示
//            SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //pickerviewの属性表示に関する関数
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: shiftlist[row] as! String, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        return attributedString
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示個数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shiftlist.count
    }
    
//    //表示内容
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return shiftlist[row] as? String
//    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        print("列: \(row)")
        //        print("値: \(shiftlist[row])")
       // SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-row))
    }
    
    //月給表示画面が表示(アプリがアクティブ)されたら呼ばれる
    func MonthlySalaryShowViewActived(){
        
        //ファイル数のカウント
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath(NSHomeDirectory() + "/Documents/Inbox")
        var filecount = 0
        while let _ = files?.nextObject() {
            filecount++
        }
        
        if(DBmethod().InboxFileCountsGet() < filecount){   //ファイル数が増えていたら(新規でダウンロードしていたら)
            //ファイルの数をデータベースへ記録
            let InboxFileCountRecord = InboxFileCountDB()
            InboxFileCountRecord.id = 0
            InboxFileCountRecord.counts = filecount
            DBmethod().AddandUpdate(InboxFileCountRecord,update: true)
            
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShiftImport")
            self.presentViewController( targetViewController, animated: true, completion: nil)
        }else{
            
        }
    }
    
    //チェックマークを表示するアニメーション
    func CheckMarkAnimation(){
        let image = UIImage(named: "../images/check.png")
        alertview.image = image
        let alertwidth = 140.0
        let alertheight = 140.0
        alertview.frame = CGRectMake(self.view.frame.width/2-CGFloat(alertwidth)/2, self.view.frame.height/2-CGFloat(alertheight)/2, CGFloat(alertwidth), CGFloat(alertheight))
        alertview.alpha = 0.0
        
        view.addSubview(alertview)
        
        //表示アニメーション
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alertview.frame = CGRectMake(self.view.frame.width/2-CGFloat(alertwidth)/2, self.view.frame.height/2-CGFloat(alertheight)/2, CGFloat(alertwidth), CGFloat(alertheight))
            self.alertview.alpha = 1.0
        })
        
        //消すアニメーション
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.alertview.alpha = 0.0
        })

    }
    
    
    func FileSaveSuccessfulAlertShow(){
        //ファイルの保存が成功していたら
        if(appDelegate.filesavealert){
            self.CheckMarkAnimation()
            appDelegate.filesavealert = false
        }
    }
}

