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

class SearchMovieViewModel: NSObject, WKUIDelegate, WKNavigationDelegate{
    
    private var userLoginSession = UserLoginSession.sharedInstance
    private let request = OneLineReviewAPI.sharedInstance
    private let disposeBag = DisposeBag()
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    public var urlMaker = OneLineReviewURL()
    
    var searchBarSubject:BehaviorSubject<Bool>!
    var searchButtonEnabledDriver:Driver<Bool>!
    
    var searchResultSubject:BehaviorSubject<URLRequest>!
    
    override init() {
        super.init()
        searchResultSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
        searchBarSubject = BehaviorSubject(value: false)
        searchButtonEnabledDriver = searchBarSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
    }
    
    public func searchKeywordBindResultPage(_ urlTarget:OneLineReview, _ keyWord:String) {
        let userData = ["queryMovieName":keyWord]
        let req = (self.urlMaker.rxMakeURLRequestObservable(urlTarget, userData))
        req.bind(to: self.searchResultSubject).disposed(by: disposeBag)
    }
}
