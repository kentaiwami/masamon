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
    let cellrow = ["G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK"]
    let holiday = ["公","夏","有"]     //表に記載される休暇日
    let staffnumber = DBmethod().StaffNumberGet()
    let mark = "F"
    var number = 6
    
    let TEST = "aaa"
    
    
    //ワンクール分のシフトをShiftDetailDBとShiftDBへ記録する
    func ShiftDBOneCoursRegist(importname: String, importpath: String, update: Bool){
        
        let documentPath: String = NSBundle.mainBundle().pathForResource(TEST, ofType: "xlsx")!
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
                let existshiftdb = DBmethod().SearchShiftDB(importname)
                let newshiftdetaildb = ShiftDetailDB()
                
                shiftdb.id = existshiftdb.id        //取り込みが上書きの場合は使われているidをそのまま使う
                shiftdb.year = 0
                shiftdb.month = 0

                newshiftdetaildb.id = existshiftdb.shiftdetail[i].id
                newshiftdetaildb.day = existshiftdb.shiftdetail[i].day
                newshiftdetaildb.staff = TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet)
                newshiftdetaildb.shiftDBrelationship = DBmethod().SearchShiftDB(importname)
                
                DBmethod().AddandUpdate(shiftdb, update: true)
                DBmethod().AddandUpdate(newshiftdetaildb, update: true)
            }else{
                shiftdb.id = DBmethod().DBRecordCount(ShiftDetailDB)/30     //新規の場合はレコードの数を割ったidを使う
                shiftdb.shiftimportname = importname
                shiftdb.shiftimportpath = importpath
                shiftdb.salaly = 0
                shiftdb.year = 0
                shiftdb.month = 0
                
                shiftdetaildb.id = shiftdetailrecordcount
                shiftdetailrecordcount++
                shiftdetaildb.day = date
                shiftdetaildb.shiftDBrelationship = shiftdb
                shiftdetaildb.staff = TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet)
                
                //シフトが11日〜来月10日のため日付のリセットを行うか判断
                if(date < 30){
                    date++
                }else{
                    date = 1
                }
                
                //すでに記録してあるListを取得して後ろに現在の記録を追加する
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
    }
    
    //表中にあるスタッフ名の場所を返す
    func StaffCellPositionGet() -> Array<String>{
        let documentPath: String = NSBundle.mainBundle().pathForResource(TEST, ofType: "xlsx")!
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
    
    //入力したユーザ名の月給を計算して結果をDBへ記録する
    func UserMonthlySalaryRegist(importname: String){
        var usershift:[String] = []
        
        let username = DBmethod().UserNameGet()
        let staffcellposition = self.StaffCellPositionGet()
        
        let documentPath: String = NSBundle.mainBundle().pathForResource(TEST, ofType: "xlsx")!
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
            
            shiftsystem = DBmethod().SearchShiftSystem(usershift[i])
            if(shiftsystem.endtime <= houlypayrecord[0].timeto){
                monthlysalary = monthlysalary + (shiftsystem.endtime - shiftsystem.starttime - 1) * Double(houlypayrecord[0].pay)
            }else{
                //22時以降の給与を先に計算
                let latertime = shiftsystem.endtime - houlypayrecord[0].timeto
                monthlysalary = monthlysalary + latertime * Double(houlypayrecord[1].pay)
                
                monthlysalary = monthlysalary + (shiftsystem.endtime - latertime - shiftsystem.starttime - 1) * Double(houlypayrecord[0].pay)
            }
        }
        
        //データベースへ記録上書き登録
        let newshiftdbsalalyadd = ShiftDB()                                 //月給を追加するための新規インスタンス
        let oldshiftdbsalalynone = DBmethod().SearchShiftDB(importname)     //月給がデフォルト値で登録されているShiftDBオブジェクト
        
        newshiftdbsalalyadd.id = oldshiftdbsalalynone.id
        
        for(var i = 0; i < oldshiftdbsalalynone.shiftdetail.count; i++){
            newshiftdbsalalyadd.shiftdetail.append(oldshiftdbsalalynone.shiftdetail[i])
        }
        
        newshiftdbsalalyadd.shiftimportname = oldshiftdbsalalynone.shiftimportname
        newshiftdbsalalyadd.shiftimportpath = oldshiftdbsalalynone.shiftimportpath
        newshiftdbsalalyadd.salaly = Int(monthlysalary)
        newshiftdbsalalyadd.year = JudgeYearAndMonth().year
        newshiftdbsalalyadd.month = JudgeYearAndMonth().endcoursmonth
        
        DBmethod().AddandUpdate(newshiftdbsalalyadd, update: true)
    }
    
    
    //その日のシフトを全員分調べて出勤者だけ列挙する。
    /*引数の説明。
    day                     => その日の日付
    staffcellpositionarray  =>スタッフのセル位置を配列で記録したもの
    worksheet               =>対象となるエクセルファイルのワークシート
    */
    func TheDayStaffAttendance(day: Int, staffcellpositionarray: Array<String>, worksheet: BRAWorksheet) -> String{
        
        var staffstring = ""
        
        for(var i = 0; i < staffnumber; i++){
            let nowstaff = staffcellpositionarray[i]
            let replaceday = nowstaff.stringByReplacingOccurrencesOfString("F", withString: cellrow[day])
            
            let dayshift: String = worksheet.cellForCellReference(replaceday).stringValue()
            let staffname: String = worksheet.cellForCellReference(nowstaff).stringValue()
            
            if(holiday.contains(dayshift) == false){       //Holiday以外なら記録
                staffstring = staffstring + staffname + ":" + dayshift + ","
            }
        }
        
        return staffstring
    }
    
    //返り値は
    //年、11日〜月末までの月、1日〜10日までの月
    func JudgeYearAndMonth() -> (year: Int, startcoursmonth: Int, endcoursmonth: Int){
        
        let documentPath: String = NSBundle.mainBundle().pathForResource(TEST, ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        let P1String: String = worksheet.cellForCellReference("P1").stringValue()
        let P1NSString = P1String as NSString
        let year = P1NSString.substringWithRange(NSRange(location: 2, length: 2))                    //平成何年かを取得
        let positionmonth = P1NSString.rangeOfString("月度").location                          //"月度"が出る場所を記録
        let monthsecondcharacter = String(P1String[P1String.startIndex.advancedBy(positionmonth-1)])   //月の最初の文字
        let monthfirstcharacter = String(P1String[P1String.startIndex.advancedBy(positionmonth-2)])
        
        if(monthsecondcharacter >= "3" && monthsecondcharacter <= "9"){       //3月度〜9月度ならば
            return (Int(year)!,Int(monthsecondcharacter)!-1,Int(monthsecondcharacter)!)
        }else{                                                              //0,1,2が1の位に来ている場合
            switch(monthsecondcharacter){
            case "0":
                return (Int(year)!,9,10)            //10月で確定
                
            case "1":
                if(monthfirstcharacter == "1"){
                    return (Int(year)!,10,11)       //11月で確定
                }else{
                    return (Int(year)!,12,1)        //1月で確定
                }
                
            case "2":
                if(monthfirstcharacter == "1"){
                    return (Int(year)!,11,12)       //12月で確定
                }
                
            default:
                break
            }
            
         return (Int(year)!,1,2)        //2月で確定
        }
    }
}

