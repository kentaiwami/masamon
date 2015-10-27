//
//  ViewController.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: データベースにサンプルデータを記録する
//TODO: 月給表示画面にパーツを置く

import UIKit
import RealmSwift

class ViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
    
    let shiftdb = ShiftDB()
    let shiftdetaildb = ShiftDetailDB()
    let test: NSMutableArray = []
    var myUIPicker: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "../images/Menu-50.png")! as UIImage
        let imageButton   = UIButton()
        imageButton.tag = 0
        imageButton.frame = CGRectMake(0, 0, 128, 128)
        imageButton.layer.position = CGPoint(x: self.view.frame.width-30, y:60)
        imageButton.setImage(image, forState: .Normal)
        imageButton.addTarget(self, action: "MenuButtontapped:", forControlEvents:.TouchUpInside)
        
        self.view.addSubview(imageButton)
        
        myUIPicker.frame = CGRectMake(0,0,self.view.bounds.width, 250.0)
        myUIPicker.delegate = self
        myUIPicker.dataSource = self
        self.view.addSubview(myUIPicker)
        
        let newNSArray = test
        newNSArray.addObject("aaa")
        print(newNSArray)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func MenuButtontapped(sender: UIButton){
        
        shiftdb.id = 2
        shiftdb.name = "AAA"
        shiftdb.imagepath = "Apath"
        shiftdb.saraly = 10000
        
        shiftdetaildb.id = 1
        shiftdetaildb.date = "11"
        shiftdetaildb.staff = "A1,B1,C1"
        shiftdetaildb.user = "遅"
        DBmethod().testadd(shiftdb)
        DBmethod().testadd(shiftdetaildb)
        do{
            print(try Realm().path)
        }catch{
            //Error
        }
        
        DBmethod().dataGet()
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示個数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return test.count
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return test[row] as? String
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("列: \(row)")
        print("値: \(test[row])")
    }
}

