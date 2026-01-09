//
//  ZoomableContainer.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.07.2025.
//

import SwiftUI

struct ZoomableContainer<Content: View>: View {
    
    @State private var tapLocation: CGPoint? = nil
    
    private let viewSize: CGSize
    private let contentAspectRatio: CGFloat
    private let maxScale: CGFloat
    private let doubleTapScale: CGFloat
    private let content: Content
    
    init(
        viewSize: CGSize,
        contentAspectRatio: CGFloat,
        maxScale: CGFloat = 5,
        doubleTapScale: CGFloat = 3,
        @ViewBuilder content: () -> Content
    ) {
        self.viewSize = viewSize
        self.contentAspectRatio = contentAspectRatio
        self.maxScale = maxScale
        self.doubleTapScale = doubleTapScale
        self.content = content()
    }
    
    func doubleTapAction(location: CGPoint) {
        tapLocation = location
    }
    
    var body: some View {
        ZoomableView(
            tapLocation: $tapLocation,
            viewSize: viewSize,
            contentAspectRatio: contentAspectRatio,
            maxScale: maxScale,
            doubleTapScale: doubleTapScale
        ) {
            content
        }
        .onTapGesture(count: 2, perform: doubleTapAction)
    }
}

private struct ZoomableView<Content: View>: UIViewControllerRepresentable {
    
    @Binding private var tapLocation: CGPoint?
    private let viewSize: CGSize
    private let contentAspectRatio: CGFloat
    private let maxScale: CGFloat
    private let doubleTapScale: CGFloat
    private let content: Content
    
    init(
        tapLocation: Binding<CGPoint?>,
        viewSize: CGSize,
        contentAspectRatio: CGFloat,
        maxScale: CGFloat,
        doubleTapScale: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self._tapLocation = tapLocation
        self.viewSize = viewSize
        self.contentAspectRatio = contentAspectRatio
        self.maxScale = maxScale
        self.doubleTapScale = doubleTapScale
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> ZoomableViewController<UIView> {
        
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.safeAreaRegions = []
        
        return ZoomableViewController(
            contentSize: viewSize.imageFitSize(for: contentAspectRatio),
            maxScale: maxScale,
            doubleTapScale: doubleTapScale,
            content: hostingController.view
        )
    }
    
    func updateUIViewController(_ uiViewController: ZoomableViewController<UIView>, context: Context) {
        
        uiViewController.updateContentSize(viewSize.imageFitSize(for: contentAspectRatio))
                
        if let location = tapLocation {
            uiViewController.handleDoubleTap(location)
            DispatchQueue.main.async {
                tapLocation = nil
            }
        }
    }
}

private class ZoomableViewController<Content: UIView>: UIViewController, UIScrollViewDelegate {
    
    private var contentSize: CGSize
    private let maxScale: CGFloat
    private let doubleTapScale: CGFloat
    private let content: Content
    
    init(
        contentSize: CGSize,
        maxScale: CGFloat,
        doubleTapScale: CGFloat,
        content: Content
    ) {
        self.contentSize = contentSize
        self.maxScale = maxScale
        self.doubleTapScale = doubleTapScale
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.clipsToBounds = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.maximumZoomScale = maxScale
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        scrollView.addSubview(content)
        content.frame = CGRect(origin: .zero, size: contentSize)
        scrollView.contentSize = contentSize

        centerContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerContent()
    }

    private func centerContent() {
        
        let scrollSize = scrollView.bounds.size
        
        let horizontalInset = max((scrollSize.width - contentSize.width * scrollView.zoomScale) / 2, 0)
        let verticalInset = max((scrollSize.height - contentSize.height * scrollView.zoomScale) / 2, 0)

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    func updateContentSize(_ newContentSize: CGSize) {
        
        guard newContentSize != contentSize else { return }
        contentSize = newContentSize

        content.frame = CGRect(origin: .zero, size: newContentSize)
        scrollView.contentSize = newContentSize
        centerContent()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        resetZoom()
        coordinator.animate { _ in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    func handleDoubleTap(_ location: CGPoint) {
        
        let zoomRect: CGRect = zoomRectForScale(
            scale: scrollView.zoomScale > 1 ? 1 : doubleTapScale,
            center: location
        )
        scrollView.zoom(to: zoomRect, animated: true)
    }

    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        
        let size = CGSize(
            width: scrollView.bounds.size.width / scale,
            height: scrollView.bounds.size.height / scale
        )
        let origin = CGPoint(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2
        )
        return CGRect(origin: origin, size: size)
    }

    func resetZoom() {
        scrollView.setZoomScale(1, animated: false)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return content
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
