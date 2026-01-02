//
//  LegacySeesturmHTMLEditorToolbar.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.01.2026.
//
import SwiftUI
import UIKit
import InfomaniakRichHTMLEditor
import Combine

final class LegacySeesturmHTMLEditorToolbar: UIView {
    
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

private struct LegacyToolbarPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> LegacySeesturmHTMLEditorToolbar {
        let view = LegacySeesturmHTMLEditorToolbar(
            textAttributes: TextAttributes(),
            onToolbarAction: { _ in }
        )
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }
    func updateUIView(_ uiView: LegacySeesturmHTMLEditorToolbar, context: Context) {}
}

#Preview {
    LegacyToolbarPreview()
        .frame(height: 56)
}
