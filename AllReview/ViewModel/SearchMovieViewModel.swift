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

class SearchMovieViewModel: ViewModel{
    
    var keywordTextSubject:BehaviorSubject<String?>!
    var searchBarSubject:BehaviorSubject<Bool>!
    var searchButtonEnabledDriver:Driver<Bool>!
    
    var searchResultSubject:BehaviorSubject<URLRequest>!
    
    let goToAddNewReviewSubject = PublishSubject<(String,[String:String])>()
    
    override init() {
        super.init()
        keywordTextSubject = BehaviorSubject(value: "")
        searchResultSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
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
