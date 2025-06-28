//
//  SeesturmHTMLAddLinkView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.03.2025.
//

import SwiftUI
import InfomaniakRichHTMLEditor

struct SeesturmHTMLAddLinkView: View {
    
    @ObservedObject private var textAttributes: TextAttributes
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var url = ""
    @State private var showError: Bool = false
    
    init(textAttributes: TextAttributes) {
        self.textAttributes = textAttributes
    }
    
    private var validUrl: URL? {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            return url
        }
        return nil
    }
    
    private enum AddLinkFields: String, FocusControlItem {
        case text
        case url
        var id: AddLinkFields { self }
    }
    
    var body: some View {
        FocusControlView(allFields: AddLinkFields.allCases) { focused in
            Form {
                Section {
                    HStack {
                        Image(systemName: "character.cursor.ibeam")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Text", text: $text)
                            .textFieldStyle(.roundedBorder)
                            .focused(focused, equals: .text)
                            .submitLabel(.next)
                            .onSubmit {
                                focused.wrappedValue = .url
                            }
                    }
                    HStack {
                        Image(systemName: "link")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("URL", text: $url)
                            .textFieldStyle(.roundedBorder)
                            .focused(focused, equals: .url)
                            .submitLabel(.done)
                            .onSubmit {
                                focused.wrappedValue = nil
                            }
                    }
                } header: {
                    Text("Link einfügen")
                }
                Section {
                    SeesturmButton(
                        type: .primary,
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
        if let vu = validUrl {
            let linkTitle = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : text.trimmingCharacters(in: .whitespacesAndNewlines)
            textAttributes.addLink(url: vu, text: linkTitle)
            dismiss()
        }
        else {
            showError = true
        }
    }
}

#Preview {
    SeesturmHTMLAddLinkView(
        textAttributes: TextAttributes()
    )
}
