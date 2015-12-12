//
//  HourlyPaySetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/28.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class Setting: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var AddScrollView: UIScrollView!
    @IBOutlet weak var TimeFrom1: UITextField!
    @IBOutlet weak var TimeTo1: UITextField!
    @IBOutlet weak var TimeFrom2: UITextField!
    @IBOutlet weak var TimeTo2: UITextField!
    @IBOutlet weak var SalalyLabel1: UITextField!
    @IBOutlet weak var SalalyLabel2: UITextField!
    @IBOutlet weak var usernametextfield: UITextField!
    @IBOutlet weak var staffnumbertextfield: UITextField!
    
    
    var myUIPicker1: UIPickerView = UIPickerView()
    var myUIPicker2: UIPickerView = UIPickerView()
    
    let time: [String] = ["0:00","0:30","1:00","1:30","2:00","2:30","3:00","3:30","4:00","4:30","5:00","5:30","6:00","6:30","7:00","7:30","8:00","8:30","9:00","9:30","10:00","10:30","11:00","11:30","12:00","12:30","13:00","13:30","14:00","14:30","15:00","15:30","16:00","16:30","17:00","17:30","18:00","18:30","19:00","19:30","20:00","20:00","21:00","21:30","22:00","22:30","23:00","23:30"]
    let wavyline: [String] = ["〜"]
    var textfieldrowfrom1 = 10
    var textfieldrowto1 = 44
    var textfieldrowfrom2 = 44
    var textfieldrowto2 = 10
    
    let saveimage = UIImage(named: "../images/save.png")
    let savebutton   = UIButton()
    
    let catimagepath: [String] = ["../images/cat1.png","../images/cat2.png"]
    let catinfo: [[Int]] = [[70,500,80],[328,560,80]]
    
    @IBOutlet weak var HPSView: UIView!
    var txtActiveField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DBmethod().ShowDBpass()
        
        self.HPSView.backgroundColor = UIColor(patternImage: UIImage(named: "../images/HPSbackground.png")!)

        //時給がすでに登録されていたら登録内容を表示する
        if(DBmethod().HourlyPayRecordGet().isEmpty){
            print("HourlyPayRecord is nil")
        }else{
            let hourlypayarray = DBmethod().HourlyPayRecordGet()
            
            TimeFrom1.text = time[Int(hourlypayarray[0].timefrom * 2)]
            TimeTo1.text = time[Int(hourlypayarray[0].timeto * 2)]
            TimeFrom2.text = time[Int(hourlypayarray[1].timefrom * 2)]
            TimeTo2.text = time[Int(hourlypayarray[1].timeto * 2)]
            SalalyLabel1.text = String(hourlypayarray[0].pay)
            SalalyLabel2.text = String(hourlypayarray[1].pay)
        }
        
        //既に登録されていたら登録内容を表示する
        if(DBmethod().DBRecordCount(UserName) == 0){
            usernametextfield.text = "月給を表示するシフト表上での名前を入力"
        }else{
            usernametextfield.text = DBmethod().UserNameGet()
        }
        
        if(DBmethod().DBRecordCount(StaffNumber) == 0){
            staffnumbertextfield.text = "シフト表に記載されているスタッフの人数を入力"
        }else{
            staffnumbertextfield.text = String(DBmethod().StaffNumberGet())
        }

        
        //猫の追加
        for(var i = 0; i < catimagepath.count; i++){
            let catimage = UIImage(named: catimagepath[i])
            let catimageview = UIImageView()
            
            catimageview.frame = CGRectMake(0, 0, CGFloat(catinfo[i][2]), CGFloat(catinfo[i][2]))
            catimageview.image = catimage
            catimageview.layer.position = CGPoint(x: catinfo[i][0], y: catinfo[i][1])
            
            self.HPSView.addSubview(catimageview)
            
        }
        
        //セーブボタンの追加
        savebutton.tag = 0
        savebutton.frame = CGRectMake(0, 0, 100, 100)
        savebutton.layer.position = CGPoint(x: self.view.frame.width/2, y:550)
        savebutton.setImage(saveimage, forState: .Normal)
        savebutton.addTarget(self, action: "SaveButtontapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(savebutton)
        
        TimeFrom1.delegate = self
        TimeTo1.delegate = self
        TimeFrom2.delegate = self
        TimeTo2.delegate = self
        SalalyLabel1.delegate = self
        SalalyLabel2.delegate = self
        usernametextfield.delegate = self
        staffnumbertextfield.delegate = self
        
        TimeFrom1.tag = 1
        TimeTo1.tag = 1
        TimeFrom2.tag = 2
        TimeTo2.tag = 2
        
        myUIPicker1.tag = 1
        myUIPicker2.tag = 2
        
        //Toolbarの作成
        let toolBar1 = UIToolbar()
        toolBar1.barStyle = UIBarStyle.Default
        toolBar1.translucent = true
        toolBar1.tintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        toolBar1.sizeToFit()
        let toolBar2 = UIToolbar()
        toolBar2.barStyle = UIBarStyle.Default
        toolBar2.translucent = true
        toolBar2.tintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        toolBar2.sizeToFit()
        let toolBarsalaly1 = UIToolbar()
        toolBarsalaly1.barStyle = UIBarStyle.Default
        toolBarsalaly1.translucent = true
        toolBarsalaly1.tintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        toolBarsalaly1.sizeToFit()
        let toolBarsalaly2 = UIToolbar()
        toolBarsalaly2.barStyle = UIBarStyle.Default
        toolBarsalaly2.translucent = true
        toolBarsalaly2.tintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        toolBarsalaly2.sizeToFit()
        let keyboardtoolbar = UIToolbar()
        keyboardtoolbar.barStyle = UIBarStyle.Default
        keyboardtoolbar.translucent = true
        keyboardtoolbar.tintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        keyboardtoolbar.sizeToFit()
        
        //Toolbarにつけるボタンの作成
        let doneButton1 = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let cancelButton1 = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let doneButton2 = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let cancelButton2 = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let salalyButton1 = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: "doneSalalyLabel:")
        let salalyButton2 = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: "doneSalalyLabel:")
        let donebutton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: "TapToolBarButton:")
        let cancelbutton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.Plain, target: self, action: "TapToolBarButton:")
        
        donebutton.tag = 1
        cancelbutton.tag = 2
        doneButton1.tag = 10
        cancelButton1.tag = 11
        doneButton2.tag = 20
        cancelButton2.tag = 21
        salalyButton1.tag = 30
        salalyButton2.tag = 31
        
        //Toolbarへボタンの追加
        toolBar1.setItems([cancelButton1,flexSpace,doneButton1], animated: false)
        toolBar1.userInteractionEnabled = true
        toolBar2.setItems([cancelButton2,flexSpace,doneButton2], animated: false)
        toolBar2.userInteractionEnabled = true
        toolBarsalaly1.setItems([flexSpace,salalyButton1], animated: false)
        toolBarsalaly1.userInteractionEnabled = true
        toolBarsalaly2.setItems([flexSpace,salalyButton2], animated: false)
        toolBarsalaly2.userInteractionEnabled = true
        keyboardtoolbar.setItems([flexSpace,donebutton], animated: false)
        keyboardtoolbar.userInteractionEnabled = true
        
        //PickerViewの追加
        myUIPicker1.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 260.0)
        myUIPicker1.delegate = self
        myUIPicker1.dataSource = self
        myUIPicker2.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 260.0)
        myUIPicker2.delegate = self
        myUIPicker2.dataSource = self
        
        SalalyLabel1.keyboardType = .NumberPad
        SalalyLabel2.keyboardType = .NumberPad
        SalalyLabel1.inputAccessoryView = toolBarsalaly1
        SalalyLabel2.inputAccessoryView = toolBarsalaly2
        
        TimeFrom1.inputView = myUIPicker1
        TimeFrom1.inputAccessoryView = toolBar1
        TimeTo1.inputView = myUIPicker1
        TimeTo1.inputAccessoryView = toolBar1
        TimeFrom2.inputView = myUIPicker2
        TimeFrom2.inputAccessoryView = toolBar2
        TimeTo2.inputView = myUIPicker2
        TimeTo2.inputAccessoryView = toolBar2
        
        usernametextfield.returnKeyType = .Done
        
        staffnumbertextfield.keyboardType = .NumberPad
        staffnumbertextfield.inputAccessoryView = keyboardtoolbar
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
        if(component == 0){
            return time.count
        }else if(component == 1){
            return wavyline.count
        }else{
            return time.count
        }
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if(component == 0){
            return time[row]
        }else if(component == 1){
            return wavyline[row]
        }else{
            return time[row]
        }
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        print("列: \(row)")
        //        print("値: \(shiftlist[row])")
        if(component == 0){
            if(pickerView.tag == 1){
                TimeFrom1.text = time[row]
                textfieldrowfrom1 = row
            }else{
                TimeFrom2.text = time[row]
                textfieldrowfrom2 = row
            }
        }else if(component == 2){
            if(pickerView.tag == 1){
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
    
    //pickerview上のボタン動作
    func donePicker(sender: UIButton){
        switch(sender.tag){
        case 10: //上のテキストフィールドのDoneボタン
            TimeFrom1.text = time[textfieldrowfrom1]
            TimeTo1.text = time[textfieldrowto1]
            TimeFrom1.resignFirstResponder()
            TimeTo1.resignFirstResponder()
        case 11: //上のテキストフィールドのcalcelボタン
            TimeFrom1.text = ""
            TimeTo1.text = ""
            TimeFrom1.resignFirstResponder()
            TimeTo1.resignFirstResponder()
        case 20: //下のテキストフィールドのDoneボタン
            TimeFrom2.text = time[textfieldrowfrom2]
            TimeTo2.text = time[textfieldrowto2]
            TimeFrom2.resignFirstResponder()
            TimeTo2.resignFirstResponder()
        case 21: //上のテキストフィールドのcalcelボタン
            TimeFrom2.text = ""
            TimeTo2.text = ""
            TimeFrom2.resignFirstResponder()
            TimeTo2.resignFirstResponder()
        default:
            break
            
        }
    }
    
    //時給入力時の完了を押した時
    func doneSalalyLabel(sender: UIButton){
        switch(sender.tag){
        case 30:
            SalalyLabel1.resignFirstResponder()
        case 31:
            SalalyLabel2.resignFirstResponder()
        default:
            break
        }
    }
    
    //textfieldがタップされた時
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField.tag == 1){
            myUIPicker1.selectRow(10, inComponent: 0, animated: true)
            myUIPicker1.selectRow(44, inComponent: 2, animated: true)
            TimeFrom1.text = time[textfieldrowfrom1]
            TimeTo1.text = time[textfieldrowto1]
        }else{
            myUIPicker2.selectRow(44, inComponent: 0, animated: true)
            myUIPicker2.selectRow(10, inComponent: 2, animated: true)
            TimeFrom2.text = time[textfieldrowfrom2]
            TimeTo2.text = time[textfieldrowto2]
        }
    }
    
    //セーブボタンを押した時
    func SaveButtontapped(sender: UIButton){
        
        if(TimeFrom1.text?.isEmpty == true || TimeTo1.text?.isEmpty == true || TimeFrom2.text?.isEmpty == true || TimeTo2.text?.isEmpty == true || SalalyLabel1.text?.isEmpty == true || SalalyLabel2.text?.isEmpty == true || usernametextfield.text?.isEmpty == true || staffnumbertextfield.text?.isEmpty == true){
            
            let alertController = UIAlertController(title: "ニャ!!", message: "項目を埋めてから押すニャ", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "ニャーさんに土下座する", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }else{
            let hourlypayrecord1 = HourlyPayDB()
            let hourlypayrecord2 = HourlyPayDB()
            hourlypayrecord1.id = 1
            hourlypayrecord1.timefrom = Double(time.indexOf(TimeFrom1.text!)!)-(Double(time.indexOf(TimeFrom1.text!)!)*0.5)
            hourlypayrecord1.timeto = Double(time.indexOf(TimeTo1.text!)!)-(Double(time.indexOf(TimeTo1.text!)!)*0.5)
            hourlypayrecord1.pay = Int(SalalyLabel1.text!)!
            hourlypayrecord2.id = 2
            hourlypayrecord2.timefrom = Double(time.indexOf(TimeFrom2.text!)!)-(Double(time.indexOf(TimeFrom2.text!)!)*0.5)
            hourlypayrecord2.timeto = Double(time.indexOf(TimeTo2.text!)!)-(Double(time.indexOf(TimeTo2.text!)!)*0.5)
            hourlypayrecord2.pay = Int(SalalyLabel2.text!)!
            
            let staffnumberrecord = StaffNumber()
            staffnumberrecord.id = 0
            staffnumberrecord.number = Int(staffnumbertextfield.text!)!
            let usernamerecord = UserName()
            usernamerecord.id = 0
            usernamerecord.name = usernametextfield.text!
            
            DBmethod().AddandUpdate(usernamerecord, update: true)
            DBmethod().AddandUpdate(staffnumberrecord, update: true)
            DBmethod().AddandUpdate(hourlypayrecord1,update: true)
            DBmethod().AddandUpdate(hourlypayrecord2,update: true)
            
            let alertController = UIAlertController(title: "ニャ!!", message: "保存したニャ", preferredStyle: .Alert)
            
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
        
//        print("テキストフィールドの下辺：(txtLimit)")
//        print("キーボードの上辺：(kbdLimit)")
        
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
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func TapToolBarButton(sender: UIButton){
        switch(sender.tag){
        case 1:         //完了ボタン
            let staffnumberrecord = StaffNumber()
            staffnumberrecord.id = 0
            staffnumberrecord.number = Int(staffnumbertextfield.text!)!
            
            DBmethod().AddandUpdate(staffnumberrecord, update: true)
            
            staffnumbertextfield.resignFirstResponder()
            
        case 2:         //キャンセルボタン
            staffnumbertextfield.resignFirstResponder()
        default:
            break
        }
    }
}
