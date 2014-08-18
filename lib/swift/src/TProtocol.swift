import Foundation

public let RPC_RESULT_FIELD_ID: Int16 = 0

public protocol TProtocol {
    var transport: TTransport { get }
    
    func writeMessageBegin(header: MessageHeader) -> Result<Void>
    func readMessageBegin() -> Result<MessageHeader>
    
    func serializeValue(val: TValue) -> NSData
    func deserializeValue(type: TType, buf: NSData) -> TValue
    
    func writeValue(val: TValue) -> Result<Void>
    func readValue(type: TType) -> Result<TValue>
}

//MARK: -

public typealias MessageHeader = (name: String, type: TMessageType, sequenceID: Int32)

//public struct MessageHeader {
//    public var name: String
//    public var type: TMessageType
//    public var sequenceID: Int32
//    
//    public init(name: String, type: TMessageType, sequenceID: Int32) {
//        self.name = name
//        self.type = type
//        self.sequenceID = sequenceID
//    }
//}

//MARK: -

//public enum Field: Equatable {
//    case Stop
//    case Data(name: String?, type: TType, id: Int16)
//}
//
//public func ==(lhs: Field, rhs: Field) -> Bool {
//    switch (lhs, rhs) {
//    case (.Stop, .Stop):
//        return true
//    case (.Data(let lhsName, let lhsType, let lhsID), .Data(let rhsName, let rhsType, let rhsID))
//        where lhsName == rhsName &&
//            lhsType == rhsType &&
//            lhsID == rhsID:
//        return true
//    default:
//        return false
//    }
//}


// TODO: this can be re-made into the parseBinaryValue function
//public func skip(thriftProtocol: TProtocol, elementType: TType) {
//    let p = thriftProtocol
//    switch elementType {
//    case .Bool:   p.readBool()
//    case .Byte:   p.readByte()
//    case .I16:    p.readI16()
//    case .I32:    p.readI32()
//    case .I64:    p.readI64()
//    case .Double: p.readDouble()
//    case .String: p.readString()
//    case .Struct:
//        p.readStructBegin()
//        var done = false
//        while !done {
//            switch p.readFieldBegin() {
//            case .Stop: done = true
//            case let .Data(name: _, type: elementType, id: _):
//                skip(p, elementType)
//                p.readFieldEnd()
//            }
//        }
//        p.readStructEnd()
//    case .List:
//        let (listElementType, listCount) = p.readListBegin()
//        for _ in 1...listCount {
//            skip(p, listElementType)
//        }
//        p.readListEnd()
//    case .Set:
//        let (setElementType, setCount) = p.readSetBegin()
//        for _ in 1...setCount {
//            skip(p, setElementType)
//        }
//        p.readSetEnd()
//    case .Map:
//        let (keyType, valueType, entryCount) = p.readMapBegin()
//        for _ in 1...entryCount {
//            skip(p, keyType)
//            skip(p, valueType)
//        }
//        p.readMapEnd()
//    case .Stop:
//        fatalError("protocol violation, cannot skip a stop field")
//    case .Void:
//        fatalError("protocol violation, cannot skip a void field")
//    }
//}
