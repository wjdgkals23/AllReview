//
//  CommonViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2020/01/02.
//  Copyright © 2020 swift. All rights reserved.
//

import Foundation

class CommonViewModel: NSObject {
    let sceneCoordinator: SceneCoordinator
    
    init(sceneCoordinator: SceneCoordinatorType) {
        self.sceneCoordinator = sceneCoordinator as! SceneCoordinator
    }
    
}
