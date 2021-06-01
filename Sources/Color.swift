import UIKit

fileprivate extension String {
    func color() -> UIColor {
        let red = Int(self[index(startIndex, offsetBy: 1)...index(startIndex, offsetBy: 2)], radix: 16)!
        let green = Int(self[index(startIndex, offsetBy: 3)...index(startIndex, offsetBy: 4)], radix: 16)!
        let blue = Int(self[index(startIndex, offsetBy: 5)...index(startIndex, offsetBy: 6)], radix: 16)!
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    }
}

extension UIColor {
    enum Semantic {
        static let ball = "#6EE7B7".color()
        static let ballValue = "#064E3B".color()
        
        static let mapBlock = "#6366F1".color()
        static let filterBlock = "#EC4899".color()
    }
}
