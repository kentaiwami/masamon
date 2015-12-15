//
//  shiftgallery.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/15.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ShiftGallery: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource{
    
    var myCollectionView : UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CollectionViewのレイアウトを生成.
        let layout = UICollectionViewFlowLayout()
        
        // Cell一つ一つの大きさ.
        layout.itemSize = CGSizeMake(self.view.frame.width, 270)
        
        // Cellのマージン.
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 30, 0)
//        layout.minimumInteritemSpacing = 130.0
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
    }
    
    override func viewDidAppear(animated: Bool) {
        self.myCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Cellが選択された際に呼び出される
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print("Num: \(indexPath.row)")
        
    }
    
    //Cellの総数を返す
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DBmethod().DBRecordCount(ShiftImportHistoryDB)
    }
    
    //Cellに値を設定する
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let shiftimportdbarray = DBmethod().ShiftImportHistoryDBGet()
        
        let cell : CustomUICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! CustomUICollectionViewCell
        cell.textLabel?.text = indexPath.row.description
        cell.textLabel?.text = shiftimportdbarray[(shiftimportdbarray.count-1) - indexPath.row].date  + "     " + shiftimportdbarray[(shiftimportdbarray.count-1) - indexPath.row].name
        
        return cell
    }
}
