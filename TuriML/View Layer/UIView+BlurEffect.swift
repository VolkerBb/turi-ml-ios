//
//  UIView+BlurEffect.swift
//  Blur
//
//  Created by Volker Bublitz on 14.06.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct BlurTag {
    static let tag = 189237123
}

extension UIView {
    
    func pinToEdges(subview v:UIView) {
        v.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        v.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        v.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func enableBlurredBackground(withStyle style: UIBlurEffect.Style, opacity: Float = 1.0) {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: style))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tag = BlurTag.tag
        v.layer.opacity = opacity
        self.insertSubview(v, at: 0)
        pinToEdges(subview: v)
    }
    
    func disableBlurredBackground() {
        self.viewWithTag(BlurTag.tag)?.removeFromSuperview()
    }
    
    
}
