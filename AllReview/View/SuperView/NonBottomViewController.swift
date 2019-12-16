//
//  NonBottomViewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/16.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

class NonBottomViewController: UIViewController {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var containerView: UIView! // containerChange 함수 필요!
    
    public var childViewController: UIViewController!
    private var naviVC: UINavigationController!
    
//    var topSafeArea:CGFloat! {
//        willSet(newValue){
//            if(newValue != self.topSafeArea) {
//                let webViewHeight = self.view.bounds.height - newValue
//                let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: webViewHeight)
//                for item in self.viewList {
//                    item.frame = cgRect
//                }
//            }
//        }
//    }
//    
//    override func viewDidLayoutSubviews() {
//        if #available(iOS 11.0, *) {
//            topSafeArea = self.view.safeAreaInsets.top
//            bottomSafeArea = self.view.safeAreaInsets.bottom
//        } else {
//            topSafeArea = topLayoutGuide.length
//            bottomSafeArea = self.bottomLayoutGuide.length
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navi = catchNavigation() {
            self.naviVC = navi
            self.onAddChildController()
        } else {
            self.viewDidLoad()
        }
        // Do any additional setup after loading the view.
    }
    
    func onAddChildController() {
        guard let childVC = self.childViewController else {
            naviVC.popViewController(animated: true)
            return
        }
        self.addChild(childVC)
        self.containerView.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
