//
//  ShiftGalleryTable.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/02.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class FileBrowse: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableview: UITableView!
    
    let closeview = UIView()
    let closebutton = UIButton()
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    // セルに表示するテキスト
    var shiftlist: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.allowsMultipleSelection = true
        
        if DBmethod().DBRecordCount(ShiftImportHistoryDB) != 0 {
            for i in (0 ... DBmethod().DBRecordCount(ShiftImportHistoryDB)-1).reverse(){
                let historydate = DBmethod().ShiftImportHistoryDBGet()[i].date
                let historyname = DBmethod().ShiftImportHistoryDBGet()[i].name
                shiftlist.append(historydate + "   " + historyname)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
                
        shiftlist.removeAll()
        
        if DBmethod().DBRecordCount(ShiftImportHistoryDB) != 0 {
            for i in (0 ... DBmethod().DBRecordCount(ShiftImportHistoryDB)-1).reverse(){
                let historydate = DBmethod().ShiftImportHistoryDBGet()[i].date
                let historyname = DBmethod().ShiftImportHistoryDBGet()[i].name
                shiftlist.append(historydate + "   " + historyname)
            }
        }
        
        self.tableview.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        appDelegate.screennumber = 3
    }
    
    var flag = false
    //表示ボタンを押した時に呼ばれる関数
    @IBAction func TapShowButton(sender: AnyObject) {
        
        //1つでも選択されていたらtrue
        if flag {
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
//            appDelegate.selectedcell = self.selectedCells
            
        }else{          //1つも選択されていない場合
            let alertController = UIAlertController(title: "履歴表示エラー", message: "シフトが1つも選択されていません", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)

        }
    }
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftlist.count
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = shiftlist[indexPath.row]
//        cell.textLabel?.textColor = UIColor.whiteColor()
 
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    //セルが選択された時に呼ばれる
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableview.cellForRowAtIndexPath(indexPath)
//        cell?.backgroundColor = UIColor.hex("AFAFAF", alpha: 1.0)
    }
    
    //セルの選択が解除された時に呼ばれる
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableview.cellForRowAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.clearColor()
    }
    
//    func SetUpCollectionView(){
//        
//        // CollectionViewのレイアウトを生成.
//        let layout = UICollectionViewFlowLayout()
//        
//        // Cell一つ一つの大きさ.
//        layout.itemSize = CGSizeMake(self.view.frame.width, 270)
//        
//        // Cellのマージン.
//        layout.sectionInset = UIEdgeInsetsMake(0, 0, 160, 0)
//        layout.minimumLineSpacing = 100.0
//        
//        // セクション毎のヘッダーサイズ.
//        layout.headerReferenceSize = CGSizeMake(100,30)
//        
//        // CollectionViewを生成.
//        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
//        
//        // Cellに使われるクラスを登録.
//        myCollectionView.registerClass(CustomUICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
//        
//        myCollectionView.delegate = self
//        myCollectionView.dataSource = self
//        
//        myCollectionView.backgroundColor = UIColor.blackColor()
//        myCollectionView.alpha = 0.0
//        
//        closeview.frame = CGRectMake(0, myCollectionView.frame.height-130, myCollectionView.frame.width, 70)
//        closeview.backgroundColor = UIColor.hex("E6E6E6", alpha: 0.8)
//        
//        closebutton.frame = CGRectMake(closeview.frame.width/2-37, 550, 74, 30)
//        closebutton.setTitle("閉じる", forState: .Normal)
//        closebutton.addTarget(self, action: #selector(FileBrowse.TapCloseButton(_:)), forControlEvents: .TouchUpInside)
//        closebutton.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0), forState: .Normal)
//        
//        myCollectionView.addSubview(closeview)
//        myCollectionView.addSubview(closebutton)
//        
//        self.view.addSubview(myCollectionView)
//    }
    
//    func TapCloseButton(sender: UIButton){
//        
//        UIView.animateWithDuration(0.2, animations: { () -> Void in
//            self.myCollectionView.alpha = 0.0
//        })
//    }
    
//    //Cellの総数を返す
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        var count = 0
//        
//        for i in 0 ..< appDelegate.selectedcell.count{
//            if appDelegate.selectedcell[i] == true {
//                count += 1
//            }
//        }
//        return count
//    }
    
//    //Cellに値を設定する
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
//        var shiftlist: [String] = []
//        let count = DBmethod().DBRecordCount(ShiftImportHistoryDB)-1
//        
//        if DBmethod().DBRecordCount(ShiftImportHistoryDB) != 0 {
//            for i in 0 ... count{
//                if appDelegate.selectedcell[i] {
//                    let historydate = DBmethod().ShiftImportHistoryDBGet()[count-i].date
//                    let historyname = DBmethod().ShiftImportHistoryDBGet()[count-i].name
//                    shiftlist.append(historydate + "     " + historyname)
//                }
//            }
//        }
//        
//        let cell : CustomUICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! CustomUICollectionViewCell
//        
//        cell.textLabel?.text = shiftlist[indexPath.row]
//        cell.ql.dataSource = self
//        cell.ql.currentPreviewItemIndex = indexPath.row
//
//        return cell
//    }
    
//    //プレビューでの表示数
//    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
//        return 1
//    }
    
//    //プレビューで表示するファイルの設定
//    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem{
//        var shiftlist: [String] = []
//        let count = DBmethod().DBRecordCount(ShiftImportHistoryDB)-1
//        
//        if DBmethod().DBRecordCount(ShiftImportHistoryDB) != 0 {
//            for i in 0 ... count{
//                if appDelegate.selectedcell[i] {
//                    let historyname = DBmethod().ShiftImportHistoryDBGet()[count-i].name
//                    shiftlist.append(historyname)
//                }
//            }
//        }
//        
//        let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
//        let url = Libralypath + "/" + shiftlist[index]
//        
//        //        let documentPath: String = NSBundle.mainBundle().pathForResource("aaa", ofType: "xlsx")!
//        let doc = NSURL(fileURLWithPath: url)
//        return doc
//    }
    
    //スクロールした際に動作する関数
    var scrollBeginingPoint: CGPoint!
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollBeginingPoint = scrollView.contentOffset;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset;
        
        //表示ボタンを押してviewを表示した時だけ移動するようにする
        if flag {
            closeview.center.y = currentPoint.y + self.view.frame.height-30
            closebutton.center.y = currentPoint.y + self.view.frame.height-30
        }else{
            closeview.center.y = closeview.center.y
            closebutton.center.y = closebutton.center.y

        }
    }
}
