//
//  RxRequests.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//URLSession

typealias api = OneLineReview
typealias err = OneLineReviewError

class OneLineReviewAPI {
    
    static let sharedInstance = OneLineReviewAPI()

    private var com: URLComponents?
    private var disaposable = DisposeBag()
    
    let decoder = JSONDecoder()
    
    init() {
        self.com = URLComponents()
        self.com?.scheme = api.scheme
        self.com?.host = api.host
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    func rxMakeLoginURLComponents(_ userData: [String:String]) -> Observable<URLRequest> {
        return Observable.create { observer in
            self.com?.path = api.memberLoginPath
            if let url = self.com?.url {
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: userData, options: .fragmentsAllowed)
                    request.httpBody = jsonData
                    observer.on(.next(request))
                } catch {
                    let error = err.makeurl(description: "TEST URL PARSE FROM URLCOMPONENTS ERR")
                    observer.on(.error(error))
                }
            }
            return Disposables.create()
        }
    }

    func rxTestLogin(userData: [String:String]) -> Observable<Any?> {
        self.rxMakeLoginURLComponents(userData).flatMap { urlRequest -> Observable<Any?> in
            let dataTask = URLSession.shared.rx.response(request: urlRequest)
            return dataTask
                .debug("testLoginRequest")
                .flatMap { (response: HTTPURLResponse, data: Data) -> Observable<Any?> in
                    if 200 ..< 300 ~= response.statusCode {
                        do {
                            let userSessionData = try self.decoder.decode(userLoginSession.self, from: data)
                            return Observable.create { observer -> Disposable in
                                observer.on(.next(userSessionData))
                                return Disposables.create()
                            }
                        } catch {
                            return Observable.error(err.parsing(description: "RESPONSE PARSE ERROR \(error)"))
                        }
                    }
                    else {
                        return Observable.error(err.network(description: "NETWORK ERROR"))
                    }
                }
        }
    }
    
}

