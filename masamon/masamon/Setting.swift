//
//  Setting.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/31.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import Eureka

class Setting: FormViewController {
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ナビゲーションバーの色などを設定する
        self.navigationController!.navigationBar.barTintColor = UIColor.black
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        self.tableView.isScrollEnabled = false
        
        let storyboard: UIStoryboard = self.storyboard!
        let HourlyWageSetting_VC = storyboard.instantiateViewController(withIdentifier: "HourlyWageSetting")
        let ShiftImportSetting_VC = storyboard.instantiateViewController(withIdentifier: "ShiftImportSetting")
        let StaffNameListSetting_VC = storyboard.instantiateViewController(withIdentifier: "StaffNameListSetting")
        let ShiftNameListSetting_VC = storyboard.instantiateViewController(withIdentifier: "ShiftNameListSetting")
        let ShiftListSetting_VC = storyboard.instantiateViewController(withIdentifier: "ShiftListSetting")

        form +++ Section()
            <<< ButtonRow() {
                $0.title = "時給の設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return HourlyWageSetting_VC},
                                            onDismiss: { vc in
                                                vc.navigationController?.popViewController(animated: true)}
                )
        }
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "ユーザ名と従業員数の設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return ShiftImportSetting_VC},
                                            onDismiss: { vc in
                                                vc.navigationController?.popViewController(animated: true)}
                )
        }
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "従業員名の設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return StaffNameListSetting_VC},
                                            onDismiss: { vc in
                                                vc.navigationController?.popViewController(animated: true)}
                )
        }
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "シフト名の設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return ShiftNameListSetting_VC},
                                            onDismiss: { vc in
                                                vc.navigationController?.popViewController(animated: true)}
                )
        }
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "取り込んだシフトの設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return ShiftListSetting_VC},
                                            onDismiss: { vc in
                                                vc.navigationController?.popViewController(animated: true)}
                )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appDelegate.screennumber = 2
    }
}
