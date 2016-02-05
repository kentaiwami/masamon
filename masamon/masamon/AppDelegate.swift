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
    var selectedcell: [Bool] = []               //ShiftGalleryTableで選択をしたセルを記録

    /*MonthlySalaryShowで使用*/
    var errorshiftnamefastcount = 0             //シフトの認識に失敗した場合の最初の失敗数を格納しておく変数
    var errorstaffnamefastcount = 0             //スタッフ名の認識に失敗した場合に、最初の失敗数を格納しておく変数

    /*MonthlySalaryShowとPDFmethodで使用*/
    var errorstaffnamepdf: [String] = []           //スタッフ名の認識に失敗した場合に、スタッフ名が書かれた1行を格納する
    var errorshiftnamepdf: [String:String] = [:]   //シフトの認識に失敗した場合に、スタッフ名と認識に失敗した文字列を格納する
    var skipstaff: [String] = []                //シフトの認識が完了しているが、認識エラーと出てしまうスタッフ名を格納する

    /*MonthlySalaryShowとXLSXmethodで使用*/
    var errorshiftnamexlsx: [String] = []       //新規シフト体制名が含まれていた場合に格納する
    
    
    /*各画面で使用*/
    var screennumber = 0    //シフト：0, カレンダー：1, 設定：2,　履歴：3
    
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let monthlysalaryshow = storyboard.instantiateViewControllerWithIdentifier("MonthlySalaryShow") as! MonthlySalaryShow
        let setting = storyboard.instantiateViewControllerWithIdentifier("Setting") as! Setting
        let shiftgallerytable = storyboard.instantiateViewControllerWithIdentifier("ShiftGalleryTable") as! ShiftGalleryTable
        let calender = storyboard.instantiateViewControllerWithIdentifier("CalenderViewController") as! CalenderViewController
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let pageController:UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        
        let navigationController:SwipeBetweenViewControllers = SwipeBetweenViewControllers(rootViewController: pageController)
        
        // Override point for customization after application launch.
        let monthlysalaryshowview:UIViewController = monthlysalaryshow
        let calenderview:UIViewController = calender
        let shiftgallerytableview:UIViewController = shiftgallerytable
        let settingview:UIViewController = setting
        
        monthlysalaryshowview.view.backgroundColor = UIColor.blackColor()
        calenderview.view.backgroundColor = UIColor.hex("696969", alpha: 0.5)
        
        navigationController.viewControllerArray = [monthlysalaryshowview,calenderview,settingview,shiftgallerytableview]
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
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
        
        //シフト体制データ
        let shiftnamepattern = ["早","早Ｍ","早カ","はや","中","中2","中3","遅","遅Ｍ","遅カ","公","夏","有"]
        let shiftstartpattern = [8.0,8.0,8.0,8.0,12.0,13.5,14.5,16.0,16.0,16.0,99.9,99.9,99.9]
        let shiftendpattern = [16.5,16.5,16.5,16.5,20.5,22.0,23.0,24.5,24.5,24.5,99.9,99.9,99.9]

        if(DBmethod().DBRecordCount(ShiftSystemDB) == 0){
            for(var i = 0; i < shiftnamepattern.count; i++){
                var gid = 0
                
                switch(i){
                //早番
                case 0...3:
                    gid = 0
                    
                //中1番
                case 4:
                    gid = 1
                
                //中2番
                case 5:
                    gid = 2
                    
                //中3番
                case 6:
                    gid = 3
                    
                //遅番
                case 7...9:
                    gid = 4
                    
                //休み
                default:
                    gid = 6
                }
                
                let ShiftSystemRecord = ShiftSystemDB()
                ShiftSystemRecord.id = i
                ShiftSystemRecord.groupid = gid
                ShiftSystemRecord.name = shiftnamepattern[i]
                ShiftSystemRecord.starttime = shiftstartpattern[i]
                ShiftSystemRecord.endtime = shiftendpattern[i]
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

