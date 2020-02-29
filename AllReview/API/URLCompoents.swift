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
    case mainMyView = "/mainList/showMyPage"
    case contentDetailView = "/mainList/showContentDetail"
    case searchMovie = "/naverapi/searchedMovieList"
    case showMembersContents = "/mainList/showMemberPage"
    case contentAdd = "/content/ad"
}

struct OneLineReviewURL { // 기본 url 셋팅
    
    static private let encoder = JSONEncoder()
    
    static func makeRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        return request
    }
    
    static func rxMakeURLRequestObservable(_ path: OneLineReview, _ userData: [String:Any]) -> Observable<URLRequest> {
        return Observable.create { observer in
            if let url = URL(string: Environment.rootURL + path.rawValue) {
                var request = self.makeRequest(url)
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: userData, options: .fragmentsAllowed)
                    request.httpBody = jsonData
                    observer.on(.next(request))
                    observer.on(.completed)
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
    
    static func makeURLRequest(_ path: OneLineReview, _ userData: UserLoginRequestData) -> URLRequest? {
        if let url = URL(string: Environment.rootURL + path.rawValue) {
            var request = self.makeRequest(url)
            do {
                let jsonData = try self.encoder.encode(userData)
                request.httpBody = jsonData
                return request
            } catch {
                let error = err.makeurl(description: "rxMakeLoginURLComponents MAKE JSON ERR")
                print(error.localizedDescription)
                return nil
            }
        } else {
            let error = err.makeurl(description: "rxMakeLoginURLComponents MAKE ERR")
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func rxMakeUrlToRequest(_ url: String) -> Observable<URLRequest> {
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
