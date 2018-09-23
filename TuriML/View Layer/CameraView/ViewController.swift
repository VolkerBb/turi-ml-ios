//
//  ViewController.swift
//  MLImageDetection
//
//  Created by Volker Bublitz on 08.06.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import UIKit
import AVFoundation

enum ExecutionMode {
    case running, error
}

class ViewController: UIViewController, CameraSessionDelegate {
    
    private var carAnalyzer: ImageAnalyzer?
    private lazy var resultIndicatorDataSource = KeywordResultIndicatorDatasource()
    
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var resultView: ResultView!
    
    private var mode = ExecutionMode.running
    private var lastDisplayTimestamp: TimeInterval = Date.distantPast.timeIntervalSinceReferenceDate
    
    private lazy var cameraSession:CameraSession = {
        let result = CameraSession()
        result.delegate = self
        return result
    }()
    
    private lazy var previewLayer:AVCaptureVideoPreviewLayer = {
        let result = AVCaptureVideoPreviewLayer(session: cameraSession.captureSession)
        result.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return result
    }()
    
    // MARK: - view lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareAnalysis()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard mode == .running else {
            return
        }
        previewLayer.frame = previewContainer.layer.bounds
    }
    
    // MARK: -    
    private func prepareAnalysis() {
        do {
            try carAnalyzer = Config.imageAnalyzer()
            resultView.resultIndicatorDataSource = resultIndicatorDataSource
            cameraSession.startSession()
            previewContainer.layer.addSublayer(previewLayer)
        }
        catch (let error) {
            mode = .error
            resultView.text = error.localizedDescription
        }
    }
    
    private func setResult(_ carResult: [DetectionResult]?) {
        guard let results = carResult else {
            resultView.text = nil
            return
        }
        resultView.text = string(fromResults: results)
    }
    
    private func string(fromResults results: [DetectionResult]) -> String {
        return results.map {
            let percentage = CGFloat($0.match * 100.0)
            return String(format: "%@ (%.2f%%)", $0.name ?? "", percentage)
            }.joined(separator: "\n")
    }
    
    private func analyzeAndDisplayResult(pixelBuffer: CVPixelBuffer) {
        carAnalyzer?.analyze(pixelBuffer: pixelBuffer, callback: { result in
            DispatchQueue.main.async {
                self.lastDisplayTimestamp = Date().timeIntervalSinceReferenceDate
                self.setResult(result)
            }
        })
    }
    
    // MARK: - CameraSessionDelegate
    func capturingStarted() {
        previewLayer.connection?.videoOrientation = Config.videoOrientation
    }
    
    func capturingError(error: CaptureSessionError) {
        mode = .error
        let text = NSLocalizedString("No permission to access camera.", comment: "No permission to access camera.")
        DispatchQueue.main.async {
            self.resultView.text = text
        }
    }
    
    func captured(pixelBuffer: CVPixelBuffer) {
        if (Date().timeIntervalSinceReferenceDate - lastDisplayTimestamp > Config.resultDisplayFreezeTime) {
            analyzeAndDisplayResult(pixelBuffer: pixelBuffer)
        }
    }
    
}

