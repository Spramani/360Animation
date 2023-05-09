//
//  imgDownload.swift
//  ImageAnimations
//
//  Created by Mayank Mangukiya on 27/04/23.
//
import UIKit
import Foundation
import Photos


extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

class ImageSaveManager{
    
    func saveImageToAlbum(_ image: UIImage, name: String) {
        
        if let collection = fetchAssetCollection(name) {
            self.saveImageToAssetCollection(image, collection: collection)
        } else {
            // Album does not exist, create it and attempt to save the image
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            }, completionHandler: { (success: Bool, error: Error?) in
                guard success == true && error == nil else {
                    NSLog("Could not create the album")
                    if let err = error {
                        NSLog("Error: \(err)")
                    }
                    return
                }
                
                if let newCollection = self.fetchAssetCollection(name) {
                    self.saveImageToAssetCollection(image, collection: newCollection)
                }
            })
        }
    }
    
    func fetchAssetCollection(_ name: String) -> PHAssetCollection? {
        
        let fetchOption = PHFetchOptions()
        fetchOption.predicate = NSPredicate(format: "title == '" + name + "'")
        
        let fetchResult = PHAssetCollection.fetchAssetCollections(
            with: PHAssetCollectionType.album,
            subtype: PHAssetCollectionSubtype.albumRegular,
            options: fetchOption)
        
        return fetchResult.firstObject
    }
    
    func saveImageToAssetCollection(_ image: UIImage, collection: PHAssetCollection) {
        
        PHPhotoLibrary.shared().performChanges({
            let pngData = image.pngData()
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            creationRequest.addResource(with: PHAssetResourceType.photo, data: pngData!, options: options)
            if let request = PHAssetCollectionChangeRequest(for: collection),
               let placeHolder = creationRequest.placeholderForCreatedAsset {
                request.addAssets([placeHolder] as NSFastEnumeration)
            }
        }, completionHandler: { (success: Bool, error: Error?) in
            guard success == true && error == nil else {
                NSLog("Could not save the image")
                if let err = error {
                    NSLog("Error: " + err.localizedDescription)
                }
                return
            }
        })
    }
}
