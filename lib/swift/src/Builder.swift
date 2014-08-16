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
    switch b(buf) {
    case .Done:
        println("done")
    }
    return buf
}


//MARK:- fixed primitive builders

func build(x: UInt8) -> Builder {
    //TODO: directly pass the pointer to the in-memory rep of the argument
    // for some reason, I can't get UnsafePointer to compile
    return { buf in
        var bytes = [x]
        buf.appendBytes(&bytes, length: bytes.count)
        return .Done
    }
}

func buildBE(x: Int16) -> Builder {
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

func buildBE(x: Int32) -> Builder {
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

func buildBE(x: Int64) -> Builder {
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
