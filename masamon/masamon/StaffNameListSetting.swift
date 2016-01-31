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
        
        //StaffNameDBのレコード全て取得
        if(DBmethod().StaffNameAllRecordGet() != nil){
            let results = DBmethod().StaffNameAllRecordGet()
            
            for(var i = 0; i < results!.count; i++){
                records.append(results![i])
            }
        }
        
        //StaffNameDBから名前を全て取得
        if(DBmethod().StaffNameArrayGet() != nil){
            texts = DBmethod().StaffNameArrayGet()!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func TapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // セルに表示するテキスト
    var texts: [String] = []
    //StaffNameDBのレコード配列
    var records: [StaffNameDB] = []
    
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
        let EditButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "編集") { (action, index) -> Void in
            
            tableView.editing = false
            self.alert(self.texts[indexPath.row] + "さんを編集します", messagetext: "新しいスタッフ名を入力して下さい", index: indexPath.row, flag: 0)
        }
        EditButton.backgroundColor = UIColor.greenColor()
        
        // Deleteボタン.
        let DeleteButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "削除") { (action, index) -> Void in
            
            tableView.editing = false
            
            self.alert(self.texts[indexPath.row] + "さんを削除します", messagetext: "本当に削除してよろしいですか？", index: indexPath.row, flag: 1)
            
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
        if(flag == 0){
            buttontitle = "編集完了"
            
            let Action:UIAlertAction = UIAlertAction(title: buttontitle,
                style: UIAlertActionStyle.Default,
                handler:{
                    (action:UIAlertAction!) -> Void in
                    let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                    if textFields != nil {
                        if(textFields![0].text! != ""){
                            self.texts[index] = textFields![0].text!
                        }
                    }
                    
                    self.table.reloadData()
                    
            })
            alert.addAction(Action)
            
            //シフト名入力用のtextfieldを追加
            alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
                text.placeholder = "スタッフ名の入力"
                text.returnKeyType = .Next
            })
            
        }else{
            buttontitle = "削除する"
            
            let Action: UIAlertAction = UIAlertAction(title: buttontitle, style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction!) -> Void in
                
                
                
                
            })
            alert.addAction(Action)
        }
        
        
        let Back: UIAlertAction = UIAlertAction(title: "戻る", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(Back)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
