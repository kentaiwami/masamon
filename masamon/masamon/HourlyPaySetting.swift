//
//  HourlyPaySetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/28.
//  Copyright © 2015年 Kenta. All rights reserved.
//
//TODO: Textfieldを4つ配置する
//TODO: Textfieldをタップしたらpickerviewが下から出てくる感じにする
//TODO: 時給をデータベースに格納

import UIKit

class HourlyPaySetting: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var TEST: UITextField!
    @IBOutlet weak var SalalyLabel1: UITextField!
    @IBOutlet weak var SalalyLabel2: UITextField!
    var myUIPicker1: UIPickerView = UIPickerView()
    let timefrom: [String] = ["0:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","24:00"]
    let timeto: [String] = ["0:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","24:00"]
    let line: [String] = ["〜"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        myUIPicker1.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 400.0)
        myUIPicker1.delegate = self
        myUIPicker1.dataSource = self
        //self.view.addSubview(myUIPicker1)
        
        SalalyLabel1.keyboardType = .Default
        SalalyLabel2.keyboardType = .Default
        TEST.inputView = myUIPicker1
        TEST.inputAccessoryView = toolBar
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
            return timefrom.count
        }else if(component == 1){
            return line.count
        }else{
            return timeto.count
        }
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(component == 0){
            return timefrom[row]
        }else if(component == 1){
            return line[row]
        }else{
            return timeto[row]
        }
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        print("列: \(row)")
        //        print("値: \(shiftlist[row])")
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80
    }
    
    //pickerview上のボタン動作
    func donePicker(sender: UIButton){
        switch(sender.tag){
        case 1: //Doneボタン
            print("tap Done")
            
        case 2: //calcelボタン
            print("tap cancel")
            
        default:
            break
            
        }
    }
}
