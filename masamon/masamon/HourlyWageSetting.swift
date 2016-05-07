//
//  HourlyPaySetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/28.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class HourlyWageSetting: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var AddScrollView: UIScrollView!
    @IBOutlet weak var TimeFrom1: UITextField!
    @IBOutlet weak var TimeTo1: UITextField!
    @IBOutlet weak var TimeFrom2: UITextField!
    @IBOutlet weak var TimeTo2: UITextField!
    @IBOutlet weak var Salaly1: UITextField!
    @IBOutlet weak var Salaly2: UITextField!
//    @IBOutlet weak var usernametextfield: UITextField!
//    @IBOutlet weak var staffnumbertextfield: UITextField!
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    var timeUIPicker: UIPickerView = UIPickerView()
    
    let time = CommonMethod().GetTime()
    let wavyline: [String] = ["〜"]
    var textfieldrowfrom1 = 8
    var textfieldrowto1 = 42
    var textfieldrowfrom2 = 42
    var textfieldrowto2 = 8
    
    let saveimage = UIImage(named: "../images/save.png")
    let savebutton   = UIButton()
    
    let catimagepath: [String] = ["../images/cat1.png","../images/cat2.png"]
    let catinfo: [[Int]] = [[70,620,80],[326,470,80]]
    
    let frameborder: [Int] = [90,265,435]
    
    let clock: [Int] = [110,285]
    let yen: [Int] = [170,340]
    let user: [Int] = [460,515]
    let usericonfilename: [String] = ["../images/user.png","../images/user2.png"]
    
    @IBOutlet weak var HPSView: UIView!
    var txtActiveField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.HPSView.backgroundColor = UIColor.blackColor()
        
        SetText()
      
        //区切るための枠線を追加
        for i in 0 ..< 3{
            let frameborderline = UIView()
            frameborderline.frame = CGRectMake(0, CGFloat(frameborder[i]), self.view.frame.width, 135)
            frameborderline.backgroundColor = UIColor.clearColor()
            frameborderline.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4).CGColor
            frameborderline.layer.borderWidth = 2
            frameborderline.layer.cornerRadius = 30
            self.HPSView.addSubview(frameborderline)
            self.HPSView.sendSubviewToBack(frameborderline)
        }

        //時計アイコンの設置
        for i in 0 ..< 2{
            let clockicon = UIImageView()
            clockicon.image = UIImage(named: "../images/clock.png")
            clockicon.frame = CGRectMake(24, CGFloat(clock[i]), 42, 40)
            self.HPSView.addSubview(clockicon)
        }
        
        //円アイコンの設置
        for i in 0 ..< 2{
            let yenicon = UIImageView()
            yenicon.image = UIImage(named: "../images/yen.png")
            yenicon.frame = CGRectMake(24, CGFloat(yen[i]), 42, 40)
            self.HPSView.addSubview(yenicon)
        }
        
        //シフト関連のアイコンを設置
        for i in 0 ..< 2{
            let usericon = UIImageView()
            usericon.image = UIImage(named: usericonfilename[i])
            usericon.frame = CGRectMake(24, CGFloat(user[i]), 42, 40)
            self.HPSView.addSubview(usericon)

        }
        
        //猫の追加
        for i in 0 ..< catimagepath.count{
            let catimage = UIImage(named: catimagepath[i])
            let catimageview = UIImageView()
            
            catimageview.frame = CGRectMake(0, 0, CGFloat(catinfo[i][2]), CGFloat(catinfo[i][2]))
            catimageview.image = catimage
            catimageview.layer.position = CGPoint(x: catinfo[i][0], y: catinfo[i][1])
            
            self.HPSView.addSubview(catimageview)
            
        }
        
        //セーブボタンの追加
        savebutton.tag = 0
        savebutton.frame = CGRectMake(0, 0, 70, 70)
        savebutton.layer.position = CGPoint(x: self.view.frame.width/2, y:620)
        savebutton.setImage(saveimage, forState: .Normal)
        savebutton.addTarget(self, action: #selector(HourlyWageSetting.SaveButtontapped(_:)), forControlEvents:.TouchUpInside)
        self.view.addSubview(savebutton)
        
        TimeFrom1.delegate = self
        TimeTo1.delegate = self
        TimeFrom2.delegate = self
        TimeTo2.delegate = self
        Salaly1.delegate = self
        Salaly2.delegate = self
//        usernametextfield.delegate = self
//        staffnumbertextfield.delegate = self
        
        TimeFrom1.tag = 1
        TimeTo1.tag = 1
        TimeFrom2.tag = 2
        TimeTo2.tag = 2
        Salaly1.tag = 3
        Salaly2.tag = 4
//        staffnumbertextfield.tag = 5
        
        timeUIPicker.tag = 1
        
        //Toolbarの作成
        let pickertoolBar = UIToolbar()
        pickertoolBar.barStyle = UIBarStyle.Default
        pickertoolBar.translucent = true
        pickertoolBar.sizeToFit()
        let numberpadtoolBar = UIToolbar()
        numberpadtoolBar.barStyle = UIBarStyle.Default
        numberpadtoolBar.translucent = true
        numberpadtoolBar.sizeToFit()
        
        //Toolbarにつけるボタンの作成
        let pickerdoneButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(HourlyWageSetting.TapButton(_:)))
        let pickercancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(HourlyWageSetting.TapButton(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let salalyButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(HourlyWageSetting.TapButton(_:)))
        
        pickerdoneButton.tag = 10
        pickercancelButton.tag = 11
        salalyButton.tag = 30
        
        //Toolbarへボタンの追加
        pickertoolBar.setItems([pickercancelButton,flexSpace,pickerdoneButton], animated: false)
        pickertoolBar.userInteractionEnabled = true
        numberpadtoolBar.setItems([flexSpace,salalyButton], animated: false)
        numberpadtoolBar.userInteractionEnabled = true
        
        //PickerViewの追加
        timeUIPicker.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 260.0)
        timeUIPicker.delegate = self
        timeUIPicker.dataSource = self
        
        Salaly1.keyboardType = .NumberPad
        Salaly2.keyboardType = .NumberPad
        Salaly1.inputAccessoryView = numberpadtoolBar
        Salaly2.inputAccessoryView = numberpadtoolBar
        
        TimeFrom1.inputView = timeUIPicker
        TimeFrom1.inputAccessoryView = pickertoolBar
        TimeTo1.inputView = timeUIPicker
        TimeTo1.inputAccessoryView = pickertoolBar
        TimeFrom2.inputView = timeUIPicker
        TimeFrom2.inputAccessoryView = pickertoolBar
        TimeTo2.inputView = timeUIPicker
        TimeTo2.inputAccessoryView = pickertoolBar
        
//        usernametextfield.returnKeyType = .Done
//        
//        staffnumbertextfield.keyboardType = .NumberPad
//        staffnumbertextfield.inputAccessoryView = numberpadtoolBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    //表示個数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return time.count
        }else if component == 1 {
            return wavyline.count
        }else{
            return time.count
        }
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return time[row]
        }else if component == 1 {
            return wavyline[row]
        }else{
            return time[row]
        }
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if component == 0 {
            if selecttextfieldtag == 1 {
                TimeFrom1.text = time[row]
                textfieldrowfrom1 = row
            }else{
                TimeFrom2.text = time[row]
                textfieldrowfrom2 = row
            }
        }else if component == 2 {
            if selecttextfieldtag == 1 {
                TimeTo1.text = time[row]
                textfieldrowto1 = row
            }else{
                TimeTo2.text = time[row]
                textfieldrowto2 = row
            }
        }
    }
    
    //幅を変更
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80
    }
    //高さを変更
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    //pickerviewやツールバー上のボタン動作
    func TapButton(sender: UIButton){
        
        if selecttextfieldtag == 1 {            //日中のテキストフィールドが選択されている状態
            switch(sender.tag){
            case 10:    //Doneボタン
                TimeFrom1.text = time[textfieldrowfrom1]
                TimeTo1.text = time[textfieldrowto1]
                TimeFrom1.resignFirstResponder()
                TimeTo1.resignFirstResponder()

            case 11:    //Cancelボタン
                textfieldrowfrom1 = 8
                textfieldrowto1 = 42

                TimeFrom1.text = ""
                TimeTo1.text = ""
                TimeFrom1.resignFirstResponder()
                TimeTo1.resignFirstResponder()
                
            default:
                break
            }
        }else if selecttextfieldtag == 2 {      //深夜のテキストフィールドが選択されている状態
            switch(sender.tag){
            case 10:    //Doneボタン
                TimeFrom2.text = time[textfieldrowfrom2]
                TimeTo2.text = time[textfieldrowto2]
                TimeFrom2.resignFirstResponder()
                TimeTo2.resignFirstResponder()
                
            case 11:    //Cancelボタン
                textfieldrowfrom2 = 42
                textfieldrowto2 = 8

                TimeFrom2.text = ""
                TimeTo2.text = ""
                TimeFrom2.resignFirstResponder()
                TimeTo2.resignFirstResponder()
                
            default:
                break
            }

        }else if selecttextfieldtag == 3 {      //日中の時給テキストフィールドが選択されている
            Salaly1.resignFirstResponder()
        }else if selecttextfieldtag == 4 {      //深夜の時給テキストフィールドが選択されている
            Salaly2.resignFirstResponder()
        }else if selecttextfieldtag == 5 {      //スタッフ人数テキストフィールドが選択されている
//            staffnumbertextfield.resignFirstResponder()
        }
    }
    
    var selecttextfieldtag = 0
    //textfieldがタップされた時
    func textFieldDidBeginEditing(textField: UITextField) {
        selecttextfieldtag = textField.tag
        if textField.tag == 1 {
            timeUIPicker.selectRow(textfieldrowfrom1, inComponent: 0, animated: true)
            timeUIPicker.selectRow(textfieldrowto1, inComponent: 2, animated: true)
            TimeFrom1.text = time[textfieldrowfrom1]
            TimeTo1.text = time[textfieldrowto1]
        }else if textField.tag == 2 {
            timeUIPicker.selectRow(textfieldrowfrom2, inComponent: 0, animated: true)
            timeUIPicker.selectRow(textfieldrowto2, inComponent: 2, animated: true)
            TimeFrom2.text = time[textfieldrowfrom2]
            TimeTo2.text = time[textfieldrowto2]
        }
    }
    
    //セーブボタンを押した時
    func SaveButtontapped(sender: UIButton){
        
        if TimeFrom1.text?.isEmpty == true || TimeTo1.text?.isEmpty == true || TimeFrom2.text?.isEmpty == true || TimeTo2.text?.isEmpty == true || Salaly1.text?.isEmpty == true || Salaly2.text?.isEmpty == true {
            
            let alertController = UIAlertController(title: "ニャ!!", message: "項目を埋めてから押すニャ", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "ニャーさんに土下座する", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }else{
            let hourlypayrecord1 = HourlyPayDB()
            let hourlypayrecord2 = HourlyPayDB()
            hourlypayrecord1.id = 1
            hourlypayrecord1.timefrom = Double(time.indexOf(TimeFrom1.text!)!)-(Double(time.indexOf(TimeFrom1.text!)!)*0.5) + 1.0
            hourlypayrecord1.timeto = Double(time.indexOf(TimeTo1.text!)!)-(Double(time.indexOf(TimeTo1.text!)!)*0.5) + 1.0
            hourlypayrecord1.pay = Int(Salaly1.text!)!
            hourlypayrecord2.id = 2
            hourlypayrecord2.timefrom = Double(time.indexOf(TimeFrom2.text!)!)-(Double(time.indexOf(TimeFrom2.text!)!)*0.5) + 1.0
            hourlypayrecord2.timeto = Double(time.indexOf(TimeTo2.text!)!)-(Double(time.indexOf(TimeTo2.text!)!)*0.5) + 1.0
            hourlypayrecord2.pay = Int(Salaly2.text!)!
            
//            let staffnumberrecord = StaffNumberDB()
//            staffnumberrecord.id = 0
//            staffnumberrecord.number = Int(staffnumbertextfield.text!)!
//            let usernamerecord = UserNameDB()
//            usernamerecord.id = 0
//            usernamerecord.name = usernametextfield.text!
            
//            DBmethod().AddandUpdate(usernamerecord, update: true)
//            DBmethod().AddandUpdate(staffnumberrecord, update: true)
            DBmethod().AddandUpdate(hourlypayrecord1,update: true)
            DBmethod().AddandUpdate(hourlypayrecord2,update: true)
            
            let alertController = UIAlertController(title: "保存完了", message: "設定情報の登録に成功しました", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //テキストフィールドが入力状態になった際に動作
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        txtActiveField = textField
        return true
    }
    //リターンキーを押した時に動作
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        
        let txtLimit = txtActiveField.frame.origin.y + txtActiveField.frame.height + 70.0
        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
                
        if txtLimit >= kbdLimit {
            AddScrollView.contentOffset.y = txtLimit - kbdLimit
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        AddScrollView.contentOffset.y = 0
    }
    
    override func viewWillAppear(animated: Bool) {
                
        super.viewWillAppear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(HourlyWageSetting.handleKeyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(HourlyWageSetting.handleKeyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        SetText()
    }
    
//    func TapToolBarButton(sender: UIButton){
//        staffnumbertextfield.resignFirstResponder()
//    }
    
    func SetText(){
        //既に登録されていたら登録内容を表示する
        if DBmethod().DBRecordCount(UserNameDB) == 0 {
//            usernametextfield.placeholder = "シフト表上での名前を入力"
//            staffnumbertextfield.placeholder = "スタッフの人数を入力"
            TimeFrom1.placeholder = "no data"
            TimeFrom2.placeholder = "no data"
            TimeTo1.placeholder = "no data"
            TimeTo2.placeholder = "no data"
            Salaly1.placeholder = "no data"
            Salaly2.placeholder = "no data"
            
        }else{
//            usernametextfield.text = DBmethod().UserNameGet()
//            staffnumbertextfield.text = String(DBmethod().StaffNumberGet())
            
            let hourlypayarray = DBmethod().HourlyPayRecordGet()
            
            TimeFrom1.text = time[Int(hourlypayarray[0].timefrom * 2) - 2]
            TimeTo1.text = time[Int(hourlypayarray[0].timeto * 2) - 2]
            TimeFrom2.text = time[Int(hourlypayarray[1].timefrom * 2) - 2]
            TimeTo2.text = time[Int(hourlypayarray[1].timeto * 2) - 2]
            Salaly1.text = String(hourlypayarray[0].pay)
            Salaly2.text = String(hourlypayarray[1].pay)
        }
    }
}
