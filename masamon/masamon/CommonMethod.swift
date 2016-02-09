//
//  CommonMethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/22.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class CommonMethod: UIViewController {

    func GetTimeNotSpecifiedVer() -> Array<String>{
        let time: [String] = ["指定なし","1:00","1:30","2:00","2:30","3:00","3:30","4:00","4:30","5:00","5:30","6:00","6:30","7:00","7:30","8:00","8:30","9:00","9:30","10:00","10:30","11:00","11:30","12:00","12:30","13:00","13:30","14:00","14:30","15:00","15:30","16:00","16:30","17:00","17:30","18:00","18:30","19:00","19:30","20:00","20:30","21:00","21:30","22:00","22:30","23:00","23:30","24:00","24:30"]

        return time
    }
    
    func GetTime() -> Array<String>{
        let time: [String] = ["1:00","1:30","2:00","2:30","3:00","3:30","4:00","4:30","5:00","5:30","6:00","6:30","7:00","7:30","8:00","8:30","9:00","9:30","10:00","10:30","11:00","11:30","12:00","12:30","13:00","13:30","14:00","14:30","15:00","15:30","16:00","16:30","17:00","17:30","18:00","18:30","19:00","19:30","20:00","20:30","21:00","21:30","22:00","22:30","23:00","23:30","24:00","24:30"]
        
        return time

    }
    
    func GetShiftGroupName() -> Array<String>{
        let shiftgroupname: [String] = ["早番","中1","中2","中3","遅番","その他","休み"]
        
        return shiftgroupname
    }
    
    func GetShiftGroupNameAndTime() -> Array<String>{
        let shiftgroupnameandtime: [String] = ["早番   8:00 〜 16:30","中1   12:00 〜 20:30","中2   13:30 〜 22:00","中3   14:30 〜 23:00","遅番   16:00 〜 24:30","その他","休み"]
        
        return shiftgroupnameandtime
    }

    //西暦を和暦に、和暦を西暦に変換して返す関数
    func Changecalendar(year: Int, calender: String) -> Int{
        if(calender == "JP"){   //和暦から西暦
            let yeartemp = String(year - 12)
            return Int("20"+yeartemp)!
        }else{                  //西暦から和暦
            let yeartemp = String(year + 12)
            let lastcharacter = String(yeartemp[yeartemp.endIndex.predecessor()])                   //最後の桁
            let lastcharacterminus = String(yeartemp[yeartemp.endIndex.predecessor().predecessor()])     //最後から1つ前の桁
            return Int(lastcharacterminus+lastcharacter)!
        }
    }
    
    //ShiftDBのリレーションシップ配列を返す
    func ShiftDBRelationArrayGet(id: Int) -> List<ShiftDetailDB>{
        var list = List<ShiftDetailDB>()
        let realm = try! Realm()
        
        list = realm.objects(ShiftDB).filter("id = %@", id)[0].shiftdetail
        
        return list
        
    }
    
    /*
    引き数： 平成yy年度 mm月度 ****というテキスト
    返り値：
    year                    => そのシフトの年
    startcoursmonth         =>シフト開始月
    startcoursmonthyear     =>シフト開始月の年
    endcoursmonth           =>シフト終了月
    endcoursmonthyear       =>シフト終了月の年
    */
    func JudgeYearAndMonth(var P1: String) -> (year: Int, startcoursmonth: Int, startcoursmonthyear: Int, endcoursmonth: Int, endcoursmonthyear: Int){
        
        //スペースがあった場合は削除
        P1 = P1.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        //平成何年かを取得
        let P1NSString = P1 as NSString
        let year = P1NSString.substringWithRange(NSRange(location: 2, length: 2))
        
        //"月度"が出る場所を記録
        let positionmonth = P1NSString.rangeOfString("月度").location
        
        //月の文字取得(1の位)
        let monthsecondcharacter = String(P1[P1.startIndex.advancedBy(positionmonth-1)])
        
        //月の文字取得(10の位)
        let monthfirstcharacter = String(P1[P1.startIndex.advancedBy(positionmonth-2)])
        

        //年度の月が5月度〜10月度ならば年度の操作をせずに返す
        if(monthsecondcharacter >= "5" && monthsecondcharacter <= "9"){
            return (Int(year)!, Int(monthsecondcharacter)!-1, Int(year)!, Int(monthsecondcharacter)!, Int(year)!)
            
        }
            
        //年度の月が10月度ならば月を操作して返す
        else if(monthsecondcharacter == "0"){
            return (Int(year)!, 9, Int(year)!, 10, Int(year)!)
        }

            
        //年度の月が11月度,12月度ならば年度の操作をせずに返す
        else if((monthsecondcharacter >= "1" && monthsecondcharacter <= "2") && monthfirstcharacter == "1"){
            return (Int(year)!, Int(monthfirstcharacter+monthsecondcharacter)!-1, Int(year)!, Int(monthfirstcharacter+monthsecondcharacter)!, Int(year)!)
        }
        
        //年度の月が1月度ならば開始月がその年,終了月は来年にして返す
        else if(monthsecondcharacter == "1"){
            return (Int(year)!, 12, Int(year)!, Int(monthsecondcharacter)!, Int(year)!+1)
        }
        
        //年度の月が2月度〜4月度ならば、来年にして返す
        else if(monthsecondcharacter >= "2" && monthsecondcharacter <= "4"){
            return (Int(year)!, Int(monthsecondcharacter)!-1, Int(year)!+1, Int(monthsecondcharacter)!, Int(year)!+1)
        }
        
        else{
            return (0,0,0,0,0)
        }
    }
    
    //スタッフ名に含まれているシフト体制を検索して結果を返す関数
    func IncludeShiftNameInStaffName(var staffname: String) -> Array<Int>{
        
        let shiftarray = DBmethod().ShiftSystemAllRecordGet()
        let holiday = DBmethod().ShiftSystemRecordArrayGetByGroudid(6)
        
        var groupidarray: [Int] = []
        
        //出勤シフトを見つけるループ処理
        for(var i = 0; i < shiftarray.count; i++){
            
            if(staffname.characters.count == 0){
                return groupidarray
                
            }else if(staffname.containsString(shiftarray[i].name)){
                staffname = staffname.stringByReplacingOccurrencesOfString(shiftarray[i].name, withString: "")
                groupidarray.append(shiftarray[i].groupid)
            }
        }
        
        //休暇シフトを見つけるループ処理
        for(var i = 0; i < holiday.count; i++){
            
            if(staffname.characters.count == 0){
                return groupidarray
                
            }else if(staffname.containsString(holiday[i].name)){
                staffname = staffname.stringByReplacingOccurrencesOfString(holiday[i].name, withString: "")
                groupidarray.append(6)
            }
        }
        
        return groupidarray
    }
    
    //受け取ったテキストからShiftSystemDBのレコードを生成して返す関数
    func CreateShiftSystemDBRecord(id: Int, shiftname: String, shiftgroup: String, shifttime: String, shiftstarttimerow: Int, shiftendtimerow: Int) -> ShiftSystemDB{
        let record = ShiftSystemDB()
        var gid = 0
        var start = 0.0
        var end = 0.0
        
        switch(shiftgroup){
        case "早番":
            gid = 0
            
        case "中1":
            gid = 1
            
        case "中2":
            gid = 2
            
        case "中3":
            gid = 3
            
        case "遅番":
            gid = 4
            
        case "その他":
            gid = 5
            
        case "休み":
            gid = 6
            
        default:
            break
        }
        
        //シフト時間に指定なしが含まれていた場合
        if(shifttime.containsString("指定なし")){
            start = 0.0
            end = 0.0
        }else{
            start = Double(shiftstarttimerow) - (Double(shiftstarttimerow) * 0.5) + 0.5
            end = Double(shiftendtimerow) - (Double(shiftendtimerow) * 0.5) + 0.5
        }
        
        record.id = id
        record.name = shiftname
        record.groupid = gid
        record.starttime = start
        record.endtime = end
        
        return record
    }
    
    //1クールのシフト範囲を返す関数
    func GetShiftCoursMonthRange(shiftstartyear: Int, shiftstartmonth: Int) -> NSRange{
        let shiftnsdate = MonthlySalaryShow().DateSerial(CommonMethod().Changecalendar(shiftstartyear, calender: "JP"), month: shiftstartmonth, day: 1)
        let c = NSCalendar.currentCalendar()
        let monthrange = c.rangeOfUnit([NSCalendarUnit.Day],  inUnit: [NSCalendarUnit.Month], forDate: shiftnsdate)
        
        return monthrange
    }

}
