//
//  ImageAnalyzer.swift
//  TuriML
//
//  Created by Volker Bublitz on 15.06.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import Foundation
import CoreVideo

protocol ImageAnalyzer {
    func analyze(pixelBuffer: CVPixelBuffer, callback: @escaping ([DetectionResult]?) -> Void)
}
