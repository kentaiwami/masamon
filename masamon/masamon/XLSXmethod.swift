//
//  ShiftRegister.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/06.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class XLSXmethod: UIViewController {
    
    //cellの列(日付が記載されている範囲)
    let cellrow = ["G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK"]
    let holiday = DBmethod().ShiftSystemNameArrayGetByGroudid(6)      //休暇のシフト体制を取得
    let mark = "F"
    var number = 6
    
    var flag = true
    
    var documentPath: String = ""
    var spreadsheet = BRAOfficeDocumentPackage()
    var worksheet = BRAWorksheet()
    var P1String: String = ""
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    //XLSXファイルのインスタンスをセットするメソッド
    func SetXLSX() -> (sheet: BRAWorksheet, P1:String){
        
        if flag {
            documentPath = DBmethod().FilePathTmpGet() as String
            spreadsheet = BRAOfficeDocumentPackage.open(documentPath)
            worksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
            P1String = worksheet.cellForCellReference("P1").stringValue()
            flag = false
            return (worksheet,P1String)
        }else{
            return (worksheet,P1String)
        }
    
    }
    
    //ワンクール分のシフトをShiftDetailDBとShiftDBへ記録する
    func ShiftDBOneCoursRegist(importname: String, importpath: String, update: Bool){
        let worksheet = self.SetXLSX()
        let shiftyearandmonth = CommonMethod().JudgeYearAndMonth(worksheet.P1)
        
        let monthrange = CommonMethod().GetShiftCoursMonthRange(shiftyearandmonth.startcoursmonthyear, shiftstartmonth: shiftyearandmonth.startcoursmonth)
        
        var date = 11
        let staffcellposition = self.StaffCellPositionGet()     //スタッフの名前が記載されているセル場所 ex.)F8,F9
        var shiftdetailarray = List<ShiftDetailDB>()
        var shiftdetailrecordcount = DBmethod().DBRecordCount(ShiftDetailDB)
        let shiftdbrecordcount = DBmethod().DBRecordCount(ShiftDB)

        var flag = 0
        
        //30(31)日分繰り返すループ
        
        for i in 0 ..< monthrange.length {
            let shiftdb = ShiftDB()
            let shiftdetaildb = ShiftDetailDB()
            
            if update {
                let existshiftdb = DBmethod().SearchShiftDB(importname)
                let newshiftdetaildb = ShiftDetailDB()
                
                shiftdb.id = existshiftdb.id        //取り込みが上書きの場合は使われているidをそのまま使う
                shiftdb.year = 0
                shiftdb.month = 0
                
                newshiftdetaildb.id = existshiftdb.shiftdetail[i].id
                newshiftdetaildb.day = existshiftdb.shiftdetail[i].day

                switch(flag){
                case 0:         //11日〜月末までの場合
                    newshiftdetaildb.year = CommonMethod().JudgeYearAndMonth(worksheet.P1).startcoursmonthyear
                    newshiftdetaildb.month = CommonMethod().JudgeYearAndMonth(worksheet.P1).startcoursmonth
                    date += 1
                    
                    if date > monthrange.length {
                        date = 1
                        flag = 1
                    }
                    
                case 1:         //1日〜10日までの場合
                    newshiftdetaildb.year = CommonMethod().JudgeYearAndMonth(worksheet.P1).endcoursmonthyear
                    newshiftdetaildb.month = CommonMethod().JudgeYearAndMonth(worksheet.P1).endcoursmonth
                    date += 1
                    
                default:
                    break
                }

                newshiftdetaildb.staff = TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet.sheet)
                newshiftdetaildb.shiftDBrelationship = DBmethod().SearchShiftDB(importname)
                
                //エラーがない時のみ記録を行う
                if appDelegate.errorshiftnamexlsx.count == 0 {
                    DBmethod().AddandUpdate(newshiftdetaildb, update: true)
                }
                
            }else{
                shiftdb.id = shiftdbrecordcount
                    
                shiftdb.shiftimportname = importname
                shiftdb.shiftimportpath = importpath
                shiftdb.salaly = 0
                shiftdb.year = 0
                shiftdb.month = 0
                
                shiftdetaildb.id = shiftdetailrecordcount
                shiftdetailrecordcount += 1
                shiftdetaildb.day = date

                switch(flag){
                case 0:         //11日〜30(31)日までの場合
                    shiftdetaildb.year = CommonMethod().JudgeYearAndMonth(worksheet.P1).startcoursmonthyear
                    shiftdetaildb.month = CommonMethod().JudgeYearAndMonth(worksheet.P1).startcoursmonth
                    date += 1
                    
                    if date > monthrange.length {
                        date = 1
                        flag = 1
                    }
                    
                case 1:         //1日〜10日までの場合
                    shiftdetaildb.year = CommonMethod().JudgeYearAndMonth(worksheet.P1).endcoursmonthyear
                    shiftdetaildb.month = CommonMethod().JudgeYearAndMonth(worksheet.P1).endcoursmonth
                    date += 1
                    
                default:
                    break
                }

                shiftdetaildb.shiftDBrelationship = shiftdb
                shiftdetaildb.staff = TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet.sheet)
                
                //すでに記録してあるListを取得して後ろに現在の記録を追加する
                for i in 0 ..< shiftdetailarray.count{
                    shiftdb.shiftdetail.append(shiftdetailarray[i])
                }
                shiftdb.shiftdetail.append(shiftdetaildb)
                
                let ID = shiftdb.id
                
                //エラーがない場合のみ記録を行う
                if appDelegate.errorshiftnamexlsx.count == 0 {
                    DBmethod().AddandUpdate(shiftdb, update: true)
                    DBmethod().AddandUpdate(shiftdetaildb, update: true)
                    shiftdetailarray = CommonMethod().ShiftDBRelationArrayGet(ID)
                }
                
            }
        }
    }
    
    //表中にあるスタッフ名の場所を返す
    func StaffCellPositionGet() -> Array<String>{
        
        let worksheet = self.SetXLSX()
        var array:[String] = []
        
        while(true){
            let Fcell: String = worksheet.sheet.cellForCellReference(mark+String(number)).stringValue()
            if Fcell.isEmpty {       //セルが空なら進めるだけ
                number += 1
            }else{
                array.append(mark+String(number))
                number += 1
            }
            
            if DBmethod().StaffNumberGet() == array.count {       //設定したスタッフ人数と取り込み数が一致したら
                break
            }
        }
        return array
    }
    
    
    //入力したユーザ名の月給を計算して結果をDBへ記録する
    func UserMonthlySalaryRegist(importname: String){
        var usershift:[String] = []
        
        let username = DBmethod().UserNameGet()
        let staffcellposition = self.StaffCellPositionGet()
        
        let worksheet = self.SetXLSX()
        
        var userposition = ""
        
        let shiftyearandmonth = CommonMethod().JudgeYearAndMonth(worksheet.P1)
        let monthrange = CommonMethod().GetShiftCoursMonthRange(shiftyearandmonth.startcoursmonthyear, shiftstartmonth: shiftyearandmonth.startcoursmonth)

//        let shiftnsdate = MonthlySalaryShow().DateSerial(CommonMethod().Changecalendar(shiftyearandmonth.year, calender: "JP"), month: shiftyearandmonth.startcoursmonth, day: 1)
//        let c = NSCalendar.currentCalendar()
//        let monthrange = c.rangeOfUnit([NSCalendarUnit.Day],  inUnit: [NSCalendarUnit.Month], forDate: shiftnsdate)
        
        //F列からユーザ名と合致する箇所を探す
        for i in 0 ..< DBmethod().StaffNumberGet(){
            let nowcell: String = worksheet.sheet.cellForCellReference(staffcellposition[i]).stringValue()
            
            if nowcell == username {
                userposition = staffcellposition[i]
                break
            }
        }
        
        //1クール分行う
        for i in 0 ..< monthrange.length{
            let replaceday = userposition.stringByReplacingOccurrencesOfString("F", withString: cellrow[i])
            let dayshift: String = worksheet.sheet.cellForCellReference(replaceday).stringValue()
            
            
            //含まれていない場合は追加
            if self.SearchContainsHolidayArray(dayshift) == false {
                usershift.append(dayshift)
            }
        }
        
        //月給の計算をする

        var monthlysalary = 0.0
        let houlypayrecord = DBmethod().HourlyPayRecordGet()
        
        for i in 0 ..< usershift.count{
            
            let shiftsystem = DBmethod().SearchShiftSystem(usershift[i])
            if shiftsystem![0].endtime <= houlypayrecord[0].timeto {
                monthlysalary = monthlysalary + (shiftsystem![0].endtime - shiftsystem![0].starttime - 1) * Double(houlypayrecord[0].pay)
            }else{
                //22時以降の給与を先に計算
                let latertime = shiftsystem![0].endtime - houlypayrecord[0].timeto
                monthlysalary = monthlysalary + latertime * Double(houlypayrecord[1].pay)
                
                monthlysalary = monthlysalary + (shiftsystem![0].endtime - latertime - shiftsystem![0].starttime - 1) * Double(houlypayrecord[0].pay)
            }
        }
        
        //データベースへ記録上書き登録
        let newshiftdbsalalyadd = ShiftDB()                                 //月給を追加するための新規インスタンス
        let oldshiftdbsalalynone = DBmethod().SearchShiftDB(importname)     //月給がデフォルト値で登録されているShiftDBオブジェクト
        
        newshiftdbsalalyadd.id = oldshiftdbsalalynone.id
        
        for i in 0 ..< oldshiftdbsalalynone.shiftdetail.count{
            newshiftdbsalalyadd.shiftdetail.append(oldshiftdbsalalynone.shiftdetail[i])
        }
        
        newshiftdbsalalyadd.shiftimportname = oldshiftdbsalalynone.shiftimportname
        newshiftdbsalalyadd.shiftimportpath = oldshiftdbsalalynone.shiftimportpath
        newshiftdbsalalyadd.salaly = Int(monthlysalary)
        newshiftdbsalalyadd.year = CommonMethod().JudgeYearAndMonth(worksheet.P1).year
        newshiftdbsalalyadd.month = CommonMethod().JudgeYearAndMonth(worksheet.P1).endcoursmonth
        
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
        
        for i in 0 ..< DBmethod().StaffNumberGet(){
            let nowstaff = staffcellpositionarray[i]
            let replaceday = nowstaff.stringByReplacingOccurrencesOfString("F", withString: cellrow[day])
            
            let dayshift: String = worksheet.cellForCellReference(replaceday).stringValue()
            let staffname: String = worksheet.cellForCellReference(nowstaff).stringValue()
            
            //Holiday以外なら記録
            if self.SearchContainsHolidayArray(dayshift) == false {
                staffstring = staffstring + staffname + ":" + dayshift + ","
            }
            
            //新規シフト名だったらエラーとして記録
            if DBmethod().SearchShiftSystem(dayshift) == nil && self.SearchContainsHolidayArray(dayshift) == false {
                if dayshift != "" && appDelegate.errorshiftnamexlsx.contains(dayshift) == false {     //空白と既に配列にある場合は記録しないため
                    appDelegate.errorshiftnamexlsx.append(dayshift)
                }
            }else if DBmethod().SearchShiftSystem(dayshift) != nil && appDelegate.errorshiftnamexlsx.contains(dayshift) == true {
                appDelegate.errorshiftnamexlsx.removeObject(dayshift)
            }else if self.SearchContainsHolidayArray(dayshift) == true {
                appDelegate.errorshiftnamexlsx.removeObject(dayshift)
            }
        }
        
        return staffstring
    }
    
    
    //新規シフト名があるか調べるメソッド
    func CheckShift(){
        let worksheet = self.SetXLSX()
        let shiftyearandmonth = CommonMethod().JudgeYearAndMonth(worksheet.P1)
        let monthrange = CommonMethod().GetShiftCoursMonthRange(shiftyearandmonth.startcoursmonthyear, shiftstartmonth: shiftyearandmonth.startcoursmonth)

//        let shiftnsdate = MonthlySalaryShow().DateSerial(CommonMethod().Changecalendar(shiftyearandmonth.year, calender: "JP"), month: shiftyearandmonth.startcoursmonth, day: 1)
//        let c = NSCalendar.currentCalendar()
//        let monthrange = c.rangeOfUnit([NSCalendarUnit.Day],  inUnit: [NSCalendarUnit.Month], forDate: shiftnsdate)
        let staffcellposition = self.StaffCellPositionGet()     //スタッフの名前が記載されているセル場所 ex.)F8,F9

        for i in 0 ..< monthrange.length{
            self.TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet.sheet)
        }
    }
    
    //スタッフ名にシフト名が含まれていたらそのスタッフ名をデータベースへ記録する関数
    func CheckStaffName(){
        let staffpositionarray = self.StaffCellPositionGet()
        let worksheet = self.SetXLSX()
        
        for i in 0 ..< staffpositionarray.count{
            let staffname: String = worksheet.sheet.cellForCellReference(staffpositionarray[i]).stringValue()
            
            let array = CommonMethod().IncludeShiftNameInStaffName(staffname)
            
            if array.count != 0 {
                let record = StaffNameDB()
                record.id = DBmethod().DBRecordCount(StaffNameDB)
                record.name = staffname
                
                if DBmethod().StaffNameArrayGet() == nil {                                  //まだ1件も登録されていない場合
                    DBmethod().AddandUpdate(record, update: true)
                    
                }else if DBmethod().StaffNameArrayGet()?.contains(staffname) == false {     //登録が被らない場合
                    DBmethod().AddandUpdate(record, update: true)
                }
            }
        }
    }
    
    //シフト名を受け取って休暇に含まれているか返す関数
    func SearchContainsHolidayArray(shiftname: String) -> Bool{
        
        var holidayflag = false
        
        for i in 0 ..< holiday.count{
            if holiday[i] == shiftname {
                holidayflag = true
                break
            }else{
                holidayflag = false
            }
        }
        
        return holidayflag
    }
}

