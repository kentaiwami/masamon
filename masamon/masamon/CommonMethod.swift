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
    
    //返り値は
    //年(和暦)、11日〜月末までの月、1日〜10日までの月
    func JudgeYearAndMonth(var P1: String) -> (year: Int, startcoursmonth: Int, endcoursmonth: Int){
        
        P1 = P1.stringByReplacingOccurrencesOfString(" ", withString: "")                   //スペースがあった場合は削除
        
        let P1NSString = P1 as NSString
        let year = P1NSString.substringWithRange(NSRange(location: 2, length: 2))                                 //平成何年かを取得
        
        let positionmonth = P1NSString.rangeOfString("月度").location                                             //"月度"が出る場所を記録
        
        let monthsecondcharacter = String(P1[P1.startIndex.advancedBy(positionmonth-1)])             //月の最初の文字
        let monthfirstcharacter = String(P1[P1.startIndex.advancedBy(positionmonth-2)])
        
        if(monthsecondcharacter >= "3" && monthsecondcharacter <= "9"){                     //3月度〜9月度ならば
            return (Int(year)!,Int(monthsecondcharacter)!-1,Int(monthsecondcharacter)!)
        }else{                                                                              //0,1,2が1の位に来ている場合
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
    
    //スタッフ名に含まれているシフト体制を検索して結果を返す関数
    func IncludeShiftNameInStaffName(var staffname: String) -> Array<Int>{
        
        let shiftarray = DBmethod().ShiftSystemAllRecordGet()
        let holiday = DBmethod().HolidayAllRecordGet()
        
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
                groupidarray.append(999)
            }
        }
        
        return groupidarray
    }
}
