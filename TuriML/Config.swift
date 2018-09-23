//
//  Config.swift
//  TuriML
//
//  Created by Volker Bublitz on 11.06.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import Foundation
import AVFoundation

struct Config {
    
    static func imageAnalyzer() throws -> ImageAnalyzer {
        return try ObjectDetectionVisionAnalyzer()
//        return ImageClassificationVisionAnalyzer()
    }
    
    /// value from 0-1, which defines the minimum probability for a recognition result to be accepted
    static let minimumRecognitionConfidence: Float = 0.2
    static let resultDisplayMaxCount = 3
    static let resultDisplayFreezeTime = 1.05
    static let showBoundingBox = false
    
    static let keywords = ["Dragon", "Dog"]
    
    static let cameraPosition = AVCaptureDevice.Position.back
    static let cameraQuality = AVCaptureSession.Preset.high
    static let videoOrientation = AVCaptureVideoOrientation.portrait
    static let pixelBufferFormat = kCVPixelFormatType_32BGRA
}
