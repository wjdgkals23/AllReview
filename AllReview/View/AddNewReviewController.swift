//
//  AddNewReviewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/14.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit
import YPImagePicker
import Foundation
import AVFoundation
import AVKit
import RxSwift
import Photos
import Cosmos

class AddNewReviewController: UIViewController {
    
    var initData: [String:String] = [String:String]()
    
    private var viewModel:AddNewReviewViewModel!
    
    @IBOutlet var imageViewPicker: UIImageView!
    @IBOutlet var imageViewPickerWidth: NSLayoutConstraint!
    @IBOutlet var imageViewPickerHeight: NSLayoutConstraint!
    
    @IBOutlet var starRatingView: CosmosView!
    @IBOutlet var starRatingLabel: UILabel!
    
    @IBOutlet var movieName: UILabel!
    
    @IBOutlet var reviewTextView: UIView!
    @IBOutlet var reviewTitle: UITextField!
    @IBOutlet var reviewContent: UITextField!
    @IBOutlet var uploadButton: UIButton!
    
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
            Observable.just(resizedImage).bind(to: self.viewModel.imageViewImageSubject).disposed(by: self.viewModel.disposeBag)
        }
    }
    
    private var navi:UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navi = catchNavigation() {
//            self.navi = navi
//            viewModel = AddNewReviewViewModel(imgURL: self.initData["posterImage"],)
//            setUpRx()
//            setUpView()
//            NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification , object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification , object: nil)
//            print(initData)
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
        
        self.reviewTitle.delegate = self
        self.reviewContent.delegate = self
        self.reviewContent.layoutMargins = UIEdgeInsets.init(top: 3, left: 5, bottom: 3, right: 5)
    }
    
    func setUpRx() {
        
        self.viewModel.imageViewDriver
            .drive(self.imageViewPicker.rx.image)
            .disposed(by: self.viewModel.disposeBag)
        
        self.viewModel.didSuccessAddReview
            .observeOn(MainScheduler.instance)
            .subscribe({ [weak self] _ in
//                self?.viewModel.reloadRequestSubject.onNext(())
                do {
                    let mainSubjectValue = try self?.viewModel.mainViewRequestSubject.value()
                    self?.viewModel.mainViewRequestSubject.onNext(mainSubjectValue)
                    let mySubjectValue = try self?.viewModel.myViewRequestSubject.value()
                    self?.viewModel.myViewRequestSubject.onNext(mySubjectValue)
                    let searchSubjectValue = try self?.viewModel.searchResultSubject.value()
                    self?.viewModel.searchResultSubject.onNext(searchSubjectValue)
                    self?.navi.popViewController(animated: true)
                } catch {
                    self?.showToast(message: "리로딩 실패", font: UIFont.systemFont(ofSize: 18, weight: .semibold))
                }
            }).disposed(by: self.viewModel.disposeBag)
        
        self.viewModel.didFailAddReview
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { errMessage in
                print(errMessage)
                self.uploadButton.isEnabled = false
            })
            .disposed(by: self.viewModel.disposeBag)
        
        self.reviewTitle.rx.text
            .bind(to: self.viewModel.reviewTitleTextSubject)
            .disposed(by: self.viewModel.disposeBag)
        
        self.reviewContent.rx.text
            .bind(to: self.viewModel.reviewContentTextSubject)
            .disposed(by: self.viewModel.disposeBag)
        
        Observable.combineLatest(viewModel.isImageValid, viewModel.isTitleValid, viewModel.isContentValid) {
            $0 && ($1 && $2)
        }
            .bind(to: self.uploadButton.rx.isEnabled)
            .disposed(by: viewModel.disposeBag)
    }
    
    @objc private func willShowKeyboard(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc private func willHideKeyboard(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    private func resizeImageViewPicker(size: CGSize) {
        imageViewPickerWidth.constant = size.width
        imageViewPickerHeight.constant = size.height
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navigationController.popViewController(animated: false)
        }
        else {
            print("View Load Fail")
        }
    }
    
    @IBAction func uploadReview(_ sender: Any) {
        let sendData = ["memberId": self.viewModel.userLoginSession.getLoginData()?.data?._id,
                        "movieId": self.initData["naverMovieId"], "starPoint": self.starPoint, "oneLineReview": self.reviewTitle.text, "detailReview":self.reviewContent.text] as [String : Any]
        self.viewModel.uploadReview(img: self.imageViewPicker.image!, data: sendData)
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
}

extension AddNewReviewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
