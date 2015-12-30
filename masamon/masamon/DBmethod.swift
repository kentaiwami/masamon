//
//  DBmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import Foundation
import RealmSwift

class DBmethod: UIViewController {

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
    
    //データベースからのデータ取得をして表示
    func dataGet() {
        
        let realm = try! Realm()
        
        let dataContent = realm.objects(ShiftDB)
        print(dataContent)
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
    
    //データベースのパスを表示
    func ShowDBpass(){
        do{
            print(try Realm().path)
        }catch{
            print("ShowDBpassError")
        }

    }

    //時給設定の情報を配列にして返す
    func HourlyPayRecordGet() -> Results<HourlyPayDB>{
        let realm = try! Realm()
        return realm.objects(HourlyPayDB)
    }
    
    //Inbox内のファイル数を返す
    func InboxFileCountsGet() -> Int{
        var count = 0
        
        let realm = try! Realm()
        count = realm.objects(InboxFileCountDB).filter("id = %@", 0)[0].counts
        
        return count
    }
    
    //コピーしたファイルパスを保存(1件のみ)
    func FilePathTmpGet() -> NSString{
        var path: NSString = ""
        
        let realm = try! Realm()
        path = realm.objects(FilePathTmpDB).filter("id = %@", 0)[0].path
        return path
    }
    
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
    
    //登録したユーザ名を返す
    func UserNameGet() -> String{
        var name = ""
        
        let realm = try! Realm()
        name = realm.objects(UserName).filter("id = %@",0)[0].name
        
        return name
    }
    
    //受け取った文字列をShiftSystemから検索し、該当するレコードを返す
    func SearchShiftSystem(shift: String) -> Results<ShiftSystem>?{
        
        let realm = try! Realm()
        let shiftsystem = realm.objects(ShiftSystem).filter("name = %@",shift)
        
        if(shiftsystem.count == 0){
            return nil
        }else{
            return shiftsystem
        }
    }

    //受け取った文字列をShiftDBから検索し、該当するレコードを返す
    func SearchShiftDB(importname: String) -> ShiftDB{
        var shiftdb = ShiftDB()
        
        let realm = try! Realm()
        shiftdb = realm.objects(ShiftDB).filter("shiftimportname = %@",importname)[0]
        
        return shiftdb
    }
    
    //登録したスタッフ人数を返す
    func StaffNumberGet() -> Int{
        var number = 0
        
        let realm = try! Realm()
        number = realm.objects(StaffNumber).filter("id = %@",0)[0].number
        
        return number
    }
    
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
}
