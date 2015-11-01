//
//  Menu.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/29.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: 丸の色を分ける
//TODO: 丸をゆっくりと点滅させる
//TODO: 丸から点線を伸ばす
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
    var tap: [UITapGestureRecognizer] = []
    var GestureRecognizerViewArray: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  tap.addTarget(self, action: "onTap:")
        
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
            let screentransitionbuttonwork = UIButton()
            let GestureRecognizerViewwork = UIView()
            let tapwork = UITapGestureRecognizer()
            
            tapwork.addTarget(self, action: "onTap:")
            screentransitionbuttonwork.frame = CGRectMake(CGFloat(buttonarrayinfo[i][0]),CGFloat(buttonarrayinfo[i][1]),CGFloat(buttonarrayinfo[i][2]),CGFloat(buttonarrayinfo[i][2]))
            GestureRecognizerViewwork.frame = CGRectMake(CGFloat(buttonarrayinfo[i][0]),CGFloat(buttonarrayinfo[i][1]),CGFloat(buttonarrayinfo[i][2]),CGFloat(buttonarrayinfo[i][2]))
            
            //テスト用に色をつけてある
//            GestureRecognizerViewwork.backgroundColor = UIColor.blueColor()
            
            if(i == 3){
                screentransitionbuttonwork.layer.cornerRadius = 45
                GestureRecognizerViewwork.layer.cornerRadius = 45
            }else{
                screentransitionbuttonwork.layer.cornerRadius = 25
                GestureRecognizerViewwork.layer.cornerRadius = 25
            }
            
            screentransitionbuttonarray.append(screentransitionbuttonwork)
            GestureRecognizerViewArray.append(GestureRecognizerViewwork)
            tap.append(tapwork)
            screentransitionbuttonarray[i].tag = i
            GestureRecognizerViewArray[i].tag = i
            AnimationMenuView.addSubview(screentransitionbuttonarray[i])
            GestureRecognizerViewArray[i].addGestureRecognizer(tap[i])
            AnimationMenuView.addSubview(GestureRecognizerViewArray[i])
            AnimationMenuView.sendSubviewToBack(GestureRecognizerViewArray[i])
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
            
            UIView.animateWithDuration(1.5, delay: 0.0, options: [UIViewAnimationOptions.Repeat,UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
                
                for(var i = 0; i < 4; i++){
                    self.screentransitionbuttonarray[i].alpha = 0.0
                }
                
                }, completion: { _ in
                    
            })
            
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                
                for(var i = 0; i < 4; i++){
                    self.screentransitionbuttonarray[i].backgroundColor =             UIColor.hex("00e6ff", alpha: 1.0)

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
            })
            
            self.view.sendSubviewToBack(self.AnimationMenuView)
        }
        
    }
    
    func onTap(gestureRecognizer: UITapGestureRecognizer){
        if(menushow == 1){
            print("tap")
        }else{
        }
    }
}
