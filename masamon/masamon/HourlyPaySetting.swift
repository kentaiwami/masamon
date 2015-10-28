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
    let time: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //PickerViewの追加
        myUIPicker1.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 400.0)
        myUIPicker1.delegate = self
        myUIPicker1.dataSource = self
        self.view.addSubview(myUIPicker1)
        myUIPicker2.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 450.0)
        myUIPicker2.delegate = self
        myUIPicker2.dataSource = self
        self.view.addSubview(myUIPicker2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示個数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return time.count
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return time[row]
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        print("列: \(row)")
        //        print("値: \(shiftlist[row])")
    }
}
