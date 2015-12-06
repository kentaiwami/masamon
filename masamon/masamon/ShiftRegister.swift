//
//  ShiftRegister.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/06.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class ShiftRegister: UIViewController {
    
    //cellの列(日付が記載されている範囲)
    let cellrow = ["G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ"]
    let holiday = ["公","夏","有"]     //表に記載される休暇日
    let staffnumber = 27    //TODO: 仮に設定。あとで入力項目を設ける
    let mark = "F"
    var number = 6
    
    //
    func AAA(importname: String, importpath: String){
        let shiftdb = ShiftDB()
        let shiftdetaildb = ShiftDetailDB()
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        
        //shiftDBへidの追加
        if(DBmethod().DBRecordCount(ShiftDB) == 0){
            shiftdb.id = 0
        }else{
            shiftdb.id = DBmethod().DBRecordCount(ShiftDB)
        }
        
        shiftdb.shiftimportname = importname
        shiftdb.shiftimportpath = importpath
        //        shiftdb.shiftdetail =
        
        var date = 11
        //var abc = List<ShiftDetailDB>()
        
        let staffcellposition = self.StaffCellPositionGet()     //スタッフの名前が記載されているセル場所 ex.)F8,F9
        
        //30日分繰り返すループ
        for(var i = 0; i < 1; i++){
            
            shiftdetaildb.id = i
            shiftdetaildb.date = date
            
            //その日のシフトを全員分調べて出勤者だけ列挙する
            for(var j = 0; j < staffnumber; j++){
                
                let nowstaff = staffcellposition[j]
                let replaceday = nowstaff.stringByReplacingOccurrencesOfString("F", withString: cellrow[i])
                
//                print("nowstaff=>" + nowstaff)
//                print("replaceday=>" + replaceday)
                
                let formula: String = worksheet.cellForCellReference(replaceday).stringValue()
                
//                print(formula)
                if(holiday.contains(formula) == false){       //Holiday以外なら記録
                    print(formula)
                }
            }
            
            
            if(date < 30){
                date++
            }else{
                date = 1
            }
        }
        
        
        
    }
    
    //表中にあるスタッフ名の場所を返す
    func StaffCellPositionGet() -> Array<String>{
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        
        var array:[String] = []
        
        
        while(true){
            let Fcell: String = worksheet.cellForCellReference(mark+String(number)).stringValue()
            if(Fcell.isEmpty){       //セルが空なら進めるだけ
                number++
            }else{
                array.append(mark+String(number))
                number++
            }
            
            if(staffnumber == array.count){       //設定したスタッフ人数と取り込み数が一致したら
                break
            }
        }
        return array
    }
    
}
