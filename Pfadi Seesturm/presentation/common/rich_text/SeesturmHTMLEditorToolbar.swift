//
//  SeesturmHTMLEditorToolbar.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.01.2026.
//
import SwiftUI
import InfomaniakRichHTMLEditor
import Combine

@available(iOS 26.0, *)
private struct SeesturmHTMLEditorToolbarView: View {
    
    @Namespace private var toolbarNamespace
    
    @ObservedObject private var textAttributes: TextAttributes
    private let buttonTint: Color
    let onToolbarAction: (SeesturmHTMLToolbarAction) -> Void
    
    init(
        textAttributes: TextAttributes,
        buttonTint: Color,
        onToolbarAction: @escaping (SeesturmHTMLToolbarAction) -> Void
    ) {
        self.textAttributes = textAttributes
        self.buttonTint = buttonTint
        self.onToolbarAction = onToolbarAction
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: 16) {
                ForEach(SeesturmHTMLToolbarAction.actionGroups, id: \.self) { group in
                    GlassEffectContainer {
                        HStack(alignment: .center, spacing: 4) {
                            ForEach(Array(group).enumerated(), id: \.element.id) { index, action in
                                Button {
                                    onToolbarAction(action)
                                } label: {
                                    Group {
                                        if action.isSelected(textAttributes) {
                                            Label(action.title, systemImage: action.iconName)
                                                .bold()
                                                .foregroundStyle(buttonTint)
                                        }
                                        else {
                                            Label(action.title, systemImage: action.iconName)
                                                .foregroundStyle(Color.secondary)
                                        }
                                    }
                                    .labelStyle(.iconOnly)
                                    .font(.title2.weight(.regular))
                                    .padding(.vertical, 4)
                                    .padding(.leading, index == 0 ? 4 : 0)
                                    .padding(.trailing, index == group.count - 1 ? 4 : 0)
                                }
                                .buttonStyle(.glass)
                                .glassEffectUnion(id: group.description, namespace: toolbarNamespace)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .scrollIndicators(.hidden)
        .background(Color.clear)
    }
}

@available(iOS 26.0, *)
final class SeesturmHTMLEditorToolbar: UIView {
    
    private let hostingController: UIHostingController<SeesturmHTMLEditorToolbarView>
    private let textAttributes: TextAttributes
    private let buttonTint: Color
    
    private var textAttributesObservation: AnyCancellable?
    
    init(
        textAttributes: TextAttributes,
        buttonTint: Color,
        onToolbarAction: @escaping (SeesturmHTMLToolbarAction) -> Void
    ) {
        self.textAttributes = textAttributes
        self.buttonTint = buttonTint
        let swiftUIView = SeesturmHTMLEditorToolbarView(
            textAttributes: textAttributes,
            buttonTint: buttonTint,
            onToolbarAction: onToolbarAction
        )
        self.hostingController = UIHostingController(rootView: swiftUIView)
        
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.insetsLayoutMarginsFromSafeArea = false
        
        super.init(frame: .zero)
        
        self.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        startObservingChangesInTextAttributes()
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return .zero
    }
    
    override var intrinsicContentSize: CGSize {
        
        let targetSize = CGSize(
            width: UIView.layoutFittingCompressedSize.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        
        let size = hostingController.view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        return size
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        hostingController.view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
    private func startObservingChangesInTextAttributes() {
        textAttributesObservation = textAttributes
            .objectWillChange
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.refreshToolbar()
            }
    }
    
    private func refreshToolbar() {
        self.hostingController.rootView = SeesturmHTMLEditorToolbarView(
            textAttributes: textAttributes,
            buttonTint: buttonTint,
            onToolbarAction: hostingController.rootView.onToolbarAction
        )
        invalidateIntrinsicContentSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 26.0, *)
#Preview {
    SeesturmHTMLEditorToolbarView(
        textAttributes: TextAttributes(),
        buttonTint: .SEESTURM_RED,
        onToolbarAction: { _ in }
    )
}
