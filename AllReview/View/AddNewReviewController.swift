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
import Photos

class AddNewReviewController: UIViewController {
    
    var initData: [String:String] = [String:String]()
    
    @IBOutlet var imageViewPicker: UIImageView!
    @IBOutlet var imageViewPickerWidth: NSLayoutConstraint!
    @IBOutlet var imageViewPickerHeight: NSLayoutConstraint!
    
    private var picker:YPImagePicker!
    
    private var image: UIImage! {
        willSet {
            let resizedImage = UIImage.resizeImage(image: newValue, targetSize: self.view.bounds.width)
            //            self.resizeImageViewPicker(size: resizedImage.size)
            self.imageViewPicker.contentMode = .scaleToFill
            self.imageViewPicker.image = resizedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navi = catchNavigation() {
            DispatchQueue.global().async {
                self.getImageFromURL(url: URL(string: self.initData["posterImage"]!.decodeUrl()!)!)
            }
            resizeImageViewPicker(size: CGSize(width: 240, height: 325))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePickerOpen))
            imageViewPicker.addGestureRecognizer(tapGesture)
            imageViewPicker.isUserInteractionEnabled = true
        } else {
            self.viewDidLoad()
        }
        // Do any additional setup after loading the view.
    }
    
    func resizeImageViewPicker(size: CGSize) {
        imageViewPickerWidth.constant = size.width
        imageViewPickerHeight.constant = size.height
    }
    
    func getImageFromURL(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        } catch {
            return
        }
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
        
        picker.didFinishPicking { [unowned picker] items, cancel in //unowned 자신보다 먼저 해지될 타겟
            if cancel {
                print("picekr cancel")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    self.imageViewPicker.image = photo.image
                    picker?.dismiss(animated: true, completion: nil)
                    return
                case .video(let _):
                    return
                }
            }
            
            picker?.dismiss(animated: true, completion: nil)
        }
        
        self.present(picker, animated: false, completion: nil)
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

//extension AddNewReviewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        self.image = info[.editedImage] as? UIImage
//        picker.dismiss(animated: false, completion: nil)
//    }
//}
