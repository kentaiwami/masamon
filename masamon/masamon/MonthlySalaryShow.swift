//
//  ViewController.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: pickerviewのUIを再検討
//TODO: シフトが誰と一緒なのかを表示
//TODO: 今日のシフトは何番なのかを表示
//TODO: ShiftDetailDBにサンプルデータを入れる
//T0DO: Coreanimation？を使ってメニューボタンの演出を行う

import UIKit
import RealmSwift

class MonthlySalaryShow: Menu,UIPickerViewDelegate, UIPickerViewDataSource{
    
    let shiftdb = ShiftDB()
    let shiftdetaildb = ShiftDetailDB()
    let shiftlist: NSMutableArray = []
    var myUIPicker: UIPickerView = UIPickerView()
    
    @IBOutlet weak var SaralyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        shiftdb.id = 1
        shiftdb.name = "2015年8月シフト"
        shiftdb.imagepath = "8月path"
        shiftdb.saraly = 100000
        
        shiftdetaildb.id = 1
        shiftdetaildb.date = "11"
        shiftdetaildb.staff = "A1,B1,C1"
        shiftdetaildb.user = 1
        //DBmethod().add(shiftdb)
        //DBmethod().add(shiftdetaildb)
        
        //PickerViewの追加
        myUIPicker.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 400.0)
        myUIPicker.delegate = self
        myUIPicker.dataSource = self
        self.view.addSubview(myUIPicker)
        
        //NSArrayへの追加
        let newNSArray = shiftlist
        if(DBmethod().ShiftDBSize() != 0){
            for(var i = DBmethod().ShiftDBSize()-1; i >= 0; i--){
                newNSArray.addObject(DBmethod().ShiftDBNameGet(i+1))
            }
            
            //pickerviewのデフォルト表示
            SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().ShiftDBSize()))
        }
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
        return shiftlist.count
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shiftlist[row] as? String
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        print("列: \(row)")
        //        print("値: \(shiftlist[row])")
        SaralyLabel.text = String(DBmethod().ShiftDBSaralyGet(DBmethod().ShiftDBSize()-row))
    }
}

