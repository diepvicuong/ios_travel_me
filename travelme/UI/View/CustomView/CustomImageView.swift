//
//  CustomImageView.swift
//  travelme
//
//  Created by DiepViCuong on 1/31/21.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    private var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        image = nil
        
        //Check image in cache
        if let cachedImage = imageCache[urlString] {
            image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        // Download image from URL
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage { return }
            
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            
            // Save image into cache
            imageCache[url.absoluteString] = photoImage
            
            // Show image
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
    
}

