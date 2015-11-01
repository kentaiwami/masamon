//
//  Menu.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/29.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: 枠線の色を分ける
//TODO: 枠線をゆっくりと点滅させる
//TODO: 枠線から点線を伸ばす
//TODO: 点線の先にどの画面へ行くのかを文字で表示
//TODO: ボタンに画面遷移を対応づける

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
    let buttonarrayinfo: [[Int]] = [[225,171,50],[75,260,50],[200,330,50],[145,217,90]] //右上,左下,右下,真ん中
    let tap: UITapGestureRecognizer = UITapGestureRecognizer()

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
        
        //遷移ボタンの作成
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
            screentransitionbuttonarray[i].addTarget(self, action: "ScreenTransitionButtontapped:", forControlEvents: .TouchUpInside)
            screentransitionbuttonarray[i].tag = i
            AnimationMenuView.addSubview(screentransitionbuttonarray[i])
        }
        
        
        
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
        
        if(menushow == 0){      //Menuが出てくる
            tap.addTarget(self, action: "onTap:")
            self.AnimationMenuView.addGestureRecognizer(tap)
            UIView.animateWithDuration(1.5, delay: 0.0, options: [UIViewAnimationOptions.Repeat,UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
                
                for(var i = 0; i < 4; i++){
                    self.screentransitionbuttonarray[i].alpha = 0.0
                }
                },
                
                completion: nil)
            
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                
                for(var i = 0; i < 4; i++){
                    self.screentransitionbuttonarray[i].backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                }
                
                self.view.bringSubviewToFront(self.AnimationMenuView)
                self.menushow = 1
            })
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                // 魔法陣出現の処理
                self.circleimageview.frame = CGRectMake(0, 60, self.view.frame.width, 400)
                self.circleimageview.alpha = 1.0
                }, completion: { _ in
            })
            
        }else{      //メニューが消える
            self.AnimationMenuView.removeGestureRecognizer(tap)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.circleimageview.alpha = 0.0
                for(var i = 0; i < 4; i++){
                    self.screentransitionbuttonarray[i].backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)
                }
                self.menushow = 0
            })
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
                }, completion: { _ in
                    self.view.sendSubviewToBack(self.AnimationMenuView)
            })
        }
        
    }
    
    func onTap(gestureRecognizer: UITapGestureRecognizer){
        print("tap")
    }
    
    func ScreenTransitionButtontapped(sender: UIButton){
        switch(sender.tag){
        case 0:
            print("右上")
        case 1:
            print("左下")
        case 2:
            print("右下")
        case 3:
            print("真ん中")
        default:
            break
        }
    }
}
