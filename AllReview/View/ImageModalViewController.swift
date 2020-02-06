//
//  ViewController.swift
//  AllReview
//
//  Created by 정하민 on 2020/02/06.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImageModalViewController: UIViewController, OneLineRevieViewControllerType {
    
    var viewModel: ImageModalViewModel!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setUpView() {
        return
    }
    
    func setUpRx() {
        self.viewModel.capturedImageSubject.distinctUntilChanged().asDriver(onErrorJustReturn: nil)
            .drive(self.imageView.rx.image).disposed(by: self.viewModel.disposeBag)
    }
    
    func setUpWebView() {
        return
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
