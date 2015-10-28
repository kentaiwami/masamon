//
//  HourlyPaySetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/28.
//  Copyright © 2015年 Kenta. All rights reserved.
//
//TODO: Textfieldを4つ配置する
//TODO: Textfieldをタップしたらpickerviewが下から出てくる感じにする
//TODO: 時給を入力するためのTextfieldを2つ作る

import UIKit

class HourlyPaySetting: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{

    var myUIPicker1: UIPickerView = UIPickerView()
    var myUIPicker2: UIPickerView = UIPickerView()
    let timefrom: [String] = ["0:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","24:00"]
    let timeto: [String] = ["0:00","1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","24:00"]
    let line: [String] = ["〜"]
    override func viewDidLoad() {
        super.viewDidLoad()

        //PickerViewの追加
        myUIPicker1.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 400.0)
        myUIPicker1.delegate = self
        myUIPicker1.dataSource = self
        self.view.addSubview(myUIPicker1)
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
}
