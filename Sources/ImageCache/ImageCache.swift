//
//  ImageCache.swift
//  ImageCache
//
//  Created by bujiandi on 2018/10/25.
//  Copyright © 2018 bujiandi. All rights reserved.
//


import UIKit
import HTTP

fileprivate var imageClient = HTTP.Client(concurrentCount: 20)
fileprivate let imageCache = Cache<String, UIImage>(costLimit: 100 * 1024 * 1024)

extension UIImage : Costable {
    public var cost: Int { return Int(size.width * size.height) }
}


private var kCurrentImageLoadQueue = "current.image.load.queue"

extension Imagable {
    
    fileprivate func cancelCurrentLoader() {
        if let queue = objc_getAssociatedObject(self, &kCurrentImageLoadQueue) as? HTTP.Queue {
            objc_setAssociatedObject(self, &kCurrentImageLoadQueue, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            queue.cancel()
//            queue.request
        }
        updateComplete()
    }
    
    fileprivate func finishDownload() {
        objc_setAssociatedObject(self, &kCurrentImageLoadQueue, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        updateComplete()
    }
    
    fileprivate func download(_ url:URL, once:Bool, _ failure:UIImage? = UIImage.downloadSetting.failure) {
        
        let queue = imageClient.queueRequest(url: url) {
            // 图片下载到 bookmark 缓存. 如果已存在, 则展示缓存内容
            $0.downloadToBookmarkCache { [weak self] (previewCacheURL) in
                let path = previewCacheURL.absoluteString
                guard let this = self else { return }
                guard let image = UIImage(contentsOfFile: path) else { return }
                
                let md5 = url.absoluteString.md5
                imageCache[md5] = image
                this.update(image: image)
                
                if once { this.cancelCurrentLoader() }
            }
            
            $0.responseImage { [weak self](image) in
                guard let this = self else { return }
                
                let md5 = url.absoluteString.md5
                imageCache[md5] = image
                
                this.update(image: image)
                this.finishDownload()
            }
        }
        queue.onComplete { [weak queue, weak self] in
            
            guard let this = self else { return }
            guard let queue = queue else { return }
            guard let error = $0 else { return }
            
            let retryCount = 1 + queue.retryCount
            
            switch error {
            case let err as HTTP.RequestError where err.isCanceled : break
            case let err as NSError where err.code == -999: break
            default:
                if retryCount < UIImage.downloadSetting.autoRetryCount {
                    queue.send(use: imageClient)
                } else {
                    this.update(image: failure)
                    this.updateComplete()
                }
            }

        }
        
//        if let view = self as? NetOverlay {
//            _ = group.overlay(view)
//        }
//        if let retry = self as? NetFailureRetryOverlay {
//            _ = group.failure(showRetryOn: retry)
//        }
        
        objc_setAssociatedObject(self, &kCurrentImageLoadQueue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        queue.send(use: imageClient)
    }
    
    @available(iOS 4.0, *)
    public func load(url:URL, downOnce:Bool = true,
                     placeholder:UIImage? = UIImage.downloadSetting.placeholder,
                     failure:UIImage? = UIImage.downloadSetting.failure) {
        
        let md5 = url.absoluteString.md5
        var image:UIImage? = imageCache[md5]
        
        if url.isFileURL {
            if image == nil {
                DispatchQueue.utility.async {
                    image = UIImage(contentsOfFile: url.relativePath)
                    DispatchQueue.main.async { [weak self] in
                        self?.update(image: image)
                        self?.updateComplete()
                    }
                }
            }
            return
        }
        
        update(image: image ?? placeholder)
        
        // 如果内存中有图片 并且 图片无需更新, 则直接忽略
        if image != nil, downOnce { return updateComplete() }
        
        // TODO: 使用缓存 和子线程 优化性能
        DispatchQueue.utility.async { [weak self] in
            let bookmarkFile = HTTP.bookmarkFileFor(key: url.absoluteString)
            let fileManager = FileManager.default
            var isDir:ObjCBool = false
            
            var needDownload = true
            defer {
                if needDownload {
                    self?.download(url, once: downOnce, failure)
                } else if !downOnce {
                    self?.download(url, once: downOnce, failure)
                }
            }
            
            // 如果从未下载过则直接开始
            if !fileManager.fileExists(atPath: bookmarkFile, isDirectory: &isDir) || isDir.boolValue {
                return
            }
            
            guard let fileURL = try? URL(resolvingAliasFileAt: URL(fileURLWithPath: bookmarkFile)) else {
                // 书签无效
                return
            }
            
//            guard let data = try? Data(contentsOf: URL(fileURLWithPath: bookmarkFile)), data.count > 0 else {
//                // 书签数据无效
//                return
//            }
//            var isStale:Bool = false
//            URL.init(resolvingAliasFileAt: <#T##URL#>, options: <#T##URL.BookmarkResolutionOptions#>)
//            guard let optionURL = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale) as URL?, let fileURL = optionURL else {
//                // 书签无效
//                return
//            }
            
            let filePath = fileURL.relativePath
            if !fileManager.fileExists(atPath: filePath, isDirectory: &isDir) || isDir.boolValue {
                // 书签指向真实文件不存在, 删除书签
                try? fileManager.removeItem(atPath: bookmarkFile)
                return
            }
            
            guard let image = UIImage(contentsOfFile: filePath) else {
                // 文件大小异常, 删除文件
                try? fileManager.removeItem(atPath: filePath)
                return
            }
            needDownload = false
            DispatchQueue.main.sync { [weak self] in
                imageCache[md5] = image
                self?.update(image: image)
                self?.updateComplete()
            }
            
        }
    }
    
}
