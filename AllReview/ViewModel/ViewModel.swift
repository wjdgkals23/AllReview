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

class ViewModel: NSObject { // 너 없어질듯....ㅋㅋㅋ
    
    var sceneCoordinator: SceneCoordinator?

    var disposeBag = DisposeBag()

    let errorHandleSubject = PublishSubject<String>()
    
    override init() {
        super.init()
    }
    
    public func closeViewController() {
        self.sceneCoordinator?.close(animated: false).subscribe(onCompleted: nil) { (err) in
            print(err.localizedDescription)
        }.disposed(by: self.disposeBag)
    }
    
}

protocol OneLineReviewViewModel {
    var sceneCoordinator: SceneCoordinator { get }
    var disposeBag: DisposeBag { get } 
}

extension OneLineReviewViewModel {

}
