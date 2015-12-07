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
    func ShiftDBOneCoursRegist(importname: String, importpath: String){
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        var date = 11
        let staffcellposition = self.StaffCellPositionGet()     //スタッフの名前が記載されているセル場所 ex.)F8,F9
        var shiftdetailarray = List<ShiftDetailDB>()
        
        //30日分繰り返すループ
        for(var i = 0; i < 30; i++){
            let shiftdb = ShiftDB()
            let shiftdetaildb = ShiftDetailDB()
            
            shiftdb.id = DBmethod().DBRecordCount(ShiftDetailDB)/30     //30レコードで1セットのため
            shiftdb.shiftimportname = importname
            shiftdb.shiftimportpath = importpath
            
            shiftdetaildb.id = i
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
            DBmethod().AddandUpdate(shiftdetaildb, update: false)

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
    
    //入力したユーザ名の1クール分の出勤(休みは除く)を配列で取得する
    func UserOneCoursShiftGet() -> Array<String>{
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
        
        for(var i = 0; i < usershift.count; i++){
            shiftsystem = DBmethod().SerachShiftSystem(usershift[i])
            print(shiftsystem)
        }
        
        return usershift
    }
}


//                //TODO: データベースのシフト体制に含まれているか検索
//                DBmethod().SerachShiftSystem("")
//                //TODO: 含まれている、かつオーバーでなければ勤務終了時間-勤務開始時間-1(休憩時間)
//
//                //TODO: 含まれていなければ休みとして処理
//
//                //TODO: 時給設定と照らし合わせて金額を算出

