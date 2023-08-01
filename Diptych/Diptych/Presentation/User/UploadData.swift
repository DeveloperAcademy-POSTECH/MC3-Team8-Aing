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
        Button {
            Task {
                try await uploadData()
            }
        } label: {
            Text("UPLOAD")
        }
    }
    
    func fetchData() async throws {
        var datas: Dictionary = [String: Data]()
        do {
            guard let snapshot = try? await Firestore.firestore().collection("photos").getDocuments() else {
                print("ERROR: (generatedCouplingCode) getAllusers")
                return
            }
            var i = 0
            for doc in snapshot.documents {
                let data = doc.data()
                let photoData = try Photo(dictionary: data)
                let jsonData = try JSONSerialization.data(withJSONObject: photoData, options: .prettyPrinted)
//                print(data)
//                let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                datas["\(i)"] = jsonData
                i += 1
            }
            print(datas["1"])
            saveDataToFile(fetchData: datas, fileName: "contentsDatas")
        }
    }
    
    func saveDataToFile(fetchData: [String:Data], fileName: String) {
        do {
            // JSON 데이터를 파일로 저장할 URL 경로를 지정합니다.
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(fileName)

            // JSON 데이터를 파일로 저장합니다.
            let jsonData = try JSONSerialization.data(withJSONObject: fetchData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)

            print("데이터를 파일로 저장 성공: \(fileURL.absoluteString)")
        } catch {
            print("데이터를 파일로 저장 실패: \(error.localizedDescription)")
        }
    }

    // 사용 예시
//    saveDataToFile(data: jsonData, fileName: "myData.json")
    
    func uploadData() async throws {
        do {
//            var jsonData = readJSONFromFile(fileName: "contentsDatas.json")
            guard let fileLocation = Bundle.main.url(forResource: "contentsDatas", withExtension: "json") else { return}
            let datas = try Data(contentsOf: fileLocation)
            guard let jsonObjects = try JSONSerialization.jsonObject(with: datas, options: .allowFragments) as? [String: [String : Any]] else { return }
            print(jsonObjects)
            for object in jsonObjects {
//                print(object.value["id"]!)
                let jsonData = try JSONSerialization.data(withJSONObject: object.value, options: .prettyPrinted)
                let decoder = JSONDecoder()
                let content = try decoder.decode(Photo.self, from: jsonData)
                print(content)
                print()
                let contentId = content.id
                let encodedContent = try Firestore.Encoder().encode(content)
                try await Firestore.firestore().collection("photos").document(contentId).setData(encodedContent, merge: true)
            }
//            print(fileLocation)
//            print(datas)
//            for data in datas {
//                let content = try? JSONDecoder().decode(Content.self, from: data)
//
//            }
//            for data in datas {
//            print(String(data: datas, encoding: .utf8))
//            }
//            print(jsonData)
//            print(jsonData!.type)
//            var jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [String: Any]] {
//                for data in jsonObject {
//                    print(data)
//                }
//            }
        }
    }
    
    func readJSONFromFile(fileName: String) -> Data? {
        do {
            // JSON 파일의 URL을 가져옵니다.
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(fileName)

            // JSON 파일의 데이터를 읽어옵니다.
            let jsonData = try Data(contentsOf: fileURL)
            return jsonData
        } catch {
            print("JSON 파일 읽기 실패: \(error.localizedDescription)")
            return nil
        }
    }

    // 사용 예시
//    if let jsonData = readJSONFromFile(fileName: "yourJSONFile.json") {
//        // JSON 데이터 사용 가능
//    } else {
//        print("JSON 파일을 읽어올 수 없습니다.")
//    }


}

extension Dictionary {

    func decodeTo<T>(_ type: T.Type) -> T? where T: Decodable {

        var dict = self

        // This block will change any Date and Timestamp type to Strings
        dict.filter {
            $0.value is Date || $0.value is Timestamp
        }.forEach {
            if $0.value is Date {
                let date = $0.value as? Date ?? Date()
                dict[$0.key] = date.timestampString as? Value
            } else if $0.value is Timestamp {
                let date = $0.value as? Timestamp ?? Timestamp()
                dict[$0.key] = date.dateValue().timestampString as? Value
            }
        }

        let jsonData = (try? JSONSerialization.data(withJSONObject: dict, options: [])) ?? nil
        if let jsonData {
            return (try? JSONDecoder().decode(type, from: jsonData)) ?? nil
        } else {
            return nil
        }
    }
}

extension Date {

    var timestampString: String {
        Date.timestampFormatter.string(from: self)
    }

    static private var timestampFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }
}

extension Photo {
    init(dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(Photo.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}

struct UploadData_Previews: PreviewProvider {
    static var previews: some View {
        UploadData()
    }
}
