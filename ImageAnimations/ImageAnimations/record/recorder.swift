//
//  recorder.swift
//  ImageAnimations
//
//  Created by Mayank Mangukiya on 17/03/23.
//

import UIKit
import AVFoundation
import Photos
import AVKit


struct RenderSettings {
    
    var width: CGFloat = UIScreen.main.bounds.width * UIScreen.main.scale
    var height: CGFloat = UIScreen.main.bounds.width * UIScreen.main.scale
    var fps: Int32 = 60   //frames per second
    var avCodecKey = AVVideoCodecType.h264
    var videoFilename = "ImageToVideo"
    var videoFilenameExt = "mp4"
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var outputURL: URL {
        
        let fileManager = FileManager.default
        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return tmpDirURL.appendingPathComponent("\(videoFilename)_\(Date())").appendingPathExtension(videoFilenameExt) as URL
        }
        fatalError("URLForDirectory() failed")
        
    }
}


@objc public class Recorder: NSObject {
    
    var displayLink : CADisplayLink?
    var outputPath : NSString?
    var referenceDate : NSDate?
    var imageCounter = 0
    
    public var view : UIView?
    public var name = "image"
    public var outputJPG = false
    
    var imagesArray = [URL]()
    
    public func start() {
        
        if (view == nil) {
            NSException(name: NSExceptionName(rawValue: "No view set"), reason: "You must set a view before calling start.", userInfo: nil).raise()
        }
        else {
            
            self.removeAllFileFromDocumentDirectory()
            self.imageCounter = 0
            
            displayLink = CADisplayLink(target: self, selector: #selector(self.handleDisplayLink(displayLink:)))
            displayLink!.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            referenceDate = NSDate()
        }
    }
    
    public func stop(completion: @escaping (_ saveURL: String) -> Void) {
        
        displayLink?.invalidate()
        
        let seconds = referenceDate?.timeIntervalSinceNow
        if (seconds != nil) {
                        
            let animator = ImageAnimator(renderSettings: RenderSettings(), imagearr: self.imagesArray)
            
            animator.render {
                let u: String = tempurl
                completion(u)
            }
                
        }
        
    }
    
    func removeAllFileFromDocumentDirectory(){
                
        let fileManager = FileManager.default
        let documentsUrl =  self.applicationDocumentsDirectory
        let documentsPath = documentsUrl.path
        
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
            
            for fileName in fileNames {
                if (fileName.hasSuffix(".jpg")) {
                    let filePathName = "\(documentsPath)/\(fileName)"
                    try fileManager.removeItem(atPath: filePathName)
                }
            }
            
            try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
                
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        
        self.imagesArray.removeAll()
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1] as URL
        
    }()
    
    @objc func handleDisplayLink(displayLink : CADisplayLink) {
        if (view != nil) {
            createImageFromView(captureView: view!)
        }
    }
    
    func outputPathString() -> String {
        if (outputPath != nil) {
            return outputPath! as String
        }
        else {
            return applicationDocumentsDirectory.absoluteString
        }
    }
    
    func createImageFromView(captureView : UIView) {
        
        UIGraphicsBeginImageContextWithOptions(captureView.bounds.size, false, 0)
        captureView.drawHierarchy(in: captureView.bounds, afterScreenUpdates: false)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        let fileExtension = "jpg"
        let data : Data? = image?.jpegData(compressionQuality: 1)
        
        var path = outputPathString()
        path = path + "/\(name)-\(imageCounter).\(fileExtension)"
        
        imageCounter = imageCounter + 1
        
        self.imagesArray.append(URL(string: path)!)
        
        if let imageRaw = data {
            do {
                try imageRaw.write(to: URL(string: path)!, options: .atomic)
            } catch {
            }
        }
        
        UIGraphicsEndImageContext()
        
    }
    
}



class ImageAnimator {
    
    static let kTimescale: Int32 = 600
    
    let settings: RenderSettings
    let videoWriter: VideoWriter
    var images: [URL]!
    
    var frameNum = 0
    
    class func removeFileAtURL(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        }
        catch _ as NSError {
            //
        }
    }
    
    init(renderSettings: RenderSettings,imagearr: [URL]) {
        settings = renderSettings
        videoWriter = VideoWriter(renderSettings: settings)
        images = imagearr
    }
    
    func render(completion: @escaping ()->Void) {
        
        // The VideoWriter will fail if a file exists at the URL, so clear it out first.
        ImageAnimator.removeFileAtURL(fileURL: settings.outputURL)
        
        videoWriter.start()
        videoWriter.render(appendPixelBuffers: appendPixelBuffers) {
            let s: String = self.settings.outputURL.path
            tempurl = s
            completion()
        }
        
    }
    
    func appendPixelBuffers(writer: VideoWriter) -> Bool {
        
        let frameDuration = CMTimeMake(value: Int64(ImageAnimator.kTimescale / settings.fps), timescale: ImageAnimator.kTimescale)
        
        while !images.isEmpty {
            
            if writer.isReadyForData == false {
                return false
            }
            
            let image = images.removeFirst()
            
            if let dicImage = UIImage(contentsOfFile: image.path) {
                
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameNum))
                let success = videoWriter.addImage(image: dicImage, withPresentationTime: presentationTime)
                if success == false {
                    fatalError("addImage() failed")
                }
                
                frameNum=frameNum+1
            }
            
        }
        
        return true
    }
    
}



class VideoWriter {
    
    let renderSettings: RenderSettings
    
    var videoWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    var isReadyForData: Bool {
        return videoWriterInput?.isReadyForMoreMediaData ?? false
    }
    
    class func pixelBufferFromImage(image: UIImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer {
        
        autoreleasepool {
            
            var pixelBufferOut: CVPixelBuffer? = nil
            
            let options = [
                kCVPixelBufferCGImageCompatibilityKey : true,
                kCVPixelBufferCGBitmapContextCompatibilityKey : true
            ] as CFDictionary
            
            
            let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options, &pixelBufferOut)
            //let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
            
            if status != kCVReturnSuccess {
                fatalError("CVPixelBufferPoolCreatePixelBuffer() failed")
            }
            
            let pixelBuffer = pixelBufferOut!
            
            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            
            let data = CVPixelBufferGetBaseAddress(pixelBuffer)
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: data, width: Int(size.width), height: Int(size.height),
                                    bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            
            context!.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            let horizontalRatio = size.width / image.size.width
            let verticalRatio = size.height / image.size.height
            
            let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit
            
            let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
            
            let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : 0
            let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : 0
            
            context!.concatenate(CGAffineTransform.identity)
            context!.draw(image.cgImage!, in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            
            return pixelBuffer
        }
    }
    
    init(renderSettings: RenderSettings) {
        self.renderSettings = renderSettings
    }
    
    func start() {
        
        let avOutputSettings: [String: AnyObject] = [
            AVVideoCodecKey: renderSettings.avCodecKey as AnyObject,
            AVVideoWidthKey: NSNumber(value: Float(renderSettings.width)),
            AVVideoHeightKey: NSNumber(value: Float(renderSettings.height))
        ]
        
        func createPixelBufferAdaptor() {
            let sourcePixelBufferAttributesDictionary = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.height))
            ]
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput,
                                                                      sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        }
        
        func createAssetWriter(outputURL: URL) -> AVAssetWriter {
            guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4) else {
                fatalError("AVAssetWriter() failed")
            }
            
            guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else {
                fatalError("canApplyOutputSettings() failed")
            }
            
            return assetWriter
        }
        
        videoWriter = createAssetWriter(outputURL: renderSettings.outputURL)
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }
        else {
            fatalError("canAddInput() returned false")
        }
        
        
        createPixelBufferAdaptor()
        
        if videoWriter.startWriting() == false {
            fatalError("startWriting() failed")
        }
        
        videoWriter.startSession(atSourceTime: CMTime.zero)
        
        precondition(pixelBufferAdaptor.pixelBufferPool != nil, "nil pixelBufferPool")
    }
    
    
    func render(appendPixelBuffers: @escaping (VideoWriter)->Bool, completion: @escaping ()->Void) {

        autoreleasepool {
            
            precondition(videoWriter != nil, "Call start() to initialze the writer")

            let queue = DispatchQueue(label: "mediaInputQueue")
            videoWriterInput.requestMediaDataWhenReady(on: queue) {
                let isFinished = appendPixelBuffers(self)
                if isFinished {
                    self.videoWriterInput.markAsFinished()
                    self.videoWriter.finishWriting() {
                        DispatchQueue.main.async {
                            completion()
                            self.videoWriter.cancelWriting()
                        }
                    }
                }
            }
        }
        
    }
    
    func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
        
        autoreleasepool {
            precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
            
            let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: renderSettings.size)
            return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        }
            
    }
    
}
