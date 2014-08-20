import Foundation
import XCTest
import Thrift


// this is a temporary test case, using hand-written Thrift objects.
class HandGen1Tests: XCTestCase {
    
    func test1() {
        let mem = TMemoryBuffer()
        let prot = TBinaryProtocol(transport: mem)
        
        var bar = Bar()
        bar.a = true
        
        var foo = Foo()
        foo.a = 1
        foo.b = 2
        foo.c = nil
        foo.d = 4
        foo.e = ["love", "wisdom", "compassion"]
        foo.f = bar
        
        foo.write(prot)
        
//        let prot2 = TBinaryProtocol(transport: mem)
//        let obj2 = Foo.read(prot2)
//        
//        // test required fields
//        XCTAssertEqual(obj.a, obj2.a, "mismatch")
//        XCTAssertEqual(obj.b, obj2.b, "mismatch")
//        
//        // test optional fields
//        if obj.c != nil {
//            XCTAssertEqual(obj.c!, obj2.c!, "mismatch")
//        }
//        if obj.d != nil {
//            XCTAssertEqual(obj.d!, obj2.d!, "mismatch")
//        }
    }
}
