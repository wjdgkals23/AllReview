//
//  TransitionStyle.swift
//  AllReview
//
//  Created by 정하민 on 2020/01/02.
//  Copyright © 2020 swift. All rights reserved.
//

import Foundation

enum TransitionStyle {
    case root
    case push
    case modal
}

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}
