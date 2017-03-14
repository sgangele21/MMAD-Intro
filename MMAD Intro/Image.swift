//
//  Image.swift
//  MMAD Intro
//
//  Created by Sahil Gangele on 3/13/17.
//  Copyright © 2017 Sahil Gangele. All rights reserved.
//

import UIKit

public struct Image {
    
    var attributes: [ImageAttributes]
    let image: UIImage
    var count: Int {
        return attributes.count
    }
    
    init?(JSON: [[String: Any]], image: UIImage) {
        self.image = image
        self.attributes = []
        for attribute in JSON {
            guard let description = attribute[Keys.description] as? String else { return nil }
            guard let score = attribute[Keys.score] as? Double  else { return nil }
            attributes.append(ImageAttributes(description: description, score: score))
        }
    }
    
    subscript(index: Int) -> ImageAttributes {
        return attributes[index]
    }
    
}

public struct ImageAttributes {
    let description: String
    let score: Double
    
    init(description: String, score: String) {
        self.init(description: description, score: Double(score)!)
    }
    
    init(description: String, score: Double) {
        self.description = description
        self.score = score
    }
}


public struct Keys {
    
    static let responses = "responses"
    static let labelAnnotations = "labelAnnotations"
    static let requests = "requests"
    static let image = "image"
    static let content = "content"
    static let features = "features"
    static let type = "type"
    static let maxResults = "maxResults"
    
    static let description = "description"
    static let score = "score"
    
}

public struct Values {
    
    static let labelDetection = "LABEL_DETECTION"
    static let maxResults = 10
}
