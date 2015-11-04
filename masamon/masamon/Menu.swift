//
//  Menu.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/29.
//  Copyright © 2015年 Kenta. All rights reserved.
//

//TODO: ボタンの3つに画面遷移を対応づける

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
    let ColorCode: [String] = ["b31aa0","277cff","ffff00","000000"]       //ぐるぐる円のRGBカラーコード
    var ovalShapeLayerArray: [CAShapeLayer] = []
    var tap: [UITapGestureRecognizer] = []
    let moveToPointFirst: [[Int]] = [[248,110],[100,570],[230,640]]
    let addToPointFirst: [[Int]] = [[248,270],[100,350],[230,420]]
    var Straightline: [UIBezierPath] = []
    var lineShapeLayer: [CAShapeLayer] = []
    var lineAnimation: [CABasicAnimation] = []
    
    let strokeAnimationGroup = CAAnimationGroup()

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
        strokeAnimationGroup.duration = 0.2
        strokeAnimationGroup.repeatDuration = CFTimeInterval.infinity
        strokeAnimationGroup.animations = [strokeStartAnimation,strokeEndAnimation]
        
        
        
        //ぐるぐる円の作成
        for(var i = 0; i < 4; i++){
            let GestureRecognizerViewwork = UIView()
            let tapwork = UITapGestureRecognizer()
            let ovalShapeLayerwork = CAShapeLayer()
            
            tapwork.addTarget(self, action: "GestureRecognizerTap:")
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
            GestureRecognizerViewArray[i].tag = i+1
            GestureRecognizerViewArray[i].addGestureRecognizer(tap[i])
            AnimationMenuView.addSubview(GestureRecognizerViewArray[i])
            AnimationMenuView.sendSubviewToBack(GestureRecognizerViewArray[i])
        }
        
        //線のアニメーション
        for(var i = 0; i < 3; i++){
            let linework = UIBezierPath()
            let lineShapeLayerwork = CAShapeLayer()
            let lineAnimationwork = CABasicAnimation(keyPath: "strokeStart")
            
            linework.moveToPoint(CGPointMake(CGFloat(moveToPointFirst[i][0]), CGFloat(moveToPointFirst[i][1])))
            linework.addLineToPoint(CGPointMake(CGFloat(addToPointFirst[i][0]), CGFloat(addToPointFirst[i][1])))
            Straightline.append(linework)
            
            lineShapeLayerwork.path = Straightline[i].CGPath
            lineShapeLayerwork.strokeColor = UIColor.clearColor().CGColor
            lineShapeLayerwork.lineWidth = 2.0
            lineShapeLayerwork.lineDashPattern = [2,3]
            lineShapeLayer.append(lineShapeLayerwork)
            
            lineAnimationwork.fromValue = 1.0
            lineAnimationwork.toValue = 0.0
            lineAnimationwork.duration = 0.3
            lineAnimation.append(lineAnimationwork)
            lineAnimation[i].delegate = self
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
            
            for(var i = 0; i < 4; i++){         //ぐるぐる円
                self.ovalShapeLayerArray[i].addAnimation(strokeAnimationGroup, forKey: nil)
                self.AnimationMenuView.layer.addSublayer(self.ovalShapeLayerArray[i])
                self.ovalShapeLayerArray[i].strokeColor = UIColor.hex(ColorCode[i], alpha: 1.0).CGColor
            }
            
            for(var i = 0; i < 3; i++){     //１番目の点線
                self.lineShapeLayer[i].strokeColor = UIColor.hex(ColorCode[i], alpha: 1.0).CGColor
                
                if(self.lineShapeLayer.isEmpty){    //aut of indexを避けるため
                    self.lineShapeLayer[i+3].strokeColor = UIColor.hex(ColorCode[i], alpha: 1.0).CGColor
                }
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
                    for(var i = 0; i < 3; i++){
                        self.lineShapeLayer[i].addAnimation(self.lineAnimation[i], forKey: nil)
                        self.view.layer.addSublayer(self.lineShapeLayer[i])
                    }
            })
            
        }else{      //メニューが消える
            for(var i = 0; i < 4; i++){
                self.ovalShapeLayerArray[i].strokeColor = UIColor.clearColor().CGColor
            }
            
            for(var i = 0; i < 3; i++){
                self.lineShapeLayer[i].strokeColor = UIColor.clearColor().CGColor
                self.lineShapeLayer[i+3].strokeColor = UIColor.clearColor().CGColor
                
                if(transitionButton.isEmpty){
                    
                }else{
                    for(var i = 0; i < 3; i++){
                        self.transitionButton[i].setTitleColor(UIColor.clearColor(), forState: .Normal)
                    }
                }
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
            finishedcount = 0
        }
        
    }
    
    func GestureRecognizerTap(gestureRecognizer: UITapGestureRecognizer){
        
        //メニューが出ているときのみ動作
        if(menushow == 1){
            Screentransition(gestureRecognizer.view!.tag)     //画面遷移を行う関数へタグを渡す
        }else{
            //メニューが出ていない時は何も動作しない
        }
    }
    
    func TransitionButtonTap(sender: UIButton){
        if(menushow == 1){
            Screentransition(sender.tag)                      //画面遷移を行う関数へタグを渡す
        }else{
            //何もしない
        }
    }
    
    //画面遷移を行う
    func Screentransition(sendertag: Int){
        switch(sendertag){
        case 1:
            print("時給設定")
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HourlyPaySetting")
            self.presentViewController( targetViewController, animated: true, completion: nil)
        case 2:
            print("取り込み")
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShiftImport")
            self.presentViewController( targetViewController, animated: true, completion: nil)
        case 3:
            print("月給表示")
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthlySalaryShow")
            self.presentViewController( targetViewController, animated: true, completion: nil)
        case 4:
            print("開発者ロール")
        default:
            break
        }

    }
    
    var finishedcount = 0
    let moveToPointSecond: [[Int]] = [[110,110],[200,570],[330,640]]
    let addToPointSecond: [[Int]] = [[248,110],[100,570],[230,640]]
    
    //CAanimation終了後に呼ばれる
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        finishedcount++
        
        if(finishedcount == 3){  //最初の線が伸びていくアニメーション終了後
            ShowSecondLine()
        }
        
        if(finishedcount == 6){ //2番目に線が伸びていくアニメーション終了後
            if(transitionButton.isEmpty){                               //アニメーションを最後まで見て生成しているかどうかを判断
                ShowTransitionButton()
            }else{//生成している場合は表示だけ行う
                for(var i = 0; i < 3; i++){
                    self.transitionButton[i].setTitleColor(UIColor.hex(ColorCode[i], alpha: 1.0), forState: .Normal)
                }
            }
        }
    }
    
    //2番目の点線を表示
    func ShowSecondLine(){
        for(var i = 3; i < 6; i++){
            let linework = UIBezierPath()
            let lineShapeLayerwork = CAShapeLayer()
            let lineAnimationwork = CABasicAnimation(keyPath: "strokeStart")
            
            linework.moveToPoint(CGPointMake(CGFloat(moveToPointSecond[i-3][0]), CGFloat(moveToPointSecond[i-3][1])))
            linework.addLineToPoint(CGPointMake(CGFloat(addToPointSecond[i-3][0]), CGFloat(addToPointSecond[i-3][1])))
            Straightline.append(linework)
            
            lineShapeLayerwork.path = Straightline[i].CGPath
            lineShapeLayerwork.strokeColor = UIColor.clearColor().CGColor
            lineShapeLayerwork.lineWidth = 2.0
            lineShapeLayerwork.lineDashPattern = [2,3]
            lineShapeLayer.append(lineShapeLayerwork)
            
            lineAnimationwork.fromValue = 1.0
            lineAnimationwork.toValue = 0.0
            lineAnimationwork.duration = 0.3
            lineAnimation.append(lineAnimationwork)
            lineAnimation[i].delegate = self
            
            //アニメーションの途中でボタンを押されても見えないようにするため
            if(menushow == 1){
                self.lineShapeLayer[i].strokeColor = UIColor.hex(ColorCode[i-3], alpha: 1.0).CGColor
            }else{
            }
            self.lineShapeLayer[i].addAnimation(self.lineAnimation[i], forKey: nil)
            self.view.layer.addSublayer(self.lineShapeLayer[i])
        }
    }
    
    var transitionButton: [UIButton] = []
    let transitionButtonTitle: [String] = ["時給設定","取り込み","月給表示"]
    let transitionButtonPosition: [[Int]] = [[150,25],[165,485],[295,555]]
    
    func ShowTransitionButton(){
        for(var i = 0; i < 3; i++){
            let transitionButtonwork = UIButton()
            transitionButtonwork.frame = CGRectMake(0, 0, 100, 50)
            transitionButtonwork.backgroundColor = UIColor.clearColor()
            transitionButtonwork.layer.position = CGPoint(x: transitionButtonPosition[i][0], y:transitionButtonPosition[i][1])
            transitionButtonwork.setTitle(transitionButtonTitle[i], forState: .Normal)
            transitionButtonwork.setTitleColor(UIColor.hex(ColorCode[i], alpha: 1.0), forState: .Normal)
            transitionButtonwork.addTarget(self, action: "TransitionButtonTap:", forControlEvents:.TouchUpInside)
            transitionButtonwork.tag = i+1
            transitionButton.append(transitionButtonwork)
            self.AnimationMenuView.addSubview(transitionButton[i])
        }
    }
}
