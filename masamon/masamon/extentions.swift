
import UIKit

extension UIColor {
    class func hex ( _ hexStr : NSString, alpha : CGFloat) -> UIColor {
        var hexString = hexStr
        
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexString as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return UIColor.white;
        }
    }
}

extension Array {
    mutating func removeObject<U: Equatable>(_ object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if index != nil {
            self.remove(at: index!)
        }
    }
}

extension String {
    fileprivate func convertFullWidthToHalfWidth(_ reverse: Bool) -> String {
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
    
    fileprivate func convertFullWidthToHalfWidthOnlyNumber(_ fullWidth: Bool) -> String {
        var str = self
        
        let pattern_number = fullWidth ? "[0-9]+" : "[０-９]+"
        let pattern_alphabet = fullWidth ? "[A-Z]+" : "[Ａ-Ｚ]+"
        
        let patternarray = [pattern_number,pattern_alphabet]
        
        for i in 0...1 {
            let regex = try! NSRegularExpression(pattern: patternarray[i], options: [])
            let results = regex.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count))
            
            results.reversed().forEach {
                let subStr = (str as NSString).substring(with: $0.range)
                str = str.replacingOccurrences(
                    of: subStr,
                    with: (fullWidth ? subStr.zenkaku : subStr.hankaku))
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
