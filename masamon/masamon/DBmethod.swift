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
    func ShiftDBNameGet(id: Int) ->String{
        var name = ""
        
        let realm = try!  Realm()
        name = realm.objects(ShiftDB).filter("id = %@", id)[0].shiftimportname
        
        return name
    }
    
    //レコードのIDを受け取って月給を返す
    func ShiftDBSaralyGet(id: Int) ->Int{
        var saraly = 0
        
        let realm = try! Realm()
        saraly = realm.objects(ShiftDB).filter("id = %@", id)[0].saraly!
        
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
    
    //インポート履歴のレコードを配列で返す
    func ShiftImportHistoryDBGet() -> Results<ShiftImportHistoryDB>{
        let realm = try! Realm()
        return realm.objects(ShiftImportHistoryDB)
    }
}
