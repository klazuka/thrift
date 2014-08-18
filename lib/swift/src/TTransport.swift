import Foundation


public protocol TTransport {
    func read(numBytes: Int) -> Result<[UInt8]>
    func write(bytes: [UInt8]) -> Result<Void>
    func flush()
}


//public class TMemoryBuffer: TTransport {
//    public private(set) var buffer: [UInt8]
//    
//    public init(bytes: [UInt8]) {
//        self.buffer = bytes
//    }
//    
//    public convenience init() {
//        self.init(bytes: [])
//    }
//    
//    public func read(numBytes: Int) -> [UInt8] {
//        assert(numBytes <= countElements(buffer), "buffer underflow") // TODO exception
//        let (left, right) = bipartiteSplit(buffer, numBytes)
//        buffer = right
//        return left
//    }
//    
//    public func write(bytes: [UInt8]) {
//        buffer.extend(bytes)
//    }
//    
//    public func flush() {
//        // no-op
//    }
//}


// split |array| into 2 parts, such that the left side will have up to |leftLength| elements
//func bipartiteSplit<T>(array: [T], leftLength: Int) -> ([T], [T]) {
//    let pivot = min(leftLength, countElements(array))
//    let left = array[0..<pivot]
//    let right = array[pivot..<countElements(array)]
//    return (Array(left), Array(right))
//}
