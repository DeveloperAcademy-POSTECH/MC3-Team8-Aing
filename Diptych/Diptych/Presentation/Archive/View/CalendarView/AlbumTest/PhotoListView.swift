//
//  PhotoListView.swift
//  Diptych
//
//  Created by Koo on 2023/07/24.
//


import SwiftUI

struct PhotoListView: View {
    @ObservedObject var VM = PhotoViewModel()

    
    var body: some View {
        NavigationView {
            List(VM.photos) { photo in
                HStack() {
                    ImageView2(imageURL: photo.imageURL)
                        .frame(width: 50,height: 50)
                    Text("\(photo.dayNum)")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("\(photo.monthNum)")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Photos")
            
            List(VM.photos) { photo in
                HStack() {
                    ImageView2(imageURL: photo.imageURL)
                        .frame(width: 50,height: 50)
                    Text("\(photo.dayNum)")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("\(photo.monthNum)")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Photos")
            
        }
    }
    
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


struct PhotoListView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoListView()
    }
}


