//
//  ShiftDB.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import RealmSwift
import Foundation

//月単位でのシフトを保存
class ShiftDB: Object {
    dynamic var id = 0
    dynamic var shiftimportname = ""       //ユーザが入力した名前を記録
    dynamic var shiftimportpath = ""  //取り込んだイメージの保存パスを記録
    var saraly: Int?      //取り込んだシフトの月給を記録
    let shiftdetail = List<ShiftDetailDB>()         //1日単位でのシフトとの関連付け
    override class func primaryKey() -> String {
        return "id"
    }
}

//1日単位でのシフトを保存
class ShiftDetailDB: Object {
    dynamic var id = 0
    dynamic var date = 0       //日付のみ記録
    dynamic var staff = ""      //例えば、Aさんが早番、Bさんが遅番、Cさんが公休、Dさんが早番の場合は"A1,B3,D1"となる予定
    dynamic var shiftDBrelationship: ShiftDB?   //月単位でのシフトとの関連付け
}

//時給の設定を保存
class HourlyPayDB: Object{
    dynamic var id = 0
    dynamic var timefrom = 0.0  //開始時間
    dynamic var timeto = 0.0    //終了時間
    dynamic var pay = 0         //時給を記録
    
    override class func primaryKey() -> String {
        return "id"
    }
}

//Inbox内にあるファイルの数を保存
class InboxFileCountDB: Object {
    dynamic var id = 0
    dynamic var counts = 0
    
    override class func primaryKey() -> String {
        return "id"
    }
}

//コピーしたファイルのパスを保存する
class FilePathTmpDB: Object{
    dynamic var id = 0
    dynamic var path: NSString = ""
    
    override class func primaryKey() -> String {
        return "id"
    }
}

//取り込んだシフトの履歴を保存する
class ShiftImportHistoryDB: Object {
    dynamic var id = 0
    dynamic var name = ""
    dynamic var date = ""
    
    override class func primaryKey() -> String {
        return "id"
    }
}

//シフト体制を保存
class ShiftSystem: Object{
    dynamic var id = 0
    dynamic var name = ""           //何番か記録
    dynamic var starttime = 0.0     //勤務開始時間
    dynamic var endtime = 0.0       //勤務終了時間
    
    override class func primaryKey() -> String {
        return "id"
    }
}