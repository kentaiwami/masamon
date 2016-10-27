//
//  FileBrowse.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/05/06.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class FileBrowse: UIViewController, UIWebViewDelegate{
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    var myWebView = UIWebView()
    var myPDFurl =  NSURL()
    var myRequest = NSURLRequest()
    var myIndiator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PDFを開くためのWebViewを生成.
        myWebView = UIWebView(frame: CGRectMake(0, 64, self.view.frame.width, self.view.frame.height))
        myWebView.delegate = self
        myWebView.scalesPageToFit = true
        
        // URLReqestを生成.
        let Libralypath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String
        let filePath = Libralypath + "/" + appDelegate.selectedcellname
        
        myPDFurl = NSURL.fileURLWithPath(filePath)
        myRequest = NSURLRequest(URL: myPDFurl)
        
        // ページ読み込み中に表示させるインジケータを生成.
        myIndiator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        myIndiator.center = self.view.center
        myIndiator.hidesWhenStopped = true
        myIndiator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // WebViewのLoad開始.
        myWebView.loadRequest(myRequest)
        
        // viewにWebViewを追加.
        self.view.addSubview(myWebView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.title = appDelegate.selectedcellname
    }
    
    func startAnimation() {
        
        // NetworkActivityIndicatorを表示.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // UIACtivityIndicatorを表示.
        if !myIndiator.isAnimating() {
            myIndiator.startAnimating()
        }
        
        // viewにインジケータを追加.
        self.view.addSubview(myIndiator)
    }
    
    func stopAnimation() {
        // NetworkActivityIndicatorを非表示.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // UIACtivityIndicatorを非表示.
        if myIndiator.isAnimating() {
            myIndiator.stopAnimating()
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        startAnimation()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        stopAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func TapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
