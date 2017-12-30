//
//  ShiftImportSetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/05/08.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import Eureka

class ShiftImportSetting: FormViewController {
    
    var default_staff_name = ""
    var default_staff_count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        default_staff_name = ""
        default_staff_count = 0
        
        if DBmethod().DBRecordCount(UserNameDB.self) != 0 {
            default_staff_name = DBmethod().UserNameGet()
            default_staff_count = DBmethod().StaffNumberGet()
        }
        
        form +++ Section("")
            <<< TextRow() {
                $0.title = "シフト表での名前"
                $0.value = default_staff_name
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "name"
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
                $0.title = "従業員の人数"
                $0.value = default_staff_count
                $0.tag = "count"
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
            let name = form.values()["name"] as! String
            let count = form.values()["count"] as! Int
            
            let staffnumberrecord = StaffNumberDB()
            staffnumberrecord.id = 0
            staffnumberrecord.number = count
            let usernamerecord = UserNameDB()
            usernamerecord.id = 0
            usernamerecord.name = name

            DBmethod().AddandUpdate(usernamerecord, update: true)
            DBmethod().AddandUpdate(staffnumberrecord, update: true)
        }else {
            present(Utility().GetStandardAlert(title: "エラー", message: "入力されていない項目があるため保存できませんでした", b_title: "OK"),animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
