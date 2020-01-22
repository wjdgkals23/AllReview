//
//  Response.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

enum LoginErrResponse: String {
    case success = "0000"
    case noUserInfo = "0404"
    case queryError = "0500"
    case passwordErr1 = "1000"
    case passwordErr2 = "2000"
    case deviceCheckIdDiff = "3000"
    case memberEmailDiff = "4000"
}

enum UploadReviewErrResponse: String {
    case success = "0000"
    case noUserInfo = "0404"
    case queryError = "0500"
    case noMovieId = "1404"
    case queryMovieError = "1500"
    case querySavedReviewError = "2404"
    case saveReviewError = "2500"
}

struct ErrResponse: Codable {
    let driver: String
    let name: String
    let index: String
    let code: String
    let errmsg: String
}

struct SuccessResponse: Codable {
    
}

struct UserInfo: Codable {
    let memberGender: String
    let memberImageUrl: String
    let wantMovieIds: [String]
    let _id: String
    let joinDate: String
    let memberName: String
    let platformCode: String
    let password: String
    let shortComment: String
    let memberEmail: String
    let deviceCheckId: String
    let saltSecretValue: String
    let __v: String
}

struct LoginInfo: Codable {
    let memberGender: String
    let memberImageUrl: String
    let wantMovieIds: Array<String>?
    let _id: String
    let joinDate: String
    let memberName: String
    let platformCode: String
    let password: String
    let shortComment: String
    let memberEmail: String
    let deviceCheckId: String
}
//"memberGender": "M",
//"memberImageUrl": "https://www.google.com/url?sa=i&source=images&cd=&ved=2ahUKEwiby6WepqnjAhUBwbwKHRxiCCQQjRx6BAgBEAU&url=https%3A%2F%2Ftvtropes.org%2Fpmwiki%2Fpmwiki.php%2FMain%2FGenres&psig=AOvVaw1QJx4SFWfHKqjgTD2onVo8&ust=1562811922956472",
//"wantMovieIds": [],
//"_id": "5d25b1a9b692d8fa466e8a75",
//"joinDate": "2019-07-10T09:36:41.918Z",
//"memberName": "veyond",
//"platformCode": "EM",
//"password": "$2a$10$2qcAkfDa8NFy3QB/Z5doH.7E2htza4.PD0NOsB3LEZA1Ei5mXC1aG",
//"shortComment": "Mystery",
//"memberEmail": "shjo@naver.com",
//"deviceCheckId": "macos-yond"

struct UserLoginSessionResponse: Codable {
    let resultCode:String
    let resultMsg:String
    let data:LoginInfo?
    let err:SuccessResponse
    let connectionId:String
}

struct UploadReviewResponse: Codable {
    let resultCode:String
    let resultMsg:String
    let data:UploadedItemData?
    let err:SuccessResponse
    let connectionId:String
}

struct UserInitSession: Codable {
    let resultCode:String
    let resultMsg:String
    let data:UserInfo
    let err:ErrResponse
    let connectionId:String
}

struct UploadedItemData: Codable {
    let memberImageUrl:String
    let likedMemberIds:[String]
    let _id:String
    let writeDateTime:String
    let movieId:String
    let movieKorName:String
    let movieEngName:String
    let productYear:String
    let oneLineReview:String
    let detailReview:String
    let memberId:String
    let memberName:String
    let starPoint:Int
    let imageUrl:String
    let detailLinkUrl:String
    let __v:Int
}

//{
//  "resultCode": "0000",
//  "resultMsg": "writeContent succeed",
//  "data": {
//    "memberImageUrl": "https://www.teammiracle.be/images/temp/user01@2x.png",
//    "likedMemberIds": [],
//    "_id": "5e006a006c53350f632c1370",
//    "writeDateTime": "2019-12-23T07:17:20.247Z",
//    "movieId": "5d5a48dcf6569570a39425c7",
//    "movieKorName": "라이온 킹",
//    "movieEngName": "The Lion King",
//    "productYear": "2019",
//    "oneLineReview": "테스트합니다.",
//    "detailReview": "리뷰 상세 내용 진짜 상세하게 안쓰셔도되요",
//    "memberId": "5d2353aa60de491e85013fb3",
//    "memberName": "조상맨",
//    "starPoint": 8,
//    "imageUrl": "https://search.pstatic.net/common/?src=http://shop1.phinf.naver.net/20181023_37/joyposter_15402753041909WK1K_JPEG/FMV-813.jpg&type=b150",
//    "detailLinkUrl": "https://movie.naver.com/movie/bi/mi/basic.nhn?code=169637",
//    "__v": 0
//  },
//  "err": {},
//  "connectionId": "201912230717203311136574"
//}
