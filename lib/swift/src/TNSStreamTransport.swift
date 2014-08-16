import Foundation

class TNSStreamTransport: TTransport {
    let inStream: NSInputStream
    let outStream: NSOutputStream
    
    init(inStream: NSInputStream, outStream: NSOutputStream) {
        self.inStream = inStream
        self.outStream = outStream
    }
    
    func read(numBytes: Int) -> [UInt8] {
        let ptr = UnsafeMutablePointer<UInt8>.alloc(numBytes)
        var got = 0
        while got < numBytes {
            let k = inStream.read(ptr+got, maxLength: numBytes-got)
            if k <= 0 {
                fatalError("end of read stream")
            }
            got += k
        }
        
        //TODO: is there really no better way to do this?
        //      maybe using withUnsafePointerToElements()?
        let a = Array(UnsafeBufferPointer(start: ptr, length: got))
        ptr.destroy(numBytes)
        return a
    }
    
    func write(bytes: [UInt8]) {
        let ptr = UnsafePointer<UInt8>(bytes)
        let numBytes = countElements(bytes)
        var got = 0
        while got < numBytes {
            let k = outStream.write(ptr+got, maxLength: numBytes-got)
            if k == -1 {
                fatalError("error writing to output stream")
            } else if k == 0 {
                fatalError("end of output stream")
            } else {
                got += k
            }
        }
    }
    
    func flush() {
        // no-op
    }
}
