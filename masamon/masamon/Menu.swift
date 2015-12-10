//
//  Menu.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/10.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class Menu: UIViewController {

    let menuimage = UIImage(named: "../images/Menu-50_White.png")
    let MenuButton   = UIButton()
    var ToolBar = UIToolbar()
    var statusbar = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ステータスバーに被せるviewの作成
        statusbar.frame = CGRectMake(0.0, 0.0, self.view.frame.width, 20.0)
        statusbar.backgroundColor = UIColor.whiteColor()
        
        
        //ツールバーの作成
        ToolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 60.0))
        ToolBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 50.0)
        ToolBar.barStyle = .BlackTranslucent
        ToolBar.tintColor = UIColor.whiteColor()
        ToolBar.backgroundColor = UIColor.blackColor()
        ToolBar.alpha = 0.1
        
        //メニューボタンの作成
        MenuButton.frame = CGRectMake(0, 0, 50, 50)
        MenuButton.layer.position = CGPoint(x: self.view.frame.width-30, y:50)
        MenuButton.setImage(menuimage, forState: .Normal)
        MenuButton.addTarget(self, action: "MenuButtontapped:", forControlEvents:.TouchUpInside)
        
        self.view.addSubview(statusbar)
        self.view.addSubview(ToolBar)
        self.view.addSubview(MenuButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //メニューボタンを押した時のアニメーション
    func MenuButtontapped(sender: UIButton){
    }
}
