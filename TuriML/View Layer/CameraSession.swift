//
//  CameraSession.swift
//  MLImageDetection
//
//  Created by Volker Bublitz on 11.06.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import UIKit
import AVFoundation

enum CaptureSessionError : Error {
    case noCameraPermission
}

protocol CameraSessionDelegate: class {
    func capturingStarted()
    func capturingError(error: CaptureSessionError)
    func captured(pixelBuffer: CVPixelBuffer)
}

class CameraSession: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession = AVCaptureSession()
    weak var delegate: CameraSessionDelegate?
    
    private var permissionGranted = false {
        didSet {
            guard permissionGranted else {
                self.delegate?.capturingError(error: .noCameraPermission)
                return
            }
        }
    }
    private let sessionQueue = DispatchQueue(label: "camera session queue")
    
    private let context = CIContext()
    lazy private var discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: Config.cameraPosition)
    
    lazy private var videoOutput:AVCaptureVideoDataOutput = {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Config.pixelBufferFormat] as [String : Any]
        return videoOutput
    }()
    
    func startSession() {
        checkPermission()
        sessionQueue.async { [unowned self] in
            guard self.permissionGranted else {
                return
            }
            self.configureSession()
            self.captureSession.startRunning()
            self.delegate?.capturingStarted()
        }
    }
    
    // MARK: - AVSession configuration
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    private func configureSession() {
        captureSession.sessionPreset = Config.cameraQuality
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = Config.videoOrientation
        connection.isVideoMirrored = Config.cameraPosition == .front
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        return discoverySession.devices.first
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.delegate?.captured(pixelBuffer: imageBuffer)
    }
    
}
