//
//  Video.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/02/20.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class Video: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let imagepath = ["../images/thumbnail1.png","../images/thumbnail2.png"]
        let position = [-120,180]
        
        for(var i = 0; i < 2; i++){
            let view = UIButton()
            let image = UIImage(named: imagepath[i])
            view.setImage(image, forState: .Normal)
            view.frame = CGRectMake(0, 0, 300, 200)
            view.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2+CGFloat(position[i]))
            view.contentMode = UIViewContentMode.ScaleAspectFit
            
            self.view.addSubview(view)
        }
        
    }

    @IBAction func TapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
