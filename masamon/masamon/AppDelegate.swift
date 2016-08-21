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
    
    /*AppDelegateで使用*/
    var window: UIWindow?
    var fileURL = ""                            //ファイルをInboxに保存した時のURLを記録
    
    /*ShiftImportとMonthlySalaryShowで使用*/
    var filesavealert = false                   //ファイルの保存が行われたかを記録
    var filename = ""                           //ユーザが取り込み時に入力したファイル名を記録
    var update = true                           //シフトの取り込みが上書きかを記録
    
    /*ShiftGalleryTableで使用*/
    var selectedcellname = ""               //ShiftGalleryTableで選択をしたセルを記録

    /*MonthlySalaryShowで使用*/
    var errorshiftnamefastcount = 0             //シフトの認識に失敗した場合の最初の失敗数を格納しておく変数
    var errorstaffnamefastcount = 0             //スタッフ名の認識に失敗した場合に、最初の失敗数を格納しておく変数

    /*MonthlySalaryShowとXLSXmethodで使用*/
    var errorshiftnamexlsx: [String] = []       //新規シフト体制名が含まれていた場合に格納する
    
    var unknownshiftname: [String] = []
    
    /*各画面で使用*/
    var screennumber = 0    //シフト：0, カレンダー：1, 設定：2,　履歴：3
    
    /*VideoViewControllerで使用*/
    var thumbnailnumber = 0     //タップしたサムネイルの番号を格納
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        fileURL = ""
        fileURL = String(url.path!)
        
        //DBへパスを記録
        let filepathrecord = FilePathTmpDB()
        filepathrecord.id = 0
        filepathrecord.path = fileURL
        DBmethod().AddandUpdate(filepathrecord,update: true)
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //InboxFileCountに空レコード(ダミー)を追加
        if DBmethod().DBRecordCount(InboxFileCountDB) == 0 {
            //レコードを追加
            let InboxFileCountRecord = InboxFileCountDB()
            InboxFileCountRecord.id = 0
            InboxFileCountRecord.counts = 0
            DBmethod().AddandUpdate(InboxFileCountRecord,update: true)
        }
        
        //FilePathTmpに空レコード(ダミー)を追加
        if DBmethod().DBRecordCount(FilePathTmpDB) == 0 {
            let FilePathTmpRecord = FilePathTmpDB()
            FilePathTmpRecord.id = 0
            FilePathTmpRecord.path = "nil"
            DBmethod().AddandUpdate(FilePathTmpRecord,update: true)
        }
        
        //シフト体制データ
        let shiftnamepattern = ["早","早M","早カ","はや","中","中2","中3","遅","遅M","遅カ","公","夏","有","不明"]

        if DBmethod().DBRecordCount(ShiftSystemDB) == 0 {
            for i in 0 ..< shiftnamepattern.count{
                let ShiftSystemRecord = ShiftSystemDB()
                var gid = 0
                
                switch(i){
                //早番
                case 0...3:
                    gid = 0
                    ShiftSystemRecord.starttime = 8.0
                    ShiftSystemRecord.endtime = 16.5
                    
                //中1番
                case 4:
                    gid = 1
                    ShiftSystemRecord.starttime = 12.0
                    ShiftSystemRecord.endtime = 20.5
                    
                //中2番
                case 5:
                    gid = 2
                    ShiftSystemRecord.starttime = 13.5
                    ShiftSystemRecord.endtime = 22.0
                    
                //中3番
                case 6:
                    gid = 3
                    ShiftSystemRecord.starttime = 14.5
                    ShiftSystemRecord.endtime = 23.0
                    
                //遅番
                case 7...9:
                    gid = 4
                    ShiftSystemRecord.starttime = 16.0
                    ShiftSystemRecord.endtime = 24.5
                    
                //休み
                case 10...12:
                    gid = 6
                    ShiftSystemRecord.starttime = 0.0
                    ShiftSystemRecord.endtime = 0.0
                    
                //その他
                default:
                    gid = 5
                    ShiftSystemRecord.starttime = 0.0
                    ShiftSystemRecord.endtime = 0.0
                    break
                }
                
                ShiftSystemRecord.id = i
                ShiftSystemRecord.groupid = gid
                ShiftSystemRecord.name = shiftnamepattern[i]
                
                DBmethod().AddandUpdate(ShiftSystemRecord, update: true)
            }
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

