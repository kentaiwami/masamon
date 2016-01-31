//
//  Setting.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/31.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class Setting: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func TapUserSetting(sender: AnyObject) {
        
        
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserSetting")
        self.presentViewController( targetViewController, animated: true, completion: nil)

        
    }
}
