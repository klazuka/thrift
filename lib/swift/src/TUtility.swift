import Foundation

// Base defines the basic set of operations on the generated
// thrift objects.
// TODO: find a proper home for this protocol definition
public protocol TBase {
    init(thriftProtocol: TProtocol)
    func write(thriftProtocol: TProtocol)
}

// helper for detecting protocol errors
//TODO: throw an exception instead?
//TODO: at the very least we should restrict it to internal or private
public func unwrapOrDie<T>(x: T?, #msg: StaticString) -> T {
    if let x2 = x {
        return x2
    } else {
        fatalError(msg)
    }
}

// Conversion functions courtesy of Jens Persson on Apple Dev Forums
// https://devforums.apple.com/message/1006792
// It's actually simpler than I at first thought, although
// this undoubtedly could get us into platform-specific troubles.
// But that's what unit tests are for.
public func thriftDoubleToUInt64(d: Double) -> UInt64 {
    return unsafeBitCast(d, UInt64.self)
}

public func thriftUint64ToDouble(k: UInt64) -> Double {
    return unsafeBitCast(k, Double.self)
}


// private struct to be included in the runtime solely
// to reduce generated code verbosity for null-ary thrifts.
// Declared public just to facilitate hand-generated code unit tests
//TODO: remove me eventually.
public struct _EmptyThriftStruct: TBase {
    let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public init(thriftProtocol: TProtocol) {
        let p = thriftProtocol
        if let name = p.readStructBegin() {
            self.name = name
        } else {
            self.name = "<unknown>"
        }
        
        var exit = false
        while !exit {
            switch p.readFieldBegin() {
            case .Stop:
                exit = true // TODO use labeled break?
            case let .Data(_, elementType, _):
                skip(p, elementType)
            }
            p.readFieldEnd()
        }
        
        p.readStructEnd()
    }
    
    public func write(thriftProtocol: TProtocol) {
        let p = thriftProtocol
        p.writeStructBegin(self.name)
        p.writeFieldStop()
        p.writeStructEnd()
    }
}
