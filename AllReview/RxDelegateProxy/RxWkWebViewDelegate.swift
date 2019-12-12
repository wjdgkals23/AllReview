//
//  File.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/11.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import WebKit
import RxSwift
import RxCocoa

//extension Reactive where Base: WKWebView {
//    var delegate : DelegateProxy<WKWebView, WKNavigationDelegate> {
//        return RxWkWebNavigationDelegateProxy.proxy(for: self.base)
//    }
//}
//
//public protocol DelegateProxyType: class {
//    associatedtype ParentObject: AnyObject
//    associatedtype Delegate
//}
//
//extension DelegateProxyType {
//    static func _currentDelegate(for object: ParentObject) -> AnyObject? {
//        return currentDelegate(for: object).map { $0 as AnyObject }
//    }
//
//    static func _setCurrentDelegate(_ delegate: AnyObject?, to object: ParentObject) {
//        return setCurrentDelegate(castOptionalOrFatalError(delegate), to: object)
//    }
//}
//
//class RxWkWebNavigationDelegateProxy: DelegateProxy<WKWebView, WKNavigationDelegate>, DelegateProxyType, WKNavigationDelegate {
//
//    typealias ParentObject = WKWebView
//    typealias Delegate = WKNavigationDelegate
//
//    static func currentDelegate(for object: WKWebView) -> WKNavigationDelegate? {
//        return object.navigationDelegate
//    }
//
//    static func setCurrentDelegate(_ delegate: WKNavigationDelegate?, to object: WKWebView) {
//        object.navigationDelegate = delegate
//    }
//
//}

//protocol
