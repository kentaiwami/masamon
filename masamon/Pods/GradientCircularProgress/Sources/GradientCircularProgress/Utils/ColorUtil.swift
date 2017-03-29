//
//  ColorUtil.swift
//  GradientCircularProgress
//
//  Created by keygx on 2015/11/23.
//  Copyright © 2015年 keygx. All rights reserved.
//

import UIKit

open class ColorUtil {
    
    open class func toUIColor(_ r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    internal class func toRGBA(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (r, g, b, a)
    }
    
    internal class func toNotOpacityColor(_ color: UIColor) -> UIColor {
        
        if color == UIColor.clear {
            return UIColor.white
        } else {
            return UIColor(
                red: ColorUtil.toRGBA(color).r,
                green: ColorUtil.toRGBA(color).g,
                blue: ColorUtil.toRGBA(color).b,
                alpha: 1.0)
        }
    }
}
