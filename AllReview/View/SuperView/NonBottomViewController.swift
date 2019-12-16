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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func onAddChildController(vc: UIViewController) {
        self.addChild(vc)
        self.containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
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
