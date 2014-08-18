//
//  Builder.swift
//  Thrift
//
//  Created by Keith Lazuka on 8/16/14.
//  Copyright (c) 2014 Acompli. All rights reserved.
//

import Foundation

let DEFAULT_CHUNK_SIZE = 4096

enum BuildSignal {
    case Done
    // case BufferFull(...)
    // case InsertChunks(...)
}

typealias Builder = NSMutableData -> BuildSignal


func toNSData(b: Builder) -> NSData {
    let buf = NSMutableData(capacity: DEFAULT_CHUNK_SIZE)
    return run(b, buf)
}

func toSwiftByteArray(b: Builder) -> [UInt8] {
    let data = toNSData(b)
    var array = [UInt8](count: data.length, repeatedValue: 0)
    data.getBytes(&array)
    return array
}

func run(b: Builder, buf: NSMutableData) -> NSData {
    switch b(buf) {
    case .Done:
        println("run: done")
        return buf
    }
}

infix operator <> { associativity right }
func <>(lhs: Builder, rhs: Builder) -> Builder {
    return { buf in
        run(rhs, buf)
        run(lhs, buf)
        return .Done
    }
}

//MARK:- fixed primitive builders

func buildBytes(x: [UInt8]) -> Builder {
    //TODO: directly pass the pointer to the in-memory rep of the argument
    // for some reason, I can't get UnsafePointer to compile
    return { buf in
        var bytes = x
        buf.appendBytes(&bytes, length: bytes.count)
        return .Done
    }
}

func buildByte(x: UInt8) -> Builder {
    //TODO: directly pass the pointer to the in-memory rep of the argument
    // for some reason, I can't get UnsafePointer to compile
    return { buf in
        var bytes = [x]
        buf.appendBytes(&bytes, length: bytes.count)
        return .Done
    }
}

func buildInt16BE(x: Int16) -> Builder {
    //TODO: directly pass the pointer to the in-memory rep of the argument
    // for some reason, I can't get UnsafePointer to compile
    return { buf in
        var bytes = [
            UInt8(x >> 8),
            UInt8(x >> 0),
        ]
        buf.appendBytes(&bytes, length: bytes.count)
        return .Done
    }
}

func buildUInt32BE(x: UInt32) -> Builder {
    //TODO: directly pass the pointer to the in-memory rep of the argument
    // for some reason, I can't get UnsafePointer to compile
    return { buf in
        var bytes = [
            UInt8(x >> 24),
            UInt8(x >> 16),
            UInt8(x >> 8),
            UInt8(x >> 0),
        ]
        buf.appendBytes(&bytes, length: bytes.count)
        return .Done
    }
}

func buildInt32BE(x: Int32) -> Builder {
    //TODO: directly pass the pointer to the in-memory rep of the argument
    // for some reason, I can't get UnsafePointer to compile
    return { buf in
        var bytes = [
            UInt8(x >> 24),
            UInt8(x >> 16),
            UInt8(x >> 8),
            UInt8(x >> 0),
        ]
        buf.appendBytes(&bytes, length: bytes.count)
        return .Done
    }
}

func buildInt64BE(x: Int64) -> Builder {
    //TODO: directly pass the pointer to the in-memory rep of the argument
    // for some reason, I can't get UnsafePointer to compile
    return { buf in
        var bytes = [
            UInt8(x >> 56),
            UInt8(x >> 48),
            UInt8(x >> 40),
            UInt8(x >> 32),
            UInt8(x >> 24),
            UInt8(x >> 16),
            UInt8(x >> 8),
            UInt8(x >> 0),
        ]
        buf.appendBytes(&bytes, length: bytes.count)
        return .Done
    }
}

func buildDoubleBE(x: Double) -> Builder {
    //TODO: directly pass the pointer to the in-memory rep of the argument
    // for some reason, I can't get UnsafePointer to compile
    let y = thriftDoubleToUInt64(x)
    return { buf in
        var bytes = [
            UInt8(y >> 56),
            UInt8(y >> 48),
            UInt8(y >> 40),
            UInt8(y >> 32),
            UInt8(y >> 24),
            UInt8(y >> 16),
            UInt8(y >> 8),
            UInt8(y >> 0),
        ]
        buf.appendBytes(&bytes, length: bytes.count)
        return .Done
    }
}
