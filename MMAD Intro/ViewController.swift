//
//  ViewController.swift
//  MMAD Intro
//
//  Created by Sahil Gangele on 3/12/17.
//  Copyright © 2017 Sahil Gangele. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let kHeaderHeight = 274.0
    var cameraViewController = UIImagePickerController()
    var googleCloudVision = GoogleCloudVision()
    var headerView: UIView?
    var currentImage: UIImage? {
        didSet {
            self.imageView.image = currentImage!
            self.tableView.contentInset = UIEdgeInsets(top: CGFloat(kHeaderHeight), left: 0, bottom: 0, right: 0)
            self.tableView.contentOffset = CGPoint(x: 0, y: -kHeaderHeight)
            self.updateHeaderView()
        }
    
    }
    var analyzedImage: Image? {
        didSet {
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
        self.setupHeaderView()
        self.setupPhotoButton()
    }

    func setupPhotoButton() {
        self.takePhotoButton.layer.masksToBounds = true
        self.takePhotoButton.layer.cornerRadius = self.takePhotoButton.frame.width / 2.0
        self.takePhotoButton.layer.borderWidth = 4.0
        self.takePhotoButton.layer.borderColor = UIColor(colorLiteralRed: 0.0, green: 128.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
        self.takePhotoButton.backgroundColor = UIColor.white
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.stopAnimating()
    }
    
    func setupCamera() {
        cameraViewController.delegate = self
        cameraViewController.sourceType = .camera
        cameraViewController.cameraCaptureMode = .photo
        cameraViewController.cameraFlashMode = .auto
        cameraViewController.showsCameraControls = true
    }
    
    func setupHeaderView() {
        // Take full contorl of the header view
        self.imageView.layer.masksToBounds = true
        self.headerView = self.tableView.tableHeaderView
        self.tableView.tableHeaderView = nil
        tableView.addSubview(self.headerView!)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.analyzedImage = nil
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageView.image = image
        self.currentImage = image
        let globalQueue = DispatchQueue.global(qos: .background)
        globalQueue.async {
            self.googleCloudVision.analyzeImage(image: self.currentImage!) { analyzedImage in
                self.analyzedImage = analyzedImage
            }
        }
        self.activityIndicator.startAnimating()
        self.cameraViewController.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        self.infoLabel.isHidden = true
        self.present(cameraViewController, animated: true, completion: nil)
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.analyzedImage == nil ? 0 : (self.analyzedImage?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttributeCell") as! ImageAttributeCell
        let index = indexPath.row
        if let attribute = self.analyzedImage?[index] {
            cell.descriptionLabel.text = attribute.description
            cell.scoreProgressView.progress = Float(attribute.score)
        }
        return cell
    }
}


extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateHeaderView()
    }
    
    func updateHeaderView() {
        let headerViewHeight = Int(kHeaderHeight)
        print(headerViewHeight)
        var headerViewFrame = CGRect(x: 0, y: -headerViewHeight, width: Int(tableView.bounds.width) , height: headerViewHeight)
        
        if Int(tableView.contentOffset.y) < -headerViewHeight {
            headerViewFrame.origin.y = tableView.contentOffset.y
            print(headerViewFrame.origin.y)
            headerViewFrame.size.height = (-tableView.contentOffset.y)
        }
        self.headerView!.frame = headerViewFrame
        
    }
}

extension UIButton {
    
    func createCircularButton(frame: CGRect) -> UIButton {
        let button = UIButton(frame: frame)
        button.layer.cornerRadius = button.frame.width / 2
        return button
    }
    
}
