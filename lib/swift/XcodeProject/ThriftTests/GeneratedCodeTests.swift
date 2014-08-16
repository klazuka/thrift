import Foundation
import XCTest
import Thrift

// a helper function to reduce boilerplate
func writeField(thriftProtocol: TProtocol, thriftType: TType, fieldID: Int16, body: () -> ()) {
    let p = thriftProtocol
    p.writeFieldBegin("", type: thriftType, id: fieldID)
    body()
    p.writeFieldEnd()
}

func writeFieldMaybe(isSet: Bool, thriftProtocol: TProtocol, thriftType: TType, fieldID: Int16, body: () -> ()) {
    if isSet {
        let p = thriftProtocol
        p.writeFieldBegin("", type: thriftType, id: fieldID)
        body()
        p.writeFieldEnd()
    }
}

// this is a temporary test case, using hand-written Thrift objects.
class GeneratedCodeTests: XCTestCase {
    
    func test1() {
        let mem = TMemoryBuffer()
        let prot = TBinaryProtocol(transport: mem)
        var obj = ExampleGeneratedClass()
        obj.a = 1
        obj.b = 2
        obj.c = nil
        obj.d = 4
        obj.write(prot)
        
        let prot2 = TBinaryProtocol(transport: mem)
        let obj2 = ExampleGeneratedClass.read(prot2)
        
        // test required fields
        XCTAssertEqual(obj.a, obj2.a, "mismatch")
        XCTAssertEqual(obj.b, obj2.b, "mismatch")
        
        // test optional fields
        if obj.c != nil {
            XCTAssertEqual(obj.c!, obj2.c!, "mismatch")
        }
        if obj.d != nil {
            XCTAssertEqual(obj.d!, obj2.d!, "mismatch")
        }
    }
}
