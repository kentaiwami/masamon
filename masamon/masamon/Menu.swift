//
//  Menu.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/29.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: 丸をアニメーションの線にする Done
//TODO: アニメーションから点線を伸ばす
//TODO: 点線の先にどの画面へ行くのかを文字で表示
//TODO: ボタンの3つに画面遷移を対応づける
//TODO: ボタン3つを色分けする

import UIKit

class Menu: UIViewController{
    var AnimationMenuView = UIView()
    let menuimage = UIImage(named: "../images/Menu-50_White.png")
    let MenuButton   = UIButton()
    var ToolBar = UIToolbar()
    var backimage = UIImage(named: "../images/background.jpg")
    var backimageview = UIImageView()
    var menushow = 0
    let circleimage = UIImage(named: "../images/circle.png")
    var circleimageview = UIImageView()
    
    let GesturePositionArray: [[Int]] = [[225,171,50],[75,260,50],[200,330,50],[145,217,90]] //右上,左下,右下,真ん中
    var GestureRecognizerViewArray: [UIView] = []
    let ovalShapeLayerArrayColorCode: [String] = ["6648ff","6648ff","6648ff","6648ff"]       //ぐるぐる円のRGBカラーコード
    var ovalShapeLayerArray: [CAShapeLayer] = []
    var tap: [UITapGestureRecognizer] = []
    let moveToPoint: [[Int]] = [[50,100],[100,100],[150,100],[200,100]]
    let addToPoint: [[Int]] = [[50,300],[100,300],[150,300],[200,300]]
    var Straightline: [UIBezierPath] = []
    var lineShapeLayer: [CAShapeLayer] = []
    var lineAnimation: [CABasicAnimation] = []
    
//    let ovalShapeLayer = CAShapeLayer()
    
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
        
        // 輪郭の線をアニメーションする(くるくるする)
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = -0.5
        strokeStartAnimation.toValue = 1.0
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 0.2
        strokeAnimationGroup.repeatDuration = CFTimeInterval.infinity
        strokeAnimationGroup.animations = [strokeStartAnimation,strokeEndAnimation]

        
        
        //遷移ボタンの作成
        for(var i = 0; i < 4; i++){
            let GestureRecognizerViewwork = UIView()
            let tapwork = UITapGestureRecognizer()
            let ovalShapeLayerwork = CAShapeLayer()
            
            tapwork.addTarget(self, action: "onTap:")
            GestureRecognizerViewwork.frame = CGRectMake(CGFloat(GesturePositionArray[i][0]),CGFloat(GesturePositionArray[i][1]),CGFloat(GesturePositionArray[i][2]),CGFloat(GesturePositionArray[i][2]))
            
            ovalShapeLayerwork.strokeColor = UIColor.clearColor().CGColor
            ovalShapeLayerwork.fillColor = UIColor.clearColor().CGColor
            ovalShapeLayerwork.lineWidth = 6.0
            ovalShapeLayerwork.path = UIBezierPath(ovalInRect: CGRect(x: CGFloat(GesturePositionArray[i][0]), y: CGFloat(GesturePositionArray[i][1]), width: CGFloat(GesturePositionArray[i][2]), height: CGFloat(GesturePositionArray[i][2]))).CGPath
            
            if(i == 3){
                GestureRecognizerViewwork.layer.cornerRadius = 45
            }else{
                GestureRecognizerViewwork.layer.cornerRadius = 25
            }
            
            GestureRecognizerViewArray.append(GestureRecognizerViewwork)
            tap.append(tapwork)
            ovalShapeLayerArray.append(ovalShapeLayerwork)
            ovalShapeLayerArray[i].addAnimation(strokeAnimationGroup, forKey: nil)
            GestureRecognizerViewArray[i].tag = i
            GestureRecognizerViewArray[i].addGestureRecognizer(tap[i])
            AnimationMenuView.addSubview(GestureRecognizerViewArray[i])
            AnimationMenuView.sendSubviewToBack(GestureRecognizerViewArray[i])
            self.AnimationMenuView.layer.addSublayer(self.ovalShapeLayerArray[i])
            
            //線のアニメーション
            let linework = UIBezierPath()
            let lineShapeLayerwork = CAShapeLayer()
            let lineAnimationwork = CABasicAnimation(keyPath: "strokeStart")
            
            linework.moveToPoint(CGPointMake(CGFloat(moveToPoint[i][0]), CGFloat(moveToPoint[i][1])))
            linework.addLineToPoint(CGPointMake(CGFloat(addToPoint[i][0]), CGFloat(addToPoint[i][1])))
            Straightline.append(linework)
            Straightline[i].stroke()

            lineShapeLayerwork.path = Straightline[i].CGPath
            lineShapeLayerwork.strokeColor = UIColor.redColor().CGColor
            lineShapeLayerwork.lineWidth = 5.0
            lineShapeLayerwork.lineDashPattern = [2,3]
            lineShapeLayer.append(lineShapeLayerwork)
            
            lineAnimationwork.fromValue = 1.0
            lineAnimationwork.toValue = 0.0
            lineAnimationwork.duration = 15.0
            lineAnimation.append(lineAnimationwork)

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
            for(var i = 0; i < 4; i++){
                self.ovalShapeLayerArray[i].strokeColor = UIColor.hex(ovalShapeLayerArrayColorCode[i], alpha: 1.0).CGColor

            }
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                self.view.bringSubviewToFront(self.AnimationMenuView)
                self.menushow = 1
            })
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                // 魔法陣出現の処理
                self.circleimageview.frame = CGRectMake(0, 60, self.view.frame.width, 400)
                self.circleimageview.alpha = 1.0
                }, completion: { _ in
                    for(var i = 0; i < 4; i++){
                    self.lineShapeLayer[i].addAnimation(self.lineAnimation[i], forKey: nil)
                    self.view.layer.addSublayer(self.lineShapeLayer[i])
                    }
            })
            
        }else{      //メニューが消える
            for(var i = 0; i < 4; i++){
                self.ovalShapeLayerArray[i].strokeColor = UIColor.clearColor().CGColor
            }
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.circleimageview.alpha = 0.0
                self.menushow = 0
            })
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.AnimationMenuView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
                }, completion: { _ in
            })
            
            self.view.sendSubviewToBack(self.AnimationMenuView)
        }
        
    }
    
    func onTap(gestureRecognizer: UITapGestureRecognizer){
        
        //メニューが出ているときのみ動作
        if(menushow == 1){
            print("tap")
        }else{
            //メニューが出ていない時は何も動作しない
        }
    }
}
