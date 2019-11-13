//
//  MainViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/31.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MainViewModel {
    
    private let request = OneLineReviewAPI.sharedInstance
    private let disposeBag = DisposeBag()
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    public var urlMaker = OneLineReviewURL()
    
    let mainViewButtonTapped:BehaviorSubject<URLRequest>
    let rankViewButtonTapped:BehaviorSubject<URLRequest>
    let myViewButtonTapped:BehaviorSubject<URLRequest>
    
    let mainViewButtonDriver:Driver<URLRequest>
    let rankViewButtonDriver:Driver<URLRequest>
    let myViewButtonDriver:Driver<URLRequest>
    
    let webMainURL = PublishSubject<URLRequest>()
    
    init() {
        mainViewButtonTapped = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        rankViewButtonTapped = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        myViewButtonTapped = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
        mainViewButtonDriver = mainViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        rankViewButtonDriver = rankViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        myViewButtonDriver = myViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
    }
    
    
}
