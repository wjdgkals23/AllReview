//
//  Scene.swift
//  AllReview
//
//  Created by 정하민 on 2020/01/02.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

enum Scene {
    case login(LoginViewModel)
    case main(MainViewModel)
    case signup(SignUpViewModel)
    case addnew(AddNewReviewViewModel)
    case search(SearchMovieViewModel)
}

extension Scene {
    func instantiate(from storyboard: String = "Main") -> UIViewController {
        let stoaryboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self {
        case .login(let viewModel):
            guard let nav = stoaryboard.instantiateViewController(withIdentifier: "LoginNav") as? UINavigationController else {
                fatalError()
            }
            guard var loginVC = nav.viewControllers.first as? LoginViewController else {
                fatalError()
            }
            
            loginVC.bind(viewModel: viewModel)
            return nav
        case .main(let viewModel):
            guard let nav = stoaryboard.instantiateViewController(withIdentifier: "MainNav") as? UINavigationController else {
                fatalError()
            }
            guard var mainVC = nav.viewControllers.first as? MainViewController else {
                fatalError()
            }

            mainVC.bind(viewModel: viewModel)
            return nav
        case .signup(_):
            guard let nav = stoaryboard.instantiateViewController(withIdentifier: "MainNav") as? UINavigationController else {
                fatalError()
            }
            return nav
        case .addnew(let viewModel):
            guard var addNewVC = stoaryboard.instantiateViewController(withIdentifier: "AddNewReviewController") as? AddNewReviewController else {
                fatalError()
            }
            addNewVC.bind(viewModel: viewModel)
            return addNewVC
        case .search(let viewModel):
            guard var searchVC = stoaryboard.instantiateViewController(withIdentifier: "SearchMovieViewController") as? SearchMovieViewController else {
                fatalError()
            }
            searchVC.bind(viewModel: viewModel)
            return searchVC
        }
    }
}
