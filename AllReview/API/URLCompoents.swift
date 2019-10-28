//
//  Requests.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

enum OneLineReviewError: Error {
    case makeurl(description: String)
    case parsing(description: String)
    case network(description: String)
}

struct OneLineReview { // 기본 url 셋팅
    static let scheme = "https"
    static let host = "www.teammiracle.be"
    
    static let memberRegisterPath = "/member/add"
    static let memberLoginPath = "/member/login"
}

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
