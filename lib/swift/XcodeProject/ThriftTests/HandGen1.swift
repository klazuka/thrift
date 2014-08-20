import Foundation
import Thrift

/*
   struct Foo {
     1: required i32 a = 99,
     2: required i32 b,
     3: optional i32 c = 101
     4: optional i32 d
     5: required list<string> e
     6: required Bar f
   }

   struct Bar {
     1: required bool a,
   }
*/


// hand-generated Thrift struct class
public struct Bar {
    
    // required Thrift field with default value
    public var a: Bool = false { didSet { aIsSet = true } }
    private var aIsSet: Bool = false
    
    func asThriftValue(thriftProtocol: TProtocol) -> TValue {
        let p = thriftProtocol
        var map: TFieldMapByID = [:]
        if aIsSet { map[1] = ("a", TValue._Bool(a)) }
        return TValue._Struct(map)
    }
    
    func write(thriftProtocol: TProtocol) {
        assert(validate(), "write failed validation")
        let p = thriftProtocol
        p.writeValue(self.asThriftValue(p))
    }
    
    func validate() -> Bool {
        return aIsSet
    }
}

// hand-generated Thrift struct class
public struct Foo {
    
    // required Thrift field with default value
    public var a: Int32 = 99 { didSet { aIsSet = true } }
    private var aIsSet: Bool = false
    
    // required Thrift field with no default value: use dummy value to satisfy the swift compiler
    public var b: Int32 = 0 { didSet { bIsSet = true } }
    private var bIsSet: Bool = false
    
    // optional Thrift field with default value
    public var c: Int32? = 101  { didSet { cIsSet = true } }
    private var cIsSet: Bool = false
    
    // optional Thrift field without a default value
    public var d: Int32? = nil { didSet { dIsSet = true } }
    private var dIsSet: Bool = false
    
    // required list-of-strings field
    public var e: [String] = [] { didSet { eIsSet = true } }
    private var eIsSet: Bool = false

    // required field referencing another Thrift struct
    public var f: Bar = Bar() { didSet { fIsSet = true } }
    private var fIsSet: Bool = false
  
    func asThriftValue(thriftProtocol: TProtocol) -> TValue {
        let p = thriftProtocol
        var map: TFieldMapByID = [:]
        if aIsSet { map[1] = ("a", TValue._I32(a)) }
        if bIsSet { map[2] = ("b", TValue._I32(b)) }
        if cIsSet { map[3] = ("c", TValue._I32(c!)) }
        if dIsSet { map[4] = ("d", TValue._I32(d!)) }
        if eIsSet { map[5] = ("e",
            TValue._List(valueType: TType.String, array: e.map({ TValue._String($0)})))
        }
        if fIsSet { map[6] = ("f", f.asThriftValue(p)) }
        return TValue._Struct(map)
    }
  
    func write(thriftProtocol: TProtocol) {
        assert(validate(), "write failed validation")
        let p = thriftProtocol
        p.writeValue(self.asThriftValue(p))
    }
    
    func validate() -> Bool {
        return aIsSet && bIsSet && eIsSet && fIsSet
    }
}
