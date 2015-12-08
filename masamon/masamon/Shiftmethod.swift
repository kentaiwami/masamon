//
//  ShiftRegister.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/06.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class Shiftmethod: UIViewController {
    
    //cellの列(日付が記載されている範囲)
    let cellrow = ["G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ"]
    let holiday = ["公","夏","有"]     //表に記載される休暇日
    let staffnumber = 27    //TODO: 仮に設定。あとで入力項目を設ける
    let mark = "F"
    var number = 6
    
    //
    func ShiftDBOneCoursRegist(importname: String, importpath: String, update: Bool){
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        var date = 11
        let staffcellposition = self.StaffCellPositionGet()     //スタッフの名前が記載されているセル場所 ex.)F8,F9
        var shiftdetailarray = List<ShiftDetailDB>()
        var shiftdetailrecordcount = DBmethod().DBRecordCount(ShiftDetailDB)
        
        //30日分繰り返すループ
        for(var i = 0; i < 30; i++){
            let shiftdb = ShiftDB()
            let shiftdetaildb = ShiftDetailDB()
            
            if(update){
                shiftdb.id = DBmethod().SerachShiftDB(importname).id        //取り込みが上書きの場合は使われているidをそのまま使う
            }else{
                shiftdb.id = DBmethod().DBRecordCount(ShiftDetailDB)/30     //新規の場合はレコードの数を割ったidを使う
            }

            shiftdb.shiftimportname = importname
            shiftdb.shiftimportpath = importpath
            
            shiftdetaildb.id = shiftdetailrecordcount
            shiftdetailrecordcount++
            shiftdetaildb.date = date
            shiftdetaildb.shiftDBrelationship = shiftdb
            
            //その日のシフトを全員分調べて出勤者だけ列挙する
            for(var j = 0; j < staffnumber; j++){
                let nowstaff = staffcellposition[j]
                let replaceday = nowstaff.stringByReplacingOccurrencesOfString("F", withString: cellrow[i])
                
                let dayshift: String = worksheet.cellForCellReference(replaceday).stringValue()
                let staffname: String = worksheet.cellForCellReference(nowstaff).stringValue()
                
                if(holiday.contains(dayshift) == false){       //Holiday以外なら記録
                    shiftdetaildb.staff = shiftdetaildb.staff + staffname + ":" + dayshift + ","
                }
            }
            
            //シフトが11日〜来月10日のため日付のリセットを行うか判断
            if(date < 30){
                date++
            }else{
                date = 1
            }

            for(var i = 0; i < shiftdetailarray.count; i++){
                shiftdb.shiftdetail.append(shiftdetailarray[i])
            }
            shiftdb.shiftdetail.append(shiftdetaildb)
            
            let ID = shiftdb.id
            
            DBmethod().AddandUpdate(shiftdb, update: true)
            DBmethod().AddandUpdate(shiftdetaildb, update: true)

            shiftdetailarray = self.ShiftDBRelationArrayGet(ID)
        }
    }
    
    //表中にあるスタッフ名の場所を返す
    func StaffCellPositionGet() -> Array<String>{
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        
        var array:[String] = []
        
        
        while(true){
            let Fcell: String = worksheet.cellForCellReference(mark+String(number)).stringValue()
            if(Fcell.isEmpty){       //セルが空なら進めるだけ
                number++
            }else{
                array.append(mark+String(number))
                number++
            }
            
            if(staffnumber == array.count){       //設定したスタッフ人数と取り込み数が一致したら
                break
            }
        }
        return array
    }
    
    //ShiftDBのリレーションシップ配列を返す
    func ShiftDBRelationArrayGet(id: Int) -> List<ShiftDetailDB>{
        var list = List<ShiftDetailDB>()
        let realm = try! Realm()
        
        list = realm.objects(ShiftDB).filter("id = %@", id)[0].shiftdetail
        
        return list
        
    }
    
    //入力したユーザ名の月給を計算して結果を返す
    func UserMonthlySalaryRegist(importname: String){
        var usershift:[String] = []
        
        let username = DBmethod().UserNameGet()
        let staffcellposition = self.StaffCellPositionGet()
        
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        var userposition = ""
        
        //F列からユーザ名と合致する箇所を探す
        for(var i = 0; i < staffnumber; i++){
            let nowcell: String = worksheet.cellForCellReference(staffcellposition[i]).stringValue()
            
            if(nowcell == username){
                userposition = staffcellposition[i]
                break
            }
        }
        
        //1クール分行う
        for(var i = 0; i < 30; i++){
            let replaceday = userposition.stringByReplacingOccurrencesOfString("F", withString: cellrow[i])
            let dayshift: String = worksheet.cellForCellReference(replaceday).stringValue()
            
            if(holiday.contains(dayshift) == false){      //holiday以外なら
                usershift.append(dayshift)
            }
        }
        
        //月給の計算をする
        var shiftsystem = ShiftSystem()
        var monthlysalary = 0.0
        let houlypayrecord = DBmethod().HourlyPayRecordGet()
        
        for(var i = 0; i < usershift.count; i++){
            
            shiftsystem = DBmethod().SerachShiftSystem(usershift[i])
            if(shiftsystem.endtime <= houlypayrecord[0].timeto){
                monthlysalary = monthlysalary + (shiftsystem.endtime - shiftsystem.starttime - 1) * Double(houlypayrecord[0].pay)
            }else{
                //22時以降の給与を先に計算
                let latertime = shiftsystem.endtime - houlypayrecord[0].timeto
                monthlysalary = monthlysalary + latertime * Double(houlypayrecord[1].pay)
                
                monthlysalary = monthlysalary + (shiftsystem.endtime - latertime - shiftsystem.starttime - 1) * Double(houlypayrecord[0].pay)
            }
        }
        
        print(monthlysalary)
        //TODO: データベースへ記録
       // let realm = try! Realm()
//        let todos = realm.objects(ShiftDB).filter("shiftimportname = %@",importname)
//        todos.setValue(monthlysalary, forKey: "saraly")
       // realm.create(ShiftDB.self, value: ["shiftimportname": importname,"saraly": monthlysalary], update: true)
//        let AAA = ShiftDB()
//        AAA.id = 1
//        AAA.shiftimportname = importname
//        AAA.saraly = Int(monthlysalary)
//        DBmethod().AddandUpdate(AAA, update: true)
    }
}

