//
//  Menu.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/29.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: エフェクトについて調査
//TODO: ボタンの配置
//TODO: 現在いる画面のボタン以外を表示するように設定
//TODO: メニューボタンを見やすい素材に変える

import UIKit

class Menu: UIViewController {
    let AnimationMenuView = UIView(frame: CGRectMake(345, 60, 100, 100))
    //let testbutton = UIButton()
    let menubackgroundimage = UIImage(named: "../images/aaa.jpg")
    let menubackgroundimageview = UIImageView()
    let menuimage = UIImage(named: "../images/Menu-50_Red.png")
    //let imageButton   = UIButton()
    var ToolBar = UIToolbar()
    var backimage = UIImage(named: "../images/aaa.jpg")
    var backimageview = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //背景を設定
        backimageview.image = backimage
        backimageview.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(backimageview)
        self.view.sendSubviewToBack(backimageview)
//        testbutton.frame = CGRectMake(0, 0, 30, 30)
//        testbutton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)

        //ツールバーの作成
        ToolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 140.0))
        ToolBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 0.0)
        ToolBar.barStyle = .BlackTranslucent
        ToolBar.tintColor = UIColor.whiteColor()
        ToolBar.backgroundColor = UIColor.grayColor()
        
        
        //メニューボタンの作成
//        imageButton.tag = 999
//        imageButton.frame = CGRectMake(0, 0, 128, 128)
//        imageButton.layer.position = CGPoint(x: self.view.frame.width-30, y:60)
//        imageButton.setImage(menuimage, forState: .Normal)
//        imageButton.addTarget(self, action: "MenuButtontapped:", forControlEvents:.TouchUpInside)
        
        //メニューの背景を作成
        menubackgroundimageview.image = menubackgroundimage
        menubackgroundimageview.frame = CGRectMake(345, 60,100, 100)
        
        self.view.addSubview(ToolBar)
        self.AnimationMenuView.addSubview(menubackgroundimageview)
       // self.view.addSubview(imageButton)
       // self.AnimationMenuView.addSubview(testbutton)
        self.view.addSubview(AnimationMenuView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func MenuButtontapped(sender: UIButton){
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            //self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            self.AnimationMenuView.frame = CGRectMake(0,0, self.view.frame.width, self.view.frame.height)
            self.menubackgroundimageview.frame = CGRectMake(0,0, self.view.frame.width, self.view.frame.height)
            self.view.bringSubviewToFront(self.AnimationMenuView)
          //  self.view.bringSubviewToFront(self.imageButton)
        })
    }
    
}
