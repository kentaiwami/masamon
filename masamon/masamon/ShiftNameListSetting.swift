//
//  ShiftNameList.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/31.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class ShiftNameListSetting: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var table: UITableView!
    
    var shiftgroupnameUIPicker: UIPickerView = UIPickerView()
    var shifttimeUIPicker: UIPickerView = UIPickerView()
    var pickerviewtoolBar = UIToolbar()
    var pickerdoneButton = UIBarButtonItem()
    let shiftgroupname = CommonMethod().GetShiftGroupName()
    var shiftgroupnametextfield = UITextField()
    var shifttimetextfield = UITextField()

    var starttime = ""
    var endtime = ""
    let wavyline: [String] = ["〜"]
    
    let time = CommonMethod().GetTime()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        
        self.RefreshData()
        
        //シフト時間を選択して表示するテキストフィールドのデフォルト表示を指定
        starttime = time[0]
        endtime = time[0]
        
        //シフトグループを選択するpickerview
        shiftgroupnameUIPicker.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 200.0)
        shiftgroupnameUIPicker.delegate = self
        shiftgroupnameUIPicker.dataSource = self
        shiftgroupnameUIPicker.tag = 2
        
        //シフト時間を選択するpickerview
        shifttimeUIPicker.frame = CGRectMake(0,0,self.view.bounds.width/2+20, 200.0)
        shifttimeUIPicker.delegate = self
        shifttimeUIPicker.dataSource = self
        shifttimeUIPicker.tag = 3
        
        //pickerviewに表示するツールバー
        pickerviewtoolBar.barStyle = UIBarStyle.Default
        pickerviewtoolBar.translucent = true
        pickerviewtoolBar.tintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        pickerviewtoolBar.sizeToFit()
        
        pickerdoneButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker:")
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        pickerviewtoolBar.setItems([flexSpace,pickerdoneButton], animated: false)
        pickerviewtoolBar.userInteractionEnabled = true
        
    }
    
    
    func RefreshData(){
        records.removeAll()
        
        //ShiftSystemDBのレコード全てをグループ別で配列に格納
        for(var i = 0; i <= 6; i++){
            records.append([])
            let results = DBmethod().ShiftSystemRecordArrayGetByGroudid(i)
            
            for(var j = 0; j < results.count; j++){
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    /*
    セクションのタイトルを返す.
    */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records[section].count
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = records[indexPath.section][indexPath.row].name
        
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
            self.alert(self.records[indexPath.section][indexPath.row].name + "を編集します", messagetext: "新しいシフト名を入力して下さい", section: indexPath.section, row: indexPath.row, flag: 0)
        }
        EditButton.backgroundColor = UIColor.greenColor()
        
        // Deleteボタン.
        let DeleteButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "削除") { (action, index) -> Void in
            
            tableView.editing = false
            
            self.alert(self.records[indexPath.section][indexPath.row].name + "を削除します", messagetext: "本当に削除してよろしいですか？", section: indexPath.row, row: indexPath.row, flag: 1)
            
        }
        DeleteButton.backgroundColor = UIColor.redColor()
        
        return [EditButton, DeleteButton]
    }
    
    //アラートを表示する関数
    func alert(titletext: String, messagetext: String, section: Int, row: Int, flag: Int){
        
        var buttontitle = ""
        
        let alert:UIAlertController = UIAlertController(title: titletext,
            message: messagetext,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        var textflag = false
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
                        
                        for textField:UITextField in textFields! {
                            if(textField.text == ""){
                                textflag = false
                                break
                            }else{
                                textflag = true
                            }
                        }
                        
                        if(textflag){
                            
                            //新規レコードの作成
                            let newstaffnamedbrecord = CommonMethod().CreateShiftSystemDBRecord(self.records[section][row].id,shiftname: textFields![0].text!, shiftgroup: textFields![1].text!, shifttime: textFields![2].text!, shiftstarttimerow: self.shiftstarttimeselectrow, shiftendtimerow: self.shiftendtimeselectrow)
                            
                            //編集前のレコードを削除
                            DBmethod().DeleteRecord(self.records[section][row])
                            
                            //編集後のレコードを追加
                            DBmethod().AddandUpdate(newstaffnamedbrecord, update: true)
                            
                            //ソートする
                            DBmethod().ShiftSystemDBSort()
                        }
                    }
                    
                    self.RefreshData()
                    
            })
            
            alert.addAction(Action)
            
            //シフト名入力用のtextfieldを追加
            alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
                text.placeholder = "新規シフト名の入力"
                text.returnKeyType = .Next
            })
            
            //シフトグループの選択内容を入れるテキストフィールドを追加
            alert.addTextFieldWithConfigurationHandler(configurationshiftgroupnameTextField)
            
            //シフト時間の選択内容を入れるテキストフィールドを追加
            alert.addTextFieldWithConfigurationHandler(configurationshifttimeTextField)
            
        case 1:
            buttontitle = "削除する"
            
            let Action: UIAlertAction = UIAlertAction(title: buttontitle, style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction!) -> Void in
                
                //                for(var i = 0; i < self.records.count; i++){
                //
                //                    if(self.early[index] == self.records[i].name){
                //                        let pivot = self.records[i].id                  //削除前にずらす元となるidを記録する
                //
                //                        //対象レコードを削除,並び替え,穴埋め
                //                        DBmethod().DeleteRecord(self.records[i])
                //                        DBmethod().StaffNameDBSort()
                //                        DBmethod().StaffNameDBFillHole(pivot)
                //
                //                        break
                //                    }
                //                }
                //                self.RefreshData()
            })
            alert.addAction(Action)
            
        case 2:
            //            buttontitle = "追加する"
            //
            //            let Action: UIAlertAction = UIAlertAction(title: buttontitle, style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            //                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
            //                if textFields != nil {
            //                    if(textFields![0].text! != ""){
            //                        let newrecord = StaffNameDB()
            //                        newrecord.id = index
            //                        newrecord.name = textFields![0].text!
            //
            //                        DBmethod().AddandUpdate(newrecord, update: true)
            //                    }
            //                }
            //
            //                //                self.RefreshData()
            //            })
            
            //シフト名入力用のtextfieldを追加
            alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
                text.placeholder = "スタッフ名の入力"
                text.returnKeyType = .Next
            })
            
            //            alert.addAction(Action)
            
        default:
            break
        }
        
        
        let Back: UIAlertAction = UIAlertAction(title: "戻る", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(Back)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //プラスボタンを押したとき
    @IBAction func TapPlusButton(sender: AnyObject) {
        //        self.alert("スタッフ名を新規追加します", messagetext: "追加するスタッフ名を入力して下さい", index: DBmethod().DBRecordCount(StaffNameDB), flag: 2)
    }
    
    //戻るボタンを押したとき
    @IBAction func TapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //pickerに表示する列数を返すデータソースメソッド.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if(pickerView.tag == 1 || pickerView.tag == 2){
            return 1
        }else{
            return 3
        }
        
    }
    
    //pickerに表示する行数を返すデータソースメソッド.
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 2){
            pickerdoneButton.tag = 2
            return shiftgroupname.count
        }else{
            pickerdoneButton.tag = 3
            if(component == 0){
                return time.count
            }else if(component == 1){
                return wavyline.count
            }else{
                return time.count
            }
        }
    }
    
    //pickerに表示する値を返すデリゲートメソッド.
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 2){
            return shiftgroupname[row]
        }else{
            if(component == 0 || component == 2){
                return time[row]
            }else{
                return wavyline[row]
            }
        }
    }
    
    //シフトグループ,シフト時間(開始),シフト時間(終了)の選択箇所を記録する変数
    var shiftgroupselectrow = 0
    var shiftstarttimeselectrow = 0
    var shiftendtimeselectrow = 0
    //pickerが選択されたとき
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 2){      //シフトグループ選択
            shiftgroupnametextfield.text = shiftgroupname[row]
            pickerdoneButton.tag = 2
            shiftgroupselectrow = row
            
        }else if(pickerView.tag == 3){      //シフト時間選択
            
            if(component == 0){
                starttime = time[row]
                shiftstarttimeselectrow = row
            }else if(component == 2){
                endtime = time[row]
                shiftendtimeselectrow = row
            }
            pickerdoneButton.tag = 3
            
            shifttimetextfield.text = starttime + " " + wavyline[0] + " " + endtime
        }
    }
    
    //シフトのグループを入れるテキストフィールドの設定をする
    func configurationshiftgroupnameTextField(textField: UITextField!){
        textField.placeholder = "シフトのグループを入力"
        textField.inputView = self.shiftgroupnameUIPicker
        textField.inputAccessoryView = self.pickerviewtoolBar
        textField.tag = 1
        textField.delegate = self
        shiftgroupnametextfield = textField
    }
    
    //シフトの時間を入れるテキストフィールドの設定をする
    func configurationshifttimeTextField(textField: UITextField!){
        textField.placeholder = "シフトの時間を入力"
        textField.inputView = self.shifttimeUIPicker
        textField.inputAccessoryView = self.pickerviewtoolBar
        textField.tag = 2
        textField.delegate = self
        shifttimetextfield = textField
    }
    
    //ツールバーの完了ボタンを押した時の関数
    func donePicker(sender:UIButton){
        
        if(sender.tag == 2){            //シフトグループの完了ボタン
            shiftgroupnametextfield.resignFirstResponder()
            shifttimetextfield.becomeFirstResponder()
        }else if(sender.tag == 3){      //シフト時間の完了ボタン
            shifttimetextfield.resignFirstResponder()
        }
    }
    
    //textfieldがタップされた時
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField.tag == 1){             //シフトグループ選択
            shiftgroupnameUIPicker.selectRow(shiftgroupselectrow, inComponent: 0, animated: true)
            textField.text = shiftgroupname[shiftgroupselectrow]
            
        }else if(textField.tag == 2){       //シフト時間選択
            shifttimeUIPicker.selectRow(shiftstarttimeselectrow, inComponent: 0, animated: true)
            shifttimeUIPicker.selectRow(shiftendtimeselectrow, inComponent: 2, animated: true)
            textField.text = time[shiftstarttimeselectrow] + " " + wavyline[0] + " " + time[shiftendtimeselectrow]
        }
    }

    
}
