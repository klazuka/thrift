import Foundation
import XCTest
import Thrift

class BinaryProtocolTests: XCTestCase {
    
    func testMessageSimple() {
        
        // write it out
        let mem = TMemoryBuffer()
        let p = TBinaryProtocol(transport: mem)
        let input = MessageHeader(name: "foo", type: .Call, sequenceID: 0)
        p.writeMessageBegin(input)
        // normally you would write a struct plus fields here, but not necessary for this test
        p.writeMessageEnd()
        
        // read it back
        let p2 = TBinaryProtocol(transport: TMemoryBuffer(bytes: mem.buffer))
        let output = p2.readMessageBegin()
        XCTAssertEqual(input.name, output.name, "names must match")
        XCTAssertEqual(input.type, output.type, "message types must match")
        XCTAssertEqual(input.sequenceID, output.sequenceID, "sequence IDs must match")
    }
    
    func testStructSimple() {
        
        // write it out
        let mem = TMemoryBuffer()
        let p = TBinaryProtocol(transport: mem)
        
        p.writeStructBegin("foo")
        
        p.writeFieldBegin("x", type: .I32, id: 1)
        p.writeI32(0x12345678)
        p.writeFieldEnd()

        p.writeFieldBegin("y", type: .String, id: 2)
        p.writeString("om")
        p.writeFieldEnd()
        
        p.writeFieldStop()
        
        p.writeStructEnd()
        
        
        // read it back
        let p2 = TBinaryProtocol(transport: TMemoryBuffer(bytes: mem.buffer))
        
        p2.readStructBegin()
        
        switch p2.readFieldBegin() {
        case .Data(name: _, type: .I32, id: 1):
            XCTAssertEqual(Int32(0x12345678), p2.readI32(), "field value")
        case .Stop:
            XCTFail("unexpected stop field")
        default:
            XCTFail("unexpected field type or ID")
        }
        p2.readFieldEnd()
        
        switch p2.readFieldBegin() {
        case .Data(name: _, type: .String, id: 2):
            XCTAssertEqual("om", p2.readString(), "field value")
        case .Stop:
            XCTFail("unexpected stop field")
        default:
            XCTFail("unexpected field type or ID")
        }
        p2.readFieldEnd()
        
        XCTAssertEqual(Field.Stop, p2.readFieldBegin(), "final field in struct must be followed by a stop field")
    
        p2.readStructEnd()
    }
    
    func testMapOfStringToInt64() {
        
        // write it out
        let mem = TMemoryBuffer()
        let p = TBinaryProtocol(transport: mem)
        
        p.writeMapBegin(.String, valueType: .I64, count: 3)
        p.writeString("unicycle")
        p.writeI64(0)
        p.writeString("bicycle")
        p.writeI64(1)
        p.writeString("tricycle")
        p.writeI64(2)
        p.writeMapEnd()
        
        
        // read it back
        let p2 = TBinaryProtocol(transport: TMemoryBuffer(bytes: mem.buffer))
        
        switch p2.readMapBegin() {
        case (.String, .I64, 3):
            XCTAssertEqual("unicycle", p2.readString())
            XCTAssertEqual(0, p2.readI64())
            XCTAssertEqual("bicycle", p2.readString())
            XCTAssertEqual(1, p2.readI64())
            XCTAssertEqual("tricycle", p2.readString())
            XCTAssertEqual(2, p2.readI64())
        default:
            XCTFail("unexpected list element type or count")
        }
        p2.readMapEnd()
    }
    
    func testListOfStrings() {
        
        // write it out
        let mem = TMemoryBuffer()
        let p = TBinaryProtocol(transport: mem)
        
        p.writeListBegin(.String, count: 3)
        p.writeString("unicycle")
        p.writeString("bicycle")
        p.writeString("tricycle")
        p.writeListEnd()
        
        
        // read it back
        let p2 = TBinaryProtocol(transport: TMemoryBuffer(bytes: mem.buffer))
        
        switch p2.readListBegin() {
        case (.String, 3):
            XCTAssertEqual("unicycle", p2.readString())
            XCTAssertEqual("bicycle", p2.readString())
            XCTAssertEqual("tricycle", p2.readString())
        default:
            XCTFail("unexpected list element type or count")
        }
        p2.readListEnd()
    }
    
    func testSetOfStrings() {
        
        // write it out
        let mem = TMemoryBuffer()
        let p = TBinaryProtocol(transport: mem)
        
        p.writeSetBegin(.String, count: 3)
        p.writeString("unicycle")
        p.writeString("bicycle")
        p.writeString("tricycle")
        p.writeSetEnd()
        
        
        // read it back
        let p2 = TBinaryProtocol(transport: TMemoryBuffer(bytes: mem.buffer))
        
        switch p2.readSetBegin() {
        case (.String, 3):
            XCTAssertEqual("unicycle", p2.readString())
            XCTAssertEqual("bicycle", p2.readString())
            XCTAssertEqual("tricycle", p2.readString())
        default:
            XCTFail("unexpected list element type or count")
        }
        p2.readSetEnd()
    }

    func simpleTest<T>(valueToTest: T, writer: ((TProtocol, T) -> Void), reader: ((TProtocol, T) -> Void)) {
        let mem = TMemoryBuffer()
        let p = TBinaryProtocol(transport: mem)
        writer(p, valueToTest)
        
        let p2 = TBinaryProtocol(transport: TMemoryBuffer(bytes: mem.buffer))
        reader(p2, valueToTest)
    }
    
    func testBool() {
        func test(b: Bool, label: String) {
            simpleTest(b, { $0.writeBool($1) }) {
                XCTAssertEqual($1, $0.readBool(), label)
            }
        }
        
        test(true, "true")
        test(false, "false")
    }
    
    func testByte() {
        func test(i: UInt8, label: String) {
            simpleTest(i, { $0.writeByte($1) }) {
                XCTAssertEqual($1, $0.readByte(), label)
            }
        }
        
        test(0, "zero")
        test(1, "non-zero")
        test(0x7f, "middle")
        test(0xff, "largest possible value")
    }

    func testI16() {
        func test(i: Int16, label: String) {
            simpleTest(i, { $0.writeI16($1) }) {
                XCTAssertEqual($1, $0.readI16(), label)
            }
        }
        
        test(0, "zero")
        test(1, "positive")
        test(-1, "negative")
        test(Int16.min, "smallest possible value")
        test(Int16.max, "largest possible value")
    }
    
    func testI32() {
        func test(i: Int32, label: String) {
            simpleTest(i, { $0.writeI32($1) }) {
                XCTAssertEqual($1, $0.readI32(), label)
            }
        }
        
        test(0, "zero")
        test(1, "positive")
        test(-1, "negative")
        test(Int32.min, "smallest possible value")
        test(Int32.max, "largest possible value")
    }
    
    func testI64() {
        func test(i: Int64, label: String) {
            simpleTest(i, { $0.writeI64($1) }) {
                XCTAssertEqual($1, $0.readI64(), label)
            }
        }
        
        test(0, "zero")
        test(1, "positive")
        test(-1, "negative")
        test(Int64.min, "smallest possible value")
        test(Int64.max, "largest possible value")
    }
    
    func testDouble() {
        func test(d: Double, label: String) {
            simpleTest(d, { $0.writeDouble($1) }) {
                XCTAssertEqual($1, $0.readDouble(), label)
            }
        }
        
        test(0.0, "zero")
        test(-0.0, "negative zero")
        test(1.0, "one")
        test(-1.0, "negative one")
        test(Double.infinity, "infinity")
        test(-Double.infinity, "infinity")
        test(3.14159, "largest possible value")
    }
    
    func testString() {
        func test(s: String, label: String) {
            simpleTest(s, { $0.writeString($1) }) {
                XCTAssertEqual($1, $0.readString(), "in and back out")
            }
        }
        
        test("", "empty string")
        test("a", "single character string")
        test("compassion", "non-zero length")
        test("вот и лето прошло", "unicode")
        test("🈯️🈳🈵🈶🆗🆒", "emoji")
    }
    
    func testBinaryData() {
        func test(d: NSData, label: String) {
            simpleTest(d, { $0.writeBinary($1) }) {
                XCTAssertEqual($1, $0.readBinary(), "in and back out")
            }
        }

        let a0: [UInt8] = []
        test(NSData(bytes: a0, length: countElements(a0)), "0 elements")
        let a1: [UInt8] = [0x0]
        test(NSData(bytes: a1, length: countElements(a1)), "1 element")
        let a3: [UInt8] = [0x0, 0x1, 0x2]
        test(NSData(bytes: a3, length: countElements(a3)), "3 elements")
    }
    
}
