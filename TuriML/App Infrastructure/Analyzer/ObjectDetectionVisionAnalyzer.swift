//
//  CoreMLAnalyzer.swift
//  TuriML
//
//  Created by Volker Bublitz on 10.06.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import UIKit
import Vision
import os.log

class ObjectDetectionVisionAnalyzer : ImageAnalyzer {
    
    var analyzing = false
    var model: VNCoreMLModel
    
    init() throws {
        model = try VNCoreMLModel(for: MyModel().model)
    }
    
    func analyze(pixelBuffer: CVPixelBuffer, callback: @escaping ([DetectionResult]?) -> Void) {
        let request = VNCoreMLRequest(model: model) {
            self.mlRequestCompletion($0, $1, callback)
        }
        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])
        }
        catch {
            callback(nil)
        }
    }
    
    private func mlRequestCompletion(_ request: VNRequest, _ error: Error?,
                                     _ callback: @escaping ([DetectionResult]?) -> Void) {
        if let err = error {
            os_log("Error analyzing pixel buffer: %@", err.localizedDescription)
            callback(nil)
            return
        }
        handleVNRequest(request, callback: callback)
    }

    private func handleVNRequest(_ request: VNRequest, callback: @escaping ([DetectionResult]?) -> Void) {
        
        let observations = request.results as? [VNRecognizedObjectObservation]
        guard let qualityMatches = observations?.filter({ $0.confidence > Config.minimumRecognitionConfidence }),
            qualityMatches.count > 0 else {
            callback(nil)
            return
        }
        
        let maxPresentableResultCount = min(Config.resultDisplayMaxCount, qualityMatches.count)
        let result = qualityMatches.prefix(upTo: maxPresentableResultCount).map {
            DetectionResult(name: $0.labels.first?.identifier, match: $0.confidence, coordinates: $0.boundingBox)
        }
        callback(result)
    }
    
}
