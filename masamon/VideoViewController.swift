//
//  VideoViewController.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/02/20.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoViewController: AVPlayerViewController {

    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var filename = ""
        
        let mainbundle = Bundle.main
        
        if appDelegate.thumbnailnumber == 1 {
            filename = "video1"
        }else{
            filename = "video2"
        }
        
        let url = mainbundle.path(forResource: filename, ofType: "mp4")!
        
        let nsurl = URL(fileURLWithPath: url)
        let playerItem = AVPlayerItem(url: nsurl)

        self.player = AVPlayer(playerItem: playerItem)
        player!.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
