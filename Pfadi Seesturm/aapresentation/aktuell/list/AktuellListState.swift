//
//  Untitled.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//

struct AktuellListState {
    var result: InfiniteScrollUiState<[WordpressPost]> = .loading(subState: .idle)
    var totalPostsAvailable: Int = 0
}
