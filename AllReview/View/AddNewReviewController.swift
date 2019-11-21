//
//  AddNewReviewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/14.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

class AddNewReviewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navi = catchNavigation() {
//            router = LoginRouter(navigation: navi)
//            viewModel = LoginViewModel()
        } else {
            self.viewDidLoad()
        }
        // Do any additional setup after loading the view.
    }
    

    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navigationController.popViewController(animated: false)
        }
        else {
            print("View Load Fail")
        }
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
