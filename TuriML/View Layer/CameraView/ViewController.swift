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

class ViewController: UIViewController {
    
    var detectedObjects:[DetectionResult] = []
    
    private var analyzer: ImageAnalyzer?
    private lazy var resultIndicatorDataSource = KeywordResultIndicatorDatasource()
    
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultView: ResultView!
    var currentResults:[DetectionResult]? {
        didSet {
            drawLayer.setNeedsDisplay()
            if (Date().timeIntervalSinceReferenceDate - lastDisplayTimestamp > Config.resultDisplayFreezeTime) {
                self.lastDisplayTimestamp = Date().timeIntervalSinceReferenceDate
                guard let results = currentResults else {
                    resultView.text = nil
                    return
                }
                resultView.text = string(fromResults: results)
            }
        }
    }
    var imageYOffset: CGFloat?
    
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
    
    private lazy var drawLayer:CAShapeLayer = {
        let result = CAShapeLayer()
        result.frame = previewLayer.frame
        result.delegate = self
        result.setNeedsDisplay()
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
        drawLayer.frame = previewLayer.bounds
    }
    
    // MARK: -    
    private func prepareAnalysis() {
        do {
            try analyzer = Config.imageAnalyzer()
            resultView.resultIndicatorDataSource = resultIndicatorDataSource
            cameraSession.startSession()
            previewContainer.layer.addSublayer(previewLayer)
            previewContainer.layer.addSublayer(drawLayer)
        }
        catch (let error) {
            mode = .error
            resultView.text = error.localizedDescription
        }
    }
    
    private func string(fromResults results: [DetectionResult]) -> String {
        return results.map {
            let percentage = CGFloat($0.match * 100.0)
            return String(format: "%@ (%.2f%%)", $0.name ?? "", percentage)
            }.joined(separator: "\n")
    }
    
    private func analyzeAndDisplayResult(pixelBuffer: CVPixelBuffer) {
        guard let _ = imageYOffset else {
            DispatchQueue.main.async {
                self.lockOffset(pixelBuffer: pixelBuffer)
            }
            return
        }
        analyzer?.analyze(pixelBuffer: pixelBuffer, callback: { result in
            DispatchQueue.main.async {
                result?.forEach({ (result) in
                    if result.match > 0.7,
                        !self.detectedObjects.containsTitle(ofOtherResult: result) {
                        let lastRowIndex = self.detectedObjects.count
                        self.detectedObjects.append(result)
                        self.tableView.insertRows(at: [IndexPath(row: lastRowIndex, section: 0)], with: .automatic)
                        return
                    }
                })
                self.currentResults = result
            }
        })
    }
    
    private func lockOffset(pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let prHeight = self.previewContainer.bounds.height
        let extent = ciImage.extent
        let extRatio = extent.height / extent.width
        self.imageYOffset = (prHeight / extRatio) / 2.0
    }
}

extension ViewController: CameraSessionDelegate {
    
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
        analyzeAndDisplayResult(pixelBuffer: pixelBuffer)
    }
    
}

extension ViewController: CALayerDelegate {
    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        guard Config.showBoundingBox else {
            return
        }
        let bounds = layer.bounds
        ctx.setStrokeColor(UIColor.green.cgColor)
        ctx.setLineWidth(2)
        currentResults?.forEach({ (result) in
            let coords = result.coordinates
            let dHeight = bounds.height * coords.height
            let dY = (bounds.height * (1.0 - coords.origin.y) - dHeight) - (imageYOffset ?? 0.0)
            let drawingRect = CGRect(x: bounds.width * coords.origin.x,
                                     y: dY,
                                     width: bounds.width * coords.width,
                                     height: dHeight)
            ctx.addRect(drawingRect)
        })
        ctx.strokePath()
    }
    
}
