//
//  AddNewReviewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/14.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

class AddNewReviewController: UIViewController {
    
    var initData: [String:String] = [String:String]()
    
    @IBOutlet var imageViewPicker: UIImageView!
    @IBOutlet var imageViewPickerWidth: NSLayoutConstraint!
    @IBOutlet var imageViewPickerHeight: NSLayoutConstraint!
    
    private let picker = UIImagePickerController()
    
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
            picker.delegate = self
            DispatchQueue.global().async {
                self.getImageFromURL(url: URL(string: self.initData["posterImage"]!.decodeUrl()!)!)
            }
            resizeImageViewPicker(size: CGSize(width: 240, height: 325))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePickerOpen))
            imageViewPicker.addGestureRecognizer(tapGesture)
            imageViewPicker.isUserInteractionEnabled = true
            picker.delegate = self
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
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.setEditing(true, animated: true)
//        picker.preferredContentSize = CGSize(width: 240, height: 325)
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

extension AddNewReviewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.image = info[.editedImage] as? UIImage
        picker.dismiss(animated: false, completion: nil)
    }
}
