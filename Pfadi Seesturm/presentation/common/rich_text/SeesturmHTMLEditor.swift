//
//  SeesturmHTMLEditor.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.03.2025.
//
import SwiftUI
import InfomaniakRichHTMLEditor

struct SeesturmHTMLEditor: View {
    
    @StateObject private var textAttributes: TextAttributes = TextAttributes()
    private let html: Binding<String>
    private let scrollable: Bool
    private let disabled: Bool
    private let buttonTint: Color
    @State private var showAddLinkSheet: Bool
    
    init(
        html: Binding<String>,
        scrollable: Bool,
        disabled: Bool,
        buttonTint: Color = .SEESTURM_GREEN,
        showAddLinkSheet: Bool = false
    ) {
        self.html = html
        self.scrollable = scrollable
        self.disabled = disabled
        self.buttonTint = buttonTint
        self.showAddLinkSheet = showAddLinkSheet
    }
    
    var body: some View {
        SeesturmHTMLEditorView(
            textAttributes: textAttributes,
            html: html,
            scrollable: scrollable,
            disabled: disabled,
            buttonTint: buttonTint
        ) { action in
                switch action {
                case .dismissKeyboard:
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                case .undo:
                    textAttributes.undo()
                case .redo:
                    textAttributes.redo()
                case .bold:
                    textAttributes.bold()
                case .italic:
                    textAttributes.italic()
                case .underline:
                    textAttributes.underline()
                case .strikethrough:
                    textAttributes.strikethrough()
                case .link:
                    if textAttributes.hasLink {
                        textAttributes.unlink()
                    }
                    else {
                        showAddLinkSheet = true
                    }
                case .orderedList:
                    textAttributes.orderedList()
                case .unorderedList:
                    textAttributes.unorderedList()
                case .removeFormat:
                    textAttributes.removeFormat()
                }
            }
            .sheet(isPresented: $showAddLinkSheet) {
                SeesturmHTMLAddLinkView(
                    textAttributes: textAttributes
                )
            }
    }
}

private struct SeesturmHTMLEditorView: View {
    
    @ObservedObject private var textAttributes: TextAttributes
    @State private var toolbar: UIView
    private let html: Binding<String>
    private let scrollable: Bool
    private let disabled: Bool
    private let buttonTint: Color
    private let onToolbarAction: (SeesturmHTMLToolbarAction) -> Void
    
    init(
        textAttributes: TextAttributes,
        html: Binding<String>,
        scrollable: Bool,
        disabled: Bool,
        buttonTint: Color,
        onToolbarAction: @escaping (SeesturmHTMLToolbarAction) -> Void
    ) {
        self.textAttributes = textAttributes
        self.html = html
        self.scrollable = scrollable
        self.disabled = disabled
        self.buttonTint = buttonTint
        self.onToolbarAction = onToolbarAction
        if #available(iOS 26.0, *) {
            let toolbar = SeesturmHTMLEditorToolbar(
                textAttributes: textAttributes,
                buttonTint: buttonTint,
                onToolbarAction: onToolbarAction
            )
            toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.toolbar = toolbar
        }
        else {
            self.toolbar = LegacySeesturmHTMLEditorToolbar(
                textAttributes: textAttributes,
                buttonTint: UIColor(buttonTint),
                onToolbarAction: onToolbarAction
            )
        }
    }
    
    var body: some View {
        RichHTMLEditor(
            html: html,
            textAttributes: textAttributes
        )
        .editorInputAccessoryView(toolbar)
        .editorScrollable(scrollable)
        .disabled(disabled)
    }
}

#Preview {
    SeesturmHTMLEditor(
        html: .constant(""),
        scrollable: false,
        disabled: false,
        showAddLinkSheet: false
    )
}

