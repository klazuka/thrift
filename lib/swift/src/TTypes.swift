
// RPC message types
public enum TMessageType: UInt8 {
    case Call = 1
    case Reply = 2
    case Exception = 3
    case Oneway = 4
}

// Thrift values
public enum TValue {
    // these names are prefixed with underscores because the compiler
    // gets confused if the name is the same as an existing Swift type.
    case _Bool(Bool)
    case _Byte(UInt8)
    case _Double(Double)
    case _I16(Int16)
    case _I32(Int32)
    case _I64(Int64)
    case _String(String)
    case _Struct([Int16:(String,TValue)])
    case _Map(keyType: TType, valueType: TType, assoc: [(TValue,TValue)])
    case _Set(valueType: TType, array: [TValue])
    case _List(valueType: TType, array: [TValue])
    
    func thriftType() -> TType {
        switch self {
        case _Bool: return TType.Bool
        case _Byte: return TType.Byte
        case _Double: return TType.Double
        case _I16: return TType.I16
        case _I32: return TType.I32
        case _I64: return TType.I64
        case _String: return TType.String
        case _Struct(_): return TType.Struct([:])
        case _Map(_,_,_): return TType.Map(keyType: Box(TType.Void), valueType: Box(TType.Void))
        case _Set(_): return TType.Set(valueType: Box(TType.Void))
        case _List(_): return TType.List(valueType: Box(TType.Void))
        }
    }
}

// a mapping from a struct's fields' names to a pair of fieldID and Thrift value
public typealias TFieldMap = [String: (Int16, TValue)]

// Thrift value types
public enum TType: RawRepresentable, Equatable {
    case Stop
    case Void
    case Bool
    case Byte
    case Double
    case I16
    case I32
    case I64
    case String
    case Struct(TFieldMap)
    case Map(keyType: Box<TType>, valueType: Box<TType>)
    case Set(valueType: Box<TType>)
    case List(valueType: Box<TType>)
    
    // implement the raw protocol explicitly because the compiler
    // cannot synthesize it for enums with associated values
    
    typealias Raw = UInt8
    
    public func toRaw() -> UInt8 {
        // Thrift types are encoded using only the "outer"
        // type information. So in the case of collection
        // types, the type of the elements is discarded.
        switch self {
        case .Stop: return 0
        case .Void: return 1
        case .Bool: return 2
        case .Byte: return 3
        case Double: return 4
        case I16: return 6
        case I32: return 8
        case I64: return 10
        case String: return 11
        case Struct: return 12
        case Map(_, _): return 13
        case Set(_): return 14
        case List(_): return 15
        }
    }
    
    public static func fromRaw(raw: UInt8) -> TType? {
        switch raw {
        case 0: return .Stop
        case 1: return .Void
        case 2: return .Bool
        case 3: return .Byte
        case 4: return .Double
        case 6: return .I16
        case 8: return .I32
        case 10: return .I64
        case 11: return .String
        case 12: return .Struct([:])
        case 13: return .Map(keyType: Box(.Void), valueType: Box(.Void))
        case 14: return .Set(valueType: Box(.Void))
        case 15: return .List(valueType: Box(.Void))
        default: return nil
        }
    }
}

let dummyTType = Box(TType.Void)

// NOTE: equality for thrift types only considers outer equality
// that is, it ignores the type of the contained elements.
// This is a consequence of the way that we implemented the
// RawRepresentable protocol.
public func ==(lhs: TType, rhs: TType) -> Bool {
    return lhs.toRaw() == rhs.toRaw()
}

