//
//  ViewController.swift
//  WhatFlower
//
//  Created by mobin on 1/3/22.
//

import UIKit
import CoreML
import Vision
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php?format=json&action= query"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        navigationController?.navigationBar.backgroundColor = .magenta
            
    }
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        present(imagePicker
                , animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
            
            guard let ciImage = CIImage(image: selectedImage) else {
                
                fatalError("this is not false ")
            }
            
            detect(image: ciImage)
            
        }
        
        imagePicker.dismiss(animated: false, completion: nil)
    }
    
    func detect(image : CIImage){
        guard let imageModel =  try? VNCoreMLModel(for: FlowerShop().model
        )else {
            fatalError(" problem for loading image")
        }
        let request = VNCoreMLRequest(model: imageModel) { request, error  in
            guard  let results = request.results as? [VNClassificationObservation] else {
                fatalError("we have problem to classifaction model")
            }
            if let firstRes = results.first{
                self.navigationController?.navigationBar.topItem?.title = "\(firstRes.identifier)"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try! handler.perform([request])
            
        }catch {
            print(error)
        }
    }
    
    func requestInfo(){
        
    }


}

