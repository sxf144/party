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
        options.deliveryMode = .highQualityFormat
        
        /**
         * 获取原图方式
         */
//        // 获取文件数据
//        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (data, _, _, _) in
//            // 获取后缀
//            var fileExtension:String?
//            // 获取资源的文件名
//            let assetResources = PHAssetResource.assetResources(for: asset)
//            // 如果资源存在
//            if let firstResource = assetResources.first {
//                // 获取文件名的扩展（后缀）
//                fileExtension = firstResource.originalFilename.pathExtension
//            }
//            
//            completion(data, nil, fileExtension)
//        }
        
        /**
         * 压缩图片为jpg方式
         */
        // 获取图像的原始尺寸
        var targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        // 需要压缩尺寸，最小边不能大于1080
        let limitMin: Double = 1080
        if targetSize.width > limitMin && targetSize.height > limitMin {
            if targetSize.width > targetSize.height {
                targetSize.height = limitMin
                targetSize.width = targetSize.width/targetSize.height*limitMin
            } else {
                targetSize.width = limitMin
                targetSize.height = targetSize.height/targetSize.width*limitMin
            }
        }
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
            guard let image = image, let imageData = image.jpegData(compressionQuality: 0.8) else {
                completion(nil, nil, nil)
                return
            }

            completion(imageData, nil, "jpg")
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


