//
//  InAppLinkOpener.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.10.2024.
//
import SwiftUI
import SafariServices

// opens any link that is clicked in SwiftUI in a in-app browser rather than jumping out of the app into safari

// needed to use SFSafariViewController in SwiftUI
struct SFSafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariView>) {
        // No need to do anything here
    }
}
private struct SafariViewControllerViewModifier: ViewModifier {
    @State private var urlToOpen: URL?
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                // do not handle mail url's
                switch url.scheme {
                case "https", "http":
                    urlToOpen = url
                    return .handled
                default:
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    urlToOpen = nil
                    return .discarded
                }
            })
            .sheet(isPresented: $urlToOpen.mappedToBool(), onDismiss: {
                urlToOpen = nil
            }, content: {
                SFSafariView(url: urlToOpen!)
            })
        
    }
}
// Monitor the `openURL` environment variable and handle them in-app instead of via the external web browser.
extension View {
    func handleOpenURLInApp() -> some View {
        modifier(SafariViewControllerViewModifier())
    }
}

// map any optional binding into a boolean binding
extension Binding {
    func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        Binding<Bool>(binding: self)
    }
}
extension Binding where Value == Bool {
    init(binding: Binding<(some Any)?>) {
        self.init(
            get: {
                binding.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }
                binding.wrappedValue = nil
            }
        )
    }
}
