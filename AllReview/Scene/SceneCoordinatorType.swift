//
//  SceneCoordinatorType.swift
//  AllReview
//
//  Created by 정하민 on 2020/01/02.
//  Copyright © 2020 swift. All rights reserved.
//

import Foundation
import RxSwift

protocol SceneCoordinatorType {
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable
    
    @discardableResult
    func close(animated: Bool) -> Completable
}
