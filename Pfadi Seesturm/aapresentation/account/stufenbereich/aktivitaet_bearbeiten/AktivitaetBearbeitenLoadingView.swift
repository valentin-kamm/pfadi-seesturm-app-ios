//
//  AktivitätBearbeitenLoadingView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.12.2024.
//

import SwiftUI

struct AktivitaetBearbeitenLoadingView: View {
    var body: some View {
        Section {
            Text("Stufe")
                .redacted(reason: .placeholder)
                .customLoadingBlinking()
        }
        Section {
            Text("Start")
                .redacted(reason: .placeholder)
                .customLoadingBlinking()
            Text("Ende")
                .redacted(reason: .placeholder)
                .customLoadingBlinking()
            HStack(spacing: 16) {
                Text("Treffpunkt")
                    .redacted(reason: .placeholder)
                    .customLoadingBlinking()
                ZStack(alignment: .trailing) {
                    TextField("", text: .constant(""))
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                    Text("Pfadiheim")
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                        .padding(.trailing, 8)
                }
                
            }
        }
        header: {
            Text("Zeit und Treffpunkt")
                .redacted(reason: .placeholder)
        } footer: {
            Text("Zeiten in MEZ/MESZ")
                .redacted(reason: .placeholder)
        }
        Section {
            HStack(spacing: 16) {
                Text("Titel")
                    .redacted(reason: .placeholder)
                    .customLoadingBlinking()
                ZStack(alignment: .trailing) {
                    TextField("", text: .constant(""))
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                    Text("Biberstufen-Aktivität")
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                        .padding(.trailing, 8)
                }
            }
            TextEditor(text: .constant(""))
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .disabled(true)
        } header: {
            Text("Beschreibung")
                .redacted(reason: .placeholder)
        }
        Section {
            Text("Push-Nachricht senden")
                .redacted(reason: .placeholder)
        } header: {
            Text("Veröffentlichen")
                .redacted(reason: .placeholder)
        }
    }
}

#Preview {
    AktivitaetBearbeitenLoadingView()
}
