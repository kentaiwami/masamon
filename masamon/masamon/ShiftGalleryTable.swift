//
//  ShiftGalleryTable.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/02.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import QuickLook

class ShiftGalleryTable: UIViewController, UITableViewDataSource, UITableViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource,QLPreviewControllerDataSource{

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var ButtomView: UIView!
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    //  チェックされたセルの位置を保存しておく辞書をプロパティに宣言
    var selectedCells:[Bool]=[Bool]()
    
    // セルに表示するテキスト
    var shiftlist: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.SetUpCollectionView()
        
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
        
        if(DBmethod().DBRecordCount(ShiftImportHistoryDB) == 0){
            no_dataimageview.alpha = 1.0
        }else{
            no_dataimageview.alpha = 0.0
        }
        
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
    
    override func viewDidAppear(animated: Bool) {
        self.myCollectionView.reloadData()
    }
    
    //表示ボタンを押した時に呼ばれる関数
    @IBAction func TapShowButton(sender: AnyObject) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        appDelegate.selectedcell = self.selectedCells
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.myCollectionView.alpha = 1.0
            self.view.bringSubviewToFront(self.myCollectionView)
            self.myCollectionView.reloadData()
        })
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
    
    var myCollectionView: UICollectionView!
    let no_dataimageview = UIImageView()
    
    func SetUpCollectionView(){
        no_dataimageview.image = UIImage(named: "../no_data.png")
        no_dataimageview.frame = CGRectMake(self.view.frame.width/2-250, self.view.frame.height/2-250, 500, 500)
        if(DBmethod().DBRecordCount(ShiftImportHistoryDB) == 0){
            no_dataimageview.alpha = 1.0
        }else{
            no_dataimageview.alpha = 0.0
        }
        
        // CollectionViewのレイアウトを生成.
        let layout = UICollectionViewFlowLayout()
        
        // Cell一つ一つの大きさ.
        layout.itemSize = CGSizeMake(self.view.frame.width, 270)
        
        // Cellのマージン.
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 90, 0)
        layout.minimumLineSpacing = 100.0
        
        // セクション毎のヘッダーサイズ.
        layout.headerReferenceSize = CGSizeMake(100,30)
        
        // CollectionViewを生成.
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        // Cellに使われるクラスを登録.
        myCollectionView.registerClass(CustomUICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        myCollectionView.backgroundColor = UIColor.blackColor()
        myCollectionView.alpha = 0.0
        
        let closeview = UIView()
        closeview.frame = CGRectMake(0, myCollectionView.frame.height-130, myCollectionView.frame.width, 70)
        closeview.backgroundColor = UIColor.hex("E6E6E6", alpha: 0.8)
        
        let closebutton = UIButton()
        closebutton.frame = CGRectMake(closeview.frame.width/2-37, 550, 74, 30)
        closebutton.setTitle("閉じる", forState: .Normal)
        closebutton.addTarget(self, action: "TapCloseButton:", forControlEvents: .TouchUpInside)
        closebutton.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0), forState: .Normal)
        
        myCollectionView.addSubview(no_dataimageview)
        myCollectionView.addSubview(closeview)
        myCollectionView.addSubview(closebutton)
        
        self.view.addSubview(myCollectionView)
    }
    
    func TapCloseButton(sender: UIButton){
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.myCollectionView.alpha = 0.0
        })
    }
    
    //Cellの総数を返す
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        
        for(var i = 0; i < appDelegate.selectedcell.count; i++){
            if(appDelegate.selectedcell[i] == true){
                count++
            }
        }
        return count
    }
    
    //Cellに値を設定する
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var shiftlist: [String] = []
        let count = DBmethod().DBRecordCount(ShiftImportHistoryDB)-1
        
        if(DBmethod().DBRecordCount(ShiftImportHistoryDB) != 0){
            for(var i = 0; i <= count; i++){
                if(appDelegate.selectedcell[i]){
                    let historydate = DBmethod().ShiftImportHistoryDBGet()[count-i].date
                    let historyname = DBmethod().ShiftImportHistoryDBGet()[count-i].name
                    shiftlist.append(historydate + "     " + historyname)
                }
            }
        }
        
        let cell : CustomUICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! CustomUICollectionViewCell
        
        cell.textLabel?.text = shiftlist[indexPath.row]
        cell.ql.dataSource = self
        cell.ql.currentPreviewItemIndex = indexPath.row
        
        return cell
    }
    
    //プレビューでの表示数
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
        return 1
    }
    
    //プレビューで表示するファイルの設定
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem{
        var shiftlist: [String] = []
        let count = DBmethod().DBRecordCount(ShiftImportHistoryDB)-1
        
        if(DBmethod().DBRecordCount(ShiftImportHistoryDB) != 0){
            for(var i = 0; i <= count; i++){
                if(appDelegate.selectedcell[i]){
                    let historyname = DBmethod().ShiftImportHistoryDBGet()[count-i].name
                    shiftlist.append(historyname)
                }
            }
        }
        
        let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
        let url = Libralypath + "/" + shiftlist[index]
        
        //        let documentPath: String = NSBundle.mainBundle().pathForResource("aaa", ofType: "xlsx")!
        let doc = NSURL(fileURLWithPath: url)
        return doc
    }
}
