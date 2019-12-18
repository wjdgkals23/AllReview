//
//  NonBottomViewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/16.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

@objc protocol OneLineReviewViewProtocol {
    func setUpView()
    func setUpRx()
    @objc optional func setUpWebView()
}

class NonBottomViewController: UIViewController {
    
    private var naviVC: UINavigationController!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var titleImageVIew: UIImageView!
    
    @IBOutlet var containerView: UIView! // containerChange 함수 필요!
    
    public var childViewController: UIViewController!
    
    var topSafeArea:CGFloat! {
        willSet(newValue){
            if(newValue != self.topSafeArea) {
                let topTotalHeight = self.headerView.bounds.height + newValue
                let webViewHeight = self.view.bounds.height - topTotalHeight
                let beforeRect = self.containerView.frame
                let cgRect = CGRect(x: beforeRect.origin.x, y: beforeRect.origin.y, width: beforeRect.width, height: webViewHeight)
                self.containerView.frame = cgRect
                self.onAddChildController()
            }
        }
    }
    var bottomSafeArea:CGFloat!

    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *) {
            topSafeArea = self.view.safeAreaInsets.top
            bottomSafeArea = self.view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navi = catchNavigation() {
            self.naviVC = navi
        } else {
            self.viewDidLoad()
        }
        // Do any additional setup after loading the view.
    }
    
    private func onAddChildController() {
        guard let childVC = self.childViewController else {
            naviVC.popViewController(animated: true)
            return
        }
        self.addChild(childVC)
        self.containerView.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        
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
