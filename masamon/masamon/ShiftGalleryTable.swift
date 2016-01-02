//
//  ShiftGalleryTable.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/02.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class ShiftGalleryTable: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var ButtomView: UIView!
    
    //  チェックされたセルの位置を保存しておく辞書をプロパティに宣言
    var selectedCells:[Bool]=[Bool]()
    
    // セルに表示するテキスト
    var shiftlist: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ButtomView.alpha = 0.8

        tableview.delegate = self
        tableview.dataSource = self
        tableview.allowsMultipleSelection = true

        if(DBmethod().DBRecordCount(ShiftImportHistoryDB) != 0){
            for(var i = DBmethod().DBRecordCount(ShiftImportHistoryDB)-1; i >= 0; i--){
                let historydate = DBmethod().ShiftImportHistoryDBGet()[i].date
                let historyname = DBmethod().ShiftImportHistoryDBGet()[i].name
                shiftlist.append(historydate + "   " + historyname)
                selectedCells.append(false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        shiftlist.removeAll()
        selectedCells.removeAll()
        
        if(DBmethod().DBRecordCount(ShiftImportHistoryDB) != 0){
            for(var i = DBmethod().DBRecordCount(ShiftImportHistoryDB)-1; i >= 0; i--){
                let historydate = DBmethod().ShiftImportHistoryDBGet()[i].date
                let historyname = DBmethod().ShiftImportHistoryDBGet()[i].name
                shiftlist.append(historydate + "   " + historyname)
                selectedCells.append(false)
            }
        }

        self.tableview.reloadData()
    }
    
    //表示ボタンを押した時に呼ばれる関数
    @IBAction func TapShowButton(sender: AnyObject) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        appDelegate.selectedcell = self.selectedCells
    }
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftlist.count
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = shiftlist[indexPath.row]
        
        if(selectedCells[indexPath.row]){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    //セルが選択された時に呼ばれる
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableview.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        selectedCells[indexPath.row] = true
    }
    
    //セルの選択が解除された時に呼ばれる
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableview.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.None
        
        selectedCells[indexPath.row] = false
    }
}
