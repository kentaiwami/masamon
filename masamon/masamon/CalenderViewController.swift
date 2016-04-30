
import UIKit

class CalenderViewController: UIViewController {
    
    //メンバ変数の設定（配列格納用）
    var count: Int!
//    var mArray: NSMutableArray!
    var mArray: [[UIButton]] = [[],[],[]]
    let for_parameter: [Int] = [-1,0,1]
    
    //メンバ変数の設定（カレンダー用）
    var nsdate: [NSDate] = []
    var year: [Int] = []
    var month: [Int] = []
    var day: [Int] = []
    var maxDay: [Int] = []
    var dayOfWeek: [Int] = []
    var now_nsdate = NSDate()
    
    //メンバ変数の設定（カレンダー関数から取得したものを渡す）
    var comps: [NSDateComponents] = []
    
    //メンバ変数の設定（カレンダーの背景色）
    var calendarBackGroundColor: UIColor!
    
    var calendarBar = UILabel()
    
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
    
    var calendarIntervalX: [Int] = []
    var calendarX: Int!
    var calendarIntervalY: Int!
    var calendarY: Int!
    var calendarSize: Int!
    var calendarFontSize: Int!
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    override func viewDidLoad() {
        super.viewDidLoad()
        CalenderViewDidLoad()
        setupTapGesture()
    }
    
    override func viewDidAppear(animated: Bool) {
        appDelegate.screennumber = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func CalenderViewDidLoad(){
        calendarBar.backgroundColor = UIColor.clearColor()
        calendarBar.frame = CGRectMake(0, 190, self.view.frame.width, 40)
        calendarBar.font = UIFont.systemFontOfSize(19)
        
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
        earlyshiftlegend.frame = CGRectMake(40, 70, 45, 45)
        center1shiftlegend.frame = CGRectMake(40, 130, 45, 45)
        center2shiftlegend.frame = CGRectMake(self.view.frame.width/2-22.5, 70, 45, 45)
        center3shiftlegend.frame = CGRectMake(self.view.frame.width/2-22.5, 130, 45, 45)
        latershiftlegend.frame = CGRectMake(self.view.frame.width-80, 70, 45, 45)
        breaktimelegend.frame = CGRectMake(self.view.frame.width-80, 130, 45, 45)
        
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
        
        //iPhone6
        calendarLabelIntervalX = 15;
        calendarLabelX         = 50;
        calendarLabelY         = 240;
        calendarLabelWidth     = 45;
        calendarLabelHeight    = 25;
        calendarLableFontSize  = 16;
        
        buttonRadius           = 22.5;
        
        calendarX              = 50;
        calendarIntervalY      = 280;
        calendarY              = 53;
        calendarSize           = 45;
        calendarFontSize       = 19;
        
        //カレンダーの配置場所を決定
        calendarIntervalX.append(-(15+50*(41%7)+45))
        calendarIntervalX.append(15)
        calendarIntervalX.append((15+50*(41%7)+60))
        
        
        //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        for i in 0..<for_parameter.count {
            
            let tmp_nsdate = GetPrevCurrentNextNSDate(i)
            
            nsdate.append(tmp_nsdate)
            comps.append(NSDateComponents())

            let range: NSRange = calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit:NSCalendarUnit.Month, forDate:tmp_nsdate)
            
            //最初にメンバ変数に格納するための現在日付の情報を取得する
            comps[i] = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:tmp_nsdate)

            let orgYear: NSInteger      = comps[i].year
            let orgMonth: NSInteger     = comps[i].month
            let orgDay: NSInteger       = comps[i].day
            let orgDayOfWeek: NSInteger = comps[i].weekday
            let max: NSInteger          = range.length
            
            year.append(orgYear)
            month.append(orgMonth)
            day.append(orgDay)
            dayOfWeek.append(orgDayOfWeek)
            maxDay.append(max)
        }
        
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
            
            calendarBaseLabel.textColor = UIColor.lightGrayColor()
            
            //曜日ラベルの配置
            calendarBaseLabel.text = String(array[i] as! NSString)
            calendarBaseLabel.textAlignment = NSTextAlignment.Center
            calendarBaseLabel.font = UIFont(name: "System", size: CGFloat(calendarLableFontSize))
            self.view.addSubview(calendarBaseLabel)
        }
    }
    
    //カレンダーを生成する関数
    func generateCalendar(start: Int, end: Int){
        
        /*
         長押しして月を進める場合に必要な処理．
         画面右のカレンダー情報を一旦記録しておいて，今月のカレンダー情報を記録する
         カレンダー生成が終わったらもとの値に戻す(本メソッド下の処理)
         */
        var tmp: [Int] = []
        if start == 2 && end == 3 {
            tmp.append(dayOfWeek[2])
            tmp.append(maxDay[2])
            tmp.append(year[2])
            tmp.append(month[2])
            
            dayOfWeek[2] = dayOfWeek[1]
            maxDay[2] = maxDay[1]
            year[2] = year[1]
            month[2] = month[1]
            
        //長押しして月を戻す場合に必要な処理
        }else if start == 0 && end == 1 {
            tmp.append(dayOfWeek[0])
            tmp.append(maxDay[0])
            tmp.append(year[0])
            tmp.append(month[0])

            dayOfWeek[0] = dayOfWeek[1]
            maxDay[0] = maxDay[1]
            year[0] = year[1]
            month[0] = month[1]

        }
        
        for i in start..<end {
            mArray.append([])
            
            //タグナンバーとトータルカウントの定義
            var tagNumber = 1
            let total     = 42
            
            //7×6=42個のボタン要素を作る
            for j in 0...41{
                
                //配置場所の定義
                let positionX   = calendarIntervalX[i] + calendarX * (j % 7)
                let positionY   = calendarIntervalY + calendarY * (j / 7)
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
                if j < dayOfWeek[i] - 1 {
                    
                    //日付の入らない部分はボタンを押せなくする
                    button.setTitle("", forState: .Normal)
                    button.enabled = false
                    
                }else if j == dayOfWeek[i] - 1 || j < dayOfWeek[i] + maxDay[i] - 1 {
                    
                    //日付の入る部分はボタンのタグを設定する（日にち）
                    button.setTitle(String(tagNumber), forState: .Normal)
                    button.tag = tagNumber
                    tagNumber += 1
                    
                }else if j == dayOfWeek[i] + maxDay[i] - 1 || j < total {
                    
                    //日付の入らない部分はボタンを押せなくする
                    button.setTitle("", forState: .Normal)
                    button.enabled = false
                    
                }
                
                
                //ボタンの配色の設定
                //@remark:このサンプルでは正円のボタンを作っていますが、背景画像の設定等も可能です。
                
                if DBmethod().TheDayStaffGet(CommonMethod().Changecalendar(year[i], calender: "A.D"), month: month[i], date: button.tag) == nil {
                    calendarBackGroundColor = UIColor.lightGrayColor()
                }else{
                    let usershift = self.ReturnUserShift(DBmethod().TheDayStaffGet(CommonMethod().Changecalendar(year[i], calender: "A.D"), month: month[i], date: button.tag)![0].staff)
                    
                    var gid = 999
                    
                    if usershift == "breaktime" {
                        gid = 5
                    }else{
                        let resultshift = DBmethod().SearchShiftSystem(usershift)
                        if resultshift != nil {
                            gid = resultshift![0].groupid
                        }
                    }
                    
                    switch(gid){
                    //早番
                    case 0:
                        calendarBackGroundColor = UIColor(
                            red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0)
                        )
                        
                    //中1
                    case 1:
                        calendarBackGroundColor = UIColor.hex("00EE76", alpha: 0.9)
                        
                    //中2
                    case 2:
                        calendarBackGroundColor = UIColor.hex("ff9900", alpha: 1.0)
                        
                    //中3
                    case 3:
                        calendarBackGroundColor = UIColor.hex("ff9966", alpha: 1.0)
                        
                    //遅番
                    case 4:
                        calendarBackGroundColor = UIColor.blackColor()
                        
                    //休み
                    case 5:
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
                
                
                //今日の日付と合致するボタンがあったら装飾する
                let nowdate = NSDate()
                let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
                let comps:NSDateComponents = calendar!.components([NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day],
                                                                  fromDate: nowdate)
                let buttonyear = comps.year
                let buttonmonth = comps.month
                let buttonday = comps.day
                
                //今日の日付と一致するボタンがある場合
                if buttonyear == year[i] && buttonmonth == month[i] && buttonday == button.tag {
                    button.layer.borderColor = UIColor.whiteColor().CGColor
                    button.layer.borderWidth = CGFloat(4.5)
                }
                
                //配置したボタンに押した際のアクションを設定する
                button.addTarget(self, action: #selector(CalenderViewController.buttonTapped(_:)), forControlEvents: .TouchUpInside)
                
                //ボタンを配置する
                self.view.addSubview(button)
                //            mArray.addObject(button)
                mArray[i].append(button)
                self.view.bringSubviewToFront(alertview)
            }
        }
        
        //今月のカレンダー生成が終わったらもとの値に戻す
        if tmp.count != 0 && start == 2 && end == 3{
            dayOfWeek[2] = tmp[0]
            maxDay[2] = tmp[1]
            year[2] = tmp[2]
            month[2] = tmp[3]
        }else if tmp.count != 0 && start == 0 && end == 1 {
            dayOfWeek[0] = tmp[0]
            maxDay[0] = tmp[1]
            year[0] = tmp[2]
            month[0] = tmp[3]
        }
        
    }
    
    //受け取った文字列の中からユーザのシフトを返す関数
    func ReturnUserShift(staff: String) -> String{
        
        if staff.rangeOfString(DBmethod().UserNameGet()) == nil {
            return "breaktime"
        }else{
            let staffNSString: NSString = staff as NSString
            let usernamelocation = staffNSString.rangeOfString(DBmethod().UserNameGet()).location
            let shiftstartposition = usernamelocation + DBmethod().UserNameGet().characters.count+1
            var nowindex = staff.startIndex
            
            //ユーザのシフトが出る場所までindexを進めるループ
            for _ in 0 ..< shiftstartposition{
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
    
    //年月を増減するパラメータを受け取りパラメータに応じたNSDateを返す(先月，今月，来月)
    func GetPrevCurrentNextNSDate(i: Int) -> NSDate {
        var tmp_nsdate = NSDate()
        var tmp_nsdate_split = CommonMethod().ReturnYearMonthDayWeekday(tmp_nsdate)
        
        //先月を設定する場合の処理
        if tmp_nsdate_split.month == 1 && i == 0{
            tmp_nsdate_split.year = tmp_nsdate_split.year + for_parameter[i]
            tmp_nsdate_split.month = 12
        }else if tmp_nsdate_split.month >= 2 && i == 0 {
            tmp_nsdate_split.month = tmp_nsdate_split.month + for_parameter[i]
        }
        
        //来月を設定する場合の処理
        if tmp_nsdate_split.month == 12 && i == 2{
            tmp_nsdate_split.year = tmp_nsdate_split.year + for_parameter[i]
            tmp_nsdate_split.month = 1
        }else if tmp_nsdate_split.month >= 2 && i == 2 {
            tmp_nsdate_split.month = tmp_nsdate_split.month + for_parameter[i]
        }
        
        tmp_nsdate_split.day = 1
        
        tmp_nsdate = CommonMethod().CreateNSDate(tmp_nsdate_split.year, month: tmp_nsdate_split.month, day: tmp_nsdate_split.day)
        
        return tmp_nsdate

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
        now_nsdate = NSDate()
        
        //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        for i in 0..<for_parameter.count {

            let tmp_nsdate = GetPrevCurrentNextNSDate(i)

            nsdate[i] = tmp_nsdate

            //最初にメンバ変数に格納するための現在日付の情報を取得する
            comps[i] = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:tmp_nsdate)
            
            //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
            let orgYear: NSInteger      = comps[i].year
            let orgMonth: NSInteger     = comps[i].month
            
            year[i]      = orgYear
            month[i]     = orgMonth
            
            currentComps.year  = year[i]
            currentComps.month = month[i]
            currentComps.day   = 1
            
            let currentDate: NSDate = currentCalendar.dateFromComponents(currentComps)!
            recreateCalendarParameter(currentCalendar, currentDate: currentDate, calendarnumber: i)
        }
    }
    
    //前の年月に該当するデータを取得する関数
    func setupPrevCalendarData() {
        
        //年月情報をずらす
        year[2] = year[1]
        month[2] = month[1]
        year[1] = year[0]
        month[1] = month[0]
        
        //現在の月に対して-1をする
        if month[0] == 0 {
            year[0] = year[0] - 1;
            month[0] = 12;
        }else{
            month[0] = month[0] - 1;
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        for i in 0..<for_parameter.count {
            let prevCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let prevComps: NSDateComponents = NSDateComponents()
            
            prevComps.year  = year[i]
            prevComps.month = month[i]
            prevComps.day   = 1
            
            let prevDate: NSDate = prevCalendar.dateFromComponents(prevComps)!
            recreateCalendarParameter(prevCalendar, currentDate: prevDate, calendarnumber: i)
        }
    }
    
    //次の年月に該当するデータを取得する関数
    func setupNextCalendarData() {
        
        //年月情報をずらす
        year[0] = year[1]
        month[0] = month[1]
        year[1] = year[2]
        month[1] = month[2]

        //現在の月に対して+1をする
        if month[2] == 12 {
            year[2] = year[2] + 1;
            month[2] = 1;
        }else{
            month[2] = month[2] + 1;
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        for i in 0..<for_parameter.count {
            let nextCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let nextComps: NSDateComponents = NSDateComponents()
            
            nextComps.year  = year[i]
            nextComps.month = month[i]
            nextComps.day   = 1
            
            let nextDate: NSDate = nextCalendar.dateFromComponents(nextComps)!
            recreateCalendarParameter(nextCalendar, currentDate: nextDate, calendarnumber: i)
        }
    }
    
    //カレンダーのパラメータを再作成する関数
    func recreateCalendarParameter(currentCalendar: NSCalendar, currentDate: NSDate, calendarnumber: Int) {
        
        //引数で渡されたものをもとに日付の情報を取得する
        let currentRange: NSRange = currentCalendar.rangeOfUnit(NSCalendarUnit.Day, inUnit:NSCalendarUnit.Month, forDate:currentDate)
        
        comps[calendarnumber] = currentCalendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:currentDate)
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        let currentYear: NSInteger      = comps[calendarnumber].year
        let currentMonth: NSInteger     = comps[calendarnumber].month
        let currentDay: NSInteger       = comps[calendarnumber].day
        let currentDayOfWeek: NSInteger = comps[calendarnumber].weekday
        let currentMax: NSInteger       = currentRange.length
        
        year[calendarnumber]      = currentYear
        month[calendarnumber]     = currentMonth
        day[calendarnumber]       = currentDay
        dayOfWeek[calendarnumber] = currentDayOfWeek
        maxDay[calendarnumber]    = currentMax
    }
    
    //表示されているボタンオブジェクトを一旦削除する関数
    func removeCalendarButtonObject() {
        
        //ビューからボタンオブジェクトを削除する
        for i in 0..<mArray.count {
            for j in 0..<mArray[i].count {
                mArray[i][j].removeFromSuperview()
            }
        }
        
        //配列に格納したボタンオブジェクトも削除する
        mArray.removeAll()
    }
    
    //指定した配列に格納されているボタンオブジェクトを削除する
    func removeCalendarButtonObjectWithArrayNumber(arraynumber: Int) {
        for i in 0..<mArray[arraynumber].count {
            mArray[arraynumber][i].removeFromSuperview()
        }
        mArray[arraynumber].removeAll()
    }
    
    
    //現在のカレンダーをセットアップする関数
    func setupCurrentCalendar() {
        
        setupCurrentCalendarData()
        generateCalendar(0, end: for_parameter.count)
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
        if DBmethod().TheDayStaffGet(CommonMethod().Changecalendar(year[1], calender: "A.D"), month: month[1], date: button.tag) == nil {
            let alertController = UIAlertController(title: "\(year[1])年\(month[1])月\(button.tag)日", message: "データなし", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }else{
            let staffstring = DBmethod().TheDayStaffGet(CommonMethod().Changecalendar(year[1], calender: "A.D"),month: month[1],date: button.tag)![0].staff
            let splitedstaffarray = MonthlySalaryShow().SplitStaffShift(staffstring)
            
            let alertviewtitle = "\(year[1])年\(month[1])月\(button.tag)日"
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
            OKButton.addTarget(self, action: #selector(CalenderViewController.TapOK(_:)), forControlEvents: .TouchUpInside)
            
            //アラートのテキストとボタンの境界線を表示する設定
            lineview.frame = CGRectMake(self.view.frame.width/2-350/2, self.view.frame.height/2-250/2+220, 350, 1)
            lineview.backgroundColor = UIColor.hex("000000", alpha: 0.2)
            
            //viewを無限に追加しないためにflagを使用する
            if flag {
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
    
    func setupTapGesture(){
        // 右方向へのスワイプ
        let gestureToRight = UISwipeGestureRecognizer(target: self, action: #selector(CalenderViewController.prevCalendarSettings))
        gestureToRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(gestureToRight)
        
        // 左方向へのスワイプ
        let gestureToLeft = UISwipeGestureRecognizer(target: self, action: #selector(CalenderViewController.nextCalendarSettings))
        gestureToLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(gestureToLeft)
        
        //長押し
        let myLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CalenderViewController.NowCalendarSettings))
        myLongPressGesture.minimumPressDuration = 0.2
        myLongPressGesture.allowableMovement = 150
        self.view.addGestureRecognizer(myLongPressGesture)
    }
    
    //日付を表示しているLabelをアニメーション表示するメソッド
    func AnimationcalendarBar(beforeposition: CGFloat) {
        calendarBar.alpha = 0.0
        calendarBar.frame = CGRectMake(beforeposition, 190, self.view.frame.width, 40)
        
        UIView.animateWithDuration(0.5) {
            self.calendarBar.frame = CGRectMake(0, 190, self.view.frame.width, 40)
            self.calendarBar.alpha = 1.0
        }
    }
    
    //カレンダーをアニメーション表示するメソッド
    func Animationcalendar(prevIntervalX: Int, mainIntervalX: Int, nextIntervalX: Int, barposition: Int) {
        let IntervalX = [prevIntervalX, mainIntervalX, nextIntervalX]
        
        UIView.animateWithDuration(0.4, animations: {
            for i in 0..<self.mArray.count {
                for j in 0..<self.mArray[i].count {
                    let positionX   = IntervalX[i] + self.calendarX * (j % 7)
                    let positionY   = self.calendarIntervalY + self.calendarY * (j / 7)
                    let buttonSizeX = self.calendarSize;
                    let buttonSizeY = self.calendarSize;

                    self.mArray[i][j].frame = CGRectMake(CGFloat(positionX), CGFloat(positionY), CGFloat(buttonSizeX), CGFloat(buttonSizeY))
                }
            }
            }) { (value: Bool) in
                self.removeCalendarButtonObject()
                self.generateCalendar(0,end: self.for_parameter.count)
        }
    }

    //前月を表示するメソッド
    func prevCalendarSettings() {
        let prevX = 15
        let mainX = (15+50*(41%7)+60)
        let nextX = (15+50*(41%7)+60)

        self.setupPrevCalendarData()
        Animationcalendar(prevX, mainIntervalX: mainX, nextIntervalX: nextX, barposition: -20)
        self.setupCalendarTitleLabel()
        AnimationcalendarBar(-20)
    }
    
    //次月を表示するメソッド
    func nextCalendarSettings() {
        let prevX = (15+50*(41%7)+60)
        let mainX = (15+50*(41%7)+60)
        let nextX = 15

        self.setupNextCalendarData()
        Animationcalendar(-prevX, mainIntervalX: -mainX, nextIntervalX: nextX, barposition: 20)
        
        self.setupCalendarTitleLabel()
        AnimationcalendarBar(20)
    }
    
    //今月を表示するメソッド
    func NowCalendarSettings(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Began {
            
            let rightX = (15+50*(41%7)+60)
            let centerX = 15

            let position = CompareDay()
            setupCurrentCalendarData()
            setupCalendarTitleLabel()
            AnimationcalendarBar(position)
            
            //戻るアニメーションの場合は，今月のカレンダーを生成
            //それを画面左に設置しておく
            //進む場合は，今月のカレンダーを生成し画面右に設置しておく
            if position > 0 {
                self.removeCalendarButtonObjectWithArrayNumber(0)
                self.removeCalendarButtonObjectWithArrayNumber(2)
                self.generateCalendar(2, end: 3)
                
                Animationcalendar(-rightX, mainIntervalX: -rightX, nextIntervalX: centerX, barposition: Int(position))

            }else if position < 0 {
                self.removeCalendarButtonObjectWithArrayNumber(0)
                self.removeCalendarButtonObjectWithArrayNumber(2)
                self.generateCalendar(0, end: 1)
                
                Animationcalendar(centerX, mainIntervalX: rightX, nextIntervalX: rightX, barposition: Int(position))
            }
        }
    }
    
    //日付を比較してcalendarBarのアニメーション開始前の場所を返す
    func CompareDay() -> CGFloat{
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let currentNSDate = CommonMethod().CreateNSDate(year[1], month: month[1], day: day[1])
        let compareunit = calendar.compareDate(now_nsdate, toDate: currentNSDate, toUnitGranularity: .Day)
        var position:CGFloat = 0
        
        //今日より小さい(前の日付の場合)
        if compareunit == .OrderedAscending {
            position = -20
            
        //今日より大きい(後の日付の場合)
        }else if compareunit == .OrderedDescending {
        
            position = 20
        }
        
        //同じ月かどうかを判定する
        let nsdatesplit = CommonMethod().ReturnYearMonthDayWeekday(now_nsdate)
        if year[1] ==  nsdatesplit.year && month[1] == nsdatesplit.month {
            position = 0
        }
        
        return position
    }
    
}
