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
        var abc = List<ShiftDetailDB>()
        
        for(var i = 0; i <= 30; i++){
            shiftdetaildb.id = i
            shiftdetaildb.date = date
            if(date < 30){
                date++
            }else{
                date = 1
            }
        }
        
        
        let formula: String = worksheet.cellForCellReference("F6").stringValue()

        
        print(formula)
        
        
        
    }
    
    //表中にあるスタッフ名の場所を返す
    func BBB() -> Array<String>{
        //let shiftdb = ShiftDB()
        //let shiftdetaildb = ShiftDetailDB()
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        
        let staffnumber = 27    //TODO: 仮に設定。あとで入力項目を設ける
        let mark = "F"
        var array:[String] = []
        var number = 6
        
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
