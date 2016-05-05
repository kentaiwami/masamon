//
//  Setting.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/31.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class Setting: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableview: UITableView!
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        appDelegate.screennumber = 2
    }
    
    // セルに表示するテキスト
    let texts = ["", "時給登録", "ユーザ名とスタッフ人数", "", "スタッフ名を追加・編集・削除", "", "シフト名を追加・編集・削除", "", "取り込んだ1クールごとのシフトを編集・削除"]
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = texts[indexPath.row]
        
        if texts[indexPath.row].characters.count != 0 {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        
        return cell
    }
    
    //空白セルを選択不可にする
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        if texts[indexPath.row].characters.count == 0  {
            return nil
        }else {
            return indexPath
        }
    }
}
