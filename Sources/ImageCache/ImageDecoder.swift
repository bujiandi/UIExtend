//
//  ImageDecoder.swift
//  ImageCache
//
//  Created by bujiandi on 2018/10/25.
//  Copyright © 2018 bujiandi. All rights reserved.
//

import UIKit
import HTTP

extension HTTP.Request {
    
    public mutating func responseImage(_ callback: @escaping (UIImage) throws -> Void) {
        response(decoder: HTTP.imageDecoder, onSuccess: callback)
    }
    
}

extension HTTP {
    
    // MARK: - 图片下载解析
    public class ImageDecoder : HTTPResponeDecoder {
        
        public typealias Result = UIImage
        
        public func decode(request:URLRequest, response: HTTPURLResponse, data: Data) throws -> Result {
            
            let fileURL = try downDecoder.decode(request: request, response: response, data: data)
            
            guard let image = UIImage(contentsOfFile: fileURL.relativePath) else {
                throw HTTP.ResponseError.unknowImageURL(request.url, fileURL)
            }
            
            return image
        }
        
    }
    
    public static let imageDecoder = ImageDecoder()
}
