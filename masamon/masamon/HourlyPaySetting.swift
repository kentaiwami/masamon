//
//  HourlyPaySetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/28.
//  Copyright © 2015年 Kenta. All rights reserved.
//
//TODO: Textfieldを4つ配置する
//TODO: 時給をデータベースに格納

import UIKit

class HourlyPaySetting: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate{

    @IBOutlet weak var TimeFrom1: UITextField!
    @IBOutlet weak var TimeTo1: UITextField!
    @IBOutlet weak var SalalyLabel1: UITextField!
    @IBOutlet weak var SalalyLabel2: UITextField!
    var myUIPicker1: UIPickerView = UIPickerView()
    let time: [String] = ["0:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","24:00"]
    let line: [String] = ["〜"]
    var textfieldrowfrom1 = 9
    var textfieldrowto1 = 22
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TimeFrom1.delegate = self
        TimeTo1.delegate = self
        
        //Toolbarの作成
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        //Toolbarにつけるボタンの作成
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        doneButton.tag = 1
        cancelButton.tag = 2
        
        //Toolbarへボタンの追加
        toolBar.setItems([cancelButton,flexSpace,doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        //PickerViewの追加
        myUIPicker1.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 260.0)
        myUIPicker1.delegate = self
        myUIPicker1.dataSource = self
        
        SalalyLabel1.keyboardType = .Default
        SalalyLabel2.keyboardType = .Default
        TimeFrom1.inputView = myUIPicker1
        TimeFrom1.inputAccessoryView = toolBar
        TimeTo1.inputView = myUIPicker1
        TimeTo1.inputAccessoryView = toolBar
        
        myUIPicker1.selectRow(9, inComponent: 0, animated: true)
        myUIPicker1.selectRow(22, inComponent: 2, animated: true)
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
            return line.count
        }else{
            return time.count
        }
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if(component == 0){
            return time[row]
        }else if(component == 1){
            return line[row]
        }else{
            return time[row]
        }
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        print("列: \(row)")
        //        print("値: \(shiftlist[row])")
        
        if(component == 0){
            TimeFrom1.text = time[row]
            textfieldrowfrom1 = row
        }else if(component == 2){
            TimeTo1.text = time[row]
            textfieldrowto1 = row
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
        case 1: //Doneボタン
            TimeFrom1.text = time[textfieldrowfrom1]
            TimeTo1.text = time[textfieldrowto1]
            TimeFrom1.resignFirstResponder()
            TimeTo1.resignFirstResponder()
        case 2: //calcelボタン
            TimeFrom1.text = ""
            TimeTo1.text = ""
            TimeFrom1.resignFirstResponder()
            TimeTo1.resignFirstResponder()
        default:
            break
            
        }
    }
    
    //textfieldがタップされた時
    func textFieldDidBeginEditing(textField: UITextField) {
        TimeFrom1.text = time[textfieldrowfrom1]
        TimeTo1.text = time[textfieldrowto1]
    }
}
