//
//  Menu.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/29.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: ボタンの配置
//TODO: 現在いる画面のボタン以外を表示するように設定

import UIKit

class Menu: UIViewController {
    var AnimationMenuView = UIView()
    let menuimage = UIImage(named: "../images/Menu-50_White.png")
    let MenuButton   = UIButton()
    var ToolBar = UIToolbar()
    var backimage = UIImage(named: "../images/background.jpg")
    var backimageview = UIImageView()
    var menushow = 0
    let circleimage = UIImage(named: "../images/circle.png")
    var circleimageview = UIImageView()
    
    var screentransitionbuttonarray: [UIButton] = []
    let buttonarrayinfo: [[Int]] = [[225,171,50],[75,260,50],[200,330,50],[145,217,90]]
    //x:225 y:171 w:50 h:50 右上
    //x:75  y:260 w:50 h:50 左下
    //x:200 y:330 w:50 h:50 右下
    //x:145 y:217 w:90 h:90 真ん中
    
    let testbutton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //背景を設定
//        backimageview.image = backimage
//        backimageview.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)
//        self.view.addSubview(backimageview)
//        self.view.sendSubviewToBack(backimageview)
        
        //ツールバーの作成
        ToolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 140.0))
        ToolBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 0.0)
        ToolBar.barStyle = .BlackTranslucent
        ToolBar.tintColor = UIColor.whiteColor()
        ToolBar.backgroundColor = UIColor.grayColor()
        
        
        //メニューボタンの作成
        MenuButton.frame = CGRectMake(0, 0, 50, 50)
        MenuButton.layer.position = CGPoint(x: self.view.frame.width-30, y:43)
        MenuButton.setImage(menuimage, forState: .Normal)
        MenuButton.addTarget(self, action: "MenuButtontapped:", forControlEvents:.TouchUpInside)
        
        //アニメーションのviewを設置
        self.AnimationMenuView.frame = CGRectMake(0, 70, 375, 667)
        
        
        //魔法陣の設置
        circleimageview.frame = CGRectMake(0, 60, self.view.frame.width, 400)
        circleimageview.image = circleimage
        circleimageview.alpha = 0.0
        
        for(var i = 0; i < 4; i++){
            let screentransitionbutton = UIButton()
            screentransitionbutton.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)
            screentransitionbutton.frame = CGRectMake(CGFloat(buttonarrayinfo[i][0]),CGFloat(buttonarrayinfo[i][1]),CGFloat(buttonarrayinfo[i][2]),CGFloat(buttonarrayinfo[i][2]))
            if(i == 3){
                screentransitionbutton.layer.cornerRadius = 45
            }else{
                screentransitionbutton.layer.cornerRadius = 25
            }
            screentransitionbuttonarray.append(screentransitionbutton)
            AnimationMenuView.addSubview(screentransitionbuttonarray[i])
        }

        
        //遷移ボタンの作成
//        testbutton.frame = CGRectMake(145, 217, 90, 90)
//        testbutton.layer.cornerRadius = 45
//        testbutton.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)
////        testbutton.layer.position = CGPoint(x: self.view.frame.width/2+65, y: self.view.frame.height/2-100)
//        testbutton.addTarget(self, action: "TestButtontapped:", forControlEvents: .TouchUpInside)
        
        //viewへの追加と前後関係の調整
        self.AnimationMenuView.addSubview(circleimageview)
        self.AnimationMenuView.sendSubviewToBack(circleimageview)
        self.view.addSubview(ToolBar)
        self.view.addSubview(MenuButton)
        self.view.addSubview(AnimationMenuView)
        self.view.sendSubviewToBack(AnimationMenuView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //メニューボタンを押した時のアニメーション
    func MenuButtontapped(sender: UIButton){
        let opt = UIViewAnimationOptions.TransitionCurlDown
        
        if(menushow == 0){      //Menuが出ていない時
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                self.testbutton.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                self.view.bringSubviewToFront(self.AnimationMenuView)
                self.menushow = 1
            })
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: opt, animations: { () -> Void in
                // 魔法陣出現の処理
                self.circleimageview.frame = CGRectMake(0, 60, self.view.frame.width, 400)
                self.circleimageview.alpha = 1.0
                }, completion: { _ in
            })
            
        }else{
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.circleimageview.alpha = 0.0
                self.testbutton.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)
                self.menushow = 0
            })
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: opt, animations: { () -> Void in
                self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
                }, completion: { _ in
                    self.view.sendSubviewToBack(self.AnimationMenuView)
            })
        }
        
    }
    
}
