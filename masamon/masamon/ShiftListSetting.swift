//
//  ShiftListSetting.swift
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
        
        self.view.backgroundColor = UIColor.hex("191919", alpha: 1.0)

        table.delegate = self
        table.dataSource = self
        
        self.RefreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func RefreshData(){
        
        self.texts.removeAll()
        
        if DBmethod().GetShiftDBAllRecordArray() != nil {
            let results = DBmethod().GetShiftDBAllRecordArray()
            
            for i in (0 ..< results!.count).reversed() {
                self.texts.append(results![i])
            }
        }
        
        self.table.reloadData()
    }
    
    
    // セルに表示するテキスト
    var texts: [ShiftDB] = []
    
    let sections = ["最新順"]
    
    //セクションの数を返す.
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    //セクションのタイトルを返す.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = texts[indexPath.row].shiftimportname
        
        return cell
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    
    //セルの削除を許可
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    //セルの選択を禁止する
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil;
    }
    
    //セルを横スクロールした際に表示されるアクションを管理するメソッド
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Editボタン.
        let EditButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "編集") { (action, index) -> Void in
            
            tableView.isEditing = false
            self.alert(self.texts[indexPath.row].shiftimportname + "を編集します", messagetext: "新しいシフト取り込み名を入力して下さい\nxlxsやpdfなどはつけてもつけなくても大丈夫です。", index: indexPath.row, flag: 0)
        }
        EditButton.backgroundColor = UIColor.green
        
        // Deleteボタン.
        let DeleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            
            tableView.isEditing = false
            
            self.alert(self.texts[indexPath.row].shiftimportname + "を削除します", messagetext: "関連する情報が全て削除されます。よろしいですか？", index: indexPath.row, flag: 1)
        }
        DeleteButton.backgroundColor = UIColor.red
        
        return [EditButton, DeleteButton]
    }
    
    //アラートを表示する関数
    func alert(_ titletext: String, messagetext: String, index: Int, flag: Int){
        
        var buttontitle = ""
        
        let alert:UIAlertController = UIAlertController(title: titletext,
            message: messagetext,
            preferredStyle: UIAlertControllerStyle.alert)
        
        //flagが0は編集、flagが1は削除
        switch(flag){
        case 0:
            buttontitle = "編集完了"
            
            let Action:UIAlertAction = UIAlertAction(title: buttontitle,
                style: UIAlertActionStyle.default,
                handler:{
                    (action:UIAlertAction!) -> Void in
                    let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                    
                    
                    if textFields != nil {
                        
                        if textFields![0].text! != "" {
                            
                            var oldfileextension = ""
                            var oldfilepath = ""
                            //上書き処理を行う
                            let oldshiftdbrecord = DBmethod().SearchShiftDB(self.texts[index].shiftimportname)
                            oldfilepath = oldshiftdbrecord.shiftimportpath
                            
                            let newshiftdbrecord = ShiftDB()
                            newshiftdbrecord.id = oldshiftdbrecord.id
                            newshiftdbrecord.year = oldshiftdbrecord.year
                            newshiftdbrecord.month = oldshiftdbrecord.month
                            
                            //変更前のファイルの拡張子を判断
                            if self.texts[index].shiftimportname.contains(".xlsx") {
                                oldfileextension = ".xlsx"
                            }else if self.texts[index].shiftimportname.contains(".pdf") {
                                oldfileextension = ".pdf"
                            }else if self.texts[index].shiftimportname.contains(".PDF") {
                                oldfileextension = ".PDF"
                            }
                            
                            var newpath = oldshiftdbrecord.shiftimportpath
                            //ユーザが入力した新規取り込み名に拡張子が含まれているか調べる
                            switch(oldfileextension){
                            case ".xlsx":
                                if textFields![0].text!.contains(".xlsx") == false {
                                    newpath = newpath.replacingOccurrences(of: self.texts[index].shiftimportname, with: textFields![0].text! + oldfileextension)
                                    newshiftdbrecord.shiftimportname = textFields![0].text! + oldfileextension
                                }
                                
                            case ".pdf":
                                if textFields![0].text!.contains(".pdf") == false {
                                    newpath = newpath.replacingOccurrences(of: self.texts[index].shiftimportname, with: textFields![0].text! + oldfileextension)
                                    newshiftdbrecord.shiftimportname = textFields![0].text! + oldfileextension
                                }
                                
                            case ".PDF":
                                if textFields![0].text!.contains(".PDF") == false {
                                    newpath = newpath.replacingOccurrences(of: self.texts[index].shiftimportname, with: textFields![0].text! + oldfileextension)
                                    newshiftdbrecord.shiftimportname = textFields![0].text! + oldfileextension
                                }
                                
                            default:
                                break
                                
                            }
                            
                            newshiftdbrecord.shiftimportpath = newpath
                            newshiftdbrecord.salaly = oldshiftdbrecord.salaly
                            
                            let oldshiftdetailarray = oldshiftdbrecord.shiftdetail
                            
                            for i in 0 ..< oldshiftdetailarray.count{
                                newshiftdbrecord.shiftdetail.append(oldshiftdetailarray[i])
                            }
                            
                            //関連するシフトを上書き更新する
                            for i in 0 ..< oldshiftdetailarray.count{
                                let newshiftdetaildbrecord = ShiftDetailDB()
                                newshiftdetaildbrecord.id = oldshiftdetailarray[i].id
                                newshiftdetaildbrecord.year = oldshiftdetailarray[i].year
                                newshiftdetaildbrecord.month = oldshiftdetailarray[i].month
                                newshiftdetaildbrecord.day = oldshiftdetailarray[i].day
                                newshiftdetaildbrecord.staff = oldshiftdetailarray[i].staff
                                newshiftdetaildbrecord.shiftDBrelationship = newshiftdbrecord
                                
                                DBmethod().AddandUpdate(newshiftdetaildbrecord, update: true)
                            }
                            
                            DBmethod().DeleteRecord(oldshiftdbrecord)
                            DBmethod().AddandUpdate(newshiftdbrecord, update: true)
                            
                            //ファイル名を変更する                            
                            do {
                                try FileManager.default.moveItem(atPath: oldfilepath, toPath: newshiftdbrecord.shiftimportpath)
                            }
                            catch{
                                print(error)
                            }
                        }
                    }
                    
                    self.RefreshData()
                    
            })
            alert.addAction(Action)
            
            //シフト取り込み名入力用のtextfieldを追加
            alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                text.placeholder = "新規取り込み名の入力"
                text.returnKeyType = .next
            })
            
        case 1:
            buttontitle = "削除する"
            
            let Action: UIAlertAction = UIAlertAction(title: buttontitle, style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction!) -> Void in
                
                var filename = ""
                
                //ShiftDBの穴埋めをするために基準となるidを記録
                let shiftdbpivot_id = self.texts[index].id
                
                //ShiftDetailの基準を見つけるための準備
                var shiftdb_year = self.texts[index].year
                let shiftdb_month = self.texts[index].month

                //ShiftDBに記録されている月が1,2,3月の場合はyearを1つ増やしてShiftDetailDBとの整合性を取る
                if shiftdb_month == 1 || shiftdb_month == 2 || shiftdb_month == 3 {
                    shiftdb_year += 1
                }
                
                //年月をもとに基準となるidを取り出す
                let shiftdetailresults = DBmethod().TheDayStaffGet(shiftdb_year, month: shiftdb_month-1, date: 11)
                
                if shiftdetailresults != nil {
                    if shiftdetailresults!.count != 0 {
                        let shiftdetaildbpivot_id = shiftdetailresults![0].id

                        //ShiftDetailDBレコードの削除
                        let shiftdbrecord = DBmethod().SearchShiftDB(self.texts[index].shiftimportname)
                        let shiftdetailarray = shiftdbrecord.shiftdetail
                        let deleterecordcount = shiftdetailarray.count
                        filename = shiftdbrecord.shiftimportname
                        
                        DBmethod().DeleteShiftDetailDBRecords(shiftdetailarray)
                        
                        //ShiftDBレコードの削除
                        DBmethod().DeleteRecord(self.texts[index])
                        
                        //ShiftDetailDBレコードのソート
                        DBmethod().ShiftDetailDBSort()
                        
                        //ShiftDBレコードのソート
                        DBmethod().ShiftDBSort()
                        
                        //穴埋め
                        DBmethod().ShiftDBFillHole(shiftdbpivot_id)
                        DBmethod().ShiftDetailDBFillHole(shiftdetaildbpivot_id, deleterecords: deleterecordcount)

                        //関連づけ
                        var shiftdb_id_count = 0
                        var shiftdetaildb_array: [ShiftDetailDB] = []
                        var shiftdetail_recordcount = 0
                        
                        //ShiftDetailDB内の11日であるレコードを配列で取得
                        let shiftdetaildb_day_array = DBmethod().GetShiftDetailDBRecordByDay(11)
                        
                        for i in 0..<DBmethod().DBRecordCount(ShiftDetailDB) {
                            
                            let shitdb_record = DBmethod().GetShiftDBRecordByID(shiftdb_id_count)
                            
                            //shiftdb_recordの年月を持ってきて何日まであるかを把握
                            let shiftrange = CommonMethod().GetShiftCoursMonthRange(shiftdetaildb_day_array[shiftdb_id_count].year, shiftstartmonth: shiftdetaildb_day_array[shiftdb_id_count].month)

                            //ShiftDetailDBのrelationshipを更新する
                            DBmethod().ShiftDetaiDB_relationshipUpdate(i, record: shitdb_record)
                            
                            //リレーションシップを更新した後のShiftDetailDBのレコードを取得
                            let shiftdetaildb_record = DBmethod().GetShiftDetailDBRecordByID(i)
                            
                            shiftdetaildb_array.append(shiftdetaildb_record)

                            shiftdetail_recordcount += 1

                            //処理済みのshiftdetailレコード数とクールの日数数が一致(当該クールのshiftdetailレコードを全て処理したら)
                            if shiftdetail_recordcount == shiftrange.length {
                                //ShiftDBのListにShiftDetaiDBListを更新する
                                let shiftimportname = DBmethod().ShiftDBGet(shiftdb_id_count)
                                DBmethod().ShiftDB_relationshipUpdate(shiftimportname, array: shiftdetaildb_array)
                                
                                shiftdb_id_count += 1
                                shiftdetail_recordcount = 0
                                shiftdetaildb_array.removeAll()
                            }
                        }

                        
                        //ファイルの削除
                        let Libralypath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
                        let filepath = Libralypath + "/" + filename
                        
                        let filemanager:FileManager = FileManager()
                        do{
                            try filemanager.removeItem(atPath: filepath)
                        }catch{
                            print(error)
                        }

                    }else{
                        self.ShowDeleteError(self.texts[index].shiftimportname)
                    }
                }else{
                    self.ShowDeleteError(self.texts[index].shiftimportname)
                }
                
                self.RefreshData()
            })
            alert.addAction(Action)
            
        default:
            break
        }
        
        
        let Back: UIAlertAction = UIAlertAction(title: "戻る", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(Back)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //削除エラーを表示するアラート
    func ShowDeleteError(_ importname: String){
        let alertController = UIAlertController(title: "削除エラー", message: importname+"の削除に失敗しました", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)

    }
}
