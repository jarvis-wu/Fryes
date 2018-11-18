//
//  Extensions.swift
//  Fryes
//
//  Created by Jarvis Wu on 2018-11-16.
//  Copyright © 2018 Jarvis Wu. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func toDate(withFormat format: String = "yyyyMMddHHmm") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension Date {
    func daysFromToday() -> Int {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: self)
        return calendar.dateComponents([.day], from: currentDate, to: targetDate).day!
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hexStr)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}
