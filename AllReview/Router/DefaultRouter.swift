//
//  DefaultRouter.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/29.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit

protocol DefaultRouter {
    func naviPush(_ to: String, _ data: Dictionary<String,String>)
    func naviPop(_ act: String)
    func viewPresent(_ to: String, _ data: Dictionary<String,String>)
    func viewDismiss(_ act: String)
}
