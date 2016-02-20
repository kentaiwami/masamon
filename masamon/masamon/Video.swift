//
//  Video.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/02/20.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import AVKit

class Video: UIViewController {

    var myMoviePlayerView : AVPlayerViewController!
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        let imagepath = ["../images/thumbnail1.png","../images/thumbnail2.png"]
        let position = [-120,180]
        
        for(var i = 0; i < 2; i++){
            let thumbnailbutton = UIButton()
            let image = UIImage(named: imagepath[i])
            thumbnailbutton.setImage(image, forState: .Normal)
            thumbnailbutton.frame = CGRectMake(0, 0, 300, 200)
            thumbnailbutton.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2+CGFloat(position[i]))
            thumbnailbutton.tag = i+1
            thumbnailbutton.addTarget(self, action: "TapThumbnail:", forControlEvents: .TouchUpInside)
            thumbnailbutton.layer.masksToBounds = true
            thumbnailbutton.layer.cornerRadius = 15
            thumbnailbutton.clipsToBounds = true
            
            //2つ目の動画を作成していないため、ボタンを無効化する
            if(i == 1){
                thumbnailbutton.enabled = false
            }
            
            self.view.addSubview(thumbnailbutton)
        }
        
    }

    @IBAction func TapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func TapThumbnail(sender: UIButton) {
        switch(sender.tag){
        case 1:
            appDelegate.thumbnailnumber = 1
            
        default:
            appDelegate.thumbnailnumber = 2
            break
        }
        
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("VideoViewController")
        self.presentViewController( targetViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
