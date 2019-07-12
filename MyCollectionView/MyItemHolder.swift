//
//  MyItemHolder.swift
//  MyCollectionView
//
//  Created by paraches on 2019/07/04.
//  Copyright © 2019 paraches. All rights reserved.
//

import Foundation
import Cocoa

class MyItemHolder {
    var url: URL
    var thumbnail: NSImage?
    var filename: String {
        get {
            return url.lastPathComponent
        }
    }
    
    init(url: URL) {
        self.url = url
        
        if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
            guard CGImageSourceGetType(imageSource) != nil else { return }
            self.thumbnail = self.thumbnailImage(imageSource: imageSource)
        }
    }
    
    func thumbnailImage(imageSource: CGImageSource) -> NSImage? {
        let thumbnailOptions = [kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                                kCGImageSourceThumbnailMaxPixelSize: 128] as [CFString : Any]
        guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil }
        return NSImage(cgImage: thumbnailRef, size: NSSize.zero)
    }
}
