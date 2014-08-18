import Foundation

private let VERSION_1: UInt32 = 0x8001_0000;
private let VERSION_MASK: UInt32 = 0xffff_0000;

public class TBinaryProtocol: TProtocol {
 
    public let transport: TTransport
    
    public init(transport: TTransport) {
        self.transport = transport
    }
    
    public func writeMessageBegin(header: MessageHeader) -> Result<Void> {
        let b = buildUInt32BE(VERSION_1 | UInt32(header.type.toRaw())) <>
        buildBinaryValue(._String(header.name)) <>
        buildBinaryValue(._I32(header.sequenceID))
        return transport.write(toSwiftByteArray(b))
    }
    
    public func readMessageBegin() -> Result<MessageHeader> {
        fatalError("implement me")
    }
    
    public func serializeValue(val: TValue) -> NSData {
        return toNSData(buildBinaryValue(val))
    }
    public func deserializeValue(type: TType, buf: NSData) -> TValue {
        fatalError("implement me")
    }
    
    public func writeValue(val: TValue) -> Result<Void> {
        return transport.write(toSwiftByteArray(buildBinaryValue(val)))
    }
    public func readValue(type: TType) -> Result<TValue> {
        fatalError("implement me")
    }
    
    
    func buildBinaryValue(val: TValue) -> Builder {
        switch val {
        case let ._Byte(x): return buildByte(x)
        case let ._Bool(x): return buildByte(x ? 1 : 0)
        case let ._Double(x): return buildDoubleBE(x)
        case let ._I16(x): return buildInt16BE(x)
        case let ._I32(x): return buildInt32BE(x)
        case let ._I64(x): return buildInt64BE(x)
        case let ._String(x):
            let utf8 = x.utf8
            return buildInt32BE(Int32(countElements(utf8))) <>
                   buildBytes(Array(utf8))
        default:
            fatalError("not yet implemented")
        }
    }
}



































