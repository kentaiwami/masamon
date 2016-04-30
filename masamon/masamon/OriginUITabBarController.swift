//
//  OriginUITabBarController.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/04/30.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class OriginUITabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.barTintColor = UIColor.hex("191919", alpha: 1.0)
        self.tabBar.translucent = false
        
        
        let fontFamily: UIFont! = UIFont.systemFontOfSize(10)
        let selectedColor:UIColor = UIColor.hex("FF8E92", alpha: 1.0)

        let selectedAttributes = [NSFontAttributeName: fontFamily, NSForegroundColorAttributeName: selectedColor]

        self.tabBarItem.setTitleTextAttributes(selectedAttributes, forState: UIControlState.Selected)
        UITabBar.appearance().tintColor = selectedColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
