//
//  InAppLinkOpener.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.10.2024.
//
import SwiftUI
import SafariServices

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
    
    private var isSheetShown: Binding<Bool> {
        Binding(
            get: {
                self.urlToOpen != nil
            },
            set: { isShown in
                if !isShown {
                    urlToOpen = nil
                }
            }
        )
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                // do not handle mail url's
                switch url.scheme {
                case "https", "http":
                    urlToOpen = url
                    return .handled
                default:
                    return .systemAction(url)
                }
            })
            .sheet(isPresented: isSheetShown, content: {
                if let url = urlToOpen {
                    SFSafariView(url: url)
                }
            })
    }
}
// Monitor the `openURL` environment variable and handle them in-app instead of via the external web browser.
extension View {
    func handleOpenURLInApp() -> some View {
        modifier(SafariViewControllerViewModifier())
    }
}
