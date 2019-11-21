//
//  ViewControllerExtension.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/21.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func catchNavigation() -> UINavigationController? {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            return navigationController
        }
        else {
            return nil
        }
    }
    
}
