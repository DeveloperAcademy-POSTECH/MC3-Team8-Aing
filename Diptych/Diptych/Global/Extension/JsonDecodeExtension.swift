//
//  JsonDecodeExtension.swift
//  Diptych
//
//  Created by Koo on 2023/07/18.
//

import Foundation

extension Bundle {
    
    func decode<T: Codable>(_ file: String) -> T {
        
        /// 1.Json 파일 가져오기
        guard let url = self.url(forResource: file, withExtension: nil)
        else {
            fatalError("Failed to locate \(file) in bundle")
        }
        
        /// 2.Json 로 부터 Data 생성
        guard let data = try? Data(contentsOf: url)
        else {
            fatalError("Failed to load \(file) from bundle")
        }
        
        /// 3. Json Decoder 생성
        let decoder = JSONDecoder()
        
        /// 4. 만든 Decoder 를 통해서 Data 를 Swift 상에서 읽을수 있게 Decode 하기
        guard let loaded = try? decoder.decode(T.self, from: data)
        else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        
        /// 5. Decode 된 Data return 하기
        return loaded
    }
    
}
