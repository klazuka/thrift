import Foundation

/*
class TSocketTransport: TNSStreamTransport {
    let hostname: String
    let port: Int

    init(hostname: String, port: Int) {
        self.hostname = hostname
        self.port = port
        
        // what to do here?
        // TODO: watch WWDC interop
        var cfRead: CFReadStreamRef?
        var cfWrite: CFWriteStreamRef?
        
        let cfr = Unmanaged.fromOpaque(cfRead)
        let cfw = Unmanaged.fromOpaque(cfWrite)
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, hostname.bridgeToObjectiveC(), UInt32(port), cfr, cfw)

        super.init(inStream: cfRead, outStream: cfWrite)
    }
}
*/
