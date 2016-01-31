//
//  StaffNameList.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/31.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class StaffNameListSetting: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func TapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // セルに表示するテキスト
    var texts = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = texts[indexPath.row]
        return cell
    }
    
    //セルの削除を許可
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    //セルを横スクロールした際に表示されるアクションを管理するメソッド
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Editボタン.
        let EditButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "edit") { (action, index) -> Void in
            
            tableView.editing = false
            print("tapedit")
            
        }
        EditButton.backgroundColor = UIColor.greenColor()
        
        // Deleteボタン.
        let DeleteButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "delete") { (action, index) -> Void in
            
            tableView.editing = false
            print("tapdelete")
            
        }
        DeleteButton.backgroundColor = UIColor.redColor()
        
        return [EditButton, DeleteButton]
    }
}
