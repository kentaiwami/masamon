//
//  Setting.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/31.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class Setting: UIViewController {


    let buttonimages = ["../images/usersetting.png","../images/staffnamelist.png","../images/shiftnamelist.png","../images/shiftlist.png"]
    let buttonpositon: [[Int]] = [[90,160],[280,160],[100,380],[280,380]]
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for(var i = 0; i < 4; i++){
            
            //画面遷移するためのボタンを追加
            let button = UIButton()
            button.tag = i + 1
            button.setImage(UIImage(named: buttonimages[i]), forState: .Normal)
            button.frame = CGRectMake(0, 0, 100, 100)
            button.layer.position = CGPoint(x: buttonpositon[i][0], y:buttonpositon[i][1])
            button.addTarget(self, action: "Buttontapped:", forControlEvents:.TouchUpInside)
            self.view.addSubview(button)
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        appDelegate.screennumber = 2
    }
    
    func Buttontapped(sender:UIButton){
        switch(sender.tag){
        case 1:
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserSetting")
            self.presentViewController( targetViewController, animated: true, completion: nil)
            
        case 2:
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("StaffNameListSetting")
            self.presentViewController( targetViewController, animated: true, completion: nil)
            
        case 3:
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShiftNameListSetting")
            self.presentViewController( targetViewController, animated: true, completion: nil)
            
        case 4:
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShiftListSetting")
            self.presentViewController( targetViewController, animated: true, completion: nil)
            
        default:
            break

        }
    }
}
