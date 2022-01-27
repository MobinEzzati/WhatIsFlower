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
import Kingfisher

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var flowerDescription: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=Trumpet_creeper"
    
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
                self.requestInfo(flowerName: firstRes.identifier)
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try! handler.perform([request])
            
        }catch {
            print(error)
        }
    }
    
    func requestInfo(flowerName : String){
        let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts|pageimages",
        "exintro" : "",
        "explaintext" : "",
        "redirects" : "1",
        "titles" : flowerName,
        "pithumbsize" : "500"
       
        ]
    
        AF.request(wikipediaURl, method: .get, parameters: parameters).validate().responseJSON { respone  in
            switch respone.result {
                
            case .success(_):
                let json = try! JSON(data: respone.data!)
                let pageId = json["query"]["pages"].dictionaryValue.keys.first!
                let description = json["query"]["pages"]["\(String(pageId))"]["extract"].stringValue
                let imageUrl = json["query"]["pages"]["\(String(pageId))"]["thumbnail"]["source"].stringValue
                self.flowerDescription.text = description
                self.imageView.kf.setImage(with:URL(string: imageUrl))
                
                break
            case .failure(let error ):
                print(error)
            }

        }
    
        
        }
        

    }




