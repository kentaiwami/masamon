//
//  UserNameRegister.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/07.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class UserNameRegister: UIViewController {

    @IBOutlet weak var usernametextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernametextfield.text = "月給を表示するシフト表上での名前を入力"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
