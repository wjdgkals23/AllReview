//
//  SearchMovieViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/15.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit

protocol SearchMovieViewModelType {
    var keywordTextSubject:BehaviorSubject<String?>! { get set }
    var searchBarSubject:BehaviorSubject<Bool>! { get set }
    var searchButtonEnabledDriver:Driver<Bool>! { get set }
    var keywordTextDriver:Driver<String?>! { get set }
    var searchResultSubject:BehaviorSubject<URLRequest?> { get set }
    
    var urlParseContext:((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)? { get set }
}

class SearchMovieViewModel: ViewModel, SearchMovieViewModelType, WKNavigationDelegate {
    
    var keywordTextSubject: BehaviorSubject<String?>!
    var searchBarSubject: BehaviorSubject<Bool>!
    var searchButtonEnabledDriver: Driver<Bool>!
    var keywordTextDriver: Driver<String?>!
    
    var searchResultSubject: BehaviorSubject<URLRequest?> = BehaviorSubject(value: nil)
    
    var urlParseContext: ((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)?
    
    init(sceneCoordinator: SceneCoordinator, keyword: String?) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        if keyword != nil {
            keywordTextSubject = BehaviorSubject(value: keyword?.decodeUrl())
            self.searchKeywordBindResultPage(.searchMovie, (keyword?.decodeUrl())!)
        } else {
            keywordTextSubject = BehaviorSubject(value: "")
        }
        
        let searchButtonEnabledObservable:Observable<Bool> = keywordTextSubject.distinctUntilChanged().flatMap { (keyword) -> Observable<Bool> in
            return Observable.create { (obs) -> Disposable in
                if let keyWord = keyword {
                    let searchButtonEnabled = keyWord.count > 0
                    obs.onNext(searchButtonEnabled)
                    return Disposables.create()
                } else {
                    obs.onError(OneLineReviewError.parsing(description: "KeyWordParse ERROR"))
                    return Disposables.create()
                }
            }
        }
        
        keywordTextDriver = keywordTextSubject.asDriver(onErrorJustReturn: "")
        searchButtonEnabledDriver = searchButtonEnabledObservable.asDriver(onErrorJustReturn: false)
        
        self.urlParseContext = { (webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
            
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
                
                if((url?.contains("app://WriteContent"))!) {
                    handler(.allow)
                    let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
                    let addNewVM = AddNewReviewViewModel(sceneCoordinator: coordinator, initData: queryDict)
                    let addNewScene = Scene.addnew(addNewVM)
                    
                    coordinator.transition(to: addNewScene, using: .push, animated: false)
                    return
                }
                else if((url?.contains("app://ExternalBrowser"))!) {
                    handler(.allow)
                    
                    let externalUrl = URL(string: ((queryDict["url"])!.decodeUrl())!)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(externalUrl!)
                    } else {
                        // Fallback on earlier versions
                        return
                    }
                }
                else {
                    handler(.allow)
                    return
                }
            }
        }
    }
    
    public func searchKeywordBindResultPage(_ urlTarget:OneLineReview, _ keyWord:String) {
        let searchData = ["queryMovieName":keyWord, "userId":(userLoginSession.getLoginData()?.data?._id)!]
        self.urlMaker.rxMakeURLRequestObservable(.searchMovie, searchData)
            .bind(to: (self.searchResultSubject))
            .disposed(by: disposeBag)
    }
}
