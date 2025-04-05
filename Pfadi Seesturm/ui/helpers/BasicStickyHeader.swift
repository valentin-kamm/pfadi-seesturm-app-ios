//
//  BasicStickyHeader.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.11.2024.
//

import SwiftUI

struct BasicStickyHeader: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(.callout)
            .fontWeight(.semibold)
            .padding(.horizontal)
            .foregroundStyle(Color.secondary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    BasicStickyHeader(
        title: "Pfadijahr 2024"
    )
}
