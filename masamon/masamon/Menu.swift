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

    //メニューボタンを押したとき
    override func MenuButtontapped(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //月給表示ボタンを押したとき
    @IBAction func TapMonthlySalaryShow(sender: AnyObject) {
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthlySalaryShow")
        targetViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(targetViewController, animated: true, completion: nil)
    }
    
    //シフト取り込みボタンを押したとき
    @IBAction func TapShiftImport(sender: AnyObject) {
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShiftImport")
        targetViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(targetViewController, animated: true, completion: nil)
    }
    
    //月給設定ボタンを押したとき
    @IBAction func TapHourlyPaySetting(sender: AnyObject) {
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HourlyPaySetting")
        targetViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(targetViewController, animated: true, completion: nil)
    }
    
    //ユーザ設定ボタンを押したとき
    @IBAction func TapUserSetting(sender: AnyObject) {
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserSetting")
        targetViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(targetViewController, animated: true, completion: nil)
    }
    
    //エンドロールボタンを押したとき
    @IBAction func TapEndRoll(sender: AnyObject) {
        //TODO: エンドロール画面へ遷移
    }
}
