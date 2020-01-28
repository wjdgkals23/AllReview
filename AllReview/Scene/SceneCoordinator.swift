    
//  SceneCoordinator.swift
//  AllReview
//
//  Created by 정하민 on 2020/01/02.
//  Copyright © 2020 swift. All rights reserved.
//

import Foundation
import RxSwift

class SceneCoordinator: SceneCoordinatorType {
    
    private var window: UIWindow
    private var currentVC: UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        self.currentVC = window.rootViewController!
    }
    
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        
        let target = scene.instantiate()
        
        switch style {
        case .root:
            currentVC = target
            window.rootViewController = target
            subject.onCompleted()
        case .push:
            guard let nav = currentVC as? UINavigationController else {
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            nav.pushViewController(target, animated: animated)
            currentVC = target
            subject.onCompleted()
        case .modal:
            currentVC.present(target, animated: animated) {
                subject.onCompleted()
            }
            currentVC = target
        }
        
        return subject.ignoreElements()
    }
    
    @discardableResult
    func close(animated: Bool) -> Completable {
        return Completable.create { [unowned self] completable in
            if let nav = self.currentVC.navigationController {
                guard nav.popViewController(animated: animated) != nil else {
                    completable(.error(TransitionError.cannotPop))
                    return Disposables.create()
                }
                self.currentVC = nav.viewControllers.last!
                completable(.completed)
            } else if let presentingVC = self.currentVC.presentingViewController { // presentingViewController : modal형식[present:]이면 view를 띄운 viewCon을 보내주고 modal형식X 면 화면을 부른 부모의 부모가 잡히고 그외에는 nil => present를 한 VC를 찾는다!!
                self.currentVC.dismiss(animated: animated) {
                    self.currentVC = presentingVC
                    completable(.completed)
                }
            }
            else {
                completable(.error(TransitionError.unknown))
                return Disposables.create()
            }
            return Disposables.create()
        }
    }
}
