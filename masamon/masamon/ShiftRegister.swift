//
//  ShiftRegister.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/06.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftRegister: UIViewController {

    //
    func AAA(importname: String, importpath: String){
        let shiftdb = ShiftDB()
        let shitdetaildb = ShiftDetailDB()
        
        //shiftDBへidの追加
        if(DBmethod().DBRecordCount(ShiftDB) == 0){
            shiftdb.id = 0
        }else{
            shiftdb.id = DBmethod().DBRecordCount(ShiftDB)
        }
        
        shiftdb.shiftimportname = importname
        shiftdb.shiftimportpath = importpath
        
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        var formula: String = worksheet.cellForCellReference("F6").stringValue()

        
        print(formula)
        
        
        
    }

}
