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
        viewswitch()
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
    
    func viewswitch(){
        if(DBmethod().DBRecordCount(InboxFileCount) == 0){
            //レコードを追加
            let InboxFileCountRecord = InboxFileCount()
            InboxFileCountRecord.id = 0
            InboxFileCountRecord.counts = 0
            DBmethod().AddandUpdate(InboxFileCountRecord)
        }else{
            //何もしない
        }
        
        let storyboard:UIStoryboard =  UIStoryboard(name: "Main",bundle:nil)
        var viewController:UIViewController
        
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath(NSHomeDirectory() + "/Documents/Inbox")
        var filecount = 0
        while let _ = files?.nextObject() {
            filecount++
        }
        
        //表示するビューコントローラーを指定
        if(DBmethod().InboxFileCountsGet() < filecount){   //ファイル数が増えていたら(新規でダウンロードしていたら)
            //ファイルの数をデータベースへ記録
            let InboxFileCountRecord = InboxFileCount()
            InboxFileCountRecord.id = 0
            InboxFileCountRecord.counts = filecount
            DBmethod().AddandUpdate(InboxFileCountRecord)
            
            viewController = storyboard.instantiateViewControllerWithIdentifier("firstViewController") as UIViewController
        }else{
            viewController = storyboard.instantiateViewControllerWithIdentifier("MonthlySalaryShow") as UIViewController
        }
        
        
        window?.rootViewController = viewController
    }
}

