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
        
        self.RefreshData()
    }
    
    func RefreshData(){
        
        records.removeAll()
        texts.removeAll()
        
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
        
        self.table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //戻るボタンを押したとき
    @IBAction func TapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //プラスボタンを押したとき
    @IBAction func TapPlusButton(sender: AnyObject) {
        self.alert("スタッフ名を新規追加します", messagetext: "追加するスタッフ名を入力して下さい", index: DBmethod().DBRecordCount(StaffNameDB), flag: 2)
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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = texts[indexPath.row]
        
        return cell
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
        
        //flagが0は編集、flagが1は削除, flagが3は追加
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
                            for(var i = 0; i < self.records.count; i++){
                                if(self.texts[index] == self.records[i].name){
                                    
                                    let newstaffnamedbrecord = StaffNameDB()
                                    newstaffnamedbrecord.id = self.records[i].id
                                    newstaffnamedbrecord.name = textFields![0].text!
                                    
                                    //編集前のレコードを削除
                                    DBmethod().DeleteRecord(self.records[i])
                                    
                                    //編集後のレコードを追加
                                    DBmethod().AddandUpdate(newstaffnamedbrecord, update: true)
                                    
                                    //ソートする
                                    DBmethod().StaffNameDBSort()
                                    
                                    break
                                }
                            }
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
                
                for(var i = 0; i < self.records.count; i++){
                    
                    if(self.texts[index] == self.records[i].name){
                        let pivot = self.records[i].id                  //削除前にずらす元となるidを記録する
                        
                        //対象レコードを削除,並び替え,穴埋め
                        DBmethod().DeleteRecord(self.records[i])
                        DBmethod().StaffNameDBSort()
                        DBmethod().StaffNameDBFillHole(pivot)

                        break
                    }
                }
                self.RefreshData()
            })
            alert.addAction(Action)
            
        case 2:
            buttontitle = "追加する"
            
            let Action: UIAlertAction = UIAlertAction(title: buttontitle, style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    if(textFields![0].text! != ""){
                        let newrecord = StaffNameDB()
                        newrecord.id = index
                        newrecord.name = textFields![0].text!
                        
                        DBmethod().AddandUpdate(newrecord, update: true)
                    }
                }
                
                self.RefreshData()
            })
            
            //シフト名入力用のtextfieldを追加
            alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
                text.placeholder = "スタッフ名の入力"
                text.returnKeyType = .Next
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
