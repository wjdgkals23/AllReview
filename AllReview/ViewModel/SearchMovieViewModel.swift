//
//  SearchMovieViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/15.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit

class SearchMovieViewModel: NSObject, WKUIDelegate, WKNavigationDelegate {
    
    private var userLoginSession = UserLoginSession.sharedInstance
    private let request = OneLineReviewAPI.sharedInstance
    private let disposeBag = DisposeBag()
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    public var urlMaker = OneLineReviewURL()
    
    var searchBarSubject:BehaviorSubject<Bool>!
    var searchButtonEnabledDriver:Driver<Bool>!
    
    let didSearchIn = PublishSubject<URLRequest>()
    let didFailSearchIn = PublishSubject<Error>()
    
    let mainViewButtonTapped:BehaviorSubject<URLRequest>
    let mainViewButtonDriver:Driver<URLRequest>
    
    override init() {
        super.init()
        
        mainViewButtonTapped = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        mainViewButtonDriver = mainViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
        searchBarSubject = BehaviorSubject(value: false)
        searchButtonEnabledDriver = searchBarSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
    }
    
//    public func
    
    public func loginDataBindFirstPage(_ urlTarget:OneLineReview, _ subject:BehaviorSubject<URLRequest>) {
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<URLRequest> in
            let userData = ["memberId":data.data._id]
            let req = (self?.urlMaker.rxMakeLoginURLComponents(urlTarget, userData))!
            return req
        }).bind(to: subject)
            .disposed(by: disposeBag)
    }
}
