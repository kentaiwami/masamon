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
    dynamic var id = 0
    dynamic var name = ""       //ユーザが入力した名前を記録
    dynamic var imagepath = ""  //取り込んだイメージの保存パスを記録
    dynamic var saraly = 0      //取り込んだシフトの月給を記録
    
    override class func primaryKey() -> String {
        return "id"
    }
}

class ShiftDetailDB: Object {
    dynamic var id = 0
    dynamic var date = ""       //日付のみ記録
    dynamic var staff = ""      //例えば、Aさんが早番、Bさんが遅番、Cさんが公休、Dさんが早番の場合は"A1,B3,D1"となる予定
    dynamic var user = 0       //userのシフトを記録
}