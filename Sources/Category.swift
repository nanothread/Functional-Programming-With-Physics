import Foundation

struct Category: OptionSet, RawRepresentable {
    var rawValue: UInt32
    
    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    static let ball = Category(rawValue: 1 << 0)
    static let hardEdge = Category(rawValue: 1 << 1)
    static let laser = Category(rawValue: 1 << 2)
    static let invisibleEdge = Category(rawValue: 1 << 3)
}
