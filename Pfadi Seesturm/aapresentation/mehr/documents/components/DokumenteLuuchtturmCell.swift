//
//  DokumenteLuuchtturmCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.10.2024.
//

import SwiftUI
import Kingfisher

struct DokumenteLuuchtturmCell: View {
    
    var document: WordpressDocument
    
    var body: some View {
        let width: CGFloat = 75
        HStack(alignment: .top, spacing: 16) {
            if let imageUrl = URL(string: document.thumbnailUrl) {
                KFImage(imageUrl)
                    .placeholder { progress in
                        Color.skeletonPlaceholderColor
                            .frame(width: width, height: width / (Double(document.thumbnailWidth) / Double(document.thumbnailHeight)))
                            .customLoadingBlinking()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: width / (Double(document.thumbnailWidth) / Double(document.thumbnailHeight)))
                    .clipped()
            }
            else {
                Rectangle()
                    .fill(Color.skeletonPlaceholderColor)
                    .frame(width: width, height: width / (Double(document.thumbnailWidth) / Double(document.thumbnailHeight)))
                    .overlay {
                        Image(systemName: "doc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                    }
            }
            VStack(alignment: .leading, spacing: 16) {
                Text(document.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fontWeight(.bold)
                    .font(.title2)
                    .allowsTightening(true)
                    .lineLimit(2)
                Label(document.published.uppercased(), systemImage: "calendar")
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .allowsTightening(true)
            }
        }
        .padding()
    }
}

#Preview {
    DokumenteLuuchtturmCell(
        document: WordpressDocument(
            id: "123",
            thumbnailUrl: "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau-pdf-212x300.jpg",
            thumbnailWidth: 212,
            thumbnailHeight: 300,
            title: "Infobroschüre Pfadi Thurgau",
            url: "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau.pdf",
            published: "test 2022-04-22T13:26:20+00:00"
        )
    )
}
