//
//  Requests.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift

enum OneLineReviewError: Error {
    case makeurl(description: String)
    case parsing(description: String)
    case network(description: String)
}

enum OneLineReview: String {
    case login = "/member/login"
    case register = "/member/add"
    case mainRankView = "/page/boxOfficePage"
    case mainMainView = "/page/mainIndexPage"
    case mainMyView = "/page/myPage"
    case contentDetailView = "/mainList/showContentDetail"
    case searchMovie = "/naverapi/searchedMovieList"
}

class OneLineReviewURL { // 기본 url 셋팅
    private let scheme = "https://"
    private let host = "www.teammiracle.be"
    
    func makeRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        return request
    }
    
    func rxMakeURLRequestObservable(_ path: OneLineReview, _ userData: [String:String]) -> Observable<URLRequest> {
        return Observable.create { [unowned self] observer in
            if let url = URL(string: self.scheme + self.host + path.rawValue) {
                var request = self.makeRequest(url)
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: userData, options: .fragmentsAllowed)
                    request.httpBody = jsonData
                    observer.on(.next(request))
                } catch {
                    let error = err.makeurl(description: "rxMakeLoginURLComponents MAKE JSON ERR")
                    observer.on(.error(error))
                }
                return Disposables.create()
            } else {
                let error = err.makeurl(description: "rxMakeLoginURLComponents MAKE ERR")
                observer.on(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func rxMakeUrlToRequest(_ url: String) -> Observable<URLRequest> {
        return Observable.create { observer in
            if let url = URL(string: url) {
                var request = self.makeRequest(url)
                request.httpMethod = "GET"
                observer.on(.next(request))
            } else {
                let error = err.makeurl(description: "rxMakeUrlToRquest MAKE ERR")
                observer.on(.error(error))
            }
            return Disposables.create()
        }
    }
    
}


extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
