import Foundation

extension Double {
    func currency() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 4
        return "$ "+numberFormatter.string(from: self as NSNumber)!
    }
    
    func truncate(to scale: Int = 2) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = scale
        numberFormatter.maximumFractionDigits = scale
        numberFormatter.decimalSeparator = "."
        let nsnum = NSNumber(value: self)
        guard let number = numberFormatter.string(from: nsnum) else { return "0" }
        return number
    }
    
}

enum PositionSide: String {
    case Long = "Long"
    case Short = "Short"
}

