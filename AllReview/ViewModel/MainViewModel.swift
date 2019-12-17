//
//  MainViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/31.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit

class MainViewModel: ViewModel{
    
    override init() {
        super.init()
        self.mainViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        self.rankViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        self.myViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
    }
    
    public func loginDataBindFirstPage(_ urlTarget:OneLineReview, _ subject:BehaviorSubject<URLRequest>) {
        userLoginSession.getRxLoginData()?.flatMap({ [weak self] user -> Observable<URLRequest> in
            let userData = ["memberId":user.data._id]
            let req = (self?.urlMaker.rxMakeURLRequestObservable(urlTarget, userData))!
            return req
        }).bind(to: subject)
            .disposed(by: disposeBag)
    }
    
}
