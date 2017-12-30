//
//  HourlyWageSetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/28.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import Eureka

class HourlyWageSetting: FormViewController {
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

    var timeUIPicker: UIPickerView = UIPickerView()
    
    let time = Utility().GetTime()
    
    var default_daytime_s = ""
    var default_daytime_e = ""
    var default_daytime_wage = 0
    var default_nighttime_s = ""
    var default_nighttime_e = ""
    var default_nighttime_wage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        CreateForm()
    }
    
    func CreateForm() {
        let RuleRequired_M = "必須項目です"
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        default_daytime_s = time[0]
        default_daytime_e = time[0]
        default_daytime_wage = 0
        default_nighttime_s = time[0]
        default_nighttime_e = time[0]
        default_nighttime_wage = 0
    
        if DBmethod().DBRecordCount(HourlyPayDB.self) != 0 {
            let hourlypayarray = DBmethod().HourlyPayRecordGet()
            default_daytime_s = time[Int(hourlypayarray[0].timefrom * 2) - 2]
            default_daytime_e = time[Int(hourlypayarray[0].timeto * 2) - 2]
            default_nighttime_s = time[Int(hourlypayarray[1].timefrom * 2) - 2]
            default_nighttime_e = time[Int(hourlypayarray[1].timeto * 2) - 2]
            default_daytime_wage = hourlypayarray[0].pay
            default_nighttime_wage = hourlypayarray[1].pay
        }

        form +++ Section("日中")
            <<< PickerInputRow<String>(""){
                $0.title = "開始時間"
                $0.options = time
                $0.value = default_daytime_s
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "daytime_s"
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = RuleRequired_M
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
                
            <<< PickerInputRow<String>(""){
                $0.title = "終了時間"
                $0.options = time
                $0.value = default_daytime_e
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "daytime_e"
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = RuleRequired_M
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
            <<< IntRow(){
                $0.title = "時給"
                $0.value = default_daytime_wage
                $0.tag = "daytime_wage"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = RuleRequired_M
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
        form +++ Section(header: "深夜", footer: "値を全て入力しないと値が保存されません")
            <<< PickerInputRow<String>(""){
                $0.title = "開始時間"
                $0.options = time
                $0.value = default_nighttime_s
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "nighttime_s"
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = RuleRequired_M
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            
            <<< PickerInputRow<String>(""){
                $0.title = "終了時間"
                $0.options = time
                $0.value = default_nighttime_e
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "nighttime_e"
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = RuleRequired_M
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            
            <<< IntRow(){
                $0.title = "時給"
                $0.value = default_nighttime_wage
                $0.tag = "nighttime_wage"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = RuleRequired_M
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var validate_err_count = 0
        for row in form.allRows {
            validate_err_count += row.validate().count
        }
        
        if validate_err_count == 0 {
            let daytime_s = form.values()["daytime_s"] as! String
            let daytime_e = form.values()["daytime_e"] as! String
            let daytime_wage = form.values()["daytime_wage"] as! Int
            let nighttime_s = form.values()["nighttime_s"] as! String
            let nighttime_e = form.values()["nighttime_e"] as! String
            let nighttime_wage = form.values()["nighttime_wage"] as! Int
            
            let hourlypayrecord_daytime = HourlyPayDB()
            let hourlypayrecord_nighttime = HourlyPayDB()
            hourlypayrecord_daytime.id = 1
            hourlypayrecord_daytime.timefrom = Double(time.index(of: daytime_s)!) - (Double(time.index(of: daytime_s)!)*0.5) + 1.0
            hourlypayrecord_daytime.timeto = Double(time.index(of: daytime_e)!)-(Double(time.index(of: daytime_e)!)*0.5) + 1.0
            hourlypayrecord_daytime.pay = daytime_wage
            hourlypayrecord_nighttime.id = 2
            hourlypayrecord_nighttime.timefrom = Double(time.index(of: nighttime_s)!)-(Double(time.index(of: nighttime_s)!)*0.5) + 1.0
            hourlypayrecord_nighttime.timeto = Double(time.index(of: nighttime_e)!)-(Double(time.index(of: nighttime_e)!)*0.5) + 1.0
            hourlypayrecord_nighttime.pay = nighttime_wage

            DBmethod().AddandUpdate(hourlypayrecord_daytime,update: true)
            DBmethod().AddandUpdate(hourlypayrecord_nighttime,update: true)
        }else {
            present(Utility().GetStandardAlert(title: "エラー", message: "入力されていない項目があるため保存できませんでした", b_title: "OK"),animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
