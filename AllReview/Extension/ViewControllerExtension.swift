//
//  ViewControllerExtension.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/21.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 3333333
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let registerBar = UIView(frame: self.statusBarFrame)
                registerBar.tag = tag
                self.keyWindow?.addSubview(registerBar)
                return registerBar
            }
        } else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
            return nil
        }
    }
}

extension UIViewController {
    
    func catchNavigation() -> UINavigationController? {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            return navigationController
        }
        else {
            return nil
        }
    }
    
    func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 2
        toastLabel.sizeToFit()
        let frame = toastLabel.frame
        toastLabel.frame = CGRect(x: self.view.frame.width/2 - frame.width/2 - 5, y: self.view.frame.height - 130, width: frame.width + 10, height: 30)
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UITextField {
    func changeDefaultColor() {
        self.backgroundColor = .white
        self.textColor = .black
        self.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4).cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 10.0
    }
}
