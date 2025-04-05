//
//  AktuellCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI
import Kingfisher
import RichText

struct AktuellCardView: View {
    
    // parameters that are passed to this view
    var post: WordpressPost
    var width: CGFloat
    
    var body: some View {
        CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
            
            let cardAspectRatio = 1.0
            let cardWidth = width - 32
            let cardHeight = cardWidth / cardAspectRatio
            
            ZStack(alignment: .bottom) {
                if let imageUrl = URL(string: post.imageUrl) {
                    KFImage(imageUrl)
                        .placeholder { progress in
                            Rectangle()
                                .fill(Color.skeletonPlaceholderColor)
                                .aspectRatio(cardAspectRatio, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .customLoadingBlinking()
                        }
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(0.9, contentMode: .fill)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                }
                else {
                    Color.skeletonPlaceholderColor
                        .frame(width: cardWidth, height: cardHeight)
                        .overlay {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                                .padding(.bottom, 165)
                        }
                }
                VStack(alignment: .leading) {
                    Text(post.titleDecoded)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                    Label(post.published.uppercased(), systemImage: "calendar")
                        .lineLimit(1)
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                        .labelStyle(.titleAndIcon)
                        .padding(.bottom, 8)
                    Text(post.contentPlain)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding([.horizontal, .bottom])
    }
    
}

#Preview("Hochformat Bild") {
    AktuellCardView(
        post: WordpressPost(
            id: 22566,
            publishedYear: "2023",
            published: "Mittwoch, 31. Juli 2024",
            modified: "2023-06-28T16:35:44+00:00",
            imageUrl: "https://seesturm.ch/wp-content/uploads/2017/11/DSC_4041.sized_.jpg",
            title: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
            titleDecoded: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
            content: "\n<p>Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende <strong>vom 23. und 24. September</strong> unter dem Motto <strong>«Die Piraten vom Bodamicus»</strong>.</p>\n\n\n\n<p>Das KaTre 2023 findet ganz in der Nähe statt, nämlich in <strong>Romanshorn direkt am schönen Bodensee</strong>. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter <a rel=\"noreferrer noopener\" href=\"http: //www.katre.ch\" target=\"_blank\">www.katre.ch</a> oder in unserem Mail vom 2. Juni.</p>\n\n\n\n<p>Leider haben wir bisher erst sehr <strong>wenige Anmeldungen</strong> erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das <a href=\"https: //seesturm.ch/wp-content/uploads/2023/06/KaTre-23__Anmeldetalon.pdf\" target=\"_blank\" rel=\"noreferrer noopener\">Anmeldeformular</a> aus und sendet es <strong>bis am 01. Juli</strong> an <a href=\"mailto: al@seesturm.ch\" target=\"_blank\" rel=\"noreferrer noopener\">al@seesturm.ch</a>.</p>\n\n\n\n<p>Danke!</p>\n",
            contentPlain: "Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende vom 23. und 24. September unter dem Motto «Die Piraten vom Bodamicus».\n\n\n\nDas KaTre 2023 findet ganz in der Nähe statt, nämlich in Romanshorn direkt am schönen Bodensee. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter www.katre.ch oder in unserem Mail vom 2. Juni.\n\n\n\nLeider haben wir bisher erst sehr wenige Anmeldungen erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das Anmeldeformular aus und sendet es bis am 01. Juli an al@seesturm.ch.\n\n\n\nDanke!",
            aspectRatio: 425/680,
            author: "seesturm"
        ),
        width: 400
    )
}

#Preview("Querformat Bild") {
    AktuellCardView(
        post: WordpressPost(
            id: 22566,
            publishedYear: "2023",
            published: "Mittwoch, 31. Juli 2024",
            modified: "2023-06-28T16:35:44+00:00",
            imageUrl: "https://seesturm.ch/wp-content/gallery/sola-2021-pfadi-piostufe/DSC1080.jpg",
            title: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
            titleDecoded: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
            content: "\n<p>Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende <strong>vom 23. und 24. September</strong> unter dem Motto <strong>«Die Piraten vom Bodamicus»</strong>.</p>\n\n\n\n<p>Das KaTre 2023 findet ganz in der Nähe statt, nämlich in <strong>Romanshorn direkt am schönen Bodensee</strong>. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter <a rel=\"noreferrer noopener\" href=\"http: //www.katre.ch\" target=\"_blank\">www.katre.ch</a> oder in unserem Mail vom 2. Juni.</p>\n\n\n\n<p>Leider haben wir bisher erst sehr <strong>wenige Anmeldungen</strong> erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das <a href=\"https: //seesturm.ch/wp-content/uploads/2023/06/KaTre-23__Anmeldetalon.pdf\" target=\"_blank\" rel=\"noreferrer noopener\">Anmeldeformular</a> aus und sendet es <strong>bis am 01. Juli</strong> an <a href=\"mailto: al@seesturm.ch\" target=\"_blank\" rel=\"noreferrer noopener\">al@seesturm.ch</a>.</p>\n\n\n\n<p>Danke!</p>\n",
            contentPlain: "Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende vom 23. und 24. September unter dem Motto «Die Piraten vom Bodamicus».\n\n\n\nDas KaTre 2023 findet ganz in der Nähe statt, nämlich in Romanshorn direkt am schönen Bodensee. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter www.katre.ch oder in unserem Mail vom 2. Juni.\n\n\n\nLeider haben wir bisher erst sehr wenige Anmeldungen erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das Anmeldeformular aus und sendet es bis am 01. Juli an al@seesturm.ch.\n\n\n\nDanke!",
            aspectRatio: 5568/3712,
            author: "seesturm"
        ),
        width: 400
    )
}
