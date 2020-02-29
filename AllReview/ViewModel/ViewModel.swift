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
    
    var sceneCoordinator: SceneCoordinator?

    let request = OneLineReviewAPI.sharedInstance
    var backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    var disposeBag = DisposeBag()
    var urlMaker = OneLineReviewURL()

    let errorHandleSubject = PublishSubject<String>()
    
    let goToNewViewControllerReviewSubject = PublishSubject<(String,[String:String?])>()
    
    override init() {
        super.init()
    }
    
    public func closeViewController() {
        self.sceneCoordinator?.close(animated: false).subscribe(onCompleted: nil) { (err) in
            print(err.localizedDescription)
        }.disposed(by: self.disposeBag)
    }
    
}
