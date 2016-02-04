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
    
    let TEST = "bbb"
    var flag = true
    
    var documentPath: String = ""
    var spreadsheet = BRAOfficeDocumentPackage()
    var worksheet = BRAWorksheet()
    var P1String: String = ""
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    //XLSXファイルのインスタンスをセットするメソッド
    func SetXLSX() -> (sheet: BRAWorksheet, P1:String){
        
        if(flag){
//            documentPath = NSBundle.mainBundle().pathForResource(TEST, ofType: "xlsx")!
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
        let shiftnsdate = MonthlySalaryShow().DateSerial(CommonMethod().Changecalendar(shiftyearandmonth.year, calender: "JP"), month: shiftyearandmonth.startcoursmonth, day: 1)
        let c = NSCalendar.currentCalendar()
        let monthrange = c.rangeOfUnit([NSCalendarUnit.Day],  inUnit: [NSCalendarUnit.Month], forDate: shiftnsdate)
        
        var date = 11
        let staffcellposition = self.StaffCellPositionGet()     //スタッフの名前が記載されているセル場所 ex.)F8,F9
        var shiftdetailarray = List<ShiftDetailDB>()
        var shiftdetailrecordcount = DBmethod().DBRecordCount(ShiftDetailDB)
        var flag = 0
        
        //30(31)日分繰り返すループ
        for(var i = 0; i < monthrange.length; i++){
            
//            let AAA = CGFloat(i) / CGFloat(monthrange.length)
//            print(String(round(AAA*100))+"%")

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
                
                if(CommonMethod().JudgeYearAndMonth(worksheet.P1).startcoursmonth == 12 && flag == 0){                     //開始月が12月の場合は昨年の12月で記録されるようにする
                    newshiftdetaildb.year = CommonMethod().JudgeYearAndMonth(worksheet.P1).year-1
                }else{
                    newshiftdetaildb.year = CommonMethod().JudgeYearAndMonth(worksheet.P1).year
                }

                switch(flag){
                case 0:         //11日〜30日までの場合
                    newshiftdetaildb.month = CommonMethod().JudgeYearAndMonth(worksheet.P1).startcoursmonth
                    date++
                    
                    if(date > monthrange.length){
                        date = 1
                        flag = 1
                    }
                    
                case 1:         //1日〜10日までの場合
                    newshiftdetaildb.month = CommonMethod().JudgeYearAndMonth(worksheet.P1).endcoursmonth
                    date++
                    
                default:
                    break
                }
//                appDelegate.errorshiftnamexlsx.removeAll()
                newshiftdetaildb.staff = TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet.sheet)
                newshiftdetaildb.shiftDBrelationship = DBmethod().SearchShiftDB(importname)
                
                //エラーがない時のみ記録を行う
                if(appDelegate.errorshiftnamexlsx.count == 0){
                    DBmethod().AddandUpdate(newshiftdetaildb, update: true)
                }
                
            }else{
                shiftdb.id = DBmethod().DBRecordCount(ShiftDetailDB)/monthrange.length     //新規の場合はレコードの数を割ったidを使う
                shiftdb.shiftimportname = importname
                shiftdb.shiftimportpath = importpath
                shiftdb.salaly = 0
                shiftdb.year = 0
                shiftdb.month = 0
                
                shiftdetaildb.id = shiftdetailrecordcount
                shiftdetailrecordcount++
                shiftdetaildb.day = date
                
                if(CommonMethod().JudgeYearAndMonth(worksheet.P1).startcoursmonth == 12 && flag == 0){                     //開始月が12月の場合は昨年の12月で記録されるようにする
                    shiftdetaildb.year = CommonMethod().JudgeYearAndMonth(worksheet.P1).year-1
                }else{
                    shiftdetaildb.year = CommonMethod().JudgeYearAndMonth(worksheet.P1).year
                }

                switch(flag){
                case 0:         //11日〜30(31)日までの場合
                    shiftdetaildb.month = CommonMethod().JudgeYearAndMonth(worksheet.P1).startcoursmonth
                    date++
                    
                    if(date > monthrange.length){
                        date = 1
                        flag = 1
                    }
                    
                case 1:         //1日〜10日までの場合
                    shiftdetaildb.month = CommonMethod().JudgeYearAndMonth(worksheet.P1).endcoursmonth
                    date++
                    
                default:
                    break
                }
//                appDelegate.errorshiftnamexlsx.removeAll()
                shiftdetaildb.shiftDBrelationship = shiftdb
                shiftdetaildb.staff = TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet.sheet)
                
                //すでに記録してあるListを取得して後ろに現在の記録を追加する
                for(var i = 0; i < shiftdetailarray.count; i++){
                    shiftdb.shiftdetail.append(shiftdetailarray[i])
                }
                shiftdb.shiftdetail.append(shiftdetaildb)
                
                let ID = shiftdb.id
                
                //エラーがない場合のみ記録を行う
                if(appDelegate.errorshiftnamexlsx.count == 0){
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
            if(Fcell.isEmpty){       //セルが空なら進めるだけ
                number++
            }else{
                array.append(mark+String(number))
                number++
            }
            
            if(DBmethod().StaffNumberGet() == array.count){       //設定したスタッフ人数と取り込み数が一致したら
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
        let shiftnsdate = MonthlySalaryShow().DateSerial(CommonMethod().Changecalendar(shiftyearandmonth.year, calender: "JP"), month: shiftyearandmonth.startcoursmonth, day: 1)
        let c = NSCalendar.currentCalendar()
        let monthrange = c.rangeOfUnit([NSCalendarUnit.Day],  inUnit: [NSCalendarUnit.Month], forDate: shiftnsdate)
        
        //F列からユーザ名と合致する箇所を探す
        for(var i = 0; i < DBmethod().StaffNumberGet(); i++){
            let nowcell: String = worksheet.sheet.cellForCellReference(staffcellposition[i]).stringValue()
            
            if(nowcell == username){
                userposition = staffcellposition[i]
                break
            }
        }
        
        //1クール分行う
        for(var i = 0; i < monthrange.length; i++){
            let replaceday = userposition.stringByReplacingOccurrencesOfString("F", withString: cellrow[i])
            let dayshift: String = worksheet.sheet.cellForCellReference(replaceday).stringValue()
            
            
            //含まれていない場合は追加
            if(self.SearchContainsHolidayArray(dayshift) == false){
                usershift.append(dayshift)
            }
        }
        
        //月給の計算をする
        //var shiftsystem = ShiftSystem()
        var monthlysalary = 0.0
        let houlypayrecord = DBmethod().HourlyPayRecordGet()
        
        for(var i = 0; i < usershift.count; i++){
            
            let shiftsystem = DBmethod().SearchShiftSystem(usershift[i])
            if(shiftsystem![0].endtime <= houlypayrecord[0].timeto){
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
        
        for(var i = 0; i < oldshiftdbsalalynone.shiftdetail.count; i++){
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
        
        for(var i = 0; i < DBmethod().StaffNumberGet(); i++){
            let nowstaff = staffcellpositionarray[i]
            let replaceday = nowstaff.stringByReplacingOccurrencesOfString("F", withString: cellrow[day])
            
            let dayshift: String = worksheet.cellForCellReference(replaceday).stringValue()
            let staffname: String = worksheet.cellForCellReference(nowstaff).stringValue()
            
            //Holiday以外なら記録
            if(self.SearchContainsHolidayArray(dayshift) == false){
                staffstring = staffstring + staffname + ":" + dayshift + ","
            }
            
            //新規シフト名だったらエラーとして記録
            if(DBmethod().SearchShiftSystem(dayshift) == nil && self.SearchContainsHolidayArray(dayshift) == false){
                if(dayshift != "" && appDelegate.errorshiftnamexlsx.contains(dayshift) == false){     //空白と既に配列にある場合は記録しないため
                    appDelegate.errorshiftnamexlsx.append(dayshift)
                }
            }else if(DBmethod().SearchShiftSystem(dayshift) != nil && appDelegate.errorshiftnamexlsx.contains(dayshift) == true){
                appDelegate.errorshiftnamexlsx.removeObject(dayshift)
            }else if(self.SearchContainsHolidayArray(dayshift) == true){
                appDelegate.errorshiftnamexlsx.removeObject(dayshift)
            }
        }
        
        return staffstring
    }
    
    
    //新規シフト名があるか調べるメソッド
    func CheckShift(){
        let worksheet = self.SetXLSX()
        let shiftyearandmonth = CommonMethod().JudgeYearAndMonth(worksheet.P1)
        let shiftnsdate = MonthlySalaryShow().DateSerial(CommonMethod().Changecalendar(shiftyearandmonth.year, calender: "JP"), month: shiftyearandmonth.startcoursmonth, day: 1)
        let c = NSCalendar.currentCalendar()
        let monthrange = c.rangeOfUnit([NSCalendarUnit.Day],  inUnit: [NSCalendarUnit.Month], forDate: shiftnsdate)
        let staffcellposition = self.StaffCellPositionGet()     //スタッフの名前が記載されているセル場所 ex.)F8,F9

        for(var i = 0; i < monthrange.length; i++){
            self.TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet.sheet)
        }
    }
    
    //スタッフ名にシフト名が含まれていたらそのスタッフ名をデータベースへ記録する関数
    func CheckStaffName(){
        let staffpositionarray = self.StaffCellPositionGet()
        let worksheet = self.SetXLSX()
        
        for(var i = 0; i < staffpositionarray.count; i++){
            let staffname: String = worksheet.sheet.cellForCellReference(staffpositionarray[i]).stringValue()
            
            let array = CommonMethod().IncludeShiftNameInStaffName(staffname)
            
            if(array.count != 0){
                let record = StaffNameDB()
                record.id = DBmethod().DBRecordCount(StaffNameDB)
                record.name = staffname
                
                if(DBmethod().StaffNameArrayGet() == nil){                                  //まだ1件も登録されていない場合
                    DBmethod().AddandUpdate(record, update: true)
                    
                }else if(DBmethod().StaffNameArrayGet()?.contains(staffname) == false){     //登録が被らない場合
                    DBmethod().AddandUpdate(record, update: true)
                }
            }
        }
    }
    
    //シフト名を受け取って休暇に含まれているか返す関数
    func SearchContainsHolidayArray(shiftname: String) -> Bool{
        
        var holidayflag = false
        
        for(var i = 0; i < holiday.count; i++){
            if(holiday[i] == shiftname){
                holidayflag = true
                break
            }else{
                holidayflag = false
            }
        }
        
        return holidayflag
    }
}

