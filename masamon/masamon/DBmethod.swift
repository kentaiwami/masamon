//
//  DBmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class DBmethod: UIViewController {

    //データベースへの追加
    func add(record: Object){
        do{
            let realm = try Realm()
            try realm.write{
                realm.add(record)
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
    
    //シフトDBの大きさを返す
    func ShiftDBSize() -> Int {
        var shiftdbcount = 0
        
        do{
            shiftdbcount = try (Realm().objects(ShiftDB).count)

        }catch{
            //Error
        }
        return shiftdbcount
    }
    
    //レコードのIDを受け取って名前を返す
    func ShiftDBNameGet(id: Int) ->String{
        var name = ""
        
        let realm = try!  Realm()
        name = realm.objects(ShiftDB).filter("id = %@", id)[0].name
        
        return name
    }
    
    //レコードのIDを受け取って月給を返す
    func ShiftDBSaralyGet(id: Int) ->Int{
        var saraly = 0
        
        let realm = try! Realm()
        saraly = realm.objects(ShiftDB).filter("id = %@", id)[0].saraly
        
        return saraly
    }
    
    //データベースのパスを表示
    func ShowDBpass(){
        do{
            print(try Realm().path)
        }catch{
            //Error
        }

    }
    //TODO: レコードを1件ずつ取得して配列に格納する
    //時給設定の情報を配列にして返す
    func HourlyPayRecordGet() -> [HourlyPay]{
        
        var array: [HourlyPay] = []
        
        return array
    }
}
