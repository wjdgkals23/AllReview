//
//  AllReviewLoginButton.swift
//  AllReview
//
//  Created by 정하민 on 2020/01/02.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

class AllReviewLoginButton: UIButton {

    
    init(frame: CGRect, color: UIColor, logo: String) {
        super.init(frame: frame)
        customLoginButtonSetUp(color: color, logo: logo)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder) // 스토리보드에서는 어떻게??
    }
    
    private func customLoginButtonSetUp(color: UIColor, logo: String) {
        self.backgroundColor = color
        setTitle(logo, for: .normal)
    }
    
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: self.center.x - 10, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: self.center.x + 10, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }

}
