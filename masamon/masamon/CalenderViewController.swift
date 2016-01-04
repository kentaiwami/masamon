//
//  CalenderViewController.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class CalenderViewController: UIViewController {
    
    //メンバ変数の設定（配列格納用）
    var count: Int!
    var mArray: NSMutableArray!
    
    //メンバ変数の設定（カレンダー用）
    var now: NSDate!
    var year: Int!
    var month: Int!
    var day: Int!
    var maxDay: Int!
    var dayOfWeek: Int!
    
    //メンバ変数の設定（カレンダー関数から取得したものを渡す）
    var comps: NSDateComponents!
    
    //メンバ変数の設定（カレンダーの背景色）
    var calendarBackGroundColor: UIColor!
    
    var calendarBar = UILabel()
    var prevMonthButton = UIButton()
    var nextMonthButton = UIButton()
    var nowMonthButton = UIButton()
    
    var earlyshiftlegend = UILabel()
    var center1shiftlegend = UILabel()
    var center2shiftlegend = UILabel()
    var center3shiftlegend = UILabel()
    var latershiftlegend = UILabel()
    var breaktimelegend = UILabel()
    
    //カレンダーの位置決め用メンバ変数
    var calendarLabelIntervalX: Int!
    var calendarLabelX: Int!
    var calendarLabelY: Int!
    var calendarLabelWidth: Int!
    var calendarLabelHeight: Int!
    var calendarLableFontSize: Int!
    
    var buttonRadius: Float!
    
    var calendarIntervalX: Int!
    var calendarX: Int!
    var calendarIntervalY: Int!
    var calendarY: Int!
    var calendarSize: Int!
    var calendarFontSize: Int!
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    override func viewDidLoad() {
        super.viewDidLoad()
        CalenderViewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        NowCalendarSettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        appDelegate.storyboradid = self.restorationIdentifier!
    }
    
    func CalenderViewDidLoad(){
        calendarBar.backgroundColor = UIColor.hex("FF8E92", alpha: 1.0)
        prevMonthButton.backgroundColor = UIColor.hex("FF8E92", alpha: 1.0)
        nextMonthButton.backgroundColor = UIColor.hex("FF8E92", alpha: 1.0)
        nowMonthButton.backgroundColor = UIColor.hex("FF8E92", alpha: 1.0)
        
        prevMonthButton.setTitle("前月", forState: .Normal)
        nextMonthButton.setTitle("前月", forState: .Normal)
        nowMonthButton.setTitle("今月", forState: .Normal)
        
        prevMonthButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        nextMonthButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        nowMonthButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        prevMonthButton.addTarget(self, action: "getPrevMonthData:", forControlEvents: .TouchUpInside)
        nextMonthButton.addTarget(self, action: "getNextMonthData:", forControlEvents: .TouchUpInside)
        nowMonthButton.addTarget(self, action: "getNowMonthData:", forControlEvents: .TouchUpInside)
        
        calendarBar.frame = CGRectMake(0, 140, self.view.frame.width, 40)
        
        //凡例の背景色を設定
        earlyshiftlegend.backgroundColor = UIColor(
            red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0)
        )
        center1shiftlegend.backgroundColor = UIColor.hex("00EE76", alpha: 1.0)
        center2shiftlegend.backgroundColor = UIColor.hex("ff9900", alpha: 1.0)
        center3shiftlegend.backgroundColor = UIColor.hex("ff9966", alpha: 1.0)
        latershiftlegend.backgroundColor = UIColor.blackColor()
        breaktimelegend.backgroundColor = UIColor(
            red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0)
        )
        
        //凡例に表示するテキストを設定
        earlyshiftlegend.text = "早番"
        center1shiftlegend.text = "中1"
        center2shiftlegend.text = "中2"
        center3shiftlegend.text = "中3"
        latershiftlegend.text = "遅番"
        breaktimelegend.text = "休み"
        
        //凡例に表示するテキストの文字色を設定
        earlyshiftlegend.textColor = UIColor.whiteColor()
        center1shiftlegend.textColor = UIColor.whiteColor()
        center2shiftlegend.textColor = UIColor.whiteColor()
        center3shiftlegend.textColor = UIColor.whiteColor()
        latershiftlegend.textColor = UIColor.whiteColor()
        breaktimelegend.textColor = UIColor.whiteColor()
        
        //凡例に表示するテキストを中央寄せに設定
        earlyshiftlegend.textAlignment = NSTextAlignment.Center
        center1shiftlegend.textAlignment = NSTextAlignment.Center
        center2shiftlegend.textAlignment = NSTextAlignment.Center
        center3shiftlegend.textAlignment = NSTextAlignment.Center
        latershiftlegend.textAlignment = NSTextAlignment.Center
        breaktimelegend.textAlignment = NSTextAlignment.Center
        
        //凡例を表示する場所と大きさを設定
        earlyshiftlegend.frame = CGRectMake(40, 20, 45, 45)
        center1shiftlegend.frame = CGRectMake(40, 80, 45, 45)
        center2shiftlegend.frame = CGRectMake(self.view.frame.width/2-22.5, 20, 45, 45)
        center3shiftlegend.frame = CGRectMake(self.view.frame.width/2-22.5, 80, 45, 45)
        latershiftlegend.frame = CGRectMake(self.view.frame.width-80, 20, 45, 45)
        breaktimelegend.frame = CGRectMake(self.view.frame.width-80, 80, 45, 45)
        
        //凡例のマスクを有効に設定
        earlyshiftlegend.layer.masksToBounds = true
        center1shiftlegend.layer.masksToBounds = true
        center2shiftlegend.layer.masksToBounds = true
        center3shiftlegend.layer.masksToBounds = true
        latershiftlegend.layer.masksToBounds = true
        breaktimelegend.layer.masksToBounds = true
        
        //凡例を角丸に設定
        earlyshiftlegend.layer.cornerRadius = 22.5
        center1shiftlegend.layer.cornerRadius = 22.5
        center2shiftlegend.layer.cornerRadius = 22.5
        center3shiftlegend.layer.cornerRadius = 22.5
        latershiftlegend.layer.cornerRadius = 22.5
        breaktimelegend.layer.cornerRadius = 22.5
        
        //凡例をviewに追加
        self.view.addSubview(earlyshiftlegend)
        self.view.addSubview(center1shiftlegend)
        self.view.addSubview(center2shiftlegend)
        self.view.addSubview(center3shiftlegend)
        self.view.addSubview(latershiftlegend)
        self.view.addSubview(breaktimelegend)
        
        
        self.view.addSubview(calendarBar)
        self.view.addSubview(prevMonthButton)
        self.view.addSubview(nextMonthButton)
        self.view.addSubview(nowMonthButton)
        
        //iPhone6
        calendarLabelIntervalX = 15;
        calendarLabelX         = 50;
        calendarLabelY         = 190;
        calendarLabelWidth     = 45;
        calendarLabelHeight    = 25;
        calendarLableFontSize  = 16;
        
        buttonRadius           = 22.5;
        
        calendarIntervalX      = 15;
        calendarX              = 50;
        calendarIntervalY      = 230;
        calendarY              = 50;
        calendarSize           = 45;
        calendarFontSize       = 19;
        
        self.prevMonthButton.frame = CGRectMake(15, 550, CGFloat(calendarSize), CGFloat(calendarSize));
        self.nextMonthButton.frame = CGRectMake(314, 550, CGFloat(calendarSize), CGFloat(calendarSize));
        self.nowMonthButton.frame = CGRectMake(self.view.frame.width/2-CGFloat(calendarSize/2), 550, CGFloat(calendarSize), CGFloat(calendarSize))
        //ボタンを角丸にする
        prevMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        nextMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        nowMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        
        //現在の日付を取得する
        now = NSDate()
        
        //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let range: NSRange = calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit:NSCalendarUnit.Month, forDate:now)
        
        //最初にメンバ変数に格納するための現在日付の情報を取得する
        comps = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:now)
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        let orgYear: NSInteger      = comps.year
        let orgMonth: NSInteger     = comps.month
        let orgDay: NSInteger       = comps.day
        let orgDayOfWeek: NSInteger = comps.weekday
        let max: NSInteger          = range.length
        
        year      = orgYear
        month     = orgMonth
        day       = orgDay
        dayOfWeek = orgDayOfWeek
        maxDay    = max
        
        //空の配列を作成する（カレンダーデータの格納用）
        mArray = NSMutableArray()
        
        //曜日ラベル初期定義
        let monthName:[String] = ["日","月","火","水","木","金","土"]
        
        //曜日ラベルを動的に配置
        setupCalendarLabel(monthName)
        
        //初期表示時のカレンダーをセットアップする
        setupCurrentCalendar()
    }
    
    //曜日ラベルの動的配置関数
    func setupCalendarLabel(array: NSArray) {
        
        let calendarLabelCount = 7
        
        for i in 0...6{
            
            //ラベルを作成
            let calendarBaseLabel: UILabel = UILabel()
            
            //X座標の値をCGFloat型へ変換して設定
            calendarBaseLabel.frame = CGRectMake(
                CGFloat(calendarLabelIntervalX + calendarLabelX * (i % calendarLabelCount)),
                CGFloat(calendarLabelY),
                CGFloat(calendarLabelWidth),
                CGFloat(calendarLabelHeight)
            )
            
            //日曜日の場合は赤色を指定
            if(i == 0){
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0)
                )
                
                //土曜日の場合は青色を指定
            }else if(i == 6){
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0)
                )
                
                //平日の場合は灰色を指定
            }else{
                
                //既に用意されている配色パターンの場合
                calendarBaseLabel.textColor = UIColor.lightGrayColor()
                
            }
            
            //曜日ラベルの配置
            calendarBaseLabel.text = String(array[i] as! NSString)
            calendarBaseLabel.textAlignment = NSTextAlignment.Center
            calendarBaseLabel.font = UIFont(name: "System", size: CGFloat(calendarLableFontSize))
            self.view.addSubview(calendarBaseLabel)
        }
    }
    
    //カレンダーを生成する関数
    func generateCalendar(){
        
        //タグナンバーとトータルカウントの定義
        var tagNumber = 1
        let total     = 42
        
        //7×6=42個のボタン要素を作る
        for i in 0...41{
            
            //配置場所の定義
            let positionX   = calendarIntervalX + calendarX * (i % 7)
            let positionY   = calendarIntervalY + calendarY * (i / 7)
            let buttonSizeX = calendarSize;
            let buttonSizeY = calendarSize;
            
            //ボタンをつくる
            let button: UIButton = UIButton()
            button.frame = CGRectMake(
                CGFloat(positionX),
                CGFloat(positionY),
                CGFloat(buttonSizeX),
                CGFloat(buttonSizeY)
            );
            
            //ボタンの初期設定をする
            if(i < dayOfWeek - 1){
                
                //日付の入らない部分はボタンを押せなくする
                button.setTitle("", forState: .Normal)
                button.enabled = false
                
            }else if(i == dayOfWeek - 1 || i < dayOfWeek + maxDay - 1){
                
                //日付の入る部分はボタンのタグを設定する（日にち）
                button.setTitle(String(tagNumber), forState: .Normal)
                button.tag = tagNumber
                tagNumber++
                
            }else if(i == dayOfWeek + maxDay - 1 || i < total){
                
                //日付の入らない部分はボタンを押せなくする
                button.setTitle("", forState: .Normal)
                button.enabled = false
                
            }
            
            //ボタンの配色の設定
            //@remark:このサンプルでは正円のボタンを作っていますが、背景画像の設定等も可能です。
            
            if(DBmethod().TheDayStaffGet(MonthlySalaryShow().Changecalendar(self.year, calender: "A.D"), month: self.month, date: button.tag) == nil){
                calendarBackGroundColor = UIColor.lightGrayColor()
            }else{
                let usershift = self.ReturnUserShift(DBmethod().TheDayStaffGet(MonthlySalaryShow().Changecalendar(self.year, calender: "A.D"), month: self.month, date: button.tag)![0].staff)
                
                switch(usershift){
                case "早","早カ":
                    calendarBackGroundColor = UIColor(
                        red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0)
                    )
                    
                case "中":
                    calendarBackGroundColor = UIColor.hex("00EE76", alpha: 0.9)
                    
                case "中2":
                    calendarBackGroundColor = UIColor.hex("ff9900", alpha: 1.0)
                    
                case "中3":
                    calendarBackGroundColor = UIColor.hex("ff9966", alpha: 1.0)
                    
                case "遅","遅カ":
                    calendarBackGroundColor = UIColor.blackColor()
                    
                case "breaktime":
                    calendarBackGroundColor = UIColor(
                        red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0)
                    )
                    
                default:
                    calendarBackGroundColor = UIColor.lightGrayColor()
                }
                
            }
            
            //ボタンのデザインを決定する
            button.backgroundColor = calendarBackGroundColor
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.titleLabel!.font = UIFont(name: "System", size: CGFloat(calendarFontSize))
            button.layer.cornerRadius = CGFloat(buttonRadius)
            
            //配置したボタンに押した際のアクションを設定する
            button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            
            //ボタンを配置する
            self.view.addSubview(button)
            mArray.addObject(button)
            self.view.bringSubviewToFront(alertview)
        }
        
    }
    
    //受け取った文字列の中からユーザのシフトを返す関数
    func ReturnUserShift(staff: String) -> String{
        
        if(staff.rangeOfString(DBmethod().UserNameGet()) == nil){
            return "breaktime"
        }else{
            let staffNSString: NSString = staff as NSString
            let usernamelocation = staffNSString.rangeOfString(DBmethod().UserNameGet()).location
            let shiftstartposition = usernamelocation + DBmethod().UserNameGet().characters.count+1
            var nowindex = staff.startIndex
            
            //ユーザのシフトが出る場所までindexを進めるループ
            for(var i = 0; i < shiftstartposition; i++){
                nowindex = nowindex.successor()
            }
            
            var usershift = ""
            
            //ユーザのシフトを抽出するループ
            while(staff[nowindex] != ","){
                usershift = usershift + String(staff[nowindex])
                nowindex = nowindex.successor()
            }
            
            return usershift
        }
    }
    
    //タイトル表記を設定する関数
    func setupCalendarTitleLabel() {
        calendarBar.text = String("\(year)年\(month)月")
        calendarBar.textAlignment = NSTextAlignment.Center
        calendarBar.textColor = UIColor.whiteColor()
        
    }
    
    //現在（初期表示時）の年月に該当するデータを取得する関数
    func setupCurrentCalendarData() {
        
        /*************
         * (重要ポイント)
         * 現在月の1日のdayOfWeek(曜日の値)を使ってカレンダーの始まる位置を決めるので、
         * yyyy年mm月1日のデータを作成する。
         * 後述の関数 setupPrevCalendarData, setupNextCalendarData も同様です。
         *************/
        let currentCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let currentComps: NSDateComponents = NSDateComponents()
        
        //現在の日付を取得する
        now = NSDate()
        
        //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        //最初にメンバ変数に格納するための現在日付の情報を取得する
        comps = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:now)
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        let orgYear: NSInteger      = comps.year
        let orgMonth: NSInteger     = comps.month
        
        year      = orgYear
        month     = orgMonth
        
        currentComps.year  = year
        currentComps.month = month
        currentComps.day   = 1
        
        let currentDate: NSDate = currentCalendar.dateFromComponents(currentComps)!
        recreateCalendarParameter(currentCalendar, currentDate: currentDate)
    }
    
    //前の年月に該当するデータを取得する関数
    func setupPrevCalendarData() {
        
        //現在の月に対して-1をする
        if(month == 0){
            year = year - 1;
            month = 12;
        }else{
            month = month - 1;
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        let prevCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let prevComps: NSDateComponents = NSDateComponents()
        
        prevComps.year  = year
        prevComps.month = month
        prevComps.day   = 1
        
        let prevDate: NSDate = prevCalendar.dateFromComponents(prevComps)!
        recreateCalendarParameter(prevCalendar, currentDate: prevDate)
    }
    
    //次の年月に該当するデータを取得する関数
    func setupNextCalendarData() {
        
        //現在の月に対して+1をする
        if(month == 12){
            year = year + 1;
            month = 1;
        }else{
            month = month + 1;
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        let nextCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let nextComps: NSDateComponents = NSDateComponents()
        
        nextComps.year  = year
        nextComps.month = month
        nextComps.day   = 1
        
        let nextDate: NSDate = nextCalendar.dateFromComponents(nextComps)!
        recreateCalendarParameter(nextCalendar, currentDate: nextDate)
    }
    
    //カレンダーのパラメータを再作成する関数
    func recreateCalendarParameter(currentCalendar: NSCalendar, currentDate: NSDate) {
        
        //引数で渡されたものをもとに日付の情報を取得する
        let currentRange: NSRange = currentCalendar.rangeOfUnit(NSCalendarUnit.Day, inUnit:NSCalendarUnit.Month, forDate:currentDate)
        
        comps = currentCalendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:currentDate)
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        let currentYear: NSInteger      = comps.year
        let currentMonth: NSInteger     = comps.month
        let currentDay: NSInteger       = comps.day
        let currentDayOfWeek: NSInteger = comps.weekday
        let currentMax: NSInteger       = currentRange.length
        
        year      = currentYear
        month     = currentMonth
        day       = currentDay
        dayOfWeek = currentDayOfWeek
        maxDay    = currentMax
    }
    
    //表示されているボタンオブジェクトを一旦削除する関数
    func removeCalendarButtonObject() {
        
        //ビューからボタンオブジェクトを削除する
        for i in 0..<mArray.count {
            mArray[i].removeFromSuperview()
        }
        
        //配列に格納したボタンオブジェクトも削除する
        mArray.removeAllObjects()
    }
    
    //現在のカレンダーをセットアップする関数
    func setupCurrentCalendar() {
        
        setupCurrentCalendarData()
        generateCalendar()
        setupCalendarTitleLabel()
    }
    
    let alertview = UIView()
    let titlelabel = UILabel()
    let textview = UITextView()
    let OKButton = UIButton()
    let lineview = UIView()

    var flag = false
    
    //カレンダーボタンをタップした時のアクション
    func buttonTapped(button: UIButton){
        if(DBmethod().TheDayStaffGet(MonthlySalaryShow().Changecalendar(year, calender: "A.D"), month: month, date: button.tag) == nil){
            let alertController = UIAlertController(title: "\(year)年\(month)月\(button.tag)日", message: "データなし", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }else{
            let staffstring = DBmethod().TheDayStaffGet(MonthlySalaryShow().Changecalendar(year, calender: "A.D"),month: month,date: button.tag)![0].staff
            let splitedstaffarray = MonthlySalaryShow().SplitStaffShift(staffstring)
            
            let alertviewtitle = "\(year)年\(month)月\(button.tag)日"
            let earlystaff = "　早番："+splitedstaffarray[0]+"\n\n"
            let center1staff = "　中1："+splitedstaffarray[1]+"\n\n"
            let center2staff = "　中2："+splitedstaffarray[2]+"\n\n"
            let center3staff = "　中3："+splitedstaffarray[3]+"\n\n"
            let laterstaff = "　遅番："+splitedstaffarray[4]+"\n\n"
            let otherstaff = "　その他："+splitedstaffarray[5]+"\n"
            let linebreak = "\n\n\n"
            let alertviewtext = linebreak+earlystaff+center1staff+center2staff+center3staff+laterstaff+otherstaff
            
            //擬似アラートの設定
            alertview.frame = CGRectMake(0,0,self.view.frame.width,self.view.frame.height)
            alertview.backgroundColor = UIColor.hex("000000", alpha: 0.3)
            
            
            //アラートのタイトル設定
            titlelabel.frame = CGRectMake(self.view.frame.width/2-350/2,self.view.frame.height/2-320/2,350,50)
            titlelabel.text = alertviewtitle
            titlelabel.textAlignment = NSTextAlignment.Center
            titlelabel.textColor = UIColor.blackColor()
            titlelabel.font = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
            
            //アラートに表示するテキストの設定
            textview.frame = CGRectMake(self.view.frame.width/2-350/2, self.view.frame.height/2-320/2, 350, 320)
            textview.layer.masksToBounds = true
            textview.layer.cornerRadius = 25
            textview.backgroundColor = UIColor.hex("FFFFFF", alpha: 1.0)
            textview.editable = false
            textview.text = alertviewtext
            textview.textColor = UIColor.blackColor()
            
            //アラートに表示するOKボタンの設定
            OKButton.backgroundColor = UIColor.clearColor()
            OKButton.frame = CGRectMake(self.view.frame.width/2-350/2,self.view.frame.height/2-250/2+230,350,50)
            OKButton.setTitle("OK", forState: .Normal)
            OKButton.setTitleColor(UIColor.hex("0099ff", alpha: 1.0), forState: .Normal)
            OKButton.layer.cornerRadius = 25
            OKButton.addTarget(self, action: "TapOK:", forControlEvents: .TouchUpInside)
            
            //アラートのテキストとボタンの境界線を表示する設定
            lineview.frame = CGRectMake(self.view.frame.width/2-350/2, self.view.frame.height/2-250/2+220, 350, 1)
            lineview.backgroundColor = UIColor.hex("000000", alpha: 0.2)
            
            //viewを無限に追加しないためにflagを使用する
            if(flag){
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.alertview.alpha = 1.0
                })
            }else{
                self.view.addSubview(self.alertview)
                self.alertview.addSubview(self.textview)
                self.alertview.addSubview(self.OKButton)
                self.alertview.addSubview(self.lineview)
                self.alertview.addSubview(self.titlelabel)
                self.alertview.alpha = 0.0
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.alertview.alpha = 1.0
                })
            }
        }
    }
    
    //アラートに表示するOKボタンを押した際に呼ばれる関数
    func TapOK(sender: UIButton){
        flag = true
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alertview.alpha = 0.0
        })
    }
    
    //前の月のボタンを押した際のアクション
    func getPrevMonthData(sender: UIButton) {
        prevCalendarSettings()
    }
    
    //次の月のボタンを押した際のアクション
    func getNextMonthData(sender: UIButton) {
        nextCalendarSettings()
    }
    
    //今月ボタンを押した際のアクション
    func getNowMonthData(sender: UIButton){
        NowCalendarSettings()
    }
    
    //前月を表示するメソッド
    func prevCalendarSettings() {
        removeCalendarButtonObject()
        setupPrevCalendarData()
        generateCalendar()
        setupCalendarTitleLabel()
    }
    
    //次月を表示するメソッド
    func nextCalendarSettings() {
        removeCalendarButtonObject()
        setupNextCalendarData()
        generateCalendar()
        setupCalendarTitleLabel()
    }
    
    //今月を表示するメソッド
    func NowCalendarSettings(){
        removeCalendarButtonObject()
        setupCurrentCalendarData()
        generateCalendar()
        setupCalendarTitleLabel()
    }
    
}
