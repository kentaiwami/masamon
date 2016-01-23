//
//  ViewController.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift
import GradientCircularProgress

class MonthlySalaryShow: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
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
    
    var currentnsdate = NSDate()        //MonthlySalaryShowがデータ表示している日付を管理
    var pdfalltextarray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentnsdate = NSDate()
        
        //テキストビューの編集をできないようにする
        EarlyShiftText.editable = false
        Center1ShiftText.editable = false
        Center2ShiftText.editable = false
        Center3ShiftText.editable = false
        LateShiftText.editable = false
        OtherShiftText.editable = false
        
        let today = NSDate()
        let date = ReturnYearMonthDayWeekday(today)         //日付を西暦,月,日,曜日に分けて取得
        self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day)           //データ表示へ分けた日付を渡す
        CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 (\(self.ReturnWeekday(date.weekday)))"
        
        //アイコンとボタンの設置
        for(var i = 0; i < 2; i++){
            let imageview = UIImageView()
            imageview.image = UIImage(named: iconnamearray[i])
            imageview.frame = CGRectMake(CGFloat(iconpositionarray[i]), 20, 42, 40)
            self.view.addSubview(imageview)
            
            let calenderbutton = UIButton()
            calenderbutton.setImage(UIImage(named: calenderbuttonnamearray[i]), forState: .Normal)
            calenderbutton.frame = CGRectMake(CGFloat(calenderbuttonposition[i]), 548, 50, 48)
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
    
    //pickerview,label,シフトの表示を更新する
    override func viewDidAppear(animated: Bool) {

        shiftlist.removeAllObjects()
        if(DBmethod().DBRecordCount(ShiftDB) != 0){
            for(var i = DBmethod().DBRecordCount(ShiftDB)-1; i >= 0; i--){
                shiftlist.addObject(DBmethod().ShiftDBGet(i))
            }
            
            //pickerviewのデフォルト表示
            SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1))
        }
        
        myUIPicker.reloadAllComponents()
        
        let today = self.currentnsdate
        let date = ReturnYearMonthDayWeekday(today)         //日付を西暦,月,日,曜日に分けて取得
        self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day)           //データ表示へ分けた日付を渡す
        CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 (\(self.ReturnWeekday(date.weekday)))"
    }
    
    //バックグラウンドで保存しながらプログレスを表示する
    let progress = GradientCircularProgress()
    let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
    var staffshiftcountflag = true
    var staffnamecountflag = true
    func savedata() {

        if(self.appDelegate.filename.containsString(".xlsx")){
            progress.show(style: OrangeClearStyle())
            dispatch_async_global { // ここからバックグラウンドスレッド

                //新規シフトがあるか確認する
                XLSXmethod().CheckShift()
                
                //スタッフ名にシフト文字が含まれていたら記録する
                XLSXmethod().CheckStaffName()
                
                //新規シフト認識エラーがない場合は月給計算を行う
                if(self.appDelegate.errorshiftnamexlsx.count == 0){
                    XLSXmethod().ShiftDBOneCoursRegist(self.appDelegate.filename, importpath: self.Libralypath+"/"+self.appDelegate.filename, update: self.appDelegate.update)
                    XLSXmethod().UserMonthlySalaryRegist(self.appDelegate.filename)
                }
                
                
                self.dispatch_async_main { // ここからメインスレッド
                    self.progress.dismiss({ () -> Void in
                        
                        /*pickerview,label,シフトの表示を更新する*/
                        self.shiftlist.removeAllObjects()
                        if(DBmethod().DBRecordCount(ShiftDB) != 0){
                            for(var i = DBmethod().DBRecordCount(ShiftDB)-1; i >= 0; i--){
                                self.shiftlist.addObject(DBmethod().ShiftDBGet(i))
                            }
                            self.SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1))
                        }
                        
                        self.myUIPicker.reloadAllComponents()
                        
                        let today = self.currentnsdate
                        let date = self.ReturnYearMonthDayWeekday(today)
                        self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day)
                        self.CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 (\(self.ReturnWeekday(date.weekday)))"

                        if(self.appDelegate.errorshiftnamexlsx.count != 0){  //新規シフト名がある場合
                            if(self.staffshiftcountflag){
                                self.appDelegate.errorshiftnamefastcount = self.appDelegate.errorshiftnamexlsx.count
                                self.staffshiftcountflag = false
                            }
                            self.StaffShiftErrorAlertShowXLSX()
                        }
                    })
                }
            }
        //取り込みがPDFの場合
        }else{
            progress.show(style: OrangeClearStyle())
            dispatch_async_global{
                
                self.pdfalltextarray = PDFmethod().AllTextGet()
                let pdfdata = PDFmethod().SplitDayShiftGet(self.pdfalltextarray)
                
                //エラーがない場合はデータベースへ書き込みを行う
                if(self.appDelegate.errorstaffnamepdf.count == 0 && self.appDelegate.errorshiftnamepdf.count == 0){
                    PDFmethod().RegistDataBase(pdfdata.shiftarray, shiftcours: pdfdata.shiftcours, importname: self.appDelegate.filename, importpath: self.Libralypath+"/"+self.appDelegate.filename,update: self.appDelegate.update)
                    PDFmethod().UserMonthlySalaryRegist(pdfdata.shiftarray, shiftcours: pdfdata.shiftcours,importname: self.appDelegate.filename)
                }
                
                self.dispatch_async_main{
                    self.progress.dismiss({ () -> Void in

                        if(self.appDelegate.errorstaffnamepdf.count != 0){  //スタッフ名認識エラーがある場合
                          if(self.staffnamecountflag){
                                self.appDelegate.errorstaffnamefastcount = self.appDelegate.errorstaffnamepdf.count
                                self.staffnamecountflag = false
                            }
                            self.StaffNameErrorAlertShowPDF()
                        }else{
                            if(self.appDelegate.errorshiftnamepdf.count != 0){  //シフト認識エラーがある場合
                                if(self.staffshiftcountflag){
                                    self.appDelegate.errorshiftnamefastcount = self.appDelegate.errorshiftnamepdf.count
                                    self.staffshiftcountflag = false
                                }
                                self.StaffShiftErrorAlertShowPDF()
                            }
                        }
                        
                        /*pickerview,label,シフトの表示を更新する*/
                        self.shiftlist.removeAllObjects()
                        if(DBmethod().DBRecordCount(ShiftDB) != 0){
                            for(var i = DBmethod().DBRecordCount(ShiftDB)-1; i >= 0; i--){
                                self.shiftlist.addObject(DBmethod().ShiftDBGet(i))
                            }
                            self.SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1))
                        }
                        
                        self.myUIPicker.reloadAllComponents()
                        
                        let today = self.currentnsdate
                        let date = self.ReturnYearMonthDayWeekday(today)
                        self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day)
                        self.CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 (\(self.ReturnWeekday(date.weekday)))"
                        
                    })
                }
            }
        }
        
    }
    
    //PDFでスタッフ名認識エラーがある場合に表示してデータ入力をさせるためのアラート
    func StaffNameErrorAlertShowPDF(){
        let errorstaffnametext = appDelegate.errorstaffnamepdf
        let donecount = appDelegate.errorstaffnamefastcount - appDelegate.errorstaffnamepdf.count
        
        let alert:UIAlertController = UIAlertController(title:"\(donecount+1)/\(appDelegate.errorstaffnamefastcount)人    スタッフ名が認識できませんでした",
            message: errorstaffnametext[0],
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let addAction:UIAlertAction = UIAlertAction(title: "追加",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    
                    if(textFields![0].text != ""){   //テキストフィールドに値が入っている場合
                        
                        let staffnamerecord = StaffNameDB()
                        staffnamerecord.id = DBmethod().DBRecordCount(StaffNameDB)
                        staffnamerecord.name = textFields![0].text!
                        
                        DBmethod().AddandUpdate(staffnamerecord, update: true)
                        
                        self.savedata()
                    }else{
                        self.StaffNameErrorAlertShowPDF()
                    }
                }
        })
        
        alert.addAction(addAction)
        
        //シフト名入力用のtextfieldを追加
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
            text.placeholder = "スタッフ名の入力"
            text.returnKeyType = .Next
            text.tag = 0
            text.delegate = self
        })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //PDFでシフト認識エラーがある場合に表示してデータ入力をさせるためのアラート
    func StaffShiftErrorAlertShowPDF(){
        
        let index = self.appDelegate.errorshiftnamepdf.startIndex.advancedBy(0)
        let keys = self.appDelegate.errorshiftnamepdf.keys[index]
        let values = self.appDelegate.errorshiftnamepdf.values[index]

        var flag = false
        let donecount = appDelegate.errorshiftnamefastcount - appDelegate.errorshiftnamepdf.count

        let alert:UIAlertController = UIAlertController(title:"\(donecount+1)/\(appDelegate.errorshiftnamefastcount)人" + "\n" + keys+"さんのシフトが取り込めません",
            message: values + "\n\n" + "<シフトの名前> \n 例) 出勤 \n\n" + "<シフトのグループ> \n 例) 早番 or 中1 or 中2 or 中3 or 遅番 or 休み or その他 \n\n" + "<シフトの時間> \n 例) 開始時間が9時,終了時間が17時の場合は、9:00 17:00 \n 時間が不明な場合は、なし",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let addAction:UIAlertAction = UIAlertAction(title: "追加",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {
                        //各textにアクセス
//                        print(textField.text)
                        
                        if(textField.text == ""){
                            flag = false
                        }else{
                            flag = true
                        }
                    }
                    
                    if(flag){   //テキストフィールドに値が全て入っている場合
                        
                        if(textFields![1].text! == "休み"){
                            let holidayrecord = self.CreateHolidayDBRecord(textFields![0].text!)
                            DBmethod().AddandUpdate(holidayrecord, update: true)
                            
                        }else{
                            let shiftsystemrecord = self.CreateShiftSystemDBRecord(textFields![0].text!, shiftgroup: textFields![1].text!, shifttime: textFields![2].text!)
                            DBmethod().AddandUpdate(shiftsystemrecord, update: true)
                        }
                        
                        self.savedata()
                    }else{
                        self.StaffShiftErrorAlertShowPDF()
                    }
                }
        })
        
        let skipAction:UIAlertAction = UIAlertAction(title: "スキップ",
            style: UIAlertActionStyle.Destructive,
            handler:{
                (action:UIAlertAction!) -> Void in
                self.appDelegate.skipstaff.append(keys)
                
                self.savedata()
            })
        
        alert.addAction(addAction)
        alert.addAction(skipAction)

        //シフト名入力用のtextfieldを追加
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
            text.placeholder = "シフトの名前を入力"
            text.returnKeyType = .Next
            text.tag = 1
            text.delegate = self
        })
        
        //シフト体制グループ用のtextfieldを追加
        alert.addTextFieldWithConfigurationHandler({ (text:UITextField!) -> Void in
            text.placeholder = "シフトのグループを入力"
            text.returnKeyType = .Next
            text.tag = 1
            text.delegate = self
        })
        
        //シフトの時間入力用のtextfieldを追加
        alert.addTextFieldWithConfigurationHandler({ (text:UITextField!) -> Void in
            text.placeholder = "シフトの時間を入力"
            text.returnKeyType = .Next
            text.tag = 0
            text.delegate = self
        })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //XLSXで新規シフト体制名が含まれていた場合に表示するアラート
    func StaffShiftErrorAlertShowXLSX(){
        let errorshiftnamexlsxarray = self.appDelegate.errorshiftnamexlsx
        print(errorshiftnamexlsxarray)
        var flag = false
        let donecount = appDelegate.errorshiftnamefastcount - appDelegate.errorshiftnamepdf.count
        
        let alert:UIAlertController = UIAlertController(title:"\(donecount+1)/\(appDelegate.errorshiftnamefastcount)人" + "\n" + errorshiftnamexlsxarray[0]+"のシフトに関する情報を入力して下さい",
            message: "<シフトの名前> \n 例) 出勤 \n\n" + "<シフトのグループ> \n 例) 早番 or 中1 or 中2 or 中3 or 遅番 or 休み or その他 \n\n" + "<シフトの時間> \n 例) 開始時間が9時,終了時間が17時の場合は、9:00 17:00 \n 時間が不明な場合は、なし",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let addAction:UIAlertAction = UIAlertAction(title: "追加",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {
                        //各textにアクセス
                        //                        print(textField.text)
                        
                        if(textField.text == ""){
                            flag = false
                        }else{
                            flag = true
                        }
                    }
                    
                    if(flag){   //テキストフィールドに値が全て入っている場合
                        
                        if(textFields![1].text! == "休み"){
                            let holidayrecord = self.CreateHolidayDBRecord(textFields![0].text!)
                            DBmethod().AddandUpdate(holidayrecord, update: true)
                            
                        }else{
                            let shiftsystemrecord = self.CreateShiftSystemDBRecord(textFields![0].text!, shiftgroup: textFields![1].text!, shifttime: textFields![2].text!)
                            DBmethod().AddandUpdate(shiftsystemrecord, update: true)
                        }
                        
                        self.savedata()
                    }else{
                        self.StaffShiftErrorAlertShowXLSX()
                    }
                }
        })
        
        alert.addAction(addAction)
        
        //シフト名入力用のtextfieldを追加
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
            text.placeholder = "シフトの名前を入力"
            text.returnKeyType = .Next
            text.tag = 1
            text.delegate = self
        })
        
        //シフト体制グループ用のtextfieldを追加
        alert.addTextFieldWithConfigurationHandler({ (text:UITextField!) -> Void in
            text.placeholder = "シフトのグループを入力"
            text.returnKeyType = .Next
            text.tag = 1
            text.delegate = self
        })
        
        //シフトの時間入力用のtextfieldを追加
        alert.addTextFieldWithConfigurationHandler({ (text:UITextField!) -> Void in
            text.placeholder = "シフトの時間を入力"
            text.returnKeyType = .Next
            text.tag = 0
            text.delegate = self
        })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //アラートに表示するテキストフィールドのreturnkeyをタップした時に呼ばれるメソッド
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        if((textField.text?.isEmpty) != nil){
            
            //シフト名,シフトグループ名の場所にカーソルがある時はボタンを有効にする
            switch(textField.tag){
            case 1:
                return true
            default:
                return false
            }
        }else{
            return false
        }
    }
    
    //受け取ったテキストからHolidayDBのレコードを生成して返す関数
    func CreateHolidayDBRecord(shiftname: String) -> HolidayDB{
        let record = HolidayDB()
        
        record.id = DBmethod().DBRecordCount(HolidayDB)
        record.name = shiftname
        
        return record
    }
    
    //受け取ったテキストからShiftSystemDBのレコードを生成して返す関数
    func CreateShiftSystemDBRecord(shiftname: String, shiftgroup: String, shifttime: String) -> ShiftSystemDB{
        let record = ShiftSystemDB()
        var gid = 0
        var start = 0.0
        var end = 0.0
        
        switch(shiftgroup){
        case "早番":
            gid = 0
            
        case "中1":
            gid = 1
            
        case "中2":
            gid = 2
            
        case "中3":
            gid = 3
            
        case "遅番":
            gid = 4
            
        default:    //その他
            gid = 5
        }
        
        if(shifttime == "なし"){
            start = 0.0
            end = 0.0
        }else{
            var index = shifttime.startIndex
            var timearray: [Double] = []
            
            for(var i = 0; i < 2; i++){
                var charactertmp = ""

                while(shifttime[index] != ":"){
                    charactertmp += String(shifttime[index])
                    index = index.successor()
                }
                
                let hour = Double(charactertmp)
                index = index.successor()
                charactertmp = ""
                
                while(String(shifttime[index]) != " "){
                    
                    charactertmp += String(shifttime[index])

                    if(shifttime.endIndex.predecessor() != index){
                        index = index.successor()
                    }else{
                        break
                    }
                }
                
                let minute = Double(charactertmp)! / 60.0

                timearray.append(hour! + minute)
                index = index.successor()
                
            }

            start = timearray[0]
            end = timearray[1]
        }
        
        record.id = DBmethod().DBRecordCount(ShiftSystemDB)
        record.name = shiftname
        record.groupid = gid
        record.starttime = start
        record.endtime = end
        
//        print(record)
        return record
    }
    
    //並行処理で使用
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    //並行処理で使用
    func dispatch_async_global(block: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
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
    
    func FileSaveSuccessfulAlertShow(){
        //ファイルの保存が行われていたら
        if(appDelegate.filesavealert){
            self.savedata()
            appDelegate.filesavealert = false
        }
    }
    
    //画面下のカレンダー操作のボタンをタップした際に動作
    func TapCalenderButton(sender: UIButton){
        switch(sender.tag){
        case 0:
            let nsdatesplit = self.ReturnYearMonthDayWeekday(currentnsdate)
            let newnsdate = self.DateSerial(nsdatesplit.year, month: nsdatesplit.month, day: nsdatesplit.day-1)
            currentnsdate = newnsdate
            
            let currentnsdatesplit = self.ReturnYearMonthDayWeekday(currentnsdate)
            self.ShowAllData(CommonMethod().Changecalendar(currentnsdatesplit.year, calender: "A.D"), m: currentnsdatesplit.month, d: currentnsdatesplit.day)
            CalenderLabel.text = "\(currentnsdatesplit.year)年\(currentnsdatesplit.month)月\(currentnsdatesplit.day)日 (\(self.ReturnWeekday(currentnsdatesplit.weekday)))"
            
        case 1:
            let nsdatesplit = self.ReturnYearMonthDayWeekday(currentnsdate)
            let newnsdate = self.DateSerial(nsdatesplit.year, month: nsdatesplit.month, day: nsdatesplit.day+1)
            currentnsdate = newnsdate
            
            let currentnsdatesplit = self.ReturnYearMonthDayWeekday(currentnsdate)
            self.ShowAllData(CommonMethod().Changecalendar(currentnsdatesplit.year, calender: "A.D"), m: currentnsdatesplit.month, d: currentnsdatesplit.day)
            CalenderLabel.text = "\(currentnsdatesplit.year)年\(currentnsdatesplit.month)月\(currentnsdatesplit.day)日 (\(self.ReturnWeekday(currentnsdatesplit.weekday)))"
        default:
            break
        }
    }
    
    //"今日"をタップした時の動作
    @IBAction func TapTodayButton(sender: AnyObject) {
        let today = NSDate()
        let date = ReturnYearMonthDayWeekday(today)         //日付を西暦,月,日,曜日に分けて取得
        self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day)           //データ表示へ分けた日付を渡す
        CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 (\(self.ReturnWeekday(date.weekday)))"

        currentnsdate = today
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
                switch(shiftsystemresult![0].groupid){
                case 0:
                    staffshiftarray[0] = staffshiftarray[0] + staffname + "、"
                case 1:
                    staffshiftarray[1] = staffshiftarray[1] + staffname + "、"
                case 2:
                    staffshiftarray[2] = staffshiftarray[2] + staffname + "、"
                case 3:
                    staffshiftarray[3] = staffshiftarray[3] + staffname + "、"
                case 4:
                    staffshiftarray[4] = staffshiftarray[4] + staffname + "、"
                case 5:
                    staffshiftarray[5] = staffshiftarray[5] + staffname + "(\(staffshift))" + "、"
                default:
                    break
                }
            }
            
            nowindex = nowindex.successor()
        }
        
        //最後の文字を削除するための処理
        for(var i = 0; i < staffshiftarray.count; i++){
            if(staffshiftarray[i] != ""){
                var str = staffshiftarray[i]
                let endPoint = str.characters.count - 1
                str = str.substringToIndex(str.startIndex.advancedBy(endPoint))
                staffshiftarray[i] = str
            }
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
        
        let fontsize:CGFloat = 14
        
        if(DBmethod().TheDayStaffGet(y, month: m, date: d) == nil){
            let whiteAttribute = [ NSForegroundColorAttributeName: UIColor.hex("BEBEBE", alpha: 1.0),NSFontAttributeName: UIFont.systemFontOfSize(fontsize)]

            EarlyShiftText.attributedText = NSMutableAttributedString(string: "早番：No Data", attributes: whiteAttribute)
            Center1ShiftText.attributedText = NSMutableAttributedString(string: "中1：No Data", attributes: whiteAttribute)
            Center2ShiftText.attributedText = NSMutableAttributedString(string: "中2：No Data", attributes: whiteAttribute)
            Center3ShiftText.attributedText = NSMutableAttributedString(string: "中3：No Data", attributes: whiteAttribute)
            LateShiftText.attributedText = NSMutableAttributedString(string: "遅番：No Data", attributes: whiteAttribute)
            OtherShiftText.attributedText = NSMutableAttributedString(string: "その他：No Data", attributes: whiteAttribute)
        }else{
            let shiftdetaidb = DBmethod().TheDayStaffGet(y, month: m, date: d)
            var splitedstaffarray = self.SplitStaffShift(shiftdetaidb![0].staff)
            
            //スタッフ名がない場合にメッセージを代入するためのループ
            for(var i = 0; i < splitedstaffarray.count; i++){
                if(splitedstaffarray[i] == ""){
                    splitedstaffarray[i] = "該当スタッフなし"
                }
            }
            
            let shiftarray = ["早番：","中1：","中2：","中3：","遅番：","その他："]
            //テキストビューにスタッフ名を羅列するためのループ
            for(var i = 0; i < splitedstaffarray.count; i++){
                var myString = NSMutableAttributedString()
                if((splitedstaffarray[i].rangeOfString(DBmethod().UserNameGet())) != nil){
                    
                    let textviewnsstring = (shiftarray[i] + splitedstaffarray[i]) as NSString
                    let usernamelocation = textviewnsstring.rangeOfString(DBmethod().UserNameGet()).location
                    let usernamelength = textviewnsstring.rangeOfString(DBmethod().UserNameGet()).length
                    let myAttribute = [ NSFontAttributeName: UIFont.systemFontOfSize(fontsize+3) ]
                    let whiteAttribute = [ NSForegroundColorAttributeName: UIColor.whiteColor()]

                    myString = NSMutableAttributedString(string: shiftarray[i] + splitedstaffarray[i], attributes: myAttribute )
                    
                    let myRange = NSRange(location: usernamelocation, length: usernamelength)                                       //ユーザ名のRange
                    let myRange2 = NSRange(location: 0, length: usernamelocation)                                                   //シフト体制のRange
                    
                    //ユーザ名が文字列の最後でない場合
                    if(textviewnsstring.length != (usernamelocation+usernamelength)){
                        let userposition = usernamelocation+usernamelength
                        let myRange3 = NSRange(location: (usernamelocation+usernamelength), length: (textviewnsstring.length-userposition))  //ユーザ名より後ろのRange
                        myString.addAttributes(whiteAttribute, range: myRange3)
                    }

                    myString.addAttributes(whiteAttribute, range: myRange2)
                    myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.hex("ff33ff", alpha: 1.0), range: myRange)                //ユーザ名強調表示
                    
                    switch(i){
                    case 0:
                        EarlyShiftText.attributedText = myString
                    case 1:
                        Center1ShiftText.attributedText = myString
                    case 2:
                        Center2ShiftText.attributedText = myString
                    case 3:
                        Center3ShiftText.attributedText = myString
                    case 4:
                        LateShiftText.attributedText = myString
                    case 5:
                        OtherShiftText.attributedText = myString
                    default:
                        break
                    }
                }else{      //ユーザ名が含まれていない場合の表示
                    let myAttribute = [ NSFontAttributeName: UIFont.systemFontOfSize(fontsize) ]
                    let myRange = NSRange(location: 0, length: (shiftarray[i] + splitedstaffarray[i]).characters.count)
                    
                    myString = NSMutableAttributedString(string: shiftarray[i] + splitedstaffarray[i], attributes: myAttribute )
                    myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.hex("BEBEBE", alpha: 1.0), range: myRange)
                    switch(i){
                    case 0:
                        EarlyShiftText.attributedText = myString
                    case 1:
                        Center1ShiftText.attributedText = myString
                    case 2:
                        Center2ShiftText.attributedText = myString
                    case 3:
                        Center3ShiftText.attributedText = myString
                    case 4:
                        LateShiftText.attributedText = myString
                    case 5:
                        OtherShiftText.attributedText = myString
                    default:
                        break
                    }
                }
            }
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
    
    func DateSerial(year : Int, month : Int, day : Int) -> NSDate {
        let comp = NSDateComponents()
        comp.year = year
        comp.month = month
        comp.day = day
        let cal = NSCalendar.currentCalendar()
        let date = cal.dateFromComponents(comp)
        
        return date!
    }
}

