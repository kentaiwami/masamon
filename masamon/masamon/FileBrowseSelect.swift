//
//  ShiftGalleryTable.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/02.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class FileBrowseSelect: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableview: UITableView!
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    // セルに表示するテキスト
    var shiftlist: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.allowsMultipleSelection = true
        
        SetShiftListArray()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
                
        shiftlist.removeAll()
        
        SetShiftListArray()
        
        self.tableview.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        appDelegate.screennumber = 3
    }
    
    func SetShiftListArray() {
        if DBmethod().DBRecordCount(ShiftDB) != 0 {
            
            let results = DBmethod().GetShiftDBAllRecordArray()
            for i in (0..<results!.count).reverse() {
                shiftlist.append(results![i].shiftimportname)
            }
        }
    }
    
    var flag = false
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftlist.count
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = shiftlist[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    let shiftdbrecord: ShiftDB = ShiftDB()
    
    //セルが選択された時に呼ばれる
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var shiftdbrecord: ShiftDB = ShiftDB()
        shiftdbrecord = DBmethod().SearchShiftDB(shiftlist[indexPath.row])
        
        appDelegate.selectedcellname = shiftdbrecord.shiftimportname
        
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FileBrowse")
        targetViewController.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController( targetViewController, animated: true, completion: nil)

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
