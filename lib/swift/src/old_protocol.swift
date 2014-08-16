import Foundation

// RPC message types
public enum TMessageType: UInt8 {
    case Call = 1
    case Reply = 2
    case Exception = 3
    case Oneway = 4
}

// element types
public enum TType: UInt8 {
    case Stop = 0
    case Void = 1
    case Bool = 2
    case Byte = 3
    case Double = 4
    // skipped
    case I16 = 6
    // skipped
    case I32 = 8
    // skipped
    case I64 = 10
    case String = 11
    case Struct = 12
    case Map = 13
    case Set = 14
    case List = 15
}

public let RPC_RESULT_FIELD_ID: Int16 = 0

public protocol TProtocol {
    var transport: TTransport { get }
    
    //MARK: RPC methods
    
    func readMessageBegin() -> MessageHeader
    func writeMessageBegin(header: MessageHeader)
    
    func readMessageEnd()
    func writeMessageEnd()
    
    //MARK: Struct & Field methods
    
    func readStructBegin() -> String?
    func writeStructBegin(name: String)
    
    func readStructEnd()
    func writeStructEnd()
    
    func readFieldBegin() -> Field
    func writeFieldBegin(name: String, type: TType, id: Int16)
    
    func readFieldEnd()
    func writeFieldEnd()
    
    // this is the only protocol method without a 'read' counterpart
    func writeFieldStop()
    
    //MARK: basic Thrift types
    
    func readBool() -> Bool
    func writeBool(b: Bool)
    
    func readByte() -> UInt8
    func writeByte(k: UInt8)
    
    func readI16() -> Int16
    func writeI16(k: Int16)
    
    func readI32() -> Int32
    func writeI32(k: Int32)
    
    func readI64() -> Int64
    func writeI64(k: Int64)
    
    func readDouble() -> Double
    func writeDouble(x: Double)
    
    func readString() -> String
    func writeString(str: String)
    
    func readBinary() -> NSData
    func writeBinary(data: NSData)
    
    //MARK: collection Thrift types
    
    func readListBegin() -> (elementType: TType, count: Int)
    func writeListBegin(elementType: TType, count: Int)
    func readListEnd()
    func writeListEnd()
    
    func readSetBegin() -> (elementType: TType, count: Int);
    func writeSetBegin(elementType: TType, count: Int);
    func readSetEnd()
    func writeSetEnd()
    
    func readMapBegin() -> (keyType: TType, valueType: TType, count: Int)
    func writeMapBegin(keyType: TType, valueType: TType, count: Int)
    func readMapEnd()
    func writeMapEnd()
}

//MARK: -

public struct MessageHeader {
    public var name: String
    public var type: TMessageType
    public var sequenceID: Int32
    
    public init(name: String, type: TMessageType, sequenceID: Int32) {
        self.name = name
        self.type = type
        self.sequenceID = sequenceID
    }
}

//MARK: -

public enum Field: Equatable {
    case Stop
    case Data(name: String?, type: TType, id: Int16)
}

public func ==(lhs: Field, rhs: Field) -> Bool {
    switch (lhs, rhs) {
    case (.Stop, .Stop):
        return true
    case (.Data(let lhsName, let lhsType, let lhsID), .Data(let rhsName, let rhsType, let rhsID))
        where lhsName == rhsName &&
            lhsType == rhsType &&
            lhsID == rhsID:
        return true
    default:
        return false
    }
}


//TODO: this is VERY similar to the |read()| function on an object
//      modulo actually using the read-data and setting it to
//      the corresponding property. Is there a way to do this
//      more generically?
public func skip(thriftProtocol: TProtocol, elementType: TType) {
    let p = thriftProtocol
    switch elementType {
    case .Bool:   p.readBool()
    case .Byte:   p.readByte()
    case .I16:    p.readI16()
    case .I32:    p.readI32()
    case .I64:    p.readI64()
    case .Double: p.readDouble()
    case .String: p.readString()
    case .Struct:
        p.readStructBegin()
        var done = false
        while !done {
            switch p.readFieldBegin() {
            case .Stop: done = true
            case let .Data(name: _, type: elementType, id: _):
                skip(p, elementType)
                p.readFieldEnd()
            }
        }
        p.readStructEnd()
    case .List:
        let (listElementType, listCount) = p.readListBegin()
        for _ in 1...listCount {
            skip(p, listElementType)
        }
        p.readListEnd()
    case .Set:
        let (setElementType, setCount) = p.readSetBegin()
        for _ in 1...setCount {
            skip(p, setElementType)
        }
        p.readSetEnd()
    case .Map:
        let (keyType, valueType, entryCount) = p.readMapBegin()
        for _ in 1...entryCount {
            skip(p, keyType)
            skip(p, valueType)
        }
        p.readMapEnd()
    case .Stop:
        fatalError("protocol violation, cannot skip a stop field")
    case .Void:
        fatalError("protocol violation, cannot skip a void field")
    }
}
