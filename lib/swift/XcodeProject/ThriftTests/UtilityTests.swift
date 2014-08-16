import Foundation
import XCTest
import Thrift

class UtilityTests: XCTestCase {
    
    func testThriftSkips() {
        let mem = TMemoryBuffer()
        let p = TBinaryProtocol(transport: mem)
        
        // write out a bunch of data to be skipped over
        p.writeBool(true)
        p.writeDouble(3.14159)
        p.writeString("blah")
        
        p.writeStructBegin("foo")
        p.writeFieldBegin("a", type: .I16, id: 1)
        p.writeI16(0x7fff)
        p.writeFieldEnd()
        p.writeFieldBegin("b", type: .I32, id: 1)
        p.writeI32(0x7fffffff)
        p.writeFieldEnd()
        p.writeFieldBegin("c", type: .I64, id: 1)
        p.writeI64(0x7fffffff_ffffffff)
        p.writeFieldEnd()
        p.writeFieldStop()
        p.writeStructEnd()
        
        p.writeListBegin(.Byte, count: 2)
        p.writeByte(0x00)
        p.writeByte(0x01)
        p.writeListEnd()
        
        p.writeSetBegin(.Byte, count: 2)
        p.writeByte(0x7f)
        p.writeByte(0x80)
        p.writeSetEnd()
        
        p.writeMapBegin(.String, valueType: .Bool, count: 2)
        p.writeString("a")
        p.writeBool(true)
        p.writeString("b")
        p.writeBool(false)
        p.writeMapEnd()
        
        // finally, write a sentinel value
        let sentinel = "<<< secret >>>"
        p.writeString(sentinel)
        
        // skip everything except the sentinel
        let p2 = TBinaryProtocol(transport: mem)
        skip(p2, .Bool)
        skip(p2, .Double)
        skip(p2, .String)
        skip(p2, .Struct)
        skip(p2, .List)
        skip(p2, .Set)
        skip(p2, .Map)

        // compare against the sentinel
        let output = p2.readString()
        XCTAssertEqual(output, sentinel, "sentinel must match the final unskipped value")
    }

    func testDoubleConversions() {
        
        func testInverse(d: Double, label: String) {
            let d2 = thriftUint64ToDouble(thriftDoubleToUInt64(d))
            XCTAssertEqual(d, d2, label)
        }
        
        testInverse(0.0, "0")
        testInverse(-0.0, "-0")
        testInverse(1.0, "1.0")
        testInverse(-2.0, "-2.0")
        testInverse(1.0000000000000002, "Smallest number > 1")
        testInverse(Double.infinity, "inf")
        testInverse(pow(2.0, -1022), "Min normal positive double")
        testInverse(pow(2.0, -1022 - 52), "Min subnormal positive double")
        
        XCTAssertEqual(thriftDoubleToUInt64( 0.0), 0x0000_0000_0000_0000, "0")
        XCTAssertEqual(thriftDoubleToUInt64(-0.0), 0x8000_0000_0000_0000, "-0")
        XCTAssertEqual(thriftDoubleToUInt64( 1.0), 0x3ff0_0000_0000_0000, "1")
        XCTAssertEqual(thriftDoubleToUInt64( 2.0), 0x4000_0000_0000_0000, "2")
        
        XCTAssertEqual(thriftDoubleToUInt64(Double.infinity), 0x7ff0_0000_0000_0000, "infinity")
        XCTAssertEqual(thriftDoubleToUInt64(-Double.infinity), 0xfff0_0000_0000_0000, "infinity")
        XCTAssertEqual(thriftDoubleToUInt64(1.0000000000000002), 0x3ff0_0000_0000_0001, "smallest number > 1")
    }


}
