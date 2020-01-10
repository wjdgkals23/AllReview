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

class ViewModel: NSObject, WKNavigationDelegate {
    
    let sceneCoordinator: SceneCoordinator!
    
    var userLoginSession = UserLoginSession.sharedInstance
    let request = OneLineReviewAPI.sharedInstance
    var backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    let disposeBag = DisposeBag()
    var urlMaker = OneLineReviewURL()
    var urlParserContext:((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)?
    
    var mainViewRequestSubject:BehaviorSubject<URLRequest?> = BehaviorSubject(value: nil)
    var rankViewRequestSubject:BehaviorSubject<URLRequest?> = BehaviorSubject(value: nil)
    var myViewRequestSubject:BehaviorSubject<URLRequest?> = BehaviorSubject(value: nil)
    
    var searchResultSubject:BehaviorSubject<URLRequest?> = BehaviorSubject(value: nil)
    
    var reloadRequestSubject: PublishSubject<Void> = PublishSubject<Void>()
    
    let goToNewViewControllerReviewSubject = PublishSubject<(String,[String:String?])>()
    let goToMyContentDetailViewSubject = PublishSubject<[String:String]>()
    
    init(sceneCoordinator: SceneCoordinatorType) {
        self.sceneCoordinator = sceneCoordinator as? SceneCoordinator
        super.init()
        self.urlParserContext = { [weak self] (webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
            
            let url = response.request.url?.absoluteString
            
            if((url?.contains("https://www.teammiracle.be"))!) {
                handler(.allow)
                return
            }
            else if((url?.contains("app://WriteContent"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
//                self?.goToNewViewControllerReviewSubject.on(.next(("add", queryDict)))
                let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
                let addNewVM = AddNewReviewViewModel(sceneCoordinator: coordinator, initData: queryDict)
                let addNewScene = Scene.addnew(addNewVM)
                
                coordinator.transition(to: addNewScene, using: .push, animated: false)
                return
            }
            else if((url?.contains("app://ExternalBrowser"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                
                let externalUrl = URL(string: ((queryDict["url"])!.decodeUrl())!)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(externalUrl!)
                } else {
                    // Fallback on earlier versions
                    return
                }
            }
            else if((url?.contains("app://SearchMovie"))!) {
                handler(.allow)
                var searchKeyword: String? = nil
                if let index = url?.firstIndex(of: "?") ?? url?.endIndex, index != url!.endIndex {
                    let temp = String((url?[index...])!)
                    let queryDict = temp.parseQueryString()
                    searchKeyword = queryDict["movieNm"]
                }
                
                let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
                let seachVM = SearchMovieViewModel(sceneCoordinator: coordinator, keyword: searchKeyword)
                let searchScene = Scene.search(seachVM)
                
                coordinator.transition(to: searchScene, using: .push, animated: false)
            }
            else if((url?.contains("app://MemberContents"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                self?.makePageURLRequest(.showMembersContents, queryDict, (self!.mainViewRequestSubject))
            }
            else if((url?.contains("app://MyContents"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                self?.makePageURLRequest(.mainMyView, queryDict, (self!.mainViewRequestSubject))
            }
            else {
                handler(.allow)
                return
            }
        }
    }
    
    public func makePageURLRequest(_ urlTarget:OneLineReview, _ param:[String:String], _ target: BehaviorSubject<URLRequest?>) {
        self.urlMaker.rxMakeURLRequestObservable(urlTarget, param).bind(to: target).disposed(by: disposeBag)
    }
    
    public func closeViewController() {
        self.sceneCoordinator.close(animated: false).subscribe(onCompleted: nil) { (err) in
            print(err.localizedDescription)
        }.disposed(by: self.disposeBag)
    }
    
}