//
//  WKEncoderValueContainer.swift
//  云成绩
//
//  Created by 小歪 on 2018/6/30.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

extension WKScriptHandlerParamsEncoder {
    
    public struct ValueContainer : SingleValueDecodingContainer {
        
        private var encoder:WKScriptHandlerParamsEncoder
        public init(_ decoder:WKScriptHandlerParamsEncoder, path:[CodingKey]) {
            encoder = decoder
            encoder.type = .value
            codingPath = path
        }
        
        public var codingPath: [CodingKey]

        public func decodeNil() -> Bool {
            return true
        }
        
        public func decode(_ type: Bool.Type) throws -> Bool {
            return false
        }
        
        public func decode(_ type: String.Type) throws -> String {
            return ""
        }
        
        public func decode(_ type: Double.Type) throws -> Double {
            return 0
        }
        
        public func decode(_ type: Float.Type) throws -> Float {
            return 0
        }
        
        public func decode(_ type: Int.Type) throws -> Int {
            return 0
        }
        
        public func decode(_ type: Int8.Type) throws -> Int8 {
            return 0
        }
        
        public func decode(_ type: Int16.Type) throws -> Int16 {
            return 0
        }
        
        public func decode(_ type: Int32.Type) throws -> Int32 {
            return 0
        }
        
        public func decode(_ type: Int64.Type) throws -> Int64 {
            return 0
        }
        
        public func decode(_ type: UInt.Type) throws -> UInt {
            return 0
        }
        
        public func decode(_ type: UInt8.Type) throws -> UInt8 {
            return 0
        }
        
        public func decode(_ type: UInt16.Type) throws -> UInt16 {
            return 0
        }
        
        public func decode(_ type: UInt32.Type) throws -> UInt32 {
            return 0
        }
        
        public func decode(_ type: UInt64.Type) throws -> UInt64 {
            return 0
        }
        
        public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try T(from: encoder)
        }
        
        
    }
}
