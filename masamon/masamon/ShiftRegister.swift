//
//  ShiftRegister.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/05.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftRegister: UIViewController {
    
    func BBB(Libralypath: String) -> String {
        let AAA = Libralypath+"/"+DBmethod().FilePathTmpGet().lastPathComponent
        print("filepath=>" + AAA)
        
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(AAA)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        let BBB: String = worksheet.cellForCellReference("A1").stringValue()
        
        return BBB
    }
}
