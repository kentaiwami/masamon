
import UIKit

extension UIColor {
    class func hex ( hexStr : NSString, alpha : CGFloat) -> UIColor {
        var hexString = hexStr
        
        hexString = hexString.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: hexString as String)
        var color: UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return UIColor.whiteColor();
        }
    }
}

extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerate() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if index != nil {
            self.removeAtIndex(index!)
        }
    }
}