//
//  UIImageExtension.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/11.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    class func resizeImage(image: UIImage, targetSize: CGFloat) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize / size.width
    

        var newSize: CGSize
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
