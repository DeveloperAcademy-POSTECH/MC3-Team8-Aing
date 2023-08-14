//
//  PhotoViewModel.swift
//  Diptych
//
//  Created by Koo on 2023/07/24.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

//MARK: - Model
struct Photo3: Identifiable {
    let id: String
    let imageURL: String
    let date: Date
    let dayNum: Int
    let monthNum : Int
}

//MARK: - ViewModel
class PhotoViewModel: ObservableObject {
    @Published var photos: [Photo3] = []

    init(){
        fetchPhotos()
        print("📍",self.photos)
    }
    
    
    func fetchPhotos() {
        // Assuming you have already configured Firebase in your app
        let firestore = Firestore.firestore()
        
        // Assuming you have a collection called "photos" and each document has "imageURL" and "date" fields
        firestore.collection("testphotos")
            .getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                print("Error fetching photos: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.photos = documents.compactMap { document in
                guard let imageURL = document.data()["imageURL"] as? String,
                      let timestamp = document.data()["date"] as? Timestamp
                else {return nil}
                
                let day = timestamp.dateValue().get(.day)
                let month = timestamp.dateValue().get(.month)
                
                return Photo3(id: document.documentID,
                              imageURL: imageURL,
                              date: timestamp.dateValue(),
                              dayNum: day,
                              monthNum: month)
            }
        }//: getDocuments
        
    }
}

//MARK: - ImageLoader
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


//MARK: - View
struct PhotoListView: View {
    @StateObject var VM = PhotoViewModel()

    var body: some View {
        
        VStack{
            ForEach(VM.photos) { index in
                HStack() {
                    ImageView2(imageURL: index.imageURL)
                        .frame(width: 50,height: 50)
                    
                    Text("\(index.dayNum)")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("\(index.monthNum)")
                        .font(.title3)
                        .foregroundColor(.gray)
                }//】 HStack
            }//】 Loop
        }//】 VStack
    }//】 Body
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}



struct ImageView2: View {
    @StateObject private var imageLoader: ImageLoader
    private let imageURL: String

    init(imageURL: String) {
        self.imageURL = imageURL
        _imageLoader = StateObject(wrappedValue: ImageLoader(imageURL: imageURL))
    }

    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            ProgressView()
        }
    }
}

//MARK: - Preview
struct PhotoListView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoListView()
    }
}




