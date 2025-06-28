//
//  MehrHorizontalPhotoScrollView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 12.06.2025.
//
import SwiftUI

struct MehrHorizontalPhotoScrollView: View {
    
    private let photosState: UiState<[WordpressPhotoGallery]>
    
    init(
        photosState: UiState<[WordpressPhotoGallery]>
    ) {
        self.photosState = photosState
    }
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            switch photosState {
            case .loading(_):
                LazyHStack(spacing: 16) {
                    ForEach(1..<10) { _ in
                        PhotoGalleryLoadingCell(
                            size: 120,
                            withText: true
                        )
                    }
                }
            case .error(_):
                EmptyView()
                    .frame(height: 0)
            case .success(let pfadijahre):
                LazyHStack(spacing: 16) {
                    ForEach(pfadijahre.reversed()) { pfadijahr in
                        NavigationLink(value: MehrNavigationDestination.albums(pfadijahr: pfadijahr)) {
                            PhotoGalleryCell(
                                size: 120,
                                thumbnailUrl: pfadijahr.thumbnailUrl,
                                title: pfadijahr.title
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .scrollDisabled(photosState.scrollingDisabled)
    }
}

#Preview("Loading") {
    MehrHorizontalPhotoScrollView(
        photosState: .loading(subState: .loading)
    )
}
#Preview("Error") {
    MehrHorizontalPhotoScrollView(
        photosState: .error(message: "Schwerer Fehler")
    )
}
#Preview("Success") {
    MehrHorizontalPhotoScrollView(
        photosState: .success(data: [
            WordpressPhotoGallery(
                title: "Test 1",
                id: UUID().uuidString,
                thumbnailUrl: "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau-pdf-212x300.jpg"
            ),
            WordpressPhotoGallery(
                title: "Test 2",
                id: UUID().uuidString,
                thumbnailUrl: "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau-pdf-212x300.jpg"
            ),
            WordpressPhotoGallery(
                title: "Test 3",
                id: UUID().uuidString,
                thumbnailUrl: "https://seesturm.ch/wp-content/uploads/2017/10/Wicky2021-scaled.jpg"
            )
        ])
    )
}
