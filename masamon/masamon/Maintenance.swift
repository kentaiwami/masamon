//
//  Maintenance.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/08/22.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class Maintenance {
    
    func FileRemove() {
        //クラッシュ等で参照されずに残ってしまったファイルを手動で削除する(保守用)
        let documentspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let Inboxpath = documentspath + "/Inbox/"       //Inboxまでのパス
        let Libralypath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String + "/"
        let filepath = Libralypath  + "85.11〜.pdf"
        let ABC = Libralypath + "12.11〜1.pdf"
        let filemanager:FileManager = FileManager()
        do{
            try filemanager.removeItem(atPath: ABC)
//            try NSFileManager.defaultManager().moveItemAtURL(NSURL(fileURLWithPath: filepath), toURL: NSURL(fileURLWithPath: ABC))

        }catch{
            print(error)
        }
    }
    
    func DBAdd() {
        let AAA = HourlyPayDB()
        AAA.id = 0
        AAA.timefrom = 4.5
        AAA.timeto = 10.0
        AAA.pay = 100
        let AAA1 = HourlyPayDB()
        AAA1.id = 1
        AAA1.timefrom = 4.5
        AAA1.timeto = 10.0
        AAA1.pay = 200
        let AAA2 = UserNameDB()
        AAA2.id = 0
        AAA2.name = "Aさん"
        let AAA3 = StaffNumberDB()
        AAA3.id = 0
        AAA3.number = 22
        
        DBmethod().AddandUpdate(AAA, update: true)
        DBmethod().AddandUpdate(AAA1, update: true)
        DBmethod().AddandUpdate(AAA2, update: true)
        DBmethod().AddandUpdate(AAA3, update: true)
    }
    
    func DBUpdate() {
        let realm = try! Realm()
        try! realm.write {
            realm.create(ShiftDB.self, value: ["shiftimportname": "8.11〜.pdf", "salaly": 9000], update: true)
        }
    }
    
    func DBDelete() {
        let realm = try! Realm()
        let user = realm.objects(ShiftDB.self).last!
        try! realm.write {
            realm.delete(user)
        }
        for i in 92...122 {
            let record = DBmethod().GetShiftDetailDBRecordByID(i)
            DBmethod().DeleteRecord(record)
        }
        
    }
}
