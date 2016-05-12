
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

extension String {
    private func convertFullWidthToHalfWidth(reverse: Bool) -> String {
        let str = NSMutableString(string: self) as CFMutableString
        CFStringTransform(str, nil, kCFStringTransformFullwidthHalfwidth, reverse)
        return str as String
    }
    
    var hankaku: String {
        return convertFullWidthToHalfWidth(false)
    }
    
    var zenkaku: String {
        return convertFullWidthToHalfWidth(true)
    }
    
    private func convertFullWidthToHalfWidthOnlyNumber(fullWidth: Bool) -> String {
        var str = self
        
        let pattern_number = fullWidth ? "[0-9]+" : "[０-９]+"
        let pattern_alphabet = fullWidth ? "[A-Z]+" : "[Ａ-Ｚ]+"
        
        let patternarray = [pattern_number,pattern_alphabet]
        
        for i in 0...1 {
            let regex = try! NSRegularExpression(pattern: patternarray[i], options: [])
            let results = regex.matchesInString(str, options: [], range: NSMakeRange(0, str.characters.count))
            
            results.reverse().forEach {
                let subStr = (str as NSString).substringWithRange($0.range)
                str = str.stringByReplacingOccurrencesOfString(
                    subStr,
                    withString: (fullWidth ? subStr.zenkaku : subStr.hankaku))
            }
        }
        
        return str
    }
    
    var hankakuOnly: String {
        return convertFullWidthToHalfWidthOnlyNumber(false)
    }
    
    var zenkakuOnly: String {
        return convertFullWidthToHalfWidthOnlyNumber(true)
    }
}