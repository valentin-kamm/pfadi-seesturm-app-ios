//
//  SeesturmHTMLAddLinkView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.03.2025.
//

import SwiftUI
import InfomaniakRichHTMLEditor

struct SeesturmHTMLAddLinkView: View {
    
    @ObservedObject var textAttributes: TextAttributes
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var url = ""
    @State private var showError: Bool = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "character.cursor.ibeam")
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.SEESTURM_GREEN)
                    TextField("Text", text: $text)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Image(systemName: "link")
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.SEESTURM_GREEN)
                    TextField("URL", text: $url)
                        .textFieldStyle(.roundedBorder)
                }
            } header: {
                Text("Link einfügen")
            }
            Section {
                SeesturmButton(
                    style: .primary,
                    action: .sync(action: {
                        onSubmit()
                    }),
                    title: "Einfügen"
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .customSnackbar(
            show: $showError,
            type: .error,
            message: "Die angegebene URL ist ungültig.",
            dismissAutomatically: true,
            allowManualDismiss: true
        )
    }
    
    private func onSubmit() {
        if let validUrl = getValidUrl() {
            let linkTitle = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : text.trimmingCharacters(in: .whitespacesAndNewlines)
            textAttributes.addLink(url: validUrl, text: linkTitle)
            dismiss()
        }
        else {
            showError = true
        }
    }
    private func getValidUrl() -> URL? {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            return url
        }
        return nil
    }
}

#Preview {
    SeesturmHTMLAddLinkView(
        textAttributes: TextAttributes()
    )
}
