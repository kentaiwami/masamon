//
//  ShiftImport.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/11/04.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftImport: Menu{

    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    @IBOutlet weak var Label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        Label.text = appDelegate.fileURL    //アプリを起動しながらファイルコピーした時に表示される
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func TEST(path: String){
        Label.text = path
    }
}
