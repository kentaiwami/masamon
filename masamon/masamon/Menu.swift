//
//  Menu.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/29.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: 背景素材を決定する
//TODO: エフェクトについて調査
//TODO: ボタンの配置
//TODO: 現在いる画面のボタン以外を表示するように設定

import UIKit

class Menu: UIViewController {
    let AnimationMenuView = UIView(frame: CGRectMake(345, 60, 100, 100))
    let testbutton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testbutton.frame = CGRectMake(0, 0, 30, 30)
        testbutton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        //メニューボタンの追加
        let image = UIImage(named: "../images/Menu-50.png")! as UIImage
        let imageButton   = UIButton()
        imageButton.tag = 999
        imageButton.frame = CGRectMake(0, 0, 128, 128)
        imageButton.layer.position = CGPoint(x: self.view.frame.width-30, y:60)
        imageButton.setImage(image, forState: .Normal)
        imageButton.addTarget(self, action: "MenuButtontapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(imageButton)
        self.AnimationMenuView.addSubview(testbutton)
        self.view.addSubview(AnimationMenuView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func MenuButtontapped(sender: UIButton){
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.AnimationMenuView.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
            self.AnimationMenuView.frame = CGRectMake(10,80, self.view.frame.width-20, 500)
            
            self.view.bringSubviewToFront(self.AnimationMenuView)
        })
    }
    
}
