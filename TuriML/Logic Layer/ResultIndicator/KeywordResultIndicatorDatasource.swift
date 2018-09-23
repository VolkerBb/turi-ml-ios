//
//  KeywordResultDatasource.swift
//  TuriML
//
//  Created by Volker Bublitz on 15.06.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import UIKit

class KeywordResultIndicatorDatasource: NSObject, ResultIndicatorDatasource {

    func color(forText text: String?) -> UIColor {
        guard let comparableText = text,
            Config.keywords.contains(where: { indicator in
                return comparableText.contains(indicator)
            }) else {
                return UIColor.red
        }
        return UIColor.green
    }
    
}
