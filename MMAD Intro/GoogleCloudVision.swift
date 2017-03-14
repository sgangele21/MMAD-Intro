//
//  GoogleCloudVision.swift
//  MMAD Intro
//
//  Created by Sahil Gangele on 3/12/17.
//  Copyright © 2017 Sahil Gangele. All rights reserved.
//
import Alamofire

public class GoogleCloudVision {
    
    let apiKey = "AIzaSyBup7JlBH7wVSIAr0bOMAfcupzUyS3VWsU"
    var baseURL: String {
        return "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"
    }
    
    func analyzeImage(image: UIImage, completion: @escaping (Image?) -> Void) {
        let encodedImage = self.encodeImage(image: image)
        let urlRequest = self.createURLRequest(encodedImage: encodedImage)
        Alamofire.request(urlRequest).responseJSON { response in
            switch response.result {
                case .failure(let error):
                    print(error)
                    break
                case .success :
                    // TODO: Make a check for the 0th Index
                    var json = response.result.value
                    if let newJSON = json as? [String : Any], let labelAnnotations = newJSON[Keys.responses] as? [[String : [Any]]], let annotations = labelAnnotations[0][Keys.labelAnnotations] as? [[String : Any]] {
                        let analyzedImage = Image(JSON: annotations, image: image)
                        completion(analyzedImage)
                    } else {
                        print("Conversion didn't work")
                    }
                    break
            }
        }
    }
    
    func encodeImage(image: UIImage) -> String {
        var newimage: UIImage = image
        var imageData = UIImagePNGRepresentation(image)
        while(imageData!.count > 1048576 ) {
            newimage = self.resizeImage(image: newimage)
            imageData = UIImagePNGRepresentation(newimage)
        }
        return (imageData?.base64EncodedString(options: .endLineWithCarriageReturn))!
    }
    
    func createURLRequest(encodedImage: String) -> URLRequest {
        let request = [
            Keys.requests: [
                Keys.image: [
                    Keys.content: encodedImage
                ],
                Keys.features: [
                    [
                        Keys.type: Values.labelDetection,
                        Keys.maxResults: Values.maxResults
                    ]
                ]
            ]
        ]
        var urlRequest = URLRequest(url: URL(string: self.baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: request, options: .prettyPrinted)
        } catch(let value) {
            print(value)
        }
        return urlRequest
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width / 2, height: image.size.height / 2)
        
        // 0.0 Becuase you want to the scale to apply automatically to every type of device screen
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        // Gets whatever image is being drawn in the current bitmap
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
