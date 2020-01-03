//
//  OneLineRevieViewControllerType.swift
//  AllReview
//
//  Created by 정하민 on 2020/01/03.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

protocol OneLineRevieViewControllerType {
    
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
    func setUpView()
    func setUpRx()
    func setUpWebView()
    
}

extension OneLineRevieViewControllerType where Self: UIViewController {
    mutating func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        setUpView()
        setUpWebView()
        setUpRx()
    }
}
