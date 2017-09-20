//
//  GradientCircularProgress.swift
//  GradientCircularProgress
//
//  Created by keygx on 2015/07/29.
//  Copyright (c) 2015年 keygx. All rights reserved.
//

import UIKit

internal var baseWindow: BaseWindow?

open class GradientCircularProgress {
    
    fileprivate var progressViewController: ProgressViewController?
    fileprivate var progressView: ProgressView?
    fileprivate var property: Property?
    
    open var isAvailable: Bool = false
    
    public init() {}
}

// MARK: Common
extension GradientCircularProgress {
    
    public func updateMessage(_ message: String) {
        if !isAvailable {
            return
        }
        
        // Use addSubView
        if let v = progressView {
            v.updateMessage(message)
        }
        
        // Use UIWindow
        if let vc = progressViewController {
            vc.updateMessage(message)
        }
    }
    
    public func updateRatio(_ ratio: CGFloat) {
        if !isAvailable {
            return
        }
        
        // Use addSubView
        if let v = progressView {
            v.ratio = ratio
        }
        
        // Use UIWindow
        if let vc = progressViewController {
            vc.ratio = ratio
        }
    }
}

// MARK: Use UIWindow
extension GradientCircularProgress {
    
    public func showAtRatio(_ display: Bool = true, style: StyleProperty = Style()) {
        if isAvailable {
            return
        }
        isAvailable = true
        property = Property(style: style)
        
        getProgressAtRatio(display, style: style)
    }
    
    fileprivate func getProgressAtRatio(_ display: Bool, style: StyleProperty) {
        baseWindow = BaseWindow()
        progressViewController = ProgressViewController()
        
        guard let win = baseWindow, let vc = progressViewController else {
            return
        }
        
        win.rootViewController = vc
        win.backgroundColor = UIColor.clear
        vc.arc(display, style: style)
    }
    
    public func show(_ style: StyleProperty = Style()) {
        if isAvailable {
            return
        }
        isAvailable = true
        property = Property(style: style)
        
        getProgress(nil, style: style)
    }
    
    public func show(_ message: String, style: StyleProperty = Style()) {
        if isAvailable {
            return
        }
        isAvailable = true
        property = Property(style: style)
        
        getProgress(message, style: style)
    }
    
    fileprivate func getProgress(_ message: String?, style: StyleProperty) {
        baseWindow = BaseWindow()
        progressViewController = ProgressViewController()
        
        guard let win = baseWindow, let vc = progressViewController else {
            return
        }
        
        win.rootViewController = vc
        win.backgroundColor = UIColor.clear
        vc.circle(message, style: style)
    }
    
    public func dismiss() {
        if !isAvailable {
            return
        }
        
        guard let prop = property else {
            return
        }
        
        if let vc = progressViewController {
            vc.dismiss(prop.dismissTimeInterval!)
        }
        
        cleanup(prop.dismissTimeInterval!, completionHandler: nil)
        
    }
    
    public func dismiss(_ completionHandler: @escaping () -> Void) -> () {
        if !isAvailable {
            return
        }
        
        guard let prop = property else {
            return
        }
        
        if let vc = progressViewController {
            vc.dismiss(prop.dismissTimeInterval!)
        }
        
        cleanup(prop.dismissTimeInterval!) {
            completionHandler()
        }
    }
    
    fileprivate func cleanup(_ t: Double, completionHandler: (() -> Void)?) {
        let delay = t * Double(NSEC_PER_SEC)
        let time  = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            guard let win = baseWindow else {
                return
            }
            
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    win.alpha = 0
                },
                completion: { [weak self] finished in
                    self?.progressViewController = nil
                    win.isHidden = true
                    win.rootViewController = nil
                    baseWindow = nil
                    self?.property = nil
                    self?.isAvailable = false
                    guard let completionHandler = completionHandler else {
                        return
                    }
                    completionHandler()
                }
            )
        }
    }
}

// MARK: Use addSubView
extension GradientCircularProgress {
    
    public func showAtRatio(_ frame: CGRect, display: Bool = true, style: StyleProperty = Style()) -> UIView? {
        if isAvailable {
            return nil
        }
        isAvailable = true
        property = Property(style: style)
        
        progressView = ProgressView(frame: frame)
        
        guard let v = progressView else {
            return nil
        }
        
        v.arc(display, style: style)
        
        return v
    }
    
    public func show(_ frame: CGRect, style: StyleProperty = Style()) -> UIView? {
        if isAvailable {
            return nil
        }
        isAvailable = true
        property = Property(style: style)
        
        return getProgress(frame, message: nil, style: style)
    }
    
    public func show(_ frame: CGRect, message: String, style: StyleProperty = Style()) -> UIView? {
        if isAvailable {
            return nil
        }
        isAvailable = true
        property = Property(style: style)
        
        return getProgress(frame, message: message, style: style)
    }
    
    fileprivate func getProgress(_ frame: CGRect, message: String?, style: StyleProperty) -> UIView? {
        
        progressView = ProgressView(frame: frame)
        
        guard let v = progressView else {
            return nil
        }
        
        v.circle(message, style: style)
        
        return v
    }
    
    public func dismiss(progress view: UIView) {
        if !isAvailable {
            return
        }
        
        guard let prop = property else {
            return
        }
        
        cleanup(prop.dismissTimeInterval!, view: view, completionHandler: nil)
    }
    
    public func dismiss(progress view: UIView, completionHandler: @escaping () -> Void) -> () {
        if !isAvailable {
            return
        }
        
        guard let prop = property else {
            return
        }
        
        cleanup(prop.dismissTimeInterval!, view: view) {
            completionHandler()
        }
    }
    
    fileprivate func cleanup(_ t: Double, view: UIView, completionHandler: (() -> Void)?) {
        let delay = t * Double(NSEC_PER_SEC)
        let time  = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    view.alpha = 0
                },
                completion: { [weak self] finished in
                    view.removeFromSuperview()
                    self?.property = nil
                    self?.isAvailable = false
                    guard let completionHandler = completionHandler else {
                        return
                    }
                    completionHandler()
                }
            )
        }
    }
}
