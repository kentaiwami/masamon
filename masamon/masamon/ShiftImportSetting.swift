//
//  ShiftImportSetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/05/08.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class ShiftImportSetting: UIViewController ,UITextFieldDelegate{

    @IBOutlet weak var usernametextfield: UITextField!
    @IBOutlet weak var staffnumbertextfield: UITextField!

    let usericonfilename = ["../images/user.png","../images/user2.png"]
    let usericonposition = [130, 190]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetText()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let salalyButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ShiftImportSetting.TapButton(_:)))

        toolBar.setItems([flexSpace,salalyButton], animated: false)
        toolBar.userInteractionEnabled = true

        //シフト関連のアイコンを設置
        for i in 0 ..< 2{
            let usericon = UIImageView()
            usericon.image = UIImage(named: usericonfilename[i])
            usericon.frame = CGRectMake(35, CGFloat(usericonposition[i]), 42, 40)
            self.view.addSubview(usericon)
            
        }
        
        //区切り線を追加
        let frameborderline = UIView()
        frameborderline.frame = CGRectMake(0, 100, self.view.frame.width, 155)
        frameborderline.backgroundColor = UIColor.clearColor()
        frameborderline.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4).CGColor
        frameborderline.layer.borderWidth = 2
        frameborderline.layer.cornerRadius = 30
        self.view.addSubview(frameborderline)
        self.view.sendSubviewToBack(frameborderline)

        //セーブボタンの追加
        let savebutton = UIButton()
        savebutton.tag = 0
        savebutton.frame = CGRectMake(0, 0, 70, 70)
        savebutton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
        savebutton.setImage(UIImage(named: "../images/save.png"), forState: .Normal)
        savebutton.addTarget(self, action: #selector(ShiftImportSetting.SaveButtontapped(_:)), forControlEvents:.TouchUpInside)
        self.view.addSubview(savebutton)

        
        usernametextfield.delegate = self
        staffnumbertextfield.delegate = self
        staffnumbertextfield.tag = 5
        
        usernametextfield.returnKeyType = .Done
        
        staffnumbertextfield.keyboardType = .NumberPad
        staffnumbertextfield.inputAccessoryView = toolBar

    }
    
    override func viewDidDisappear(animated: Bool) {
        SetText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func SetText(){
        if DBmethod().DBRecordCount(UserNameDB) == 0 {
            usernametextfield.placeholder = "シフト表上での名前を入力"
            staffnumbertextfield.placeholder = "スタッフの人数を入力"
        }else {
            usernametextfield.text = DBmethod().UserNameGet()
            staffnumbertextfield.text = String(DBmethod().StaffNumberGet())
        }
    }
    
    //リターンキーを押した時に動作
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    func TapButton(sender: UIButton) {
        usernametextfield.resignFirstResponder()
        staffnumbertextfield.resignFirstResponder()
    }
    
    //セーブボタンを押した時
    func SaveButtontapped(sender: UIButton){
        if usernametextfield.text?.isEmpty == true || staffnumbertextfield.text?.isEmpty == true {
            let alertController = UIAlertController(title: "ニャ!!", message: "項目を埋めてから押すニャ", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "ニャーさんに土下座する", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)

        }else {
            let staffnumberrecord = StaffNumberDB()
            staffnumberrecord.id = 0
            staffnumberrecord.number = Int(staffnumbertextfield.text!)!
            let usernamerecord = UserNameDB()
            usernamerecord.id = 0
            usernamerecord.name = usernametextfield.text!
            
            DBmethod().AddandUpdate(usernamerecord, update: true)
            DBmethod().AddandUpdate(staffnumberrecord, update: true)
            
            let alertController = UIAlertController(title: "保存完了", message: "設定情報の登録に成功しました", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)

        }
    }

}
