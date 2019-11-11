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
    private var urlMaker = OneLineReviewURL()
    
    let mainViewButtonTapped:BehaviorSubject<Bool>
    let rankViewButtonTapped:BehaviorSubject<Bool>
    let myViewButtonTapped:BehaviorSubject<Bool>
    
    let mainViewButtonDriver:Driver<Bool>
    let rankViewButtonDriver:Driver<Bool>
    let myViewButtonDriver:Driver<Bool>
    
    let webMainURL = PublishSubject<URLRequest>()
    
    init() {
        mainViewButtonTapped = BehaviorSubject(value: false)
        rankViewButtonTapped = BehaviorSubject(value: false)
        myViewButtonTapped = BehaviorSubject(value: false)
        
        mainViewButtonDriver = mainViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: false)
        rankViewButtonDriver = rankViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: false)
        myViewButtonDriver = myViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: false)
    }
    
    
}
