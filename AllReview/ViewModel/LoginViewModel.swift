//
//  LoginViewModel.swift
//  AllReview
//
//  Created by 정하민 on 24/09/2019.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift

enum LoginNavigationStackAction {
    case set(viewModels: [Any], animated: Bool)
    case push(viewModels: [Any], animated: Bool)
    case pop(animated: Bool)
}

class LoginViewModel {
    // inputs
    let navigationStackActions = BehaviorSubject<LoginNavigationStackAction>(value: .set(viewModels: [], animated: false))
//    let
}
