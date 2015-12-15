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
        layout.itemSize = CGSizeMake(50, 50)
        
        // Cellのマージン.
        layout.sectionInset = UIEdgeInsetsMake(16, 16, 32, 16)
        
        // セクション毎のヘッダーサイズ.
        layout.headerReferenceSize = CGSizeMake(100,30)
        
        // CollectionViewを生成.
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        // Cellに使われるクラスを登録.
        myCollectionView.registerClass(CustomUICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        self.view.addSubview(myCollectionView)
        
//        // ScrollViewを生成.
//        myScrollView = UIScrollView()
//        
//        // ScrollViewの大きさを設定する.
//        myScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
//        
//        // UIImageに画像を設定する.
//        let myImage = UIImage(named: "c014.jpg")!
//        
//        // UIImageViewを生成する.
//        let myImageView = UIImageView()
//        
//        // myImageViewのimageにmyImageを設定する.
//        myImageView.image = myImage
//        
//        // frameの値を設定する.
//        myImageView.frame = CGRectMake(0, 0, myImage.size.width, myImage.size.height)
//        
//        // ScrollViewにmyImageViewを追加する.
//        myScrollView.addSubview(myImageView)
//        
//        // ScrollViewにcontentSizeを設定する.
//        myScrollView.contentSize = CGSizeMake(myImageView.frame.size.width, myImageView.frame.size.height)
//        
//        // ViewにScrollViewをAddする.
//        self.view.addSubview(myScrollView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
    Cellが選択された際に呼び出される
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print("Num: \(indexPath.row)")
        
    }
    
    /*
    Cellの総数を返す
    */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    /*
    Cellに値を設定する
    */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : CustomUICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! CustomUICollectionViewCell
        cell.textLabel?.text = indexPath.row.description
        
        return cell
    }
}
