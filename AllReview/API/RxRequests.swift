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

    private let session: URLSession = URLSession(configuration: .default)
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
    
    func rxMakeLoginURLComponents(_ userData: [String:String]) -> Observable<URL> {
        return Observable.create { observer in

            self.com?.path = api.memberLoginPath
            self.com?.queryItems?.removeAll()

            self.com?.setQueryItems(with: userData)

            if let urlResult = self.com?.url {
                observer.on(.next(urlResult))
            }
            
            let error = err.makeurl(description: "TEST URL PARSE FROM URLCOMPONENTS ERR")
            observer.on(.error(error))
            
            
            return Disposables.create()
        }
    }

    func rxTestLogin(userData: [String:String]) -> Observable<userSession?> {
        self.rxMakeLoginURLComponents(userData).flatMap { url -> Observable<userSession?> in
            let request = URLRequest(url: url)
            let dataTask = URLSession.shared.rx.response(request: request)
            return dataTask
                .debug("testLoginRequest")
                .flatMap { (response: HTTPURLResponse, data: Data) -> Observable<userSession?> in
                    if 200 ..< 300 ~= response.statusCode {
                        do {
                            let userSessionData = try self.decoder.decode(userSession.self, from: data)
                            return Observable.create { observer -> Disposable in
                                observer.on(.next(userSessionData))
                                return Disposables.create()
                            }
                        } catch {
                            return Observable.error(err.parsing(description: "RESPONSE PARSE ERROR"))
                        }
                    }
                    else {
                        return Observable.error(err.network(description: "NETWORK ERROR"))
                    }
                }
        }
    }
    
}

