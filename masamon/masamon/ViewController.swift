//
//  ViewController.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "../images/Menu-50.png")! as UIImage
        let imageButton   = UIButton()
        imageButton.tag = 0
        imageButton.frame = CGRectMake(0, 0, 128, 128)
        imageButton.layer.position = CGPoint(x: self.view.frame.width-30, y:60)
        imageButton.setImage(image, forState: .Normal)
        imageButton.addTarget(self, action: "MenuButtontapped:", forControlEvents:.TouchUpInside)
        
        self.view.addSubview(imageButton)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func MenuButtontapped(sender: UIButton){
        print("MenuButtonTapped")
    }

}

