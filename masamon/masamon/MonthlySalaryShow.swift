//
//  ViewController.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: pickerviewのUIを再検討
//TODO: シフトが誰と一緒なのかを表示
//TODO: 今日のシフトは何番なのかを表示
//TODO: ShiftDetailDBにサンプルデータを入れる

import UIKit
import RealmSwift

class MonthlySalaryShow: Menu,UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var testlabel: UILabel!
    let shiftdb = ShiftDB()
    let shiftdetaildb = ShiftDetailDB()
    let shiftlist: NSMutableArray = []
    var myUIPicker: UIPickerView = UIPickerView()
    @IBOutlet weak var SaralyLabel: UILabel!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //アプリがアクティブになったとき
        notificationCenter.addObserver(self,selector: "MonthlySalaryShowViewActived",name:UIApplicationDidBecomeActiveNotification,object: nil)
        
        //print("fileURL=>" + appDelegate.fileURL)
        
//        DBmethod().ShowDBpass()
        self.view.backgroundColor = UIColor.whiteColor()
        shiftdb.id = 1
        shiftdb.name = "2015年8月シフト"
        shiftdb.imagepath = "8月path"
        shiftdb.saraly = 100000
        
        shiftdetaildb.id = 1
        shiftdetaildb.date = "11"
        shiftdetaildb.staff = "A1,B1,C1"
        shiftdetaildb.user = 1
        //DBmethod().add(shiftdb)
        //DBmethod().add(shiftdetaildb)
        
        //PickerViewの追加
        myUIPicker.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 400.0)
        myUIPicker.delegate = self
        myUIPicker.dataSource = self
        self.view.addSubview(myUIPicker)
        
        //NSArrayへの追加
        let newNSArray = shiftlist
        if(DBmethod().DBRecordCount(ShiftDB) != 0){
            for(var i = DBmethod().DBRecordCount(ShiftDB)-1; i >= 0; i--){
                newNSArray.addObject(DBmethod().ShiftDBNameGet(i+1))
            }
            
            //pickerviewのデフォルト表示
            SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示個数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shiftlist.count
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shiftlist[row] as? String
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        print("列: \(row)")
        //        print("値: \(shiftlist[row])")
        SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-row))
    }
    
    //月給表示画面が表示(アプリがアクティブ)されたら呼ばれる
    func MonthlySalaryShowViewActived(){
        print("a")
        //ファイル数のカウント
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath(NSHomeDirectory() + "/Documents/Inbox")
        var filecount = 0
        while let _ = files?.nextObject() {
            filecount++
            print("bbb")
        }

        if(DBmethod().InboxFileCountsGet() < filecount){   //ファイル数が増えていたら(新規でダウンロードしていたら)
            //ファイルの数をデータベースへ記録
            let InboxFileCountRecord = InboxFileCount()
            InboxFileCountRecord.id = 0
            InboxFileCountRecord.counts = filecount
            DBmethod().AddandUpdate(InboxFileCountRecord)
            
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShiftImport")
            self.presentViewController( targetViewController, animated: true, completion: nil)
        }else{
            
        }
    }
}

