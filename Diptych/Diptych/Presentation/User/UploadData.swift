//
//  UploadData.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/08/01.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UploadData: View {
    var body: some View {
        Button {
            Task {
                try await fetchData()
            }
        } label: {
            Text("FETCH")
        }
    }
    
    func fetchData() async throws {
        do {
            guard let snapshot = try? await Firestore.firestore().collection("contents").getDocuments() else {
                print("ERROR: (generatedCouplingCode) getAllusers")
                return
            }
            for doc in snapshot.documents {
                print(doc)
            }
        }
    }
}

struct UploadData_Previews: PreviewProvider {
    static var previews: some View {
        UploadData()
    }
}
