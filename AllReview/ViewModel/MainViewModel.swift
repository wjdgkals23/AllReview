//
//  MainViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/31.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit

protocol MainViewModelType {
    var mainViewRequestSubject:BehaviorSubject<URLRequest?> { get set }
    var rankViewRequestSubject:BehaviorSubject<URLRequest?>  { get set }
    var myViewRequestSubject:BehaviorSubject<URLRequest?>  { get set }
    var goToMyContentDetailViewSubject:PublishSubject<[String:String]> { get set }
    
    var urlParseContext:((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)? { get set }
}

class MainViewModel: ViewModel, MainViewModelType, WKNavigationDelegate {
    
    var mainViewRequestSubject: BehaviorSubject<URLRequest?> = BehaviorSubject(value: nil)
    var rankViewRequestSubject: BehaviorSubject<URLRequest?> = BehaviorSubject(value: nil)
    var myViewRequestSubject: BehaviorSubject<URLRequest?> = BehaviorSubject(value: nil)
    
    var goToMyContentDetailViewSubject: PublishSubject<[String : String]> = PublishSubject<[String:String]>()
    
    var urlParseContext: ((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)?
    
    override init(sceneCoordinator: SceneCoordinatorType) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        self.urlParseContext = { [weak self] (webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
            
            let url = response.request.url?.absoluteString
            
            if((url?.contains("https://www.teammiracle.be"))!) {
                handler(.allow)
                return
            } else {
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                var queryDict:[String: String] = [:]
                if temp != "" {
                    queryDict = temp.parseQueryString()
                }
                    
                if((url?.contains("app://SearchMovie"))!) {
                    handler(.allow)
                    var searchKeyword: String? = nil
                    if let ind = index, ind != url!.endIndex {
                        searchKeyword = queryDict["movieNm"]
                    }
                    
                    let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
                    let seachVM = SearchMovieViewModel(sceneCoordinator: coordinator, keyword: searchKeyword)
                    let searchScene = Scene.search(seachVM)
                    
                    coordinator.transition(to: searchScene, using: .push, animated: false)
                }
                else if((url?.contains("app://MemberContents"))!) {
                    handler(.allow)
                    self!.makePageURLRequest(.showMembersContents, queryDict, (self!.mainViewRequestSubject))
                }
                else if((url?.contains("app://MyContents"))!) {
                    handler(.allow)
                    self!.makePageURLRequest(.mainMyView, queryDict, (self!.mainViewRequestSubject))
                }
                else if((url?.contains("app://ShareContent"))!) {
                    handler(.allow)
                    print(queryDict["url"]?.decodeUrl())
                }
                else if((url?.contains("app://ShareScreenshot"))!) {
                    handler(.allow)
                    print("ScreenShot!")
                }
                else {
                    handler(.allow)
                    return
                }
            }
        }
    }
    
    public func loginDataBindFirstPage(_ urlTarget:OneLineReview, _ subject:BehaviorSubject<URLRequest?>) {
        userLoginSession.getRxLoginData()?.flatMap({ [weak self] user -> Observable<URLRequest> in
            let userData = ["memberId":user.data!._id, "userId":user.data!._id]
            let req = (self?.urlMaker.rxMakeURLRequestObservable(urlTarget, userData))!
            return req
        }).bind(to: subject)
            .disposed(by: disposeBag)
    }
    
    public func pushSearchView() {
        let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
        let seachVM = SearchMovieViewModel(sceneCoordinator: coordinator, keyword: nil)
        let searchScene = Scene.search(seachVM)
        
        coordinator.transition(to: searchScene, using: .push, animated: false)
    }
}
