import Foundation

private let VERSION_1: UInt32 = 0x8001_0000;
private let VERSION_MASK: UInt32 = 0xffff_0000;


public class old_TBinaryProtocol: TProtocol {
    public let transport: TTransport
    
    public init(transport: TTransport) {
        self.transport = transport
    }
    
    //MARK: RPC methods
    
    public func readMessageBegin() -> MessageHeader {
        let prefix = _readU32()
        let version = prefix & VERSION_MASK
        if version == VERSION_1 {
            let type = unwrapOrDie(TMessageType.fromRaw(UInt8(prefix & 0xff)), msg: "bad input: unknown message type")
            let name = readString()
            let seqID = readI32()
            return MessageHeader(name: name, type: type, sequenceID: seqID)
        } else {
            fatalError("bad input: invalid message header begin")
        }
    }
    public func writeMessageBegin(header: MessageHeader) {
        _writeU32(UInt32(VERSION_1 | UInt32(header.type.toRaw())))
        writeString(header.name)
        writeI32(header.sequenceID)
    }
    
    public func readMessageEnd() {}
    public func writeMessageEnd() {}

    
    //MARK: struct methods
    
    public func readStructBegin() -> String? { return nil }
    public func writeStructBegin(name: String) {}
    public func readStructEnd() {}
    public func writeStructEnd() {}
    
    //MARK: field methods
    
    public func readFieldBegin() -> Field {
        switch unwrapOrDie(TType.fromRaw(readByte()), msg: "bad input: unknown field type") {
        case TType.Stop: return Field.Stop
        case let fieldType: return Field.Data(name: nil, type: fieldType, id: readI16())
        }
    }
    
    public func writeFieldBegin(name: String, type: TType, id: Int16) {
        writeByte(type.toRaw())
        writeI16(id)
    }
    
    public func readFieldEnd() {}
    public func writeFieldEnd() {}
    
    public func writeFieldStop() {
        writeByte(TType.Stop.toRaw())
    }
    
    //MARK: basic Thrift types
    
    public func readBool() -> Bool {
        return readByte() == 1
    }
    public func writeBool(b: Bool) {
        writeByte(b ? 1 : 0)
    }
    
    public func readByte() -> UInt8 {
        return transport.read(1)[0]
    }
    public func writeByte(k: UInt8) -> Void {
        transport.write([k])
    }
    
    public func readI16() -> Int16 {
        let bytes = transport.read(2)
        return
            (Int16(bytes[0]) << 8) |
            (Int16(bytes[1]) << 0)
    }
    public func writeI16(k: Int16) -> Void {
        var bytes: [UInt8] = []
        bytes.append(UInt8((k >> 8) & 0xff))
        bytes.append(UInt8((k >> 0) & 0xff))
        transport.write(bytes)
    }
    
    // thrift technically doesn't support unsigned integers,
    // but the message header uses it. There's probably a cleaner
    // way to do this, but for now, this works.
    private func _readU32() -> UInt32 {
        let bytes = transport.read(4)
        return
            (UInt32(bytes[0]) << 24) |
            (UInt32(bytes[1]) << 16) |
            (UInt32(bytes[2]) << 8)  |
            (UInt32(bytes[3]) << 0)
    }
    private func _writeU32(k: UInt32) -> Void {
        var bytes: [UInt8] = []
        bytes.append(UInt8((k >> 24) & 0xff))
        bytes.append(UInt8((k >> 16) & 0xff))
        bytes.append(UInt8((k >> 8) & 0xff))
        bytes.append(UInt8((k >> 0) & 0xff))
        transport.write(bytes)
    }
    
    public func readI32() -> Int32 {
        let bytes = transport.read(4)
        return
            (Int32(bytes[0]) << 24) |
            (Int32(bytes[1]) << 16) |
            (Int32(bytes[2]) << 8)  |
            (Int32(bytes[3]) << 0)
    }
    public func writeI32(k: Int32) -> Void {
        var bytes: [UInt8] = []
        bytes.append(UInt8((k >> 24) & 0xff))
        bytes.append(UInt8((k >> 16) & 0xff))
        bytes.append(UInt8((k >> 8) & 0xff))
        bytes.append(UInt8((k >> 0) & 0xff))
        transport.write(bytes)
    }
    
    public func readI64() -> Int64 {
        let bytes = transport.read(8)
        return
            (Int64(bytes[0]) << 56) |
            (Int64(bytes[1]) << 48) |
            (Int64(bytes[2]) << 40) |
            (Int64(bytes[3]) << 32) |
            (Int64(bytes[4]) << 24) |
            (Int64(bytes[5]) << 16) |
            (Int64(bytes[6]) << 8)  |
            (Int64(bytes[7]) << 0)
    }
    public func writeI64(k: Int64) -> Void {
        var bytes: [UInt8] = []
        bytes.append(UInt8((k >> 56) & 0xff))
        bytes.append(UInt8((k >> 48) & 0xff))
        bytes.append(UInt8((k >> 40) & 0xff))
        bytes.append(UInt8((k >> 32) & 0xff))
        bytes.append(UInt8((k >> 24) & 0xff))
        bytes.append(UInt8((k >> 16) & 0xff))
        bytes.append(UInt8((k >> 8) & 0xff))
        bytes.append(UInt8((k >> 0) & 0xff))
        transport.write(bytes)
    }
    
    public func readDouble() -> Double {
        let bytes = transport.read(8)
        let k = (UInt64(bytes[0]) << 56) |
                (UInt64(bytes[1]) << 48) |
                (UInt64(bytes[2]) << 40) |
                (UInt64(bytes[3]) << 32) |
                (UInt64(bytes[4]) << 24) |
                (UInt64(bytes[5]) << 16) |
                (UInt64(bytes[6]) << 8)  |
                (UInt64(bytes[7]) << 0)
        return thriftUint64ToDouble(k)
    }
    public func writeDouble(x: Double) {
        let k = thriftDoubleToUInt64(x)
        var bytes: [UInt8] = []
        bytes.append(UInt8((k >> 56) & 0xff))
        bytes.append(UInt8((k >> 48) & 0xff))
        bytes.append(UInt8((k >> 40) & 0xff))
        bytes.append(UInt8((k >> 32) & 0xff))
        bytes.append(UInt8((k >> 24) & 0xff))
        bytes.append(UInt8((k >> 16) & 0xff))
        bytes.append(UInt8((k >> 8) & 0xff))
        bytes.append(UInt8((k >> 0) & 0xff))
        transport.write(bytes)
    }
    
    public func readString() -> String {
        let len = Int(readI32())
        var myBytes = transport.read(len)
        return NSString(bytes: myBytes, length: myBytes.count, encoding: NSUTF8StringEncoding)
    }
    public func writeString(str: String) {
        let utf8 = str.utf8
        writeI32(Int32(countElements(utf8)))
        transport.write(Array(utf8))
    }
    
    public func readBinary() -> NSData {
        let len = Int(readI32())
        var myBytes = transport.read(len)
        return NSData(bytes: myBytes, length: myBytes.count)
    }
    public func writeBinary(data: NSData) {
        let len = data.length
        var myBytes = [UInt8](count: len, repeatedValue:0)
        data.getBytes(&myBytes, length: len)
        writeI32(Int32(len))
        transport.write(myBytes)
    }
    
    //MARK: collection Thrift types
    
    public func readListBegin() -> (elementType: TType, count: Int) {
        let elementType = unwrapOrDie(TType.fromRaw(readByte()), msg: "bad input: unknown element type")
        let count = readI32()
        return (elementType: elementType, count: Int(count))
    }
    public func writeListBegin(elementType: TType, count: Int) {
        writeByte(elementType.toRaw())
        writeI32(Int32(count))
    }

    public func readListEnd() {}
    public func writeListEnd() {}

    public func readSetBegin() -> (elementType: TType, count: Int) {
      return readListBegin()
    }
    public func writeSetBegin(elementType: TType, count: Int) {
        writeListBegin(elementType, count: count)
    }
    
    public func readSetEnd() {}
    public func writeSetEnd() {}


    public func readMapBegin() -> (keyType: TType, valueType: TType, count: Int) {
        let keyType = unwrapOrDie(TType.fromRaw(readByte()), msg: "bad input: unknown key type")
        let valueType = unwrapOrDie(TType.fromRaw(readByte()), msg: "bad input: unknown key type")
        let count = readI32()
        return (keyType: keyType, valueType: valueType, count: Int(count))
    }
    public func writeMapBegin(keyType: TType, valueType: TType, count: Int) {
        writeByte(keyType.toRaw())
        writeByte(valueType.toRaw())
        writeI32(Int32(count))
    }

    public func readMapEnd() {}
    public func writeMapEnd() {}
}
