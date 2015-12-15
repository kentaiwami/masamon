//
//  CustomUICollectionViewCell.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/15.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class CustomUICollectionViewCell: UICollectionViewCell {
 
    var imageview: UIImageView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // UILabelを生成.
//        textLabel = UILabel(frame: CGRectMake(0, 0, frame.width, frame.height))
//        textLabel?.text = "nil"
//        textLabel?.backgroundColor = UIColor.whiteColor()
//        textLabel?.textAlignment = NSTextAlignment.Center
        
        //imageviewを作成
        imageview = UIImageView(frame: CGRectMake(0, 0, frame.width, frame.height))
        imageview?.image = UIImage(named: "../images/BBB.png")
        
       // imageview?.backgroundColor = UIColor.blueColor()
        
        // Cellに追加.
      //  self.contentView.addSubview(view!)
        self.contentView.addSubview(imageview!)
    }
}
