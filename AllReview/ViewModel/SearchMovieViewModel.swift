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

class SearchMovieViewModel: ViewModel {
    
    var keywordTextSubject:BehaviorSubject<String?>!
    var searchBarSubject:BehaviorSubject<Bool>!
    var searchButtonEnabledDriver:Driver<Bool>!
    var keywordTextDriver:Driver<String?>!
    
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
        
    }
    
    public func searchKeywordBindResultPage(_ urlTarget:OneLineReview, _ keyWord:String) {
        let searchData = ["queryMovieName":keyWord, "userId":(userLoginSession.getLoginData()?.data?._id)!]
        self.urlMaker.rxMakeURLRequestObservable(.searchMovie, searchData)
        .bind(to: (self.searchResultSubject))
        .disposed(by: disposeBag)
    }
}
