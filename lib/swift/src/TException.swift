import Foundation

enum TApplicationExceptionType: Int32, Printable {
    case Unknown = 0
    case UnknownMethod = 1
    case InvalidMessageType = 2
    case WrongMethodName = 3
    case BadSequenceID = 4
    case MissingResult = 5
    case InternalError = 6
    case ProtocolError = 7
    case InvalidTransform = 8
    case InvalidProtocol = 9
    case UnsupportedClientType = 10
    
    //TODO: is there really no more concise way of defining this mapping in Swift???
    var description: String {
    get {
        switch self {
        case Unknown: return "Unknown"
        case UnknownMethod: return "Unknown Method"
        case InvalidMessageType: return "Invalid Message Type"
        case WrongMethodName: return "Wrong Method Name"
        case BadSequenceID: return "Bad Sequence ID"
        case MissingResult: return "Missing Result"
        case InternalError: return "Internal Error"
        case ProtocolError: return "Protocol Error"
        case InvalidTransform: return "Invalid Transform"
        case InvalidProtocol: return "Invalid Protocol"
        case UnsupportedClientType: return "Unsupported Client Type"
        }
    }
    }
}

public class TApplicationException: NSException, TBase {
    let message: String?
    let type: TApplicationExceptionType = .Unknown // TODO remove default: workaround for a Swift bug
  
    public required init(coder aDecoder: NSCoder!) {
        // TODO: implement NSCoding protocol
        fatalError("not supported")
    }
  
    public required init(thriftProtocol: TProtocol) {
        let p = thriftProtocol
        p.readStructBegin()
        
        var exit = false
        while !exit {
            switch p.readFieldBegin() {
            case .Stop:
                exit = true // TODO use labeled break?
            case .Data(_, .String, 1):
                self.message = p.readString()
            case .Data(_, .I32, 2):
                self.type = unwrapOrDie(TApplicationExceptionType.fromRaw(p.readI32()), msg: "invalid TApplicationException type")
            case let .Data(_, elementType, _):
                skip(p, elementType)
            }
            p.readFieldEnd()
        }
        
        p.readStructEnd()
        super.init(name: self.description, reason: self.message, userInfo: nil)
    }
    
    public func write(thriftProtocol: TProtocol) {
        let p = thriftProtocol
        p.writeStructBegin("TApplicationException")
        if self.message != nil {
            p.writeFieldBegin("message", type: .String, id: 1)
            p.writeString(self.message!)
            p.writeFieldEnd()
        }
        p.writeFieldBegin("type", type: .I32, id: 2)
        p.writeI32(self.type.toRaw())
        p.writeFieldEnd()
        p.writeFieldStop()
        p.writeStructEnd()
    }
}