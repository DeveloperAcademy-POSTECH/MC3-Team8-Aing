//
//  AlbumModel.swift
//  Diptych
//
//  Created by Koo on 2023/07/18.
//

import SwiftUI

// AppData
struct AlbumData: Identifiable, Codable {

    let id : String
    let ContentID : String
    var isCompleted : Bool
//    var date: Date


    //Sample 데이터
    static let sampleAlbumData = AlbumData(
        id: "230718",
        ContentID: "0",
        isCompleted: false
//        date: 2023-07-18
    )//: Sample

}//: AppData
