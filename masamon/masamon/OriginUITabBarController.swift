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
        self.tabBar.isTranslucent = false
        
        
        let fontFamily: UIFont! = UIFont.systemFont(ofSize: 10)
        let selectedColor:UIColor = UIColor.hex("FF8E92", alpha: 1.0)

        let selectedAttributes = [NSFontAttributeName: fontFamily, NSForegroundColorAttributeName: selectedColor] as [String : Any]

        self.tabBarItem.setTitleTextAttributes(selectedAttributes, for: UIControlState.selected)
        UITabBar.appearance().tintColor = selectedColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
