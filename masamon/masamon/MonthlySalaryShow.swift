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
    
    let shiftdb = ShiftDB()
    let shiftdetaildb = ShiftDetailDB()
    var shiftlist: NSMutableArray = []
    var onecourspicker: UIPickerView = UIPickerView()
    @IBOutlet weak var SaralyLabel: UILabel!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    let alertview = UIImageView()
    
    var currentnsdate = NSDate()        //MonthlySalaryShowがデータ表示している日付を管理
    
    let wavyline: [String] = ["〜"]
    let time = CommonMethod().GetTimeNotSpecifiedVer()
    let shiftgroupname = CommonMethod().GetShiftGroupName()
    var shiftgroupnameUIPicker: UIPickerView = UIPickerView()
    var shifttimeUIPicker: UIPickerView = UIPickerView()
    var pickerviewtoolBar = UIToolbar()
    var pickerdoneButton = UIBarButtonItem()
    
    var shiftgroupnametextfield = UITextField()
    var shifttimetextfield = UITextField()
    
    var CalenderLabel = UILabel()
    
    let shiftarray = [" 早番："," 中1："," 中2："," 中3："," 遅番："," その他："]

    var ShiftLabelArray: [[UILabel]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupShiftLabel()      //シフトを表示するラベルを設置する
        
        self.setupTapGesture()      //タップを検出するジェスチャーを追加
        
        self.setupdayofweekLabel()  //日曜日〜土曜日までのラベルを設置する
        
        self.SetupDayButton(0)      //1週間分の日付を表示するボタンを設置する
        
        //シフト時間を選択して表示するテキストフィールドのデフォルト表示を指定
        starttime = time[0]
        endtime = time[0]
        
        //シフトグループを選択するpickerview
        shiftgroupnameUIPicker.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 200.0)
        shiftgroupnameUIPicker.delegate = self
        shiftgroupnameUIPicker.dataSource = self
        shiftgroupnameUIPicker.tag = 2
        
        //シフト時間を選択するpickerview
        shifttimeUIPicker.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 200.0)
        shifttimeUIPicker.delegate = self
        shifttimeUIPicker.dataSource = self
        shifttimeUIPicker.tag = 3
        
        //pickerviewに表示するツールバー
        pickerviewtoolBar.barStyle = UIBarStyle.Default
        pickerviewtoolBar.translucent = true
        pickerviewtoolBar.sizeToFit()
        
        pickerdoneButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MonthlySalaryShow.donePicker(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        pickerviewtoolBar.setItems([flexSpace,pickerdoneButton], animated: false)
        pickerviewtoolBar.userInteractionEnabled = true
        
        
        currentnsdate = NSDate()
        
        let today = NSDate()
        
        //前日、当日、翌日のラベルにデータをセットする
        let daycontrol = [-1,0,1]
        for i in 0..<ShiftLabelArray.count {
            //control[i]分だけ日付を操作したnsdateを作成する
            let calendar = NSCalendar.currentCalendar()
            let daycontroled_nsdate = calendar.dateByAddingUnit(.Day, value: daycontrol[i], toDate: today, options: [])
            let daycontroled_splitday = self.ReturnYearMonthDayWeekday(daycontroled_nsdate!)

            self.ShowAllData(CommonMethod().Changecalendar(daycontroled_splitday.year, calender: "A.D"), m: daycontroled_splitday.month, d: daycontroled_splitday.day, arraynumber: i)
        }
        
        let date = self.ReturnYearMonthDayWeekday(today)
        //日付を表示するラベルの初期設定
        CalenderLabel.frame = CGRectMake(8, 240, 359, 33)
        CalenderLabel.backgroundColor = UIColor.clearColor()
        CalenderLabel.textColor = UIColor.whiteColor()
        CalenderLabel.textAlignment = NSTextAlignment.Center
        self.SetCalenderLabel(date.year, month: date.month, day: date.day, weekday: date.weekday)

        self.view.addSubview(CalenderLabel)
        
        NSTimer.scheduledTimerWithTimeInterval(1.0,target:self,selector:#selector(MonthlySalaryShow.FileSaveSuccessfulAlertShow),
                                               userInfo: nil, repeats: true);
        
        //アプリがアクティブになったとき
        notificationCenter.addObserver(self,selector: #selector(MonthlySalaryShow.MonthlySalaryShowViewActived),name:UIApplicationDidBecomeActiveNotification,object: nil)
        
        //PickerViewの追加
        onecourspicker.frame = CGRectMake(-20,35,self.view.bounds.width/2+20, 150.0)
        onecourspicker.delegate = self
        onecourspicker.dataSource = self
        onecourspicker.tag = 1
        self.view.addSubview(onecourspicker)
        
        //NSArrayへの追加
        if DBmethod().DBRecordCount(ShiftDB) != 0 {
            for i in (0 ... DBmethod().DBRecordCount(ShiftDB)-1).reverse(){
                shiftlist.addObject(DBmethod().ShiftDBGet(i))
            }
            
            //pickerviewのデフォルト表示
            SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1))
        }
    }
    
    //pickerview,label,シフトの表示を更新する
    override func viewDidAppear(animated: Bool) {
        
        shiftlist.removeAllObjects()
        if DBmethod().DBRecordCount(ShiftDB) != 0 {
            for i in (0 ... DBmethod().DBRecordCount(ShiftDB)-1).reverse(){
                shiftlist.addObject(DBmethod().ShiftDBGet(i))
            }
            
            //pickerviewのデフォルト表示
            SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1))
        }else{
            SaralyLabel.text = ""
        }
        
        onecourspicker.reloadAllComponents()
        
        let today = self.currentnsdate
        let date = ReturnYearMonthDayWeekday(today)         //日付を西暦,月,日,曜日に分けて取得
        self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 1)           //データ表示へ分けた日付を渡す
        CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 \(self.ReturnWeekday(date.weekday))曜日"
        
        appDelegate.screennumber = 0
    }
    
    //バックグラウンドで保存しながらプログレスを表示する
    let progress = GradientCircularProgress()
    let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
    var staffshiftcountflag = true
    var staffnamecountflag = true
    func savedata() {
        
        if self.appDelegate.filename.containsString(".xlsx") {
            progress.show(style: OrangeClearStyle())
            dispatch_async_global { // ここからバックグラウンドスレッド
                
                //新規シフトがあるか確認する
                XLSXmethod().CheckShift()
                
                //スタッフ名にシフト文字が含まれていたら記録する
                XLSXmethod().CheckStaffName()
                
                //新規シフト認識エラーがない場合は月給計算を行う
                if self.appDelegate.errorshiftnamexlsx.count == 0 {
                    XLSXmethod().ShiftDBOneCoursRegist(self.appDelegate.filename, importpath: self.Libralypath+"/"+self.appDelegate.filename, update: self.appDelegate.update)
                    XLSXmethod().UserMonthlySalaryRegist(self.appDelegate.filename)
                }
                
                
                self.dispatch_async_main { // ここからメインスレッド
                    self.progress.dismiss({ () -> Void in
                        
                        /*pickerview,label,シフトの表示を更新する*/
                        self.shiftlist.removeAllObjects()
                        if DBmethod().DBRecordCount(ShiftDB) != 0 {
                            for i in (0 ... DBmethod().DBRecordCount(ShiftDB)-1).reverse(){
                                self.shiftlist.addObject(DBmethod().ShiftDBGet(i))
                            }
                            self.SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1))
                        }
                        
                        self.onecourspicker.reloadAllComponents()
                        
                        let today = self.currentnsdate
                        let date = self.ReturnYearMonthDayWeekday(today)
                        self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 1)
                        self.CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 \(self.ReturnWeekday(date.weekday))曜日"
                        
                        if self.appDelegate.errorshiftnamexlsx.count != 0 {  //新規シフト名がある場合
                            if self.staffshiftcountflag {
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
                
                //PDF内のデータをテキスト配列に格納＆エラーのチェック
                var pdfalltextarray: [String] = []
                pdfalltextarray = PDFmethod().AllTextGet()
                let pdfdata = PDFmethod().SplitDayShiftGet(pdfalltextarray)
                
                
                //エラーがない場合はデータベースへ書き込みを行う
                if self.appDelegate.errorstaffnamepdf.count == 0 && self.appDelegate.errorshiftnamepdf.count == 0 {
                    PDFmethod().RegistDataBase(pdfdata.shiftarray, shiftcours: pdfdata.shiftcours, importname: self.appDelegate.filename, importpath: self.Libralypath+"/"+self.appDelegate.filename,update: self.appDelegate.update)
                    PDFmethod().UserMonthlySalaryRegist(pdfdata.shiftarray, shiftcours: pdfdata.shiftcours,importname: self.appDelegate.filename)
                }
                
                self.dispatch_async_main{
                    self.progress.dismiss({ () -> Void in
                        
                        if self.appDelegate.errorstaffnamepdf.count != 0 {  //スタッフ名認識エラーがある場合
                            if self.staffnamecountflag {
                                self.appDelegate.errorstaffnamefastcount = self.appDelegate.errorstaffnamepdf.count
                                self.staffnamecountflag = false
                            }
                            self.StaffNameErrorAlertShowPDF()
                        }else{
                            if self.appDelegate.errorshiftnamepdf.count != 0 {  //シフト認識エラーがある場合
                                if self.staffshiftcountflag {
                                    self.appDelegate.errorshiftnamefastcount = self.appDelegate.errorshiftnamepdf.count
                                    self.staffshiftcountflag = false
                                }
                                self.StaffShiftErrorAlertShowPDF()
                            }
                        }
                        
                        /*pickerview,label,シフトの表示を更新する*/
                        self.shiftlist.removeAllObjects()
                        if DBmethod().DBRecordCount(ShiftDB) != 0 {
                            for i in (0 ... DBmethod().DBRecordCount(ShiftDB)-1).reverse(){
                                self.shiftlist.addObject(DBmethod().ShiftDBGet(i))
                            }
                            self.SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1))
                        }
                        
                        self.onecourspicker.reloadAllComponents()
                        
                        let today = self.currentnsdate
                        let date = self.ReturnYearMonthDayWeekday(today)
                        self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 1)
                        self.CalenderLabel.text = "\(date.year)年\(date.month)月\(date.day)日 \(self.ReturnWeekday(date.weekday))曜日"
                        
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
        
        let addAction:UIAlertAction = UIAlertAction(title: "スタッフ名を登録",
                                                    style: UIAlertActionStyle.Default,
                                                    handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                        if textFields != nil {
                                                            
                                                            if textFields![0].text != "" {   //テキストフィールドに値が入っている場合
                                                                
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
                                                        message: values + "\n\n" + "<シフトの名前> \n 例) 出勤 \n",
                                                        preferredStyle: UIAlertControllerStyle.Alert)
        
        let addAction:UIAlertAction = UIAlertAction(title: "追加",
                                                    style: UIAlertActionStyle.Default,
                                                    handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                        if textFields != nil {
                                                            for textField:UITextField in textFields! {
                                                                
                                                                if textField.text == "" {
                                                                    flag = false
                                                                    break
                                                                }else{
                                                                    flag = true
                                                                }
                                                            }
                                                            
                                                            if flag {   //テキストフィールドに値が全て入っている場合
                                                                
                                                                let newrecord = CommonMethod().CreateShiftSystemDBRecord(DBmethod().DBRecordCount(ShiftSystemDB),shiftname: textFields![0].text!, shiftgroup: textFields![1].text!, shifttime: textFields![2].text!, shiftstarttimerow: self.shiftstarttimeselectrow,shiftendtimerow: self.shiftendtimeselectrow)
                                                                DBmethod().AddandUpdate(newrecord, update: true)
                                                                
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
        
        alert.addAction(skipAction)
        alert.addAction(addAction)
        
        //シフト名入力用のtextfieldを追加
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
            text.placeholder = "シフトの名前を入力"
            text.returnKeyType = .Next
            text.tag = 0
            text.delegate = self
        })
        
        //シフトグループの選択内容を入れるテキストフィールドを追加
        alert.addTextFieldWithConfigurationHandler(configurationshiftgroupnameTextField)
        
        //シフト時間の選択内容を入れるテキストフィールドを追加
        alert.addTextFieldWithConfigurationHandler(configurationshifttimeTextField)
        
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //XLSXで新規シフト体制名が含まれていた場合に表示するアラート
    func StaffShiftErrorAlertShowXLSX(){
        let errorshiftnamexlsxarray = self.appDelegate.errorshiftnamexlsx
        print(errorshiftnamexlsxarray)
        var flag = false
        let donecount = appDelegate.errorshiftnamefastcount - appDelegate.errorshiftnamexlsx.count
        
        let alert:UIAlertController = UIAlertController(title:"\(donecount+1)/\(appDelegate.errorshiftnamefastcount)個" + "\n" + errorshiftnamexlsxarray[0]+"のシフトに関する情報を入力して下さい",
                                                        message: "<シフトの名前> \n 例) 出勤 \n",
                                                        preferredStyle: UIAlertControllerStyle.Alert)
        
        let addAction:UIAlertAction = UIAlertAction(title: "追加",
                                                    style: UIAlertActionStyle.Default,
                                                    handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                        if textFields != nil {
                                                            
                                                            for textField:UITextField in textFields! {
                                                                if textField.text == "" {
                                                                    flag = false
                                                                    break
                                                                }else{
                                                                    flag = true
                                                                }
                                                            }
                                                            
                                                            if flag {   //テキストフィールドに値が全て入っている場合
                                                                
                                                                let newrecord = CommonMethod().CreateShiftSystemDBRecord(DBmethod().DBRecordCount(ShiftSystemDB),shiftname: textFields![0].text!, shiftgroup: textFields![1].text!, shifttime: textFields![2].text!, shiftstarttimerow: self.shiftstarttimeselectrow,shiftendtimerow: self.shiftendtimeselectrow)
                                                                DBmethod().AddandUpdate(newrecord, update: true)
                                                                
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
            text.tag = 0
            text.delegate = self
        })
        
        //シフトグループの選択内容を入れるテキストフィールドを追加
        alert.addTextFieldWithConfigurationHandler(configurationshiftgroupnameTextField)
        
        //シフト時間の選択内容を入れるテキストフィールドを追加
        alert.addTextFieldWithConfigurationHandler(configurationshifttimeTextField)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //アラートに表示するテキストフィールドのreturnkeyをタップした時に呼ばれるメソッド
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField.text?.isEmpty) != nil {
            
            //シフト名,シフトグループ名の場所にカーソルがある時はボタンを有効にする
            switch(textField.tag){
            case 0:
                return true
            default:
                return false
            }
        }else{
            return false
        }
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
        
        if pickerView.tag == 1 {
            let attributedString = NSAttributedString(string: shiftlist[row] as! String, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
            return attributedString
        }else if pickerView.tag == 2 {
            let attributedString = NSAttributedString(string: shiftgroupname[row] , attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
            return attributedString
        }else{
            if component == 0 {
                let attributedString = NSAttributedString(string: time[row] , attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
                return attributedString
            }else if component == 1 {
                let attributedString = NSAttributedString(string: wavyline[row] , attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
                return attributedString
            }else{
                let attributedString = NSAttributedString(string: time[row] , attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
                return attributedString
            }
        }
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        if pickerView.tag == 1 || pickerView.tag == 2 {
            return 1
        }else{
            return 3
        }
    }
    
    //表示個数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 {
            return shiftlist.count
        }else if pickerView.tag == 2 {
            pickerdoneButton.tag = 2
            return shiftgroupname.count
        }else{
            pickerdoneButton.tag = 3
            if component == 0 {
                return time.count
            }else if component == 1 {
                return wavyline.count
            }else{
                return time.count
            }
        }
    }
    
    var starttime = ""
    var endtime = ""
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {            //取り込んだシフト
            if DBmethod().DBRecordCount(ShiftDB) != 0 {         //レコードが0のときは何もしない
                SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB)-1-row))
            }
            
        }else if pickerView.tag == 2 {      //シフトグループ選択
            shiftgroupnametextfield.text = shiftgroupname[row]
            pickerdoneButton.tag = 2
            shiftgroupselectrow = row
            
        }else if pickerView.tag == 3 {      //シフト時間選択
            
            if component == 0 {
                starttime = time[row]
                shiftstarttimeselectrow = row
            }else if component == 2 {
                endtime = time[row]
                shiftendtimeselectrow = row
            }
            pickerdoneButton.tag = 3
            
            shifttimetextfield.text = starttime + " " + wavyline[0] + " " + endtime
        }
    }
    
    //月給表示画面が表示(アプリがアクティブ)されたら呼ばれる
    func MonthlySalaryShowViewActived(){
        
        //ファイル数のカウント
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath(NSHomeDirectory() + "/Documents/Inbox")
        var filecount = 0
        while let _ = files?.nextObject() {
            filecount += 1
        }
        
        if DBmethod().InboxFileCountsGet() < filecount {   //ファイル数が増えていたら(新規でダウンロードしていたら)
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
        if appDelegate.filesavealert {
            self.savedata()
            appDelegate.filesavealert = false
        }
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
            
            if DBmethod().SearchShiftSystem(staffshift) == nil {     //シフト体制になかったらその他に分類
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
        for i in 0 ..< staffshiftarray.count{
            if staffshiftarray[i] != "" {
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
    
    //金額をコンマ付きの文字列として返す関数
    func GetCommaSalalyString(salaly: Int) -> String{
        
        var tmp = String(salaly)
        var index = tmp.endIndex.predecessor()
        var i = 1
        
        while(tmp.startIndex != index){
            
            if i % 3 == 0 {
                tmp.insert(",", atIndex: index)
            }
            
            i += 1
            index = index.predecessor()
        }
        
        return tmp
    }
    
    
    /*
     引数の説明
     y: 和暦
     m: 月
     d: 日
     */
    //受け取った日付のデータ表示を行う
    func ShowAllData(y: Int, m: Int, d: Int, arraynumber: Int){
        
        let fontsize:CGFloat = 14
        
        if DBmethod().TheDayStaffGet(y, month: m, date: d) == nil {
            let whiteAttribute = [ NSForegroundColorAttributeName: UIColor.hex("BEBEBE", alpha: 1.0),NSFontAttributeName: UIFont.systemFontOfSize(fontsize)]
            
            for i in 0..<ShiftLabelArray[arraynumber].count {
                ShiftLabelArray[arraynumber][i].attributedText = NSMutableAttributedString(string: shiftarray[i] + "No Data", attributes: whiteAttribute)
            }
            
        }else{
            let shiftdetaidb = DBmethod().TheDayStaffGet(y, month: m, date: d)
            var splitedstaffarray = self.SplitStaffShift(shiftdetaidb![0].staff)
            
            //スタッフ名がない場合にメッセージを代入するためのループ
            for i in 0 ..< splitedstaffarray.count{
                if splitedstaffarray[i] == "" {
                    splitedstaffarray[i] = "該当スタッフなし"
                }
            }
            
            //テキストビューにスタッフ名を羅列するためのループ
            for i in 0 ..< splitedstaffarray.count{
                var myString = NSMutableAttributedString()
                if (splitedstaffarray[i].rangeOfString(DBmethod().UserNameGet())) != nil {
                    
                    let textviewnsstring = (shiftarray[i] + splitedstaffarray[i]) as NSString
                    let usernamelocation = textviewnsstring.rangeOfString(DBmethod().UserNameGet()).location
                    let usernamelength = textviewnsstring.rangeOfString(DBmethod().UserNameGet()).length
                    let myAttribute = [ NSFontAttributeName: UIFont.systemFontOfSize(fontsize+3) ]
                    let whiteAttribute = [ NSForegroundColorAttributeName: UIColor.whiteColor()]
                    
                    myString = NSMutableAttributedString(string: shiftarray[i] + splitedstaffarray[i], attributes: myAttribute )
                    
                    let myRange = NSRange(location: usernamelocation, length: usernamelength)                                       //ユーザ名のRange
                    let myRange2 = NSRange(location: 0, length: usernamelocation)                                                   //シフト体制のRange
                    
                    //ユーザ名が文字列の最後でない場合
                    if textviewnsstring.length != (usernamelocation+usernamelength) {
                        let userposition = usernamelocation+usernamelength
                        let myRange3 = NSRange(location: (usernamelocation+usernamelength), length: (textviewnsstring.length-userposition))  //ユーザ名より後ろのRange
                        myString.addAttributes(whiteAttribute, range: myRange3)
                    }
                    
                    myString.addAttributes(whiteAttribute, range: myRange2)
                    myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.hex("ff33ff", alpha: 1.0), range: myRange)                //ユーザ名強調表示
                    
                    ShiftLabelArray[arraynumber][i].attributedText = myString
                    
                }else{      //ユーザ名が含まれていない場合の表示
                    let myAttribute = [ NSFontAttributeName: UIFont.systemFontOfSize(fontsize) ]
                    let myRange = NSRange(location: 0, length: (shiftarray[i] + splitedstaffarray[i]).characters.count)
                    
                    myString = NSMutableAttributedString(string: shiftarray[i] + splitedstaffarray[i], attributes: myAttribute )
                    myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.hex("BEBEBE", alpha: 1.0), range: myRange)
                    
                    ShiftLabelArray[arraynumber][i].attributedText = myString
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
    
    //年,月,日からNSDateを生成する
    func CreateNSDate(year : Int, month : Int, day : Int) -> NSDate {
        let comp = NSDateComponents()
        comp.year = year
        comp.month = month
        comp.day = day
        let cal = NSCalendar.currentCalendar()
        let date = cal.dateFromComponents(comp)
        
        return date!
    }
    
    //ツールバーの完了ボタンを押した時の関数
    func donePicker(sender:UIButton){
        
        if sender.tag == 2 {            //シフトグループの完了ボタン
            shiftgroupnametextfield.resignFirstResponder()
            shifttimetextfield.becomeFirstResponder()
        }else if sender.tag == 3 {      //シフト時間の完了ボタン
            shifttimetextfield.resignFirstResponder()
        }
    }
    
    
    //シフトのグループを入れるテキストフィールドの設定をする
    func configurationshiftgroupnameTextField(textField: UITextField!){
        textField.placeholder = "シフトのグループを入力"
        textField.inputView = self.shiftgroupnameUIPicker
        textField.inputAccessoryView = self.pickerviewtoolBar
        textField.tag = 1
        textField.delegate = self
        shiftgroupnametextfield = textField
    }
    
    //シフトの時間を入れるテキストフィールドの設定をする
    func configurationshifttimeTextField(textField: UITextField!){
        textField.placeholder = "シフトの時間を入力"
        textField.inputView = self.shifttimeUIPicker
        textField.inputAccessoryView = self.pickerviewtoolBar
        textField.tag = 2
        textField.delegate = self
        shifttimetextfield = textField
    }
    
    //シフトグループ,シフト時間(開始),シフト時間(終了)の選択箇所を記録する変数
    var shiftgroupselectrow = 0
    var shiftstarttimeselectrow = 0
    var shiftendtimeselectrow = 0
    
    //textfieldがタップされた時
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 1 {             //シフトグループ選択
            shiftgroupnameUIPicker.selectRow(shiftgroupselectrow, inComponent: 0, animated: true)
            textField.text = shiftgroupname[shiftgroupselectrow]
            
        }else if textField.tag == 2 {       //シフト時間選択
            shifttimeUIPicker.selectRow(shiftstarttimeselectrow, inComponent: 0, animated: true)
            shifttimeUIPicker.selectRow(shiftendtimeselectrow, inComponent: 2, animated: true)
            textField.text = time[shiftstarttimeselectrow] + " " + wavyline[0] + " " + time[shiftendtimeselectrow]
        }
    }
    
    //シェイクジェスチャーを有効にする
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(motion: UIEventSubtype,withEvent event: UIEvent?){
        
        if motion == UIEventSubtype.MotionShake {
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Video")
            self.presentViewController( targetViewController, animated: true, completion: nil)
        }
    }
    
    //曜日ラベルを表示するためのメソッド
    func setupdayofweekLabel(){
        //曜日ラベルの配置
        let monthName:[String] = ["日","月","火","水","木","金","土"]
        let calendarLabelIntervalX = 15;
        let calendarLabelX         = 50;
        let calendarLabelY         = 170;
        let calendarLabelWidth     = 45;
        let calendarLabelHeight    = 25;
        
        for i in 0...6{
            
            //ラベルを作成
            let calendarBaseLabel: UILabel = UILabel()
            
            //X座標の値をCGFloat型へ変換して設定
            calendarBaseLabel.frame = CGRectMake(
                CGFloat(calendarLabelIntervalX + calendarLabelX * (i % 7)),
                CGFloat(calendarLabelY),
                CGFloat(calendarLabelWidth),
                CGFloat(calendarLabelHeight)
            )
            
            //日曜日の場合は赤色を指定
            if i == 0 {
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(1.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0)
                )
                
                //土曜日の場合は青色を指定
            }else if i == 6 {
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(1.0), alpha: CGFloat(1.0)
                )
                
                //平日の場合は灰色を指定
            }else{
                
                //既に用意されている配色パターンの場合
                calendarBaseLabel.textColor = UIColor.whiteColor()
                
            }
            
            //曜日ラベルの配置
            calendarBaseLabel.text = String(monthName[i] as NSString)
            calendarBaseLabel.textAlignment = NSTextAlignment.Center
            calendarBaseLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
            self.view.addSubview(calendarBaseLabel)
        }
    }
    
    var buttontilearray:[String] = []
    var buttonobjectarray: [UIButton] = []
    
    func SetupDayButton(judgeswipe: Int){
        
        //todayと一致するボタンタイトルがある場合は常に文字を白表示にする
        let totayNSDate = NSDate()
        let todaysplitday = ReturnYearMonthDayWeekday(totayNSDate) //日付を西暦,月,日,曜日に分けて取得
        
        self.RemoveButtonObjects()
        
        //ボタンのタイトルを日付から計算して生成する
        let currentsplitdate = self.ReturnYearMonthDayWeekday(currentnsdate)
        self.SetDayArray(currentnsdate,pivotweekday:currentsplitdate.weekday)      //buttontilearrayへ値を格納する
        
        for i in 0...6{
            
            //配置場所の定義
            let positionX   = 15 + 50 * (i % 7)
            let positionY   = 195
            let buttonSize = 40;
            
            //ボタンをつくる
            let button: UIButton = UIButton()
            button.frame = CGRectMake(
                CGFloat(positionX),
                CGFloat(positionY),
                CGFloat(buttonSize),
                CGFloat(buttonSize)
            );
            
            //ボタンのデザインを決定する
            button.backgroundColor = UIColor.clearColor()
            button.setTitleColor(UIColor.grayColor(), forState: .Normal)
            button.titleLabel!.font = UIFont.systemFontOfSize(19)
            button.layer.cornerRadius = CGFloat(buttonSize/2)
            button.tag = Int(buttontilearray[i])!
            
            button.setTitle(buttontilearray[i], forState: .Normal)
            
            //currentnsdateと一致するボタンがある場合
            if currentsplitdate.day == Int(buttontilearray[i]) {
                button.backgroundColor = UIColor.hex("FF8E92", alpha: 1.0)
                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
            
            //今日の日付と一致するボタンがある場合は文字色を白にする
            if todaysplitday.day == Int(buttontilearray[i]) {
                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
            
            //配置したボタンに押した際のアクションを設定する
            button.addTarget(self, action: #selector(MonthlySalaryShow.TapDayButton(_:)), forControlEvents: .TouchUpInside)
            
            //ボタンを配置する
            self.view.addSubview(button)
            self.view.bringSubviewToFront(button)
            
            //土曜日を表示中に、日付を進めるスワイプが発生したら
            if judgeswipe == 1 && currentsplitdate.weekday == 1 {
                
                self.AnimationDayButton(button, beforeposition: positionX+300, afterpositon: positionX, positionY: positionY, buttonsize: buttonSize)
                
                //日曜日を表示中に、日付を戻すスワイプが発生したら
            }else if judgeswipe == -1 && currentsplitdate.weekday == 7 {
                self.AnimationDayButton(button, beforeposition: positionX-300, afterpositon: positionX, positionY: positionY, buttonsize: buttonSize)
            }
            
            //タップをして今日に移動する際に、アニメーションを行う
            if tapanimationbuttonflag {
                if judgeswipe == 1 && tapanimationbuttonflag {
                    self.AnimationDayButton(button, beforeposition: positionX+300, afterpositon: positionX, positionY: positionY, buttonsize: buttonSize)
                }else if judgeswipe == -1 && tapanimationbuttonflag {
                    self.AnimationDayButton(button, beforeposition: positionX-300, afterpositon: positionX, positionY: positionY, buttonsize: buttonSize)
                }
            }
            
            buttonobjectarray.append(button)
        }
        
        tapanimationbuttonflag = false
    }
    
    //日付ボタンをタップした際に呼ばれる関数
    func TapDayButton(sender: UIButton){
        let currentsplitday = ReturnYearMonthDayWeekday(currentnsdate) //日付を西暦,月,日,曜日に分けて取得
        
        //タップした日付ボタンと表示中の日付の配列位置を比較
        let tagindex = buttontilearray.indexOf(String(sender.tag))
        let currentdayindex = buttontilearray.indexOf(String(currentsplitday.day))
        
        self.DayControl(tagindex!-currentdayindex!)
        let currentnsdatesplit = self.ReturnYearMonthDayWeekday(currentnsdate)

        //今日の日付より大きい日付(翌日以降)のボタンがタップされた場合
        if tagindex! - currentdayindex! > 0 {
            self.AnimationCalenderLabel(20, afterposition: 8)
            self.ShowAllData(CommonMethod().Changecalendar(currentnsdatesplit.year, calender: "A.D"), m: currentnsdatesplit.month, d: currentnsdatesplit.day, arraynumber: 2)
            self.AnimationShiftLabelCompletion(shiftlabel_x[0], mainposition: shiftlabel_x[0], nextpositon: shiftlabel_x[1])
        
        //今日の日付より小さい日付(前日以降)のボタンがタップされた場合
        }else if tagindex! - currentdayindex! < 0 {
            self.AnimationCalenderLabel(-4, afterposition: 8)
            self.ShowAllData(CommonMethod().Changecalendar(currentnsdatesplit.year, calender: "A.D"), m: currentnsdatesplit.month, d: currentnsdatesplit.day, arraynumber: 0)
            self.AnimationShiftLabelCompletion(shiftlabel_x[1], mainposition: shiftlabel_x[2], nextpositon: shiftlabel_x[2])
        
        //今日の日付と同じボタンがタップされた場合
        }else{
            self.AnimationCalenderLabel(8, afterposition: 8)
        }
    }
    
    //ジェスチャーを検知するメソッド
    func setupTapGesture() {
        // 右方向へのスワイプ
        let gestureToRight = UISwipeGestureRecognizer(target: self, action: #selector(MonthlySalaryShow.prevday))
        gestureToRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(gestureToRight)
        
        // 左方向へのスワイプ
        let gestureToLeft = UISwipeGestureRecognizer(target: self, action: #selector(MonthlySalaryShow.nextday))
        gestureToLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(gestureToLeft)
        
        //長押し
        let myLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MonthlySalaryShow.today))
        myLongPressGesture.minimumPressDuration = 0.5
        myLongPressGesture.allowableMovement = 150
        self.view.addGestureRecognizer(myLongPressGesture)
    }
    
    var tapanimationbuttonflag = false      //タップをした際にbuttontilearray内に今日の日付が含まれているかを記録
    
    //日付を表示しているLabelをアニメーション表示するメソッド
    func AnimationCalenderLabel(beforeposition: CGFloat, afterposition: CGFloat) {
        CalenderLabel.alpha = 0.0
        CalenderLabel.frame = CGRectMake(beforeposition, 240, 359, 33)
        
        UIView.animateWithDuration(0.5) {
            self.CalenderLabel.frame = CGRectMake(afterposition, 240, 359, 33)
            self.CalenderLabel.alpha = 1.0
        }
    }
    
    //日付を表示しているLabelに日付の内容をセットするメソッド
    func SetCalenderLabel(year: Int, month: Int, day: Int, weekday: Int){
        CalenderLabel.text = "\(year)年\(month)月\(day)日 \(self.ReturnWeekday(weekday))曜日"
    }
    
    //日付を表示するボタンのアニメーションを行うメソッド
    func AnimationDayButton(button: UIButton, beforeposition: Int, afterpositon: Int, positionY: Int, buttonsize: Int){
        button.frame = CGRectMake(
            CGFloat(beforeposition),
            CGFloat(positionY),
            CGFloat(buttonsize),
            CGFloat(buttonsize)
        );
        
        UIView.animateWithDuration(0.3, animations: {
            button.frame = CGRectMake(
                CGFloat(afterpositon),
                CGFloat(positionY),
                CGFloat(buttonsize),
                CGFloat(buttonsize)
            );
        })
    }
    
    //シフトラベルをアニメーションした後に、初期位置に戻す関数
    func AnimationShiftLabelCompletion(prevposition: Int, mainposition: Int, nextpositon: Int){
        let positionarray = [prevposition,mainposition,nextpositon]
        var y: CGFloat = 0
        var w: CGFloat = 0
        var h: CGFloat = 0
        
        UIView.animateWithDuration(0.4, animations: {
            for i in 0..<self.ShiftLabelArray.count {
                for j in 0..<self.ShiftLabelArray[i].count {
                    y = self.ShiftLabelArray[i][j].frame.origin.y
                    w = self.ShiftLabelArray[i][j].frame.size.width
                    h = self.ShiftLabelArray[i][j].frame.size.height
                    self.ShiftLabelArray[i][j].frame = CGRectMake(CGFloat(positionarray[i]), y, w, h)
                }
            }

            }, completion: {
                (value: Bool) in

                //配置場所をユーザが気づかないように瞬時に戻す
                for i in 0..<self.ShiftLabelArray.count {
                    for j in 0..<self.ShiftLabelArray[i].count {
                        y = self.ShiftLabelArray[i][j].frame.origin.y
                        w = self.ShiftLabelArray[i][j].frame.size.width
                        h = self.ShiftLabelArray[i][j].frame.size.height
                        self.ShiftLabelArray[i][j].frame = CGRectMake(CGFloat(self.shiftlabel_x[i]), y, w, h)
                    }
                }
                
                //配置を元に戻すと同時に表示内容も更新する
                let daycontrol = [-1,0,1]
                for i in 0..<self.ShiftLabelArray.count {
                    //control[i]分だけ日付を操作したnsdateを作成する
                    let calendar = NSCalendar.currentCalendar()
                    let daycontroled_nsdate = calendar.dateByAddingUnit(.Day, value: daycontrol[i], toDate: self.currentnsdate, options: [])
                    let daycontroled_splitday = self.ReturnYearMonthDayWeekday(daycontroled_nsdate!)

                    self.ShowAllData(CommonMethod().Changecalendar(daycontroled_splitday.year, calender: "A.D"), m: daycontroled_splitday.month, d: daycontroled_splitday.day, arraynumber: i)
                }
        })
    }
    
    
    //シフトを表示するラベルを設置する関数
    let shiftlabel_h = [63,35,35,35,63,63]
    let shiftlabel_line = [3,1,1,1,3,3]
    let shiftlabel_x = [-360,8,375]
    
    func setupShiftLabel(){
        let space = 7
        
        //2次元配列の初期化
        for i in 0...2 {
            var startheight = 275+space
            ShiftLabelArray.append([])
            
            for j in 0..<shiftlabel_line.count {
                let label = UILabel()
                label.frame = CGRectMake(CGFloat(shiftlabel_x[i]), CGFloat(startheight + j*space), 359, CGFloat(shiftlabel_h[j]))
                label.backgroundColor = UIColor.hex("4C4C4C", alpha: 1.0)
                label.numberOfLines = shiftlabel_line[j]
                
                ShiftLabelArray[i].append(label)
                self.view.addSubview(label)

                startheight += shiftlabel_h[j]
            }
        }
    }
    
    func nextday(){
        self.DayControl(1)

        //日付表示ラベルを画面右側からアニメーション表示させる
        self.AnimationCalenderLabel(20, afterposition: 8)
        self.AnimationShiftLabelCompletion(shiftlabel_x[0], mainposition: shiftlabel_x[0], nextpositon: shiftlabel_x[1])
    }
    
    func prevday(){
        self.DayControl(-1)

        //日付表示ラベルを画面左側からアニメーション表示させる
        self.AnimationCalenderLabel(-4, afterposition: 8)
        self.AnimationShiftLabelCompletion(shiftlabel_x[1], mainposition: shiftlabel_x[2], nextpositon: shiftlabel_x[2])
    }
    
    func today(){
        let today = NSDate()
        let date = ReturnYearMonthDayWeekday(today)
        self.SetCalenderLabel(date.year, month: date.month, day: date.day, weekday: date.weekday)
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let compareunit = calendar.compareDate(currentnsdate, toDate: today, toUnitGranularity: .Day)
        
        currentnsdate = today
        
        if buttontilearray.contains(String(date.day)) == false {
            tapanimationbuttonflag = true
        }
        
        //現在表示している日付と今日の日付を比較して、アニメーションを切り替えて表示する
        if compareunit == .OrderedAscending {           //currentnsdateが今日より小さい(前の日付)場合
            self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 2)
            self.AnimationCalenderLabel(20, afterposition: 8)
            self.SetupDayButton(1)
            self.AnimationShiftLabelCompletion(shiftlabel_x[0], mainposition: shiftlabel_x[0], nextpositon: shiftlabel_x[1])
            
        }else if compareunit == .OrderedDescending{     //currentnsdateが今日より大きい(後の日付)場合
            self.ShowAllData(CommonMethod().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 0)
            self.AnimationCalenderLabel(-4, afterposition: 8)
            self.SetupDayButton(-1)
            self.AnimationShiftLabelCompletion(shiftlabel_x[1], mainposition: shiftlabel_x[2], nextpositon: shiftlabel_x[2])
            
        }else{                                          //日付が同じ場合
            self.AnimationCalenderLabel(8, afterposition: 8)
            self.SetupDayButton(0)
        }
    }

    
    //何日進めるかの値を受け取って日付を操作する
    func DayControl(control: Int){
        //control分だけ日付を操作したnsdateを作成する
        let calendar = NSCalendar.currentCalendar()
        let daycontroled_nsdate = calendar.dateByAddingUnit(.Day, value: control, toDate: self.currentnsdate, options: [])
        
        currentnsdate = daycontroled_nsdate!

        let currentnsdatesplit = self.ReturnYearMonthDayWeekday(currentnsdate)
        
        //日付を表示しているラベルの内容を変更する
        self.SetCalenderLabel(currentnsdatesplit.year, month: currentnsdatesplit.month, day: currentnsdatesplit.day, weekday: currentnsdatesplit.weekday)

        self.SetupDayButton(control)
    }
    
    //1週間分の日付を配列へ格納するメソッド
    func SetDayArray(pivotnsdate: NSDate, pivotweekday: Int){
        var tmparray: [Int] = []
        var j = 0                   //日付を増やすための変数
        
        let nsdatesplit = self.ReturnYearMonthDayWeekday(pivotnsdate)
        
        //今日の日付から日曜日までの日付を追加する
        for i in (1..<pivotweekday).reverse() {
            let newnsdate = self.CreateNSDate(nsdatesplit.year, month: nsdatesplit.month, day: nsdatesplit.day-i)
            let newnsdatesplit = self.ReturnYearMonthDayWeekday(newnsdate)
            tmparray.append(newnsdatesplit.day)
        }
        
        //今日の日付から土曜日までの日付を追加する
        for _ in pivotweekday...7 {
            let newnsdate = self.CreateNSDate(nsdatesplit.year, month: nsdatesplit.month, day: nsdatesplit.day+j)
            j += 1
            let newnsdatesplit = self.ReturnYearMonthDayWeekday(newnsdate)
            tmparray.append(newnsdatesplit.day)
        }
        
        for i in 0...6 {
            self.buttontilearray.append(String(tmparray[i]))
        }
    }
    
    //ボタンオブジェクトを削除するメソッド
    func RemoveButtonObjects(){
        
        for i in 0..<buttonobjectarray.count {
            buttonobjectarray[i].removeFromSuperview()
        }
        
        self.buttontilearray.removeAll()
    }
}

