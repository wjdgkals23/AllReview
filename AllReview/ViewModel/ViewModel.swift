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
import WebKit
import UIKit

protocol WebNavigationDelegateType {
    var urlParseContext:((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)? { get }
}

class ViewModel: NSObject {
    
    let sceneCoordinator: SceneCoordinator!
    
    var userLoginSession = UserLoginSession.sharedInstance
    let request = OneLineReviewAPI.sharedInstance
    var backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    var disposeBag = DisposeBag()
    var urlMaker = OneLineReviewURL()

    let errorHandleSubject: PublishSubject<String> = PublishSubject<String>()
    
    let goToNewViewControllerReviewSubject = PublishSubject<(String,[String:String?])>()
    
    
    init(sceneCoordinator: SceneCoordinatorType) {
        self.sceneCoordinator = sceneCoordinator as? SceneCoordinator
        super.init()
    }
    
    public func makePageURLRequest(_ urlTarget:OneLineReview, _ param:[String:String], _ target: PublishSubject<URLRequest?>) {
        self.urlMaker.rxMakeURLRequestObservable(urlTarget, param).bind(to: target).disposed(by: disposeBag)
    }
    
    public func closeViewController() {
        self.sceneCoordinator.close(animated: false).subscribe(onCompleted: nil) { (err) in
            print(err.localizedDescription)
        }.disposed(by: self.disposeBag)
    }
    
}
