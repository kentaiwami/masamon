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
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 30, 0)
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
        return DBmethod().DBRecordCount(ShiftImportHistoryDB)
    }
    
    //Cellに値を設定する
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let shiftimportdbarray = DBmethod().ShiftImportHistoryDBGet()
        
        let cell : CustomUICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! CustomUICollectionViewCell
        cell.textLabel?.text = shiftimportdbarray[(shiftimportdbarray.count-1) - indexPath.row].date  + "     " + shiftimportdbarray[(shiftimportdbarray.count-1) - indexPath.row].name
        cell.ql.dataSource = self
        cell.ql.currentPreviewItemIndex = indexPath.row

        return cell
    }
    
    //プレビューでの表示数
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
        return DBmethod().DBRecordCount(ShiftImportHistoryDB)
    }
    
    //プレビューで表示するファイルの設定
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem{
        let shiftimportdbarray = DBmethod().ShiftImportHistoryDBGet()
        
        let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
        let url = Libralypath + "/" + shiftimportdbarray[index].name
        let doc = NSURL(fileURLWithPath: url)
        return doc
    }
    
}
