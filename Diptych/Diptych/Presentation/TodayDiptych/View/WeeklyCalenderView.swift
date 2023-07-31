//
//  WeeklyCalenderView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI
import FirebaseStorage

enum DiptychState {
    case incomplete
    case half
    case complete
}

struct WeeklyCalenderView: View {

    @State var day: String
    @State var date: String
    @State var isToday: Bool
    @State var thumbnail: String?
    @State var thumbnailURL: URL?
    var diptychState = DiptychState.half

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.systemSalmon, lineWidth: isToday ? 2 : 0)
                .frame(width: 44, height: 44)
                .overlay {
                    switch diptychState {
                    case .incomplete: // TODO: - 오늘 이후에는 그냥 빈 뷰가 나가야 하는디 ...
                        if isToday {
                            EmptyView()
                        } else {
                            Color.lightGray
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    case .half:
                        if isToday {
                            RoundedRectangle(cornerRadius: 18)
                                .trim(from: 0.25, to: 0.75)
                                .fill(Color.systemSalmon)
                        } else {
                            Color.lightGray
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    case .complete:
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.systemSalmon)
                    }
                }
            Text(day)
                .font(.pretendard(.bold, size: 16))
                .foregroundColor(.offBlack)
        }
        .onAppear {
            print("thumbnail: \(thumbnail)")
            Task {
                await downloadImage()
            }
        }
    }

    func downloadImage() async {
        if let thumbnail = thumbnail, !thumbnail.isEmpty {
            do {
                let url = try await Storage.storage().reference(forURL: thumbnail).downloadURL()
                   thumbnailURL = url
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct WeeklyCalenderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeeklyCalenderView(day: "월", date: "07", isToday: true)
            WeeklyCalenderView(day: "월", date: "08", isToday: false)
        }
        .previewLayout(.sizeThatFits)
    }
}
