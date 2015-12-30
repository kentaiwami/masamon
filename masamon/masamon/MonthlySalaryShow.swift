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
    @IBOutlet weak var OtherShiftText: UITextView!
    
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
        
        let today = NSDate()
        let date = ReturnYearMonthDayWeekday(today)         //日付を西暦,月,日,曜日に分けて取得
        self.ShowAllData(self.Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day)           //データ表示へ分けた日付を渡す
        CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 \(self.ReturnWeekday(date.weekday))曜日"
        
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
    
    //画面下のカレンダー操作のボタンをタップした際に動作
    func TapCalenderButton(sender: UIButton){
        switch(sender.tag){
        case 0:
            print("back")
            //TODO: 日付をマイナスしてメソッドを呼び出す
        case 1:
            print("next")
            //TODO: 日付をプラスしてメソッドを呼び出す
        default:
            break
        }
    }
    //"今日"をタップした時の動作
    @IBAction func TapTodayButton(sender: AnyObject) {
        let today = NSDate()
        let date = ReturnYearMonthDayWeekday(today)         //日付を西暦,月,日,曜日に分けて取得
        self.ShowAllData(self.Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day)           //データ表示へ分けた日付を渡す
        CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 \(self.ReturnWeekday(date.weekday))曜日"
        
    }
    
    //受け取った文字列をシフト体制に分別して返す
    func SplitStaffShift(staff: String) -> Array<String>{
        var staffshiftarray: [String] = ["","","","","",""]         //早番,中1,中2,中3,遅,その他
        let endindex = staff.endIndex       //文字列の最後の場所
        var nowindex = staff.startIndex     //文字列の現在地
        
        while(nowindex != endindex){
            var staffname = ""
            var staffshift = ""

            while(staff[nowindex] != ":"){                            //スタッフ名を抽出するループ
                staffname = staffname + String(staff[nowindex])
                nowindex = nowindex.successor()
            }
            
            nowindex = nowindex.successor()
            
            while(staff[nowindex] != ","){                            //シフトを抽出するループ
                staffshift = staffshift + String(staff[nowindex])
                nowindex = nowindex.successor()
            }
            
            if(DBmethod().SearchShiftSystem(staffshift) == nil){     //シフト体制になかったらその他に分類
                staffshiftarray[5] = staffshiftarray[5] + staffname + "(\(staffshift))" + "、"
            }else{
                let shiftsystemresult = DBmethod().SearchShiftSystem(staffshift)
                switch(shiftsystemresult![0].id){
                case 0,1,2,3:
                    staffshiftarray[0] = staffshiftarray[0] + staffname + "、"
                case 4:
                    staffshiftarray[1] = staffshiftarray[1] + staffname + "、"
                case 5:
                    staffshiftarray[2] = staffshiftarray[2] + staffname + "、"
                case 6:
                    staffshiftarray[3] = staffshiftarray[3] + staffname + "、"
                case 7,8,9:
                    staffshiftarray[4] = staffshiftarray[4] + staffname + "、"
                default:
                    break
                }
            }
            
            nowindex = nowindex.successor()
        }
        
        //最後の文字を削除するための処理
        for(var i = 0; i < staffshiftarray.count-1; i++){
            var str = staffshiftarray[i]
            let endPoint = str.characters.count - 1
            str = str.substringToIndex(str.startIndex.advancedBy(endPoint))
            staffshiftarray[i] = str
        }
        
        return staffshiftarray
    }
    
    //受け取ったNSDateを年(西暦),月,日,曜日に分けて返す
    func ReturnYearMonthDayWeekday(date : NSDate) -> (year: Int, month: Int, day: Int, weekday: Int) {
        let calendar = NSCalendar.currentCalendar()
        let comp : NSDateComponents = calendar.components(
            [.Year,.Month,.Day,.Weekday], fromDate: date)
        return (comp.year,comp.month,comp.day,comp.weekday)
    }
    
    
    /*
    引数の説明
    y: 和暦
    m: 月
    d: 日
    */
    //受け取った日付のデータ表示を行う
    func ShowAllData(y: Int, m: Int, d: Int){
        
        if(DBmethod().TheDayStaffGet(y, month: m, date: d) == nil){
            EarlyShiftText.text = "早番：データなし"
            Center1ShiftText.text = "中1：データなし"
            Center2ShiftText.text = "中2：データなし"
            Center3ShiftText.text = "中3：データなし"
            LateShiftText.text = "遅番：データなし"
            OtherShiftText.text = "その他：データなし"
        }else{
            let shiftdetaidb = DBmethod().TheDayStaffGet(y, month: m, date: d)
            var splitedstaffarray = self.SplitStaffShift(shiftdetaidb![0].staff)
            
            EarlyShiftText.text = "早番：" + splitedstaffarray[0]
            Center1ShiftText.text = "中1：" + splitedstaffarray[1]
            Center2ShiftText.text = "中2：" + splitedstaffarray[2]
            Center3ShiftText.text = "中3：" + splitedstaffarray[3]
            LateShiftText.text = "遅番：" + splitedstaffarray[4]
            OtherShiftText.text = "その他：" + splitedstaffarray[5]
        }
    }
    
    //西暦を和暦に、和暦を西暦に変換して返す関数
    func Changecalendar(year: Int, calender: String) -> Int{
        if(calender == "JP"){   //和暦から西暦
            let yeartemp = String(year - 12)
            return Int("20"+yeartemp)!
        }else{                  //西暦から和暦
            let yeartemp = String(year + 12)
            let lastcharacter = String(yeartemp[yeartemp.endIndex.predecessor()])                   //最後の桁
            let lastcharacterminus = String(yeartemp[yeartemp.endIndex.predecessor().predecessor()])     //最後から1つ前の桁
            return Int(lastcharacterminus+lastcharacter)!
        }
    }
    
    //受け取った曜日の数字を実際の曜日に変換する
    func ReturnWeekday(weekday: Int) ->String{
        switch(weekday){
        case 1:
            return "日"
        case 2:
            return "月"
        case 3:
            return "火"
        case 4:
            return "水"
        case 5:
            return "木"
        case 6:
            return "金"
        case 7:
            return "土"
        default:
            return ""
        }
    }
}

