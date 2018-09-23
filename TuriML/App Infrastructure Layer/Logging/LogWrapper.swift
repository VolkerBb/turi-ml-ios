//
//  AppLog.swift
//  BarmerServiceApp2018
//
//  Created by Volker Bublitz on 22.02.18.
//  Copyright © 2018 T-Systems Multimedia Solutions GmbH. All rights reserved.
//

import UIKit
import os.log

class LogWrapper: NSObject {
    
    /// Log in DEBUG mode only
    static func debug(_ message: String, log:OSLog = OSLog.default, _ args: CVarArg...) {
        #if DEBUG
        let logText = String(format: message, arguments: args)
        os_log("%@", log: log, type: .debug, logText)
        #endif
    }
        
}
