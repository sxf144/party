//
//  PhotoManager.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import Photos

class PhotoManager: NSObject {
    
    static let shared = PhotoManager()
    
    private override init() {
        super.init()
    }
}

extension PhotoManager {
    
    func fetchAssetData(asset: PHAsset, completion: @escaping (Data?, TimeInterval?, String?) -> Void) {
        switch asset.mediaType {
        case .image:
            // 如果是图片
            fetchImageData(for: asset, completion: completion)
        case .video:
            // 如果是视频
            fetchVideoData(for: asset, completion: completion)
        default:
            // 其他类型，可以根据需要进行处理
            completion(nil, nil, nil)
        }
    }

    func fetchImageData(for asset: PHAsset, completion: @escaping (Data?, TimeInterval?, String?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        
        // 获取文件后缀
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (data, _, _, _) in
            var fileExtension:String?
            // 获取资源的文件名
            let assetResources = PHAssetResource.assetResources(for: asset)
            // 如果资源存在
            if let firstResource = assetResources.first {
                // 获取文件名的扩展（后缀）
                fileExtension = firstResource.originalFilename.pathExtension
            }
            
            completion(data, nil, fileExtension)
        }
    }

    func fetchVideoData(for asset: PHAsset, completion: @escaping (Data?, TimeInterval?, String?) -> Void) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            guard let avAsset = avAsset as? AVURLAsset else {
                completion(nil, nil, nil)
                return
            }

            do {
                let videoData = try Data(contentsOf: avAsset.url)
                let duration = avAsset.duration.seconds

                // 获取文件后缀
                let fileExtension = avAsset.url.pathExtension

                completion(videoData, duration, fileExtension)
            } catch {
                print("Error fetching video data: \(error.localizedDescription)")
                completion(nil, nil, nil)
            }
        }
    }
}


