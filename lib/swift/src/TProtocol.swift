import Foundation

public let RPC_RESULT_FIELD_ID: Int16 = 0

public protocol TProtocol {
    var transport: TTransport { get }
    
    func writeMessageBegin(header: MessageHeader) -> Result<Void>
    func readMessageBegin() -> Result<MessageHeader>
    
    // TODO: should the serialized data representation be NSData or
    // something like a slice of UInt8?
    func serializeValue(val: TValue) -> NSData
    func deserializeValue(type: TType, buf: NSData) -> TValue
    
    func writeValue(val: TValue) -> Result<Void>
    func readValue(type: TType) -> Result<TValue>
}

public typealias MessageHeader = (name: String, type: TMessageType, sequenceID: Int32)

