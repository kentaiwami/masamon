//
//  ShiftNameListSetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/31.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class ShiftNameListSetting: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var table: UITableView!
    
    var shiftgroupnameUIPicker: UIPickerView = UIPickerView()

    var pickerviewtoolBar = UIToolbar()
    var pickerdoneButton = UIBarButtonItem()
    
    let shiftgroupname = CommonMethod().GetShiftGroupName()
    
    var shiftgroupnametextfield = UITextField()

    var starttime = ""
    var endtime = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.hex("191919", alpha: 1.0)

        table.delegate = self
        table.dataSource = self
        
        self.RefreshData()
        
        //シフトグループを選択するpickerview
        shiftgroupnameUIPicker.frame = CGRect(x: 0,y: 0,width: self.view.bounds.width/2+20, height: 200.0)
        shiftgroupnameUIPicker.delegate = self
        shiftgroupnameUIPicker.dataSource = self
        shiftgroupnameUIPicker.tag = 2
        
        //pickerviewに表示するツールバー
        pickerviewtoolBar.barStyle = UIBarStyle.default
        pickerviewtoolBar.isTranslucent = true
        pickerviewtoolBar.sizeToFit()
        
        pickerdoneButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ShiftNameListSetting.donePicker(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        pickerviewtoolBar.setItems([flexSpace,pickerdoneButton], animated: false)
        pickerviewtoolBar.isUserInteractionEnabled = true
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ShiftNameListSetting.TapPlusButton(_:)))
        navigationItem.rightBarButtonItems = [add]
    }
    
    
    func RefreshData(){
        records.removeAll()
        
        //ShiftSystemDBのレコード全てをグループ別で配列に格納
        for i in 0 ... 6 {
        
            records.append([])
            let results = DBmethod().ShiftSystemRecordArrayGetByGroudid(i)
            
            for j in 0 ..< results.count{
                records[i].append(results[j])
            }
        }
        
        self.table.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //ShiftSystemDBのレコード配列
    var records: [[ShiftSystemDB]] = []
    
    // Sectionで使用する配列を定義する.
    let sections = CommonMethod().GetShiftGroupNameAndTime()
    
    /*
    セクションの数を返す.
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    /*
    セクションのタイトルを返す.
    */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records[section].count
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = records[indexPath.section][indexPath.row].name
        
        return cell
    }
    
    //セルの削除を許可
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool
    {
        let cellname = self.records[indexPath.section][indexPath.row].name
        
        if cellname == "不明" {
            return false
        }else {
            return true
        }
    }
    
    //セルを横スクロールした際に表示されるアクションを管理するメソッド
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Editボタン.
        let EditButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "編集") { (action, index) -> Void in
            
            tableView.isEditing = false
            self.alert(self.records[indexPath.section][indexPath.row].name + "を編集します", messagetext: "新しいシフト名を入力して下さい", section: indexPath.section, row: indexPath.row, flag: 0)
        }
        EditButton.backgroundColor = UIColor.green
        
        // Deleteボタン.
        let DeleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            
            tableView.isEditing = false
            
            self.alert(self.records[indexPath.section][indexPath.row].name + "を削除します", messagetext: "本当に削除してよろしいですか？", section: indexPath.section, row: indexPath.row, flag: 1)
            
        }
        DeleteButton.backgroundColor = UIColor.red
        
        return [EditButton, DeleteButton]
    }
    
    //アラートを表示する関数
    func alert(_ titletext: String, messagetext: String, section: Int, row: Int, flag: Int){
        
        var buttontitle = ""
        
        let alert:UIAlertController = UIAlertController(title: titletext,
            message: messagetext,
            preferredStyle: UIAlertControllerStyle.alert)
        
        var textflag = false
        //flagが0は編集、flagが1は削除, flagが3は追加
        switch(flag){
        case 0:
            buttontitle = "編集完了"
            
            let Action:UIAlertAction = UIAlertAction(title: buttontitle,
                style: UIAlertActionStyle.default,
                handler:{
                    (action:UIAlertAction!) -> Void in
                    let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                    if textFields != nil {
                        
                        for textField:UITextField in textFields! {
                            if textField.text == "" {
                                textflag = false
                                break
                            }else{
                                textflag = true
                            }
                        }
                        
                        if textflag {
                            //新規レコードの作成
                            let newrecord = CommonMethod().CreateShiftSystemDBRecord(self.records[section][row].id,shiftname: textFields![0].text!, shiftgroup: textFields![1].text!)

                            //編集前のレコードを削除
                            DBmethod().DeleteRecord(self.records[section][row])

                            //編集後のレコードを追加
                            DBmethod().AddandUpdate(newrecord, update: true)
                            
                            //ソートする
                            DBmethod().ShiftSystemDBSort()
                        }
                    }
                    
                    self.RefreshData()
                    
            })
            
            alert.addAction(Action)
            
            //シフト名入力用のtextfieldを追加
            alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                text.placeholder = "新規シフト名の入力"
                text.returnKeyType = .next
            })
            
            //シフトグループの選択内容を入れるテキストフィールドを追加
            alert.addTextField(configurationHandler: configurationshiftgroupnameTextField)
                        
        case 1:
            buttontitle = "削除する"
            
            let Action: UIAlertAction = UIAlertAction(title: buttontitle, style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction!) -> Void in
                
                let pivot = self.records[section][row].id                  //削除前にずらす元となるidを記録する
                
                //対象レコードを削除,並び替え,穴埋め
                DBmethod().DeleteRecord(self.records[section][row])
                DBmethod().ShiftSystemDBSort()
                DBmethod().ShiftSystemDBFillHole(pivot)

                self.RefreshData()
            })
            alert.addAction(Action)
            
        case 2:
            buttontitle = "追加する"
            
            let Action: UIAlertAction = UIAlertAction(title: buttontitle, style: UIAlertActionStyle.default, handler: { (action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    
                    for textField:UITextField in textFields! {
                        if textField.text == "" {
                            textflag = false
                            break
                        }else{
                            textflag = true
                        }
                    }

                    if textflag {
                        let newrecord = CommonMethod().CreateShiftSystemDBRecord(DBmethod().DBRecordCount(ShiftSystemDB.self),shiftname: textFields![0].text!, shiftgroup: textFields![1].text!)

                        DBmethod().AddandUpdate(newrecord, update: true)
                    }
                }
                
                self.RefreshData()
            })
            
            //シフト名入力用のtextfieldを追加
            alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                text.placeholder = "新規シフト名の入力"
                text.returnKeyType = .next
            })
            
            //シフトグループの選択内容を入れるテキストフィールドを追加
            alert.addTextField(configurationHandler: configurationshiftgroupnameTextField)
            
            alert.addAction(Action)
            
        default:
            break
        }
        
        
        let Back: UIAlertAction = UIAlertAction(title: "戻る", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(Back)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //プラスボタンを押したとき
    func TapPlusButton(_ sender: AnyObject) {
        self.alert("シフト名を新規追加します", messagetext: "追加するシフト名の情報を入力して下さい", section: 0, row: 0, flag: 2)
    }
    
    //pickerに表示する列数を返すデータソースメソッド.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //pickerに表示する行数を返すデータソースメソッド.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerdoneButton.tag = 2
        return shiftgroupname.count
    }
    
    //pickerに表示する値を返すデリゲートメソッド.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shiftgroupname[row]
    }
    
    //シフトグループの選択箇所を記録する変数
    var shiftgroupselectrow = 0
    
    //pickerが選択されたとき
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        shiftgroupnametextfield.text = shiftgroupname[row]
        pickerdoneButton.tag = 2
        shiftgroupselectrow = row
    }
    
    //シフトのグループを入れるテキストフィールドの設定をする
    func configurationshiftgroupnameTextField(_ textField: UITextField!){
        textField.placeholder = "シフトのグループを入力"
        textField.inputView = self.shiftgroupnameUIPicker
        textField.inputAccessoryView = self.pickerviewtoolBar
        textField.tag = 1
        textField.delegate = self
        shiftgroupnametextfield = textField
    }
    
    //ツールバーの完了ボタンを押した時の関数
    func donePicker(_ sender:UIButton){
        shiftgroupnametextfield.resignFirstResponder()
    }
    
    //textfieldがタップされた時
    func textFieldDidBeginEditing(_ textField: UITextField) {
        shiftgroupnameUIPicker.selectRow(shiftgroupselectrow, inComponent: 0, animated: true)
        textField.text = shiftgroupname[shiftgroupselectrow]
    }
    
}
