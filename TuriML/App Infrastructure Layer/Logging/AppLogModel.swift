//
//  AppLogModel.swift
//  BarmerServiceApp2018
//
//  Created by Volker Bublitz on 09.02.18.
//  Copyright © 2018 T-Systems Multimedia Solutions GmbH. All rights reserved.
//

import os.log

struct AppLogModel {
    private static let subsystem = "com.t-systems-mms.TuriML"
    static let commonLog = OSLog(subsystem: AppLogModel.subsystem, category: "Common")
}
