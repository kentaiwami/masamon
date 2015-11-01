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

import UIKit

class Menu: UIViewController {
    let AnimationMenuView = UIView(frame: CGRectMake(345, 60, 100, 100))
    //let testbutton = UIButton()
    let menuimage = UIImage(named: "../images/Menu-50_White.png")
    let imageButton   = UIButton()
    var ToolBar = UIToolbar()
    var backimage = UIImage(named: "../images/background.jpg")
    var backimageview = UIImageView()
    var menushow = 0
    let candleimage = UIImage(named: "../images/candle.png")
    var candleimageview = UIImageView()
    let test = UIImage(named: "../images/button2.png")
    var testbutton = UIButton()
    
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
        imageButton.frame = CGRectMake(0, 0, 50, 50)
        imageButton.layer.position = CGPoint(x: self.view.frame.width-30, y:43)
        imageButton.setImage(menuimage, forState: .Normal)
        imageButton.addTarget(self, action: "MenuButtontapped:", forControlEvents:.TouchUpInside)
        
        //ろうそくの作成
        candleimageview.frame = CGRectMake(345, 60, 100, 100)
        candleimageview.image = candleimage
        
        //遷移ボタンの作成
        testbutton.frame = CGRectMake(0, 0, 200, 300)
        testbutton.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2-50)
        testbutton.setImage(test, forState: .Normal)
        testbutton.addTarget(self, action: "TestButtontapped:", forControlEvents: .TouchUpInside)
        
        self.AnimationMenuView.addSubview(testbutton)
        self.AnimationMenuView.addSubview(candleimageview)
        self.view.addSubview(ToolBar)
        self.view.addSubview(imageButton)
        self.view.addSubview(AnimationMenuView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func MenuButtontapped(sender: UIButton){
        
        if(menushow == 0){      //Menuが出ていない時
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                self.AnimationMenuView.frame = CGRectMake(0,65, self.view.frame.width, self.view.frame.height)
                self.candleimageview.frame = CGRectMake(0, self.view.frame.height/2, 400, 400)
                self.view.bringSubviewToFront(self.AnimationMenuView)
                self.menushow = 1
            })
        }else{
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                self.AnimationMenuView.frame = CGRectMake(380,60, 100, 100)
                self.candleimageview.frame = CGRectMake(345, 60, 100, 100)
                self.view.bringSubviewToFront(self.AnimationMenuView)
                self.menushow = 0
            })
        }
        
    }
    
}
