//
//  SeesturmHTMLEditor.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.03.2025.
//
import SwiftUI
import InfomaniakRichHTMLEditor
import Combine

struct SeesturmHTMLEditor: View {
    
    @StateObject private var textAttributes: TextAttributes
    private let html: Binding<String>
    private let scrollable: Bool
    private let disabled: Bool
    @State private var showAddLinkSheet: Bool
    
    init(
        textAttributes: TextAttributes = TextAttributes(),
        html: Binding<String>,
        scrollable: Bool,
        disabled: Bool,
        showAddLinkSheet: Bool = false
    ) {
        _textAttributes = StateObject(wrappedValue: textAttributes)
        self.html = html
        self.scrollable = scrollable
        self.disabled = disabled
        self.showAddLinkSheet = showAddLinkSheet
    }
    
    var body: some View {
        SeesturmHTMLEditorView(
            textAttributes: textAttributes,
            html: html,
            scrollable: scrollable,
            disabled: disabled
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
    @State private var toolbar: SeesturmHTMLEditorToolbar
    private let html: Binding<String>
    private let scrollable: Bool
    private let disabled: Bool
    private let onToolbarAction: (SeesturmHTMLToolbarAction) -> Void
    
    init(
        textAttributes: TextAttributes,
        html: Binding<String>,
        scrollable: Bool,
        disabled: Bool,
        onToolbarAction: @escaping (SeesturmHTMLToolbarAction) -> Void
    ) {
        self.textAttributes = textAttributes
        self.html = html
        self.scrollable = scrollable
        self.disabled = disabled
        self.onToolbarAction = onToolbarAction
        self.toolbar = SeesturmHTMLEditorToolbar(
            textAttributes: textAttributes,
            onToolbarAction: onToolbarAction
        )
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

private class SeesturmHTMLEditorToolbar: UIView {
    
    private let textAttributes: TextAttributes
    private let onToolbarAction: (SeesturmHTMLToolbarAction) -> Void
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private let toolbarHeight: CGFloat = 56
    
    private var textAttributesObservation: AnyCancellable?
    
    init(
        textAttributes: TextAttributes,
        onToolbarAction: @escaping (SeesturmHTMLToolbarAction) -> Void
    ) {
        self.textAttributes = textAttributes
        self.onToolbarAction = onToolbarAction
        super.init(frame: .zero)
        setupViews()
        setupAllButtons()
        startObservingChangesInTextAttributes()
        setNeedsLayout()
    }
    
    private func setupViews() {
        
        backgroundColor = .systemGray6
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: toolbarHeight).isActive = true
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    private func setupAllButtons() {
        for actionGroup in SeesturmHTMLToolbarAction.actionGroups {
            for action in actionGroup {
                let button = createButton(for: action)
                stackView.addArrangedSubview(button)
            }
            if actionGroup != SeesturmHTMLToolbarAction.actionGroups.last {
                let divider = createDivider()
                stackView.addArrangedSubview(divider)
            }
        }
    }
    
    private func createButton(for action: SeesturmHTMLToolbarAction) -> UIButton {
        
        let button = UIButton(configuration: .borderless())
        button.setImage(action.icon, for: .normal)
        button.tag = action.rawValue
        button.isSelected = action.isSelected(textAttributes)
        button.tintColor = action.buttonTint
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 40),
            button.widthAnchor.constraint(equalToConstant: 40)
        ])
        button.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        return button
    }
    
    private func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .systemGray4
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 30)
        ])
        return divider
    }
    
    @objc private func didTapOnButton(_ sender: UIButton) {
        guard let action = SeesturmHTMLToolbarAction(rawValue: sender.tag) else {
            return
        }
        onToolbarAction(action)
    }
    
    private func refreshButtons() {
        for case let button as UIButton in stackView.arrangedSubviews {
            if let action = SeesturmHTMLToolbarAction(rawValue: button.tag) {
                button.isSelected = action.isSelected(textAttributes)
            }
        }
    }
    
    private func startObservingChangesInTextAttributes() {
        textAttributesObservation = textAttributes
            .objectWillChange
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.refreshButtons()
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    SeesturmHTMLEditor(
        textAttributes: TextAttributes(),
        html: .constant(""),
        scrollable: false,
        disabled: false,
        showAddLinkSheet: false
    )
}
