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
    
    var mainViewRequestSubject:BehaviorSubject<URLRequest>!
    var rankViewRequestSubject:BehaviorSubject<URLRequest>!
    var myViewRequestSubject:BehaviorSubject<URLRequest>!
    
    override init() {
        super.init()
        mainViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        rankViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        myViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
    }
    
    public func loginDataBindFirstPage(_ urlTarget:OneLineReview, _ subject:BehaviorSubject<URLRequest>) {
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<URLRequest> in
            let userData = ["memberId":data.data._id]
            let req = (self?.urlMaker.rxMakeURLRequestObservable(urlTarget, userData))!
            return req
        }).bind(to: subject)
            .disposed(by: disposeBag)
    }
    
}
