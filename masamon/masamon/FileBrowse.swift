//
//  FileBrowse.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/05/06.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit

class FileBrowse: UIViewController, UIWebViewDelegate{
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    var myWebView = UIWebView()
//    var myPDFurl =  URL()
//    var myRequest = URLRequest(url: "")
    var myIndiator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PDFを開くためのWebViewを生成.
        myWebView = UIWebView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height))
        myWebView.delegate = self
        myWebView.scalesPageToFit = true
        
        // URLReqestを生成.
        let Libralypath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
        let filePath = Libralypath + "/" + appDelegate.selectedcellname
        
        let myPDFurl = URL(fileURLWithPath: filePath)
        let myRequest = URLRequest(url: myPDFurl)
        
        // ページ読み込み中に表示させるインジケータを生成.
        myIndiator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndiator.center = self.view.center
        myIndiator.hidesWhenStopped = true
        myIndiator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // UIACtivityIndicatorを表示.
        if !myIndiator.isAnimating {
            myIndiator.startAnimating()
        }
        
        // viewにインジケータを追加.
        self.view.addSubview(myIndiator)
    }
    
    func stopAnimation() {
        // NetworkActivityIndicatorを非表示.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // UIACtivityIndicatorを非表示.
        if myIndiator.isAnimating {
            myIndiator.stopAnimating()
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        startAnimation()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        stopAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func TapBackButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
