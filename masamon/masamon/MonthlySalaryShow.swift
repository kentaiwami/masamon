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
    
    @IBOutlet weak var CalenderLabel: UILabel!
    @IBOutlet weak var EarlyShiftText: UITextView!
    @IBOutlet weak var Center1ShiftText: UITextView!
    @IBOutlet weak var Center2ShiftText: UITextView!
    @IBOutlet weak var Center3ShiftText: UITextView!
    @IBOutlet weak var LateShiftText: UITextView!
    
    let shiftdb = ShiftDB()
    let shiftdetaildb = ShiftDetailDB()
    var shiftlist: NSMutableArray = []
    var myUIPicker: UIPickerView = UIPickerView()
    @IBOutlet weak var SaralyLabel: UILabel!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    let alertview = UIImageView()
    let iconnamearray = ["../images/work.png","../images/salaly.png"]
    let iconpositionarray = [15,200]
    let calenderbuttonposition = [15,315]
    let calenderbuttonnamearray = ["../images/backday.png","../images/nextday.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //今日の日付を表示
        self.NowDateShow()
        
        if(DBmethod().TheDayStaffGet(27, month: 12, date: 10) == nil){
            EarlyShiftText.text = "早番：データなし"
            Center1ShiftText.text = "中1：データなし"
            Center2ShiftText.text = "中2：データなし"
            Center3ShiftText.text = "中3：データなし"
            LateShiftText.text = "遅番：データなし"
        }else{
            let AAA = DBmethod().TheDayStaffGet(27, month: 12, date: 10)
            EarlyShiftText.text = AAA![0].staff
            Center1ShiftText.text = "中1：データなし"
            Center2ShiftText.text = "中2：データなし"
            Center3ShiftText.text = "中3：データなし"
            LateShiftText.text = "遅番：データなし"
        }

        //アイコンとボタンの設置
        for(var i = 0; i < 2; i++){
            let imageview = UIImageView()
            imageview.image = UIImage(named: iconnamearray[i])
            imageview.frame = CGRectMake(CGFloat(iconpositionarray[i]), 20, 42, 40)
            self.view.addSubview(imageview)
            
            let calenderbutton = UIButton()
            calenderbutton.setImage(UIImage(named: calenderbuttonnamearray[i]), forState: .Normal)
            calenderbutton.frame = CGRectMake(CGFloat(calenderbuttonposition[i]), 555, 42, 40)
            calenderbutton.addTarget(self, action: "TapCalenderButton:", forControlEvents: .TouchUpInside)
            calenderbutton.tag = i
            self.view.addSubview(calenderbutton)
        }
        
        NSTimer.scheduledTimerWithTimeInterval(1.0,target:self,selector:Selector("FileSaveSuccessfulAlertShow"),
            userInfo: nil, repeats: true);
        
        //アプリがアクティブになったとき
        notificationCenter.addObserver(self,selector: "MonthlySalaryShowViewActived",name:UIApplicationDidBecomeActiveNotification,object: nil)
        
        //PickerViewの追加
        myUIPicker.frame = CGRectMake(-20,10,self.view.bounds.width/2+20, 150.0)
        myUIPicker.delegate = self
        myUIPicker.dataSource = self
        self.view.addSubview(myUIPicker)
        
        //NSArrayへの追加
        if(DBmethod().DBRecordCount(ShiftDB) != 0){
            for(var i = DBmethod().DBRecordCount(ShiftDB)-1; i >= 0; i--){
                shiftlist.addObject(DBmethod().ShiftDBGet(i))
            }
            
            //pickerviewのデフォルト表示
            SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1))
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
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1-row))
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
    
    //画面したのカレンダー操作のボタンをタップした際に動作
    func TapCalenderButton(sender: UIButton){
        switch(sender.tag){
        case 0:
            print("back")
        case 1:
            print("next")
        default:
            break
        }
    }
    //"今日"をタップした時の動作
    @IBAction func TapTodayButton(sender: AnyObject) {
        self.NowDateShow()
    }
    
    func NowDateShow(){
        let now = NSDate() // 現在日時の取得
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
        dateFormatter.timeStyle = .NoStyle // 時刻だけ表示させない
        dateFormatter.dateStyle = .FullStyle
        CalenderLabel.text = dateFormatter.stringFromDate(now)
    }
}

