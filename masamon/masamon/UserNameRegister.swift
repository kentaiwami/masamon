//
//  UserNameRegister.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/07.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class UserNameRegister: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var usernametextfield: UITextField!
    @IBOutlet weak var messagelabel: UILabel!
    
    let alertview = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernametextfield.delegate = self
        usernametextfield.returnKeyType = .Done
        
        usernametextfield.text = "月給を表示するシフト表上での名前を入力"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //キーボードの完了(改行)を押したらキーボードを閉じる&保存の処理を行う
    func textFieldShouldReturn(textfield: UITextField) -> Bool {
        usernametextfield.resignFirstResponder()
        
        if(usernametextfield.text != ""){
            let AAA = UserName()
            AAA.id = 0
            AAA.name = usernametextfield.text!
            
            DBmethod().AddandUpdate(AAA, update: true)
            self.CheckMarkAnimation()
        }else{
            let alertController = UIAlertController(title: "登録エラー", message: "名前を入力して下さい", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        return true
    }
    
    //UITextFieldが編集された直後に呼ばれる
    func textFieldDidBeginEditing(textField: UITextField){
        usernametextfield.text = ""
    }
    
    //TODO: 無駄にコピペしているので効率よくする
    //チェックマークを表示するアニメーション
    func CheckMarkAnimation(){
        let image = UIImage(named: "../images/check.png")
        alertview.image = image
        let alertwidth = 140.0
        let alertheight = 140.0
        alertview.frame = CGRectMake(self.view.frame.width/2-CGFloat(alertwidth)/2, self.view.frame.height/2-CGFloat(alertheight)/2, CGFloat(alertwidth), CGFloat(alertheight))
        alertview.alpha = 0.0
        
        view.addSubview(alertview)
        
        //表示アニメーション
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alertview.frame = CGRectMake(self.view.frame.width/2-CGFloat(alertwidth)/2, self.view.frame.height/2-CGFloat(alertheight)/2, CGFloat(alertwidth), CGFloat(alertheight))
            self.alertview.alpha = 1.0
        })
        
        //消すアニメーション
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.alertview.alpha = 0.0
        })
        
    }

}
