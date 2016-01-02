//
//  ShiftGalleryTable.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/02.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class ShiftGalleryTable: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func TapShowButton(sender: AnyObject) {
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShiftGallery")
        self.presentViewController( targetViewController, animated: true, completion: nil)
    }
}
