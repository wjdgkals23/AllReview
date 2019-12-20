//
//  AddNewReviewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/14.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit
import YPImagePicker
import AVFoundation
import AVKit
import RxSwift
import Photos
import Cosmos

class AddNewReviewController: UIViewController, OneLineReviewViewProtocol {
    
    var initData: [String:String] = [String:String]()
    
    private var viewModel:AddNewReviewViewModel!
    
    @IBOutlet var imageViewPicker: UIImageView!
    @IBOutlet var imageViewPickerWidth: NSLayoutConstraint!
    @IBOutlet var imageViewPickerHeight: NSLayoutConstraint!
    @IBOutlet var starRatingView: CosmosView!
    @IBOutlet var starRatingLabel: UILabel!
    
    @IBOutlet var movieName: UILabel!
    
    private var starPoint: Int = 0 {
        willSet {
            self.starRatingLabel.text = String(newValue)
        }
    }
    
    private var picker:YPImagePicker!
    
    private var image: UIImage! {
        willSet {
            let resizedImage = UIImage.resizeImage(image: newValue, targetSize: self.view.bounds.width)
            self.imageViewPicker.image = resizedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navi = catchNavigation() {
            viewModel = AddNewReviewViewModel()
            setUpView()
            setUpRx()
            
            print(initData)
        } else {
            self.viewDidLoad()
        }
    }
    
    func setUpView() {
        self.resizeImageViewPicker(size: CGSize(width: 240, height: 325))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePickerOpen))
        self.imageViewPicker.addGestureRecognizer(tapGesture)
        self.imageViewPicker.isUserInteractionEnabled = true
        self.imageViewPicker.contentMode = .scaleToFill
        
        self.movieName.text = self.initData["movieKorName"]!.decodeUrl()
        
        
        self.starRatingView.didTouchCosmos = { rating in
            self.starPoint = Int(rating*2)
        }
        self.starPoint = 5
        self.starRatingView.settings.fillMode = .half
        self.starRatingView.settings.minTouchRating = 0.0
        self.starRatingView.settings.updateOnTouch = true
    }
    
    func setUpRx() {
        self.viewModel.imageViewImageSubject.asObservable().subscribe(onNext: { [weak self] img in
            self?.image = img
        })
        self.viewModel.request.commomImageLoad(url: URL(string: self.initData["posterImage"]!.decodeUrl()!)!)
            .bind(to: self.viewModel.imageViewImageSubject)
            .disposed(by: self.viewModel.disposeBag)
    }
    
    private func SendPhoto() {
     
    }
    
    private func resizeImageViewPicker(size: CGSize) {
        imageViewPickerWidth.constant = size.width
        imageViewPickerHeight.constant = size.height
    }
    
}

extension AddNewReviewController: YPImagePickerDelegate {
    
    func noPhotos() {
        self.showToast(message: "사진이없습니다.", font: UIFont.systemFont(ofSize: 17, weight: .semibold))
    }
    
    @objc func imagePickerOpen() {
        var config = YPImagePickerConfiguration()
        
        config.library.mediaType = .photo
        config.shouldSaveNewPicturesToAlbum = false
        config.video.compression = AVAssetExportPresetMediumQuality
        config.video.libraryTimeLimit = 500.0
        config.showsCrop = .rectangle(ratio: (240/325))
        config.library.maxNumberOfItems = 1
        config.screens = [.library]
        
        picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        
        picker.didFinishPicking { [unowned picker, weak self] items, cancel in //unowned 자신보다 먼저 해지될 타겟
            if cancel {
                print("picekr cancel")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    self?.image = photo.image
                    picker?.dismiss(animated: true, completion: nil)
                    return
                case .video(_):
                    return
                }
            }
            
            picker?.dismiss(animated: true, completion: nil)
        }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navigationController.popViewController(animated: false)
        }
        else {
            print("View Load Fail")
        }
    }
}

