//
//  Menu.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/10.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class Menu: MenuBar {

    @IBOutlet weak var background: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        background.image = UIImage(named: "../images/img298.png")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func MenuButtontapped(sender: UIButton){
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func TapMonthlySalaryShow(sender: AnyObject) {
    }
    
    @IBAction func TapShiftImport(sender: AnyObject) {
    }
    @IBAction func TapHourlyPaySetting(sender: AnyObject) {
    }
    @IBAction func TapUserSetting(sender: AnyObject) {
    }
    @IBAction func TapEndRoll(sender: AnyObject) {
    }
}
