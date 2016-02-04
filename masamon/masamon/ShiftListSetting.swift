//
//  ShiftList.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/31.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class ShiftListSetting: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func RefreshData(){
        

        
        self.table.reloadData()
        
    }

    
    // セルに表示するテキスト
    var texts: [String] = []

    //戻るボタンをタップしたとき
    @IBAction func TapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = texts[indexPath.row]
        
        return cell
    }
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }

    
    //セルの削除を許可
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    //セルの選択を禁止する
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil;
    }

    //セルを横スクロールした際に表示されるアクションを管理するメソッド
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Editボタン.
        let EditButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "編集") { (action, index) -> Void in
            
            tableView.editing = false
            self.alert(self.texts[indexPath.row] + "を編集します", messagetext: "新しいシフト取り込み名を入力して下さい", index: indexPath.row, flag: 0)
        }
        EditButton.backgroundColor = UIColor.greenColor()
        
        // Deleteボタン.
        let DeleteButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "削除") { (action, index) -> Void in
            
            tableView.editing = false
            
            self.alert(self.texts[indexPath.row] + "を削除します", messagetext: "関連する情報が全て削除されます。よろしいですか？", index: indexPath.row, flag: 1)
            
        }
        DeleteButton.backgroundColor = UIColor.redColor()
        
        return [EditButton, DeleteButton]
    }

    //アラートを表示する関数
    func alert(titletext: String, messagetext: String, index: Int, flag: Int){
        
        var buttontitle = ""
        
        let alert:UIAlertController = UIAlertController(title: titletext,
            message: messagetext,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        //flagが0は編集、flagが1は削除
        switch(flag){
        case 0:
            buttontitle = "編集完了"
            
            let Action:UIAlertAction = UIAlertAction(title: buttontitle,
                style: UIAlertActionStyle.Default,
                handler:{
                    (action:UIAlertAction!) -> Void in
                    let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                    if textFields != nil {
                        if(textFields![0].text! != ""){
                            
                            //上書き処理を行う
                           
                        }
                    }
                    
                    self.RefreshData()
                    
            })
            alert.addAction(Action)
            
            //シフト名入力用のtextfieldを追加
            alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
                text.placeholder = "スタッフ名の入力"
                text.returnKeyType = .Next
            })
            
        case 1:
            buttontitle = "削除する"
            
            let Action: UIAlertAction = UIAlertAction(title: buttontitle, style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction!) -> Void in
                

                self.RefreshData()
            })
            alert.addAction(Action)
            
        default:
            break
        }
        
        
        let Back: UIAlertAction = UIAlertAction(title: "戻る", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(Back)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }


}
