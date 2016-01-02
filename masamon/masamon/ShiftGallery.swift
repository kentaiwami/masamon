//
//  shiftgallery.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/15.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import QuickLook

class ShiftGallery: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource,QLPreviewControllerDataSource{
    
    var myCollectionView : UICollectionView!
    let no_dataimageview = UIImageView()
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        self.view.addSubview(myCollectionView)
        self.view.addSubview(no_dataimageview)
        
        self.view.sendSubviewToBack(myCollectionView)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.myCollectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        if(DBmethod().DBRecordCount(ShiftImportHistoryDB) == 0){
            no_dataimageview.alpha = 1.0
        }else{
            no_dataimageview.alpha = 0.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    //閉じるボタンを押した時に動作する

}
