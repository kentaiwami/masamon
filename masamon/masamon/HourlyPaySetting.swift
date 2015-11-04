//
//  HourlyPaySetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/28.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: テキストフィールドから血が垂れているようにする
//TODO: セーブボタンを見やすいイメージにあったやつにする
//TODO: 全体的に少し下に下げて間隔を調整する Done

import UIKit

class HourlyPaySetting: Menu, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var TimeFrom1: UITextField!
    @IBOutlet weak var TimeTo1: UITextField!
    @IBOutlet weak var TimeFrom2: UITextField!
    @IBOutlet weak var TimeTo2: UITextField!
    @IBOutlet weak var SalalyLabel1: UITextField!
    @IBOutlet weak var SalalyLabel2: UITextField!
    
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
    
    let catimage1 = UIImage(named: "../images/cat1.png")
    let catimageview1 = UIImageView()
    let catimage2 = UIImage(named: "../images/cat2.png")
    let catimageview2 = UIImageView()
    let catimage3 = UIImage(named: "../images/cat3.png")
    let catimageview3 = UIImageView()
    let catimage4 = UIImage(named: "../images/cat4.png")
    let catimageview4 = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DBmethod().ShowDBpass()
        
        self.view.backgroundColor = UIColor.hex("ff00ff", alpha: 0.7)
        
        //猫の追加
        catimageview1.frame = CGRectMake(0, 0, 60, 60)
        catimageview1.image = catimage1
        catimageview1.layer.position = CGPoint(x: 60, y: 166)
        self.view.addSubview(catimageview1)
        
        catimageview2.frame = CGRectMake(0, 0, 70, 70)
        catimageview2.image = catimage2
        catimageview2.layer.position = CGPoint(x: 250, y: 169)
        self.view.addSubview(catimageview2)

        catimageview3.frame = CGRectMake(0, 0, 70, 70)
        catimageview3.image = catimage3
        catimageview3.layer.position = CGPoint(x: 60, y: 314)
        self.view.addSubview(catimageview3)
        
        catimageview4.frame = CGRectMake(0, 0, 80, 80)
        catimageview4.image = catimage4
        catimageview4.layer.position = CGPoint(x: 320, y: 385)
        self.view.addSubview(catimageview4)
        
        
        
        
        
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
        
        //Toolbarにつけるボタンの作成
        let doneButton1 = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let cancelButton1 = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let doneButton2 = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let cancelButton2 = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let salalyButton1 = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: "doneSalalyLabel:")
        let salalyButton2 = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: "doneSalalyLabel:")
        
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
        
        if(TimeFrom1.text?.isEmpty == true || TimeTo1.text?.isEmpty == true || TimeFrom2.text?.isEmpty == true || TimeTo2.text?.isEmpty == true || SalalyLabel1.text?.isEmpty == true || SalalyLabel2.text?.isEmpty == true){
            
            let alertController = UIAlertController(title: "Error!!", message: "全ての項目を埋めないと保存できんぞ", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "懺悔する", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }else{
            let hourlypayrecord1 = HourlyPay()
            let hourlypayrecord2 = HourlyPay()
            hourlypayrecord1.id = 1
            hourlypayrecord1.timefrom = Double(time.indexOf(TimeFrom1.text!)!)-(Double(time.indexOf(TimeFrom1.text!)!)*0.5)
            hourlypayrecord1.timeto = Double(time.indexOf(TimeTo1.text!)!)-(Double(time.indexOf(TimeTo1.text!)!)*0.5)
            hourlypayrecord1.pay = Int(SalalyLabel1.text!)!
            hourlypayrecord2.id = 2
            hourlypayrecord2.timefrom = Double(time.indexOf(TimeFrom2.text!)!)-(Double(time.indexOf(TimeFrom2.text!)!)*0.5)
            hourlypayrecord2.timeto = Double(time.indexOf(TimeTo2.text!)!)-(Double(time.indexOf(TimeTo2.text!)!)*0.5)
            hourlypayrecord2.pay = Int(SalalyLabel2.text!)!
            
            DBmethod().add(hourlypayrecord1)
            DBmethod().add(hourlypayrecord2)
        }
    }
}
