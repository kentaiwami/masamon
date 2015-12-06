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
    var filesavealert = false
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        fileURL = ""
        fileURL = String(url)
        
        //DBへパスを記録
        let filepathrecord = FilePathTmpDB()
        filepathrecord.id = 0
        filepathrecord.path = fileURL
        DBmethod().AddandUpdate(filepathrecord,update: true)
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //InboxFileCountに空レコード(ダミー)を追加
        if(DBmethod().DBRecordCount(InboxFileCountDB) == 0){
            //レコードを追加
            let InboxFileCountRecord = InboxFileCountDB()
            InboxFileCountRecord.id = 0
            InboxFileCountRecord.counts = 0
            DBmethod().AddandUpdate(InboxFileCountRecord,update: true)
        }
        
        //FilePathTmpに空レコード(ダミー)を追加
        if(DBmethod().DBRecordCount(FilePathTmpDB) == 0){
            let FilePathTmpRecord = FilePathTmpDB()
            FilePathTmpRecord.id = 0
            FilePathTmpRecord.path = "nil"
            DBmethod().AddandUpdate(FilePathTmpRecord,update: true)
        }
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

