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
  
    //MARK:- build
    
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
        case let ._List(type, values):
            return buildThriftType(type) <>
                   buildInt32BE(Int32(values.count)) <>
                   buildBinaryList(values)
        case let ._Map(keyType, valueType, alist):
            return buildThriftType(keyType) <>
                   buildThriftType(valueType) <>
                   buildInt32BE(Int32(alist.count)) <>
                   buildBinaryMap(alist)
        case let ._Struct(dict):
            return buildBinaryStruct(dict) <>
                   buildByte(TType.Stop.toRaw())
        default:
            fatalError("not yet implemented")
        }
    }
    
    func buildThriftType(type: TType) -> Builder {
        return buildByte(type.toRaw())
    }
    
    func buildThriftTypeOf(value: TValue) -> Builder {
        return buildThriftType(value.thriftType())
    }
    
    func buildBinaryList(values: [TValue]) -> Builder {
        let f = { mappend(self.buildBinaryValue($0), $1) }
        return foldr(f, mempty(), values)
    }
    
    func buildBinaryMap(alist: [(TValue, TValue)]) -> Builder {
        // the closure's parameters are annotated because
        // type inference blows-up otherwise
        let f = { (acc:Builder, pair:(TValue,TValue)) -> Builder in
            let (key, val) = pair
            return acc <> self.buildBinaryValue(key) <> self.buildBinaryValue(val)
        }
        return foldl(f, mempty(), alist)
    }
    
    func buildBinaryStruct(dict: [Int16: (String, TValue)]) -> Builder {
        var acc = mempty()
        for (fieldID, pair) in dict {
            let (_, value) = pair
            acc = acc <>
                  buildThriftTypeOf(value) <>
                  buildInt16BE(fieldID) <>
                  buildBinaryValue(value)
        }
        return acc
    }
}

//MARK:- parse

func parseBinaryValue(type: TType, bytes: [UInt8]) -> Parser<TValue> {
  switch type {
//  case TType.Bool: parseByte(b) <^> { $0 == 1 }
    
//  case let ._Byte(x): return buildByte(x)
//  case let ._Bool(x): return buildByte(x ? 1 : 0)
//  case let ._Double(x): return buildDoubleBE(x)
//  case let ._I16(x): return buildInt16BE(x)
//  case let ._I32(x): return buildInt32BE(x)
//  case let ._I64(x): return buildInt64BE(x)
//  case let ._String(x):
//    let utf8 = x.utf8
//    return buildInt32BE(Int32(countElements(utf8))) <>
//      buildBytes(Array(utf8))
//  case let ._List(type, values):
//    return buildThriftType(type) <>
//      buildInt32BE(Int32(values.count)) <>
//      buildBinaryList(values)
//  case let ._Map(keyType, valueType, alist):
//    return buildThriftType(keyType) <>
//      buildThriftType(valueType) <>
//      buildInt32BE(Int32(alist.count)) <>
//      buildBinaryMap(alist)
//  case let ._Struct(dict):
//    return buildBinaryStruct(dict) <>
//      buildByte(TType.Stop.toRaw())
  default:
    fatalError("not yet implemented")
  }
}


































