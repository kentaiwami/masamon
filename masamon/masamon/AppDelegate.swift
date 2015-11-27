//
//  AppDelegate.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var fileURL = ""
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        fileURL = String(url)
        
        print(fileURL)
        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        var flg: Bool //分岐条件
        
        let storyboard:UIStoryboard =  UIStoryboard(name: "Main",bundle:nil)
        var viewController:UIViewController
        
        if(self.fileURL.isEmpty){
            flg = true
        }else{
            flg = false
        }
        
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        
        print(documentsPath)
        let unko = String(documentsPath) + "Inbox/"
        print(unko)
        
//        let fileMgr = NSFileManager.defaultManager()
        
//        if let enumerator: NSDirectoryEnumerator = fileMgr.enumeratorAtPath(String(unko)) {
//            while let element = enumerator.nextObject() as? String {
//                print(element)
//            }
//        }
        
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath(NSHomeDirectory())
        filemanager.enumeratorAtPath()
        while let file = files?.nextObject() {
            print(file)
        }
        
//        // ドキュメントフォルダのパス文字列を取得
//        var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        var aDirectory: String = paths[0] as! String
//        var error: NSErrorPointer
//        // zipファイルを列挙してみる
//        var suffix: String = ".zip"
//        // ファイルマネージャクラスを取得
//        var fileManager: NSFileManager = NSFileManager.defaultManager()
//        // ドキュメントディレクトリ直下の.zipで終わるファイル名のファイルを列挙
//        do{
//            for path: String in try fileManager.contentsOfDirectoryAtPath(aDirectory){
//                var attrs: [NSObject : AnyObject] = try fileManager.attributesOfItemAtPath(path)
//                // レギュラーファイルで且つ.zipで終わるもの
//                if .Regular.compare(attrs[NSFileType]) && path.hasSuffix(suffix) {
//                    // ファイル名だけなので、ディレクトリへのパスにアペンド
//                    var fullPath: String = documentsDirectory.stringByAppendingPathComponent(path)
//                    var fullPath1: String =
//                    /*do somthing to fullPath*/
//                }
//                
//            }
//        }catch{
//            print("Error")
//        }
        
        //表示するビューコントローラーを指定
        if  flg {
            viewController = storyboard.instantiateViewControllerWithIdentifier("firstViewController") as UIViewController
        } else {
            viewController = storyboard.instantiateViewControllerWithIdentifier("secondViewController") as UIViewController
        }
        
        
        window?.rootViewController = viewController
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

