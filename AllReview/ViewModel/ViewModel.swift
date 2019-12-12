//
//  ViewParent.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/12.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel: NSObject {
    
    var userLoginSession = UserLoginSession.sharedInstance
    let request = OneLineReviewAPI.sharedInstance
    var backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    let disposeBag = DisposeBag()
    var urlMaker = OneLineReviewURL()
    
    func loadPageView(_ urlTarget:OneLineReview, _ param:[String:String], _ target: BehaviorSubject<URLRequest>) {
        self.urlMaker.rxMakeURLRequestObservable(.contentDetailView, param).bind(to: target).disposed(by: disposeBag)
    }

}
