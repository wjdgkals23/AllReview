//
//  AddNewReviewViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/15.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import WebKit

class AddNewReviewViewModel: ViewModel{
    
    var imageViewImageSubject: BehaviorSubject<UIImage?>!
    
    override init() {
        imageViewImageSubject = BehaviorSubject(value: #imageLiteral(resourceName: "title"))
    }

}

extension AddNewReviewViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
