//
//  DBmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class DBmethod: UIViewController {

    
    /****************データベース全般メソッド*************/
     
    //データベースへの追加(ID重複の場合は上書き)
    func AddandUpdate(record: Object, update: Bool){
        do{
            let realm = try Realm()
            try realm.write{
                realm.add(record, update: update)
            }
        }catch{
            //Error
        }
    }
    
//    //データベースからのデータ取得をして表示
//    func dataGet() {
//        
//        let realm = try! Realm()
//        
//        let dataContent = realm.objects(ShiftDB)
//        print(dataContent)
//    }
    
    //データベースのパスを表示
    func ShowDBpass(){
        do{
            print(try Realm().path)
        }catch{
            print("ShowDBpassError")
        }
        
    }
    
    //指定したDBのレコード数を返す
    func DBRecordCount(DBName: Object.Type) -> Int {
        var dbrecordcount = 0
        
        do{
            dbrecordcount = try (Realm().objects(DBName).count)

        }catch{
            //Error
        }
        return dbrecordcount
    }
    
    /****************ShiftDB関連メソッド*************/

     //TODO: ここでエラーが出る
    //レコードのIDを受け取って名前を返す
    func ShiftDBGet(id: Int) -> String{
        var shiftimportname = ""
        
        let realm = try! Realm()
        shiftimportname = realm.objects(ShiftDB).filter("id = %@",id)[0].shiftimportname
        return shiftimportname
    }
    
    
    //レコードのIDを受け取って月給を返す
    func ShiftDBSaralyGet(id: Int) ->Int{
        var saraly = 0
        
        let realm = try! Realm()
        saraly = realm.objects(ShiftDB).filter("id = %@", id)[0].salaly
        
        return saraly
    }
    
    //受け取った文字列をShiftDBから検索し、該当するレコードを返す
    func SearchShiftDB(importname: String) -> ShiftDB{
        var shiftdb = ShiftDB()
        
        let realm = try! Realm()
        shiftdb = realm.objects(ShiftDB).filter("shiftimportname = %@",importname)[0]
        
        return shiftdb
    }
    
    
    /****************HourlyPayDB関連メソッド*************/


    //時給設定の情報を配列にして返す
    func HourlyPayRecordGet() -> Results<HourlyPayDB>{
        let realm = try! Realm()
        return realm.objects(HourlyPayDB)
    }

    
    
    
    
    
    /****************HolidayDB関連メソッド*************/

    //休暇を示すシフト体制の文字を配列にして返す
    func HolidayNameArrayGet() -> Array<String>{
        var array: [String] = []
        
        let realm = try! Realm()
        
        for(var i = 0; i < DBmethod().DBRecordCount(HolidayDB); i++){
            let name = realm.objects(HolidayDB).filter("id = %@",i)[0].name
            array.append(name)
        }
        
        return array
    }
    
    //休暇を示すシフト体制のレコードを配列で返す関数
    func HolidayAllRecordGet() -> Results<HolidayDB>{
        let realm = try! Realm()
        
        return realm.objects(HolidayDB)
    }
    
    
    
    /****************InboxFileCountDB関連メソッド*************/

    //Inbox内のファイル数を返す
    func InboxFileCountsGet() -> Int{
        var count = 0
        
        let realm = try! Realm()
        count = realm.objects(InboxFileCountDB).filter("id = %@", 0)[0].counts
        
        return count
    }
    
    
    /****************FilePathTmpDB関連メソッド*************/

    //コピーしたファイルパスを保存(1件のみ)
    func FilePathTmpGet() -> NSString{
        var path: NSString = ""
        
        let realm = try! Realm()
        path = realm.objects(FilePathTmpDB).filter("id = %@", 0)[0].path
        return path
    }
    
    
    /****************ShiftImportHistoryDB関連メソッド*************/

    //インポート履歴の最後を返す(最新の取り込み)
    func ShiftImportHistoryDBLastGet() -> ShiftImportHistoryDB{
        var shiftimporthistorylast = ShiftImportHistoryDB()
        
        let realm = try! Realm()
        shiftimporthistorylast = (realm.objects(ShiftImportHistoryDB).last)!
        
        return shiftimporthistorylast
    }
    
    
    //インポート履歴を配列で返す
    func ShiftImportHistoryDBGet() -> Results<ShiftImportHistoryDB>{
        let realm = try! Realm()
        return realm.objects(ShiftImportHistoryDB)
    }
    
    
    
    /****************UserNameDB関連メソッド*************/

    //登録したユーザ名を返す
    func UserNameGet() -> String{
        var name = ""
        
        let realm = try! Realm()
        name = realm.objects(UserNameDB).filter("id = %@",0)[0].name
        
        return name
    }
    
    
    
    /****************ShiftSystemDB関連メソッド*************/

    //受け取った文字列をShiftSystemから検索し、該当するレコードを返す
    func SearchShiftSystem(shift: String) -> Results<ShiftSystemDB>?{
        
        let realm = try! Realm()
        let shiftsystem = realm.objects(ShiftSystemDB).filter("name = %@",shift)
        
        if(shiftsystem.count == 0){
            return nil
        }else{
            return shiftsystem
        }
    }
    
    //受け取ったIDをShiftSystemから検索し、該当するShiftSystemのレコードを返す
    func ShiftSystemNameGet(id: Int) -> ShiftSystemDB{
        
        let realm = try! Realm()
        let record = realm.objects(ShiftSystemDB).filter("id = %@",id)[0]
        
        return record
    }
    
    //受け取ったgroupidをShiftSystemから検索し、該当するShiftSystemのレコードを配列で返す
    func ShiftSystemNameArrayGetByGroudid(groupid: Int) -> Results<ShiftSystemDB>{
        
        let realm = try! Realm()
        let name = realm.objects(ShiftSystemDB).filter("groupid = %@",groupid)

        return name
    }
    
    //シフト名を配列で返す関数
    func ShiftSystemNameArrayGet() -> Array<String>{
        var array: [String] = []
        let realm = try! Realm()
        
        for(var i = 0; i < DBmethod().DBRecordCount(ShiftSystemDB); i++){
            let name = realm.objects(ShiftSystemDB).filter("id = %@",i)[0].name
            array.append(name)
        }
        
        return array
    }
    
    func ShiftSystemAllRecordGet() -> Results<ShiftSystemDB>{
        let realm = try! Realm()
        
        return realm.objects(ShiftSystemDB)
    }
    

    
    /****************StaffNumberDB関連メソッド*************/
    
    //登録したスタッフ人数を返す
    func StaffNumberGet() -> Int{
        var number = 0
        
        let realm = try! Realm()
        number = realm.objects(StaffNumberDB).filter("id = %@",0)[0].number
        
        return number
    }
    
    
    /****************ShiftDetailDB関連メソッド*************/
    
    //year,month,dateを受け取ってその日のレコードを返す
    func TheDayStaffGet(year: Int, month: Int, date: Int) -> Results<ShiftDetailDB>?{
        
        let realm = try! Realm()
        let stafflist = realm.objects(ShiftDetailDB).filter("year = %@ AND month = %@ AND day = %@",year,month,date)
        
        if(stafflist.count == 0){
            return nil
        }else{
            return stafflist
        }
    }
    
    
    
    /****************StaffNameDB関連メソッド*************/
    
    //StaffNameDBに保存されているスタッフ名を配列で返す関数
    func StaffNameArrayGet() -> Array<String>?{
        var array: [String] = []
        let realm = try! Realm()
        
        if(DBmethod().DBRecordCount(StaffNameDB) == 0){
            return nil
        }else{
            for(var i = 0; i < DBmethod().DBRecordCount(StaffNameDB); i++){
                let name = realm.objects(StaffNameDB).filter("id = %@",i)[0].name
                array.append(name)
            }
            
            return array
        }
    }

}
