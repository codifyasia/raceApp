//
//  UIView+Extension.swift
//  RunApp
//
//  Created by Michael Peng on 10/5/19.
//  Copyright © 2019 Michael Peng. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor, property: String) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        
        if (property == "corner") {
            gradientLayer.cornerRadius = 20
        }
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
