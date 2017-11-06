//
//  FileBrowseSelect.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/02.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class FileBrowseSelect: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableview: UITableView!
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    // セルに表示するテキスト
    var shiftlist: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.allowsMultipleSelection = true
        
        SetShiftListArray()
        
        //ナビゲーションバーの色などを設定する
        self.navigationController!.navigationBar.barTintColor = UIColor.black
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
                
        shiftlist.removeAll()
        
        SetShiftListArray()
        
        self.tableview.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appDelegate.screennumber = 3
    }
    
    func SetShiftListArray() {
        if DBmethod().DBRecordCount(ShiftDB.self) != 0 {
            
            let results = DBmethod().GetShiftDBAllRecordArray()
            for i in (0..<results!.count).reversed() {
                shiftlist.append(results![i].shiftimportname)
            }
        }
    }
    
    var flag = false
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftlist.count
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = shiftlist[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    let shiftdbrecord: ShiftDB = ShiftDB()
    
    //セルが選択された時に呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var shiftdbrecord: ShiftDB = ShiftDB()
        shiftdbrecord = DBmethod().SearchShiftDB(shiftlist[indexPath.row])
        
        appDelegate.selectedcellname = shiftdbrecord.shiftimportname
        
        let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "FileBrowse")
        self.navigationController!.pushViewController(targetViewController, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
