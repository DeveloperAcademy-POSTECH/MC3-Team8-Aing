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
        VStack(spacing: 9) {
            Text(day)
                .font(.pretendard(.medium, size: 14))

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.systemSalmon, lineWidth: isToday ? 2 : 0)
                    .frame(width: 44, height: 50)
                    .overlay {
                        /// [1] 오늘 일 때
                        if isToday {
                            switch diptychState {
                            case .incomplete:
                                EmptyView()
                            case .half:
                                RoundedRectangle(cornerRadius: 18)
                                    .trim(from: 0.25, to: 0.75)
                                    .fill(Color.systemSalmon)
                            case .complete:
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.systemSalmon)
                            }
                        /// [2] 오늘이 아닐 때
                        } else {
                            switch diptychState {
                            case .complete:
                                ZStack {
//                                    AsyncImage(url: thumbnailURL) { image in
//                                        image
//                                            .resizable()
//                                            .clipShape(RoundedRectangle(cornerRadius: 18))
//                                    } placeholder: {
//                                        ProgressView()
//                                    }

                                    Color.offBlack.opacity(0.5)
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                }
                            default:
                                EmptyView()
                            }
                        }
                    case .half:
                        if isToday {
                            switch diptychState {
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
