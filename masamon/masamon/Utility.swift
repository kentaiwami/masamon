//
//  CommonMethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/22.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift
import KeychainAccess

class Utility: UIViewController {
    
    /**
     30分ごとの時間を返す
     
     - returns: 時間が格納されたArray
     */
    func GetTime() -> Array<String>{
        let time: [String] = ["1:00","1:30","2:00","2:30","3:00","3:30","4:00","4:30","5:00","5:30","6:00","6:30","7:00","7:30","8:00","8:30","9:00","9:30","10:00","10:30","11:00","11:30","12:00","12:30","13:00","13:30","14:00","14:30","15:00","15:30","16:00","16:30","17:00","17:30","18:00","18:30","19:00","19:30","20:00","20:30","21:00","21:30","22:00","22:30","23:00","23:30","24:00","24:30"]
        
        return time

    }
    
    /**
     シフトのグループ名を返す
     
     - returns: シフトのグループ名が格納されたArray
     */
    func GetShiftGroupName() -> Array<String>{
        let shiftgroupname: [String] = ["早番","中1","中2","中3","遅番","その他","休み"]
        
        return shiftgroupname
    }
    
    /**
     シフトのグループ名と時間を返す
     
     - returns: シフトのグループ名と時間が格納されたArray
     */
    func GetShiftGroupNameAndTime() -> Array<String>{
        let shiftgroupnameandtime: [String] = ["早番   8:00 〜 16:30","中1   12:00 〜 20:30","中2   13:30 〜 22:00","中3   14:30 〜 23:00","遅番   16:00 〜 24:30","その他","休み"]
        
        return shiftgroupnameandtime
    }


    /**
     西暦を和暦に、和暦を西暦に変換して返す
     
     - parameter year:     西暦or和暦
     - parameter calender: 変換処理を判断するための文字列
     
     - returns: 西暦or和暦
     */
    func Changecalendar(_ year: Int, calender: String) -> Int{
        if calender == "JP" {   //和暦から西暦
            let yeartemp = String(year - 12)
            return Int("20"+yeartemp)!
        }else{                  //西暦から和暦
            let yeartemp = String(year + 12)
            let lastcharacter = String(yeartemp[yeartemp.characters.index(before: yeartemp.endIndex)])                   //最後の桁
            let lastcharacterminus = String(yeartemp[yeartemp.index(yeartemp.endIndex, offsetBy: -2)])     //最後から1つ前の桁

            return Int(lastcharacterminus+lastcharacter)!
        }
    }
    
    
    /**
     平成xx年度〜が記述されている文字列を受け取って，シフトの開始・終了年月を判断する
     
     - parameter P1: 平成yy年度 mm月度 ****というテキスト
     
     - returns: year                シフトの年
                startcoursmonth     シフト開始月
                startcoursmonthyear シフト開始月の年
                endcoursmonth       シフト終了月
                endcoursmonthyear   シフト終了月の年

     */
    func JudgeYearAndMonth( _ P1: String) -> (year: Int, startcoursmonth: Int, startcoursmonthyear: Int, endcoursmonth: Int, endcoursmonthyear: Int){
        
        var P1String = P1

        //スペースがあった場合は削除
        P1String = P1String.replacingOccurrences(of: " ", with: "")
        P1String = P1String.replacingOccurrences(of: "　", with: "")
        
        //平成何年かを取得
        let P1NSString = P1String as NSString
        let year_position = P1NSString.range(of: "年度").location
        let year_first_digit = String(P1String[P1String.characters.index(P1String.startIndex, offsetBy: year_position-1)])
        let year_second_digit = String(P1String[P1String.characters.index(P1String.startIndex, offsetBy: year_position-2)])
        let year = year_second_digit + year_first_digit
        
        //"月度"が出る場所を記録
        let positionmonth = P1NSString.range(of: "月度").location
        
        //月の文字取得(1の位)
        let monthfirstdigit = String(P1String[P1String.characters.index(P1String.startIndex, offsetBy: positionmonth-1)])
        
        //月の文字取得(10の位)
        let monthseconddigit = String(P1String[P1String.characters.index(P1String.startIndex, offsetBy: positionmonth-2)])
        

        //年度の月が4月度〜9月度ならば年度の操作をせずに返す
        if monthfirstdigit >= "4" && monthfirstdigit <= "9" {
            return (Int(year)!, Int(monthfirstdigit)!-1, Int(year)!, Int(monthfirstdigit)!, Int(year)!)
        }
            
        //年度の月が10月度ならば月を操作して返す
        else if monthfirstdigit == "0" {
            return (Int(year)!, 9, Int(year)!, 10, Int(year)!)
        }

            
        //年度の月が11月度,12月度ならば年度の操作をせずに返す
        else if (monthfirstdigit >= "1" && monthfirstdigit <= "2") && monthseconddigit == "1" {
            return (Int(year)!, Int(monthseconddigit+monthfirstdigit)!-1, Int(year)!, Int(monthseconddigit+monthfirstdigit)!, Int(year)!)
        }
        
        //年度の月が1月度ならば開始月がその年,終了月は来年にして返す
        else if monthfirstdigit == "1" {
            return (Int(year)!, 12, Int(year)!, Int(monthfirstdigit)!, Int(year)!+1)
        }
        
        //年度の月が2月度〜3月度ならば、来年にして返す
        else if monthfirstdigit >= "2" && monthfirstdigit <= "3" {
            return (Int(year)!, Int(monthfirstdigit)!-1, Int(year)!+1, Int(monthfirstdigit)!, Int(year)!+1)
        }
        
        else{
            return (0,0,0,0,0)
        }
    }
    

    /**
     スタッフ名に含まれているシフト体制を検索して結果を返す
     
     - parameter staffname: スタッフ名
     
     - returns: シフトのグループidを格納したArray
     */
    func IncludeShiftNameInStaffName( _ staffname: String) -> Array<Int>{
        
        let shiftarray = DBmethod().ShiftSystemAllRecordGet()
        let holiday = DBmethod().ShiftSystemRecordArrayGetByGroudid(6)
        
        var groupidarray: [Int] = []
        
        var staffnamestring = staffname
        
        //出勤シフトを見つけるループ処理
        for i in 0 ..< shiftarray.count{
            
            if staffnamestring.characters.count == 0 {
                return groupidarray
                
            }else if staffnamestring.contains(shiftarray[i].name) {
                staffnamestring = staffnamestring.replacingOccurrences(of: shiftarray[i].name, with: "")
                groupidarray.append(shiftarray[i].groupid)
            }
        }
        
        //休暇シフトを見つけるループ処理
        for i in 0 ..< holiday.count{
            
            if staffnamestring.characters.count == 0 {
                return groupidarray
                
            }else if staffnamestring.contains(holiday[i].name) {
                staffnamestring = staffnamestring.replacingOccurrences(of: holiday[i].name, with: "")
                groupidarray.append(6)
            }
        }
        
        return groupidarray
    }
    

    /**
     受け取ったテキストからShiftSystemDBのレコードを生成して返す関数
     
     - parameter id:                id
     - parameter shiftname:         シフト体制名
     - parameter shiftgroup:        シフトグループ
     
     - returns: 生成したShiftSystemDBレコード
     */
    func CreateShiftSystemDBRecord(_ id: Int, shiftname: String, shiftgroup: String) -> ShiftSystemDB{
        let record = ShiftSystemDB()
        var gid = 0
        var start = 0.0
        var end = 0.0
        
        switch(shiftgroup){
        case "早番":
            gid = 0
            start = 8.0
            end = 16.5
            
        case "中1":
            gid = 1
            start = 12.0
            end = 20.5
            
        case "中2":
            gid = 2
            start = 13.5
            end = 22.0
            
        case "中3":
            gid = 3
            start = 14.5
            end = 23.0
            
        case "遅番":
            gid = 4
            start = 16.0
            end = 24.5
            
        case "その他":
            gid = 5
            start = 0.0
            end = 0.0
            
        case "休み":
            gid = 6
            start = 0.0
            end = 0.0
            
        default:
            break
        }
        
        record.id = id
        record.name = shiftname
        record.groupid = gid
        record.starttime = start
        record.endtime = end
        
        return record
    }
    

    /**
     1クールのシフト範囲を返す
     
     - parameter shiftstartyear:  シフトの開始年
     - parameter shiftstartmonth: シフトの開始月
     
     - returns: シフト範囲
     */
    func GetShiftCoursMonthRange(_ shiftstartyear: Int, shiftstartmonth: Int) -> NSRange{
        let shiftnsdate = self.CreateNSDate(Utility().Changecalendar(shiftstartyear, calender: "JP"), month: shiftstartmonth, day: 1)
        let c = Calendar.current
        let monthrange = (c as NSCalendar).range(of: [NSCalendar.Unit.day],  in: [NSCalendar.Unit.month], for: shiftnsdate)
        
        return monthrange
    }
    

    /**
     年,月,日からNSDateを生成する
     
     - parameter year:  年
     - parameter month: 月
     - parameter day:   日
     
     - returns: 生成したNSDate
     */
    func CreateNSDate(_ year : Int, month : Int, day : Int) -> Date {
        var comp = DateComponents()
        comp.year = year
        comp.month = month
        comp.day = day
        let cal = Calendar.current
        let date = cal.date(from: comp)
        
        return date!
    }


    /**
     受け取ったNSDateを年(西暦),月,日,曜日に分けて返す
     
     - parameter date: NSdate型のデータ
     
     - returns: 年,月,日,曜日
     */
    func ReturnYearMonthDayWeekday(_ date : Date) -> (year: Int, month: Int, day: Int, weekday: Int) {
        let calendar = Calendar.current
        let comp : DateComponents = (calendar as NSCalendar).components(
            [.year,.month,.day,.weekday], from: date)
        return (comp.year!,comp.month!,comp.day!,comp.weekday!)
    }
    
    func GenerateKey() -> Data {
        let uuid = NSUUID().uuidString.components(separatedBy: "-").joined()
        let key = uuid + uuid
        
        return key.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
    
    func GetKey() -> Data {
        let keychain = Keychain()
        let key = try! keychain.getData("db_key")
        return key!
    }
    
    func GetStandardAlert(title: String, message: String, b_title: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: b_title, style:UIAlertActionStyle.default)
        
        alertController.addAction(ok)
        
        return alertController
    }

}

class Indicator {
    let indicator = UIActivityIndicatorView()
    
    func showIndicator(view: UIView) {
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = view.center
        indicator.color = UIColor.gray
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        view.bringSubview(toFront: indicator)
        indicator.startAnimating()
    }
    
    func stopIndicator() {
        self.indicator.stopAnimating()
    }
}

