import Foundation

extension Double {
    func currency() -> String{
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = ","
            numberFormatter.groupingSize = 3
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.decimalSeparator = "."
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 7
            return "$ "+numberFormatter.string(from: self as NSNumber)!
    }
}

enum PositionSide {
    case Long
    case Short
}

