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
    
    //指定したオブジェクトを削除する
    func DeleteRecord(object: Object) {
        
        do{
            let realm = try Realm()
            
            try realm.write {
                realm.delete(object)
            }
        }catch{
            //Error
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

    //ShiftDBのリレーションシップリストをUpdateする
    func ShiftDB_relationshipUpdate(importname: String, array: [ShiftDetailDB]){
        
        //配列で渡されるのでListへ変換する
        let list = List(array)
        
        do{
            let realm = try Realm()
            try realm.write{
                realm.create(ShiftDB.self, value: ["shiftimportname":importname, "shiftdetail":list], update: true)
            }
        }catch{
            //Error
            print(ErrorType)
        }
    }

    //レコードのIDを受け取って名前を返す
    func ShiftDBGet(id: Int) -> String{
        var shiftimportname = ""
        
        let realm = try! Realm()
        shiftimportname = realm.objects(ShiftDB).filter("id = %@",id)[0].shiftimportname
        return shiftimportname
    }
    
    //ShiftDBのリレーションシップ配列を返す
    func ShiftDBRelationArrayGet(id: Int) -> List<ShiftDetailDB>{
        var list = List<ShiftDetailDB>()
        let realm = try! Realm()
        
        list = realm.objects(ShiftDB).filter("id = %@", id)[0].shiftdetail
        
        return list
        
    }
    
    //レコードのIDを受け取って月給を返す
    func ShiftDBSaralyGet(id: Int) ->Int{
        var saraly = 0
        
        let realm = try! Realm()
        saraly = realm.objects(ShiftDB).filter("id = %@", id)[0].salaly
        
        return saraly
    }
    
    //id受け取ってレコードを返す
    func GetShiftDBRecordByID(id: Int) -> ShiftDB{
        let realm = try! Realm()
        let record = realm.objects(ShiftDB).filter("id = %@",id)[0]
        return record
    }
    
    //受け取った文字列をShiftDBから検索し、該当するレコードを返す
    func SearchShiftDB(importname: String) -> ShiftDB{
        var shiftdb = ShiftDB()
        
        let realm = try! Realm()
        shiftdb = realm.objects(ShiftDB).filter("shiftimportname = %@",importname)[0]
        
        return shiftdb
    }
    
    //ShiftDBのレコードを配列にして返す
    func GetShiftDBAllRecordArray() -> Results<ShiftDB>?{
        let realm = try! Realm()
        
        if DBmethod().DBRecordCount(ShiftDB) != 0 {
            return realm.objects(ShiftDB)
        }else{
            return nil
        }
    }
    
    //ShiftDBの虫食い状態を直す
    func ShiftDBFillHole(id: Int){
        do{
            let realm = try Realm()
            let count = DBmethod().DBRecordCount(ShiftDB)
            var copyrecordarray: [ShiftDB] = []
            
            //ユーザが削除したレコード以降のレコードの情報をコピーして削除する
            for i in id ..< count{
                let record = realm.objects(ShiftDB).filter("id = %@",i+1)[0]
                
                let copyrecord = ShiftDB()
                copyrecord.id = record.id
                copyrecord.year = record.year
                copyrecord.month = record.month
                copyrecord.shiftimportname = record.shiftimportname
                copyrecord.shiftimportpath = record.shiftimportpath
                copyrecord.salaly = record.salaly
                
                copyrecordarray.append(copyrecord)
                
                DBmethod().DeleteRecord(record)
            }
            
            //コピーしたレコードのidをずらしてデータベースへ追加する
            for i in 0..<copyrecordarray.count {
                copyrecordarray[i].id = id + i
                DBmethod().AddandUpdate(copyrecordarray[i], update: true)
            }
            
        }catch{
            //Error
        }
    }

    
    //ShiftDBのソートを行う
    func ShiftDBSort(){
        let realm = try! Realm()
        
        let sortedresults = realm.objects(ShiftDB).sorted("id")         //ソート後の結果を取得
        let nonsortedresults = realm.objects(ShiftDB)                   //ソート前の結果を取得
        
        var tmparray: [ShiftDB] = []
        
        //ソート後のレコード内容を作業用配列に入れる
        for i in 0 ..< sortedresults.count{
            let tmprecord = ShiftDB()
            tmprecord.id = sortedresults[i].id
            tmprecord.year = sortedresults[i].year
            tmprecord.month = sortedresults[i].month
            tmprecord.salaly = sortedresults[i].salaly
            tmprecord.shiftimportname = sortedresults[i].shiftimportname
            tmprecord.shiftimportpath = sortedresults[i].shiftimportpath
            
            tmparray.append(tmprecord)
        }
        
        //順序がおかしいレコードを全て削除した後に、ソート済みのレコードを書き込む
        do{
            try realm.write({ () -> Void in
                realm.delete(nonsortedresults)
                for i in 0 ..< tmparray.count{
                    realm.add(tmparray[i], update: true)
                }
            })
            
        }catch{
            //Error
        }
    }

    
    
    /****************HourlyPayDB関連メソッド*************/


    //時給設定の情報を配列にして返す
    func HourlyPayRecordGet() -> Results<HourlyPayDB>{
        let realm = try! Realm()
        return realm.objects(HourlyPayDB)
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
        
        if shiftsystem.count == 0 {
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
    func ShiftSystemRecordArrayGetByGroudid(groupid: Int) -> Results<ShiftSystemDB>{
        
        let realm = try! Realm()
        let name = realm.objects(ShiftSystemDB).filter("groupid = %@",groupid)

        return name
    }
    
    //受け取ったgroupidをShiftSystemから検索し、該当するShiftSystemの名前を配列で返す
    func ShiftSystemNameArrayGetByGroudid(groupid: Int) -> Array<String>{
        
        var name: [String] = []
        
        let realm = try! Realm()
        let results = realm.objects(ShiftSystemDB).filter("groupid = %@",groupid)
        
        for i in 0 ..< results.count{
            name.append(results[i].name)
        }
        
        return name

    }
    
    //シフト名を配列で返す関数
    func ShiftSystemNameArrayGet() -> Array<String>{
        var array: [String] = []
        let realm = try! Realm()
        
        for i in 0 ..< DBmethod().DBRecordCount(ShiftSystemDB){
            let name = realm.objects(ShiftSystemDB).filter("id = %@",i)[0].name
            array.append(name)
        }
        
        return array
    }
    
    func ShiftSystemAllRecordGet() -> Results<ShiftSystemDB>{
        let realm = try! Realm()
        
        return realm.objects(ShiftSystemDB)
    }
    
    //ShiftSystemDBの虫食い状態を直す関数
    func ShiftSystemDBFillHole(id: Int){
        do{
            let realm = try Realm()
            let count = DBmethod().DBRecordCount(ShiftSystemDB)
            var copyrecordarray: [ShiftSystemDB] = []
            
            //ユーザが削除したレコード以降のレコードの情報をコピーして削除する
            for i in id ..< count{
                let record = realm.objects(ShiftSystemDB).filter("id = %@",i+1)[0]
                
                let copyrecord = ShiftSystemDB()
                copyrecord.id = record.id
                copyrecord.name = record.name
                copyrecord.groupid = record.groupid
                copyrecord.starttime = record.starttime
                copyrecord.endtime = record.endtime
                
                copyrecordarray.append(copyrecord)
                
                DBmethod().DeleteRecord(record)
            }
            
            //コピーしたレコードのidをずらしてデータベースへ追加する
            for i in 0..<copyrecordarray.count {
                copyrecordarray[i].id = id + i
                DBmethod().AddandUpdate(copyrecordarray[i], update: true)
            }

        }catch{
            //Error
        }
    }

    
    //ShiftSystemDBのソートを行う
    func ShiftSystemDBSort(){
        let realm = try! Realm()
        
        let sortedresults = realm.objects(ShiftSystemDB).sorted("id")         //ソート後の結果を取得
        let nonsortedresults = realm.objects(ShiftSystemDB)                   //ソート前の結果を取得
        
        var tmparray: [ShiftSystemDB] = []
        
        //ソート後のレコード内容を作業用配列に入れる
        for i in 0 ..< sortedresults.count{
            let tmprecord = ShiftSystemDB()
            tmprecord.id = sortedresults[i].id
            tmprecord.name = sortedresults[i].name
            tmprecord.groupid = sortedresults[i].groupid
            tmprecord.starttime = sortedresults[i].starttime
            tmprecord.endtime = sortedresults[i].endtime
            
            tmparray.append(tmprecord)
        }
        
        
        //順序がおかしいレコードを全て削除した後に、ソート済みのレコードを書き込む
        do{
            try realm.write({ () -> Void in
                realm.delete(nonsortedresults)
                for i in 0 ..< tmparray.count{
                    realm.add(tmparray[i], update: true)
                }
            })
            
        }catch{
            //Error
        }
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
    
    //受け取った日付に該当するレコードを配列にして返す
    func GetShiftDetailDBRecordByDay(day: Int) -> Results<ShiftDetailDB> {
        let realm = try! Realm()
        let results = realm.objects(ShiftDetailDB).filter("day = %@",day)
        
        return results
    }
    
    //受け取ったidに対応するShiftDetailDBのレコードを返す
    func GetShiftDetailDBRecordByID(id: Int) -> ShiftDetailDB{
        let realm = try! Realm()
        let record = realm.objects(ShiftDetailDB).filter("id = %@",id)[0]
        
        return record
    }
    
    //ShiftDetailDBのリレーションシップをUpdateする
    func ShiftDetaiDB_relationshipUpdate(id: Int, record: ShiftDB){
        do{
            let realm = try Realm()
            try realm.write{
                realm.create(ShiftDetailDB.self, value: ["id":id, "shiftDBrelationship":record], update: true)
            }
        }catch{
            //Error
        }
    }

    
    //year,month,dateを受け取ってその日のレコードを返す
    func TheDayStaffGet(year: Int, month: Int, date: Int) -> Results<ShiftDetailDB>?{
        
        let realm = try! Realm()
        let stafflist = realm.objects(ShiftDetailDB).filter("year = %@ AND month = %@ AND day = %@",year,month,date)
        
        if stafflist.count == 0 {
            return nil
        }else{
            return stafflist
        }
    }
    
    
    //受け取ったリストに該当するレコードを削除する
    func DeleteShiftDetailDBRecords(objects: List<ShiftDetailDB>) {
        
        do{
            let realm = try Realm()
            
            try realm.write {
                realm.delete(objects)
            }
        }catch{
            //Error
        }
    }
    
    //ShiftDetailDBのソートを行う
    func ShiftDetailDBSort(){
        let realm = try! Realm()
        
        let sortedresults = realm.objects(ShiftDetailDB).sorted("id")         //ソート後の結果を取得
        let nonsortedresults = realm.objects(ShiftDetailDB)                   //ソート前の結果を取得
        
        var tmparray: [ShiftDetailDB] = []
        
        //ソート後のレコード内容を作業用配列に入れる
        for i in 0 ..< sortedresults.count{
            let tmprecord = ShiftDetailDB()
            tmprecord.id = sortedresults[i].id
            tmprecord.year = sortedresults[i].year
            tmprecord.month = sortedresults[i].month
            tmprecord.day = sortedresults[i].day
            tmprecord.staff = sortedresults[i].staff
            
            tmparray.append(tmprecord)
        }
        
        //順序がおかしいレコードを全て削除した後に、ソート済みのレコードを書き込む
        do{
            try realm.write({ () -> Void in
                realm.delete(nonsortedresults)
                for i in 0 ..< tmparray.count{
                    realm.add(tmparray[i], update: true)
                }
            })
            
        }catch{
            //Error
        }
    }
    
    //ShiftDetailDBの虫食い状態を直す
    func ShiftDetailDBFillHole(id: Int, deleterecords: Int){
        do{
            let realm = try Realm()
            let count = DBmethod().DBRecordCount(ShiftDetailDB)
            var copyrecordarray: [ShiftDetailDB] = []
            
            //ユーザが削除したレコード以降のレコードの情報をコピーして削除する
            for i in id ..< count{
                let record = realm.objects(ShiftDetailDB).filter("id = %@",i+deleterecords)[0]
                
                let copyrecord = ShiftDetailDB()

                copyrecord.id = record.id
                copyrecord.year = record.year
                copyrecord.month = record.month
                copyrecord.day = record.day
                copyrecord.staff = record.staff
                
                copyrecordarray.append(copyrecord)
                
                DBmethod().DeleteRecord(record)
            }
            
            //コピーしたレコードのidをずらしてデータベースへ追加する
            for i in 0..<copyrecordarray.count {
                copyrecordarray[i].id = id + i
                DBmethod().AddandUpdate(copyrecordarray[i], update: true)
            }
            
        }catch{
            //Error
        }
    }
    
    
    /****************StaffNameDB関連メソッド*************/
    
    //StaffNameDBに保存されているスタッフ名を配列で返す関数
    func StaffNameArrayGet() -> Array<String>?{
        var array: [String] = []
        let realm = try! Realm()
        
        if DBmethod().DBRecordCount(StaffNameDB) == 0 {
            return nil
        }else{
            for i in 0 ..< DBmethod().DBRecordCount(StaffNameDB){
                let name = realm.objects(StaffNameDB).filter("id = %@",i)[0].name
                array.append(name)
            }
            
            return array
        }
    }
    
    /**
     フラグによってマネージャーと店長のみか、マネージャー以外かのスタッフ名を配列で返す関数
     
     - parameter flag: 0はマネージャー以外、1はマネージャーと店長
     
     - returns: スタッフ名が格納された1次元配列
     */
    func ManagerStaffNameArrayGet(flag: Int) -> Array<String>?{
        var array: [String] = []
        let realm = try! Realm()
        
        if DBmethod().DBRecordCount(StaffNameDB) == 0 {
            return nil
        }else{
            for i in 0 ..< DBmethod().DBRecordCount(StaffNameDB){
                var flag_bool = false
                if flag == 0 {
                    flag_bool = false
                }else {
                    flag_bool = true
                }
                
                let name = realm.objects(StaffNameDB).filter("id = %@",i)[0].name
                
                if name.containsString("M") == flag_bool {
                    array.append(name)
                }
            }
            
            if flag == 1 {
                array.append("店長")
            }
            
            return array
        }
    }
    
    //StaffNameDBの全レコードを取得する
    func StaffNameAllRecordGet() -> Results<StaffNameDB>?{
        let realm = try! Realm()
        
        return realm.objects(StaffNameDB)
    }
    
    //StaffNameDBの虫食い状態を直す関数
    func StaffNameDBFillHole(id: Int){
        do{
            let realm = try Realm()
            let count = DBmethod().DBRecordCount(StaffNameDB)
            
            for i in id ..< count{
                //
                let nextrecord = realm.objects(StaffNameDB).filter("id = %@",i+1)[0]
                
                let newrecord = StaffNameDB()
                newrecord.id = nextrecord.id - 1
                newrecord.name = nextrecord.name
                
                DBmethod().AddandUpdate(newrecord, update: true)
            }
        }catch{
            //Error
        }
    }

    //StaffNameDBのソートを行う
    func StaffNameDBSort(){
        let realm = try! Realm()
        
        let sortedresults = realm.objects(StaffNameDB).sorted("id")         //ソート後の結果を取得
        let nonsortedresults = realm.objects(StaffNameDB)                   //ソート前の結果を取得
        
        var tmparray: [StaffNameDB] = []
        
        //ソート後のレコード内容を作業用配列に入れる
        for i in 0 ..< sortedresults.count{
            let tmprecord = StaffNameDB()
            tmprecord.id = sortedresults[i].id
            tmprecord.name = sortedresults[i].name
            tmparray.append(tmprecord)
        }
        
        //順序がおかしいレコードを全て削除した後に、ソート済みのレコードを書き込む
        do{
            try realm.write({ () -> Void in
                realm.delete(nonsortedresults)
                for i in 0 ..< tmparray.count{
                    realm.add(tmparray[i], update: true)
                }
            })
            
        }catch{
            //Error
        }
    }
}
