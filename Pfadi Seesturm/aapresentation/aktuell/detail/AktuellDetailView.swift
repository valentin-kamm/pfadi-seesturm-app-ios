//
//  AktuellDetailView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.10.2024.
//

import SwiftUI
import Kingfisher
import RichText

struct AktuellDetailView<Link: View>: View {
    
    @StateObject var viewModel: AktuellDetailViewModel
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var appState: AppStateViewModel
    
    let pushNavigationLink: () -> Link
    
    var body: some View {
        
        Group {
            switch viewModel.state {
            case .loading(_):
                VStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.skeletonPlaceholderColor)
                        .aspectRatio(4/3, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .customLoadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(2)
                        .padding(.horizontal)
                        .font(.title)
                        .fontWeight(.bold)
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT)
                        .padding(.bottom, -100)
                        .padding(.horizontal)
                        .font(.body)
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                }
            case .error(let message):
                ScrollView {
                    CardErrorView(
                        errorTitle: "Ein Fehler ist aufgetreten",
                        errorDescription: message,
                        asyncRetryAction: {
                            await viewModel.fetchPost()
                        }
                    )
                    .padding(.vertical)
                }
            case .success(let post):
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if let imageUrl = URL(string: post.imageUrl) {
                                KFImage(imageUrl)
                                    .placeholder { progress in
                                        ZStack(alignment: .top) {
                                            Rectangle()
                                                .fill(Color.skeletonPlaceholderColor)
                                                .aspectRatio(post.aspectRatio, contentMode: .fit)
                                                .frame(maxWidth: .infinity)
                                                .customLoadingBlinking()
                                            ProgressView(value: progress.fractionCompleted, total: Double(1.0))
                                                .progressViewStyle(.linear)
                                                .tint(Color.SEESTURM_GREEN)
                                        }
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(post.aspectRatio, contentMode: .fit)
                                    .frame(width: geometry.size.width, height: geometry.size.width / post.aspectRatio)
                                    .clipped()
                            }
                            Text(post.titleDecoded)
                                .padding(.horizontal)
                                .multilineTextAlignment(.leading)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, URL(string: post.imageUrl) == nil ? 16 : 0)
                            Label(post.published, systemImage: "calendar")
                                .padding(.horizontal)
                                .lineLimit(1)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .labelStyle(.titleAndIcon)
                            RichText(html: post.content)
                                .transition(.none)
                                .linkOpenType(.SFSafariView())
                                .placeholder(content: {
                                    Text(Constants.PLACEHOLDER_TEXT)
                                        .padding(.bottom, -100)
                                        .padding(.horizontal)
                                        .font(.body)
                                        .redacted(reason: .placeholder)
                                        .customLoadingBlinking()
                                })
                                .padding([.horizontal, .bottom])
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                pushNavigationLink()
                /*
                NavigationLink(value: navigationDestination) {
                    Image(systemName: "bell.badge")
                }
                 */
            }
        }
        .task {
            if viewModel.state.taskShouldRun {
                await viewModel.fetchPost()
            }
        }
    }
}

#Preview("Artikel aus Internet laden") {
    AktuellDetailView(
        viewModel: AktuellDetailViewModel(
            service: AktuellService(
                repository: AktuellRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            input: .id(id: 22566)
        ),
        pushNavigationLink: {
            NavigationLink(value: AktuellNavigationDestination.pushNotifications) {
                Image(systemName: "bell.badge")
            }
        }
    )
}

#Preview("Artikel übergeben") {
    AktuellDetailView(
        viewModel: AktuellDetailViewModel(
            service: AktuellService(
                repository: AktuellRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            input: .object(
                object: WordpressPost(
                    id: 22566,
                    publishedYear: "2023",
                    published: "2023-06-28T16:29:56+00:00",
                    modified: "2023-06-28T16:35:44+00:00",
                    imageUrl: "https://seesturm.ch/wp-content/gallery/sola-2021-pfadi-piostufe/DSC1080.jpg",
                    title: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
                    titleDecoded: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
                    content: "\n<p>Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende <strong>vom 23. und 24. September</strong> unter dem Motto <strong>«Die Piraten vom Bodamicus»</strong>.</p>\n\n\n\n<p>Das KaTre 2023 findet ganz in der Nähe statt, nämlich in <strong>Romanshorn direkt am schönen Bodensee</strong>. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter <a rel=\"noreferrer noopener\" href=\"http: //www.katre.ch\" target=\"_blank\">www.katre.ch</a> oder in unserem Mail vom 2. Juni.</p>\n\n\n\n<p>Leider haben wir bisher erst sehr <strong>wenige Anmeldungen</strong> erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das <a href=\"https: //seesturm.ch/wp-content/uploads/2023/06/KaTre-23__Anmeldetalon.pdf\" target=\"_blank\" rel=\"noreferrer noopener\">Anmeldeformular</a> aus und sendet es <strong>bis am 01. Juli</strong> an <a href=\"mailto: al@seesturm.ch\" target=\"_blank\" rel=\"noreferrer noopener\">al@seesturm.ch</a>.</p>\n\n\n\n<p>Danke!</p>\n",
                    contentPlain: "Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende vom 23. und 24. September unter dem Motto «Die Piraten vom Bodamicus».\n\n\n\nDas KaTre 2023 findet ganz in der Nähe statt, nämlich in Romanshorn direkt am schönen Bodensee. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter www.katre.ch oder in unserem Mail vom 2. Juni.\n\n\n\nLeider haben wir bisher erst sehr wenige Anmeldungen erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das Anmeldeformular aus und sendet es bis am 01. Juli an al@seesturm.ch.\n\n\n\nDanke!",
                    aspectRatio: 5568/3712,
                    author: "seesturm"
                )
            )
        ),
        pushNavigationLink: {
            NavigationLink(value: AktuellNavigationDestination.pushNotifications) {
                Image(systemName: "bell.badge")
            }
        }
    )
}
