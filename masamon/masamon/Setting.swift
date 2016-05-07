//
//  Setting.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/31.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class Setting: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableview: UITableView!
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ナビゲーションバーの色などを設定する
        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.scrollEnabled = false
        
        //tableviewの下の余白部分を埋める処理
        let spaceview = UIView()
        let spaceview_y:CGFloat = 418
        spaceview.backgroundColor = UIColor.hex("FFFFFF", alpha: 0.9)
        spaceview.frame = CGRectMake(0, spaceview_y, self.view.frame.width, self.view.frame.height - spaceview_y)
        self.view.addSubview(spaceview)
    }
    
    override func viewDidAppear(animated: Bool) {
        appDelegate.screennumber = 2
    }
    
    // セルに表示するテキスト
    let texts = ["時給登録", "ユーザ名とスタッフ人数", "", "スタッフ名を追加・編集・削除", "", "シフト名を追加・編集・削除", "", "取り込んだシフトを編集・削除"]
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = texts[indexPath.row]
        
        if texts[indexPath.row].characters.count != 0 {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.textLabel?.textColor = UIColor.blackColor()
        }else {
            cell.backgroundColor = UIColor.hex("000000", alpha: 0.07)
        }
        
        
        let cellSelectedView = UIView()
        cellSelectedView.backgroundColor = UIColor.lightGrayColor()
        cell.selectedBackgroundView = cellSelectedView
        
        return cell
    }
    
    //空白セルを選択不可にする
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        if texts[indexPath.row].characters.count == 0  {
            return nil
        }else {
            return indexPath
        }
    }
    
    //セルをタップして選択したら動作
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var screen_name = ""
        switch indexPath.row {
        case 0:
            screen_name = "HourlyWageSetting"
        
        case 1:
            screen_name = "ShiftImportSetting"
            
        case 3:
            screen_name = "StaffNameListSetting"
            
        case 5:
            screen_name = "ShiftNameListSetting"
            
        case 7:
            screen_name = "ShiftListSetting"
        default:
            break
        }
        
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier(screen_name)
        targetViewController.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        self.navigationController!.pushViewController(targetViewController, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
}
