//
//  ResultView.swift
//  TuriML
//
//  Created by Volker Bublitz on 15.06.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import UIKit

protocol ResultIndicatorDatasource : class {
    func color(forText text: String?) -> UIColor
}

class ResultView: UIView {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    weak var resultIndicatorDataSource:ResultIndicatorDatasource?
    
    var text : String? {
        didSet {
            self.prepareTextTransition()
            self.resultLabel.text = self.text
            self.animateTextChange(text)
        }
    }
    
    private func animateTextChange(_ text: String?) {
        UIView.animate(withDuration: 0.25) {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.alpha = self.text == nil ? 0.0 : 1.0
            self.indicatorView.backgroundColor = self.color(forText: self.text)
        }
    }
    
    private func prepareTextTransition() {
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.duration = 0.25
        transition.type = CATransitionType.fade
        self.layer.add(transition, forKey: "textchange")
    }
    
    private func color(forText text: String?) -> UIColor {
        return self.resultIndicatorDataSource?.color(forText: self.text) ?? UIColor.clear
    }

    override func awakeFromNib() {
        resultLabel.text = nil
        indicatorView.layer.cornerRadius = 10.0
        indicatorView.backgroundColor = UIColor.red
        layer.cornerRadius = 8.0
        enableBlurredBackground(withStyle: .dark, opacity: 0.8)
    }
    
}
