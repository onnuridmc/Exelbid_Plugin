import Foundation
import UIKit

extension UIColor {
    // Hex to RGB
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        // #FFF 형식을 #FFFFFF로 변환
        if hexSanitized.count == 3 {
            let r = hexSanitized[hexSanitized.startIndex]
            let g = hexSanitized[hexSanitized.index(hexSanitized.startIndex, offsetBy: 1)]
            let b = hexSanitized[hexSanitized.index(hexSanitized.startIndex, offsetBy: 2)]
            hexSanitized = "\(r)\(r)\(g)\(g)\(b)\(b)"
        }

        // RGB 값 추출
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
