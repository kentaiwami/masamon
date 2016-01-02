//
//  ShiftGalleryTable.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/02.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class ShiftGalleryTable: UIViewController {

    @IBOutlet weak var ButtomView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ButtomView.alpha = 0.8

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func TapShowButton(sender: AnyObject) {
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShiftGallery")
        self.presentViewController( targetViewController, animated: true, completion: nil)
    }
}
