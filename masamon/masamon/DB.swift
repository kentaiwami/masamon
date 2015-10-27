//
//  ShiftDB.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import RealmSwift
import Foundation

class ShiftDB: Object {
    dynamic var ID = 0
    dynamic var Name = ""
    dynamic var ImagePath = ""
    dynamic var Saraly = 0
    let ShiftDetails = List<ShiftDetailDB>()
    
    override class func primaryKey() -> String {
        return "ShiftID"
    }
}

class ShiftDetailDB: Object {
    dynamic var ID = 0
    dynamic var date = ""       //日付のみ記録
    dynamic var staff = ""      //例えば、Aさんが早番、Bさんが遅番、Cさんが公休、Dさんが早番の場合は"A1,B3,D1"となる予定
    dynamic var user = ""       //userのシフトを記録
}