//
//  CVPixelBuffer+Resize.swift
//  TuriML
//
//  Created by Volker Bublitz on 14.06.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import Foundation
import CoreVideo
import Accelerate

extension CVPixelBuffer {
    
    public func resizedPixelBuffer(cropX: Int,
                       cropY: Int,
                       cropWidth: Int,
                       cropHeight: Int,
                       scaleWidth: Int,
                       scaleHeight: Int) -> CVPixelBuffer? {
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        guard let srcData = CVPixelBufferGetBaseAddress(self) else {
            print("Error: could not get pixel buffer base address")
            return nil
        }
        let srcBytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let offset = cropY*srcBytesPerRow + cropX*4
        var srcBuffer = vImage_Buffer(data: srcData.advanced(by: offset),
                                      height: vImagePixelCount(cropHeight),
                                      width: vImagePixelCount(cropWidth),
                                      rowBytes: srcBytesPerRow)
        
        let destBytesPerRow = scaleWidth*4
        guard let destData = malloc(scaleHeight*destBytesPerRow) else {
            print("Error: out of memory")
            return nil
        }
        var destBuffer = vImage_Buffer(data: destData,
                                       height: vImagePixelCount(scaleHeight),
                                       width: vImagePixelCount(scaleWidth),
                                       rowBytes: destBytesPerRow)
        
        let error = vImageScale_ARGB8888(&srcBuffer, &destBuffer, nil, vImage_Flags(0))
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        if error != kvImageNoError {
            print("Error:", error)
            free(destData)
            return nil
        }
        
        let releaseCallback: CVPixelBufferReleaseBytesCallback = { _, ptr in
            if let ptr = ptr {
                free(UnsafeMutableRawPointer(mutating: ptr))
            }
        }
        let pixelFormat = CVPixelBufferGetPixelFormatType(self)
        var dstPixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreateWithBytes(nil, scaleWidth, scaleHeight,
                                                  pixelFormat, destData,
                                                  destBytesPerRow, releaseCallback,
                                                  nil, nil, &dstPixelBuffer)
        
        if status != kCVReturnSuccess {
            print("Error: could not create new pixel buffer")
            free(destData)
            return nil
        }
        return dstPixelBuffer
    }
    
    /**
     Resizes a CVPixelBuffer to a new width and height.
     */
    public func resizedPixelBuffer(width targetWidth: Int, height targetHeight: Int) -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let minSideLength = min(width, height)
        return self.resizedPixelBuffer(cropX: Int(Double(width)/2.0 - Double(minSideLength)/2.0),
                                       cropY: Int(Double(height)/2.0 - Double(minSideLength)/2.0),
                                 cropWidth: minSideLength,
                                 cropHeight: minSideLength,
                                 scaleWidth: targetWidth, scaleHeight: targetHeight)
    }
}
