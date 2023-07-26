//
//  PhotoListView.swift
//  Diptych
//
//  Created by Koo on 2023/07/24.
//


import SwiftUI

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
                }
            }
            
            
//            List(VM.photos) {data in
//
//                    HStack() {
//                        ImageView2(imageURL: data.imageURL)
//                            .frame(width: 50,height: 50)
//                        Text("\(data.dayNum)")
//                            .font(.title3)
//                            .foregroundColor(.gray)
//                        Text("\(data.monthNum)")
//                            .font(.title3)
//                            .foregroundColor(.gray)
//                    }//】 HStack
//
//            }//】 VStack

            
        
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


