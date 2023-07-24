//
//  ImageLoader.swift
//  Diptych
//
//  Created by Koo on 2023/07/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage


class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    init(imageURL: String) {
        fetchImage(imageURL: imageURL)
    }
    
    func fetchImage(imageURL: String) {
        let storage = Storage.storage()
        let reference = storage.reference(forURL: imageURL)
        
        reference.getData(maxSize: 10 * 1024 * 1024) { data, error in
            guard let data = data else {
                print("Error fetching image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
    }
}
