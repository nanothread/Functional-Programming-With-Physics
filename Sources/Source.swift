import Foundation

struct Source: IteratorProtocol, Sequence {
    typealias Element = Int

    private var originalValues: AnySequence<Int>
    private lazy var iterator: AnyIterator<Int> = originalValues.makeIterator()
    
    init<T: Sequence>(values: T) where T.Element == Int {
        self.originalValues = AnySequence(values)
    }
    
    mutating func next() -> Int? {
        iterator.next()
    }
    
    mutating func reset() {
        iterator = originalValues.makeIterator()
    }
}
