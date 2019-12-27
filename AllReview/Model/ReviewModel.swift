//
//  ReviewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

struct ReView: Codable {
    var memberId: String
    var movieId: String
    var oneLineReview: String
    var detailReview: String
    var starPoint: Int
    var imageUrl: String
}
