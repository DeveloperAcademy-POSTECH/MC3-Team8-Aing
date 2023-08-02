//
//  DiptychCompleteAlertObject.swift
//  Diptych
//
//  Created by 김민 on 2023/08/02.
//

import Foundation

class DiptychCompleteAlertObject: ObservableObject {
    
    @Published var isDiptychCompleted = false
    @Published var isDiptychCompleteAlertShown = false
}
//
//    @Published var isDiptychCompleteAlertShown = false {
//        didSet {
//            UserDefaults.standard.set(isDiptychCompleteAlertShown, forKey: "diptychCompleteAlertShown")
//        }
//    }
//
//    private var lastDate: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: "lastDateKey") as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: "lastDateKey")
//        }
//    }
//
//    init() {
//        isDiptychCompleteAlertShown = UserDefaults.standard.bool(forKey: "diptychCompleteAlertShown")
//    }
//
//    func checkDateAndResetAlertIfNeeded() {
//        let currentDate = Date()
//        if let lastDate = lastDate, Calendar.current.isDate(lastDate, inSameDayAs: currentDate) == false {
//            isDiptychCompleteAlertShown = false
//        }
//        self.lastDate = currentDate
//    }
//}
