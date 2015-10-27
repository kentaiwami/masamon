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

    func testadd(record: Object){
        do{
            let realm = try Realm()
            try realm.write{
                realm.add(record)
            }
        }catch{
            //Error
        }
    }
}
