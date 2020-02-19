//
//  ImageModalViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2020/02/06.
//  Copyright © 2020 swift. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ImageModalViewModel: ViewModel {
    
    var capturedImageSubject:BehaviorSubject<UIImage?> = BehaviorSubject<UIImage?>(value: nil)
    
    init(sceneCoordinator: SceneCoordinatorType, image: UIImage?) {
        super.init()
        self.sceneCoordinator = sceneCoordinator as! SceneCoordinator
        self.capturedImageSubject.onNext(image)
    }
}

