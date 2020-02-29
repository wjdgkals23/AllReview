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

class SearchMovieViewModel: ViewModel, WKNavigationDelegate {
    
    // SearchViewModel은 검색어를 통해 웹뷰를 교체하는 기능을 한다.
    // searchURLReqeust = 버튼이벤트감지(지속적으로 탐지) + 로그인 정보를 끌어온다(withLatestFrom)
    
    var keywordTextSubject: BehaviorSubject<String?>
    var searchButtonEnabledDriver: Driver<Bool> // 글자가 1개 이상 있어야 확인가능하다!! ++ 검색결과가 없을 때를 Parse 해서 이쁘게 처리할 수 있지 않을까!?!?
    var keywordTextDriver: Driver<String?>
    
    var searchResult: Observable<URLRequest>
    var buttonTapped: PublishSubject<Void> = PublishSubject<Void>()
    
    var urlParseContext: ((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)?
    
    init(sceneCoordinator: SceneCoordinator, keyword: String?) {
        if keyword != nil {
            keywordTextSubject = BehaviorSubject(value: keyword?.decodeUrl())
        } else {
            keywordTextSubject = BehaviorSubject(value: "")
        }
        
        let searchButtonEnabledObservable:Observable<Bool> = keywordTextSubject.distinctUntilChanged()
            .map { str in
                guard let string = str else { return false }
                return string.count > 1
            }
        
        searchResult = Observable.combineLatest(UserLoginSession.sharedInstance.rxloginData.asObservable(), keywordTextSubject.asObservable())
            .flatMap{ loginData, keyword in
                OneLineReviewURL.rxMakeURLRequestObservable(.searchMovie, ["queryMovieName": keyword, "userId": loginData.data?._id])
            }

            
        
        keywordTextDriver = keywordTextSubject.asDriver(onErrorJustReturn: "")
        searchButtonEnabledDriver = searchButtonEnabledObservable.asDriver(onErrorJustReturn: false)
        
        super.init()
        self.sceneCoordinator = sceneCoordinator
    }
}

extension SearchMovieViewModel: WebNavigationDelegateType {
    convenience init(keyword: String?) {
        
        let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
        self.init(sceneCoordinator: coordinator, keyword: keyword)
        
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
                
                if((url?.contains("app://WriteContent"))!) {
                    handler(.allow)
                    let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
                    let addNewVM = AddNewReviewViewModel(sceneCoordinator: coordinator, initData: queryDict)
                    let addNewScene = Scene.addnew(addNewVM)
                    
                    self?.sceneCoordinator?.transition(to: addNewScene, using: .push, animated: false)
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
}
