//
//  UpdateRequiredView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.06.2025.
//

import SwiftUI

struct UpdateRequiredView: View {
    
    var body: some View {
        
        ContentUnavailableView(
            label: {
                Label("Update benötigt", systemImage: "arrow.down.circle")
            },
            description: {
                Text("Bitte lade die aktuellste Version der Pfadi Seesturm App herunter, um die App weiter nutzen zu können.")
            },
            actions: {
                SeesturmButton(
                    type: .primary,
                    action: .sync(action: {
                        let url = URL(string: "https://apps.apple.com/app/id1633468734")!
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    title: "Zum App Store"
                )
            }
        )
        .background(Material.thick)
    }
}

#Preview {
    UpdateRequiredView()
}
