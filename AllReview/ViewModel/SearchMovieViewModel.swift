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

class SearchMovieViewModel: ViewModel, WKNavigationDelegate{
    
    var keywordTextSubject:BehaviorSubject<String?>!
    var searchBarSubject:BehaviorSubject<Bool>!
    var searchButtonEnabledDriver:Driver<Bool>!
    
    var searchResultSubject:BehaviorSubject<URLRequest>!
    
    let goToAddNewReviewSubject = PublishSubject<(String,[String:String])>()
    
    var urlParserContext:((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)!
    
    override init() {
        super.init()
        keywordTextSubject = BehaviorSubject(value: "")
        searchResultSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
        urlParserContext = {(webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
            
            let url = response.request.url?.absoluteString
            
            if((url?.contains("https://www.teammiracle.be/"))!) {
                handler(.allow)
                return
            }
            else if((url?.contains("app://writeContent"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                self.goToAddNewReviewSubject.on(.next(("add", queryDict)))
                return
            }
            else {
                handler(.cancel)
                return
            }
            
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

        searchButtonEnabledDriver = searchButtonEnabledObservable.asDriver(onErrorJustReturn: false)
        
    }
    
    public func searchKeywordBindResultPage(_ urlTarget:OneLineReview, _ keyWord:String) {
        let userData = ["queryMovieName":keyWord]
        self.urlMaker.rxMakeURLRequestObservable(.searchMovie, userData)
        .bind(to: (self.searchResultSubject)!).disposed(by: disposeBag)
    }
}
