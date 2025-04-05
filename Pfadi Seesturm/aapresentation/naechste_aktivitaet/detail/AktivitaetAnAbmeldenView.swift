//
//  AktivitaetAnAbmeldenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.12.2024.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct AktivitaetAnAbmeldenView: View {
    
    @Query private var personenQuery: [GespeichertePersonDao]
    private var personen: [GespeichertePerson] {
        personenQuery.map { $0.toGespeichertePerson() }
    }
    
    @StateObject var viewModel: AktivitaetDetailViewModel
    var aktivitaet: GoogleCalendarEvent
    var stufe: SeesturmStufe
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Vorname", text: viewModel.vornameBinding)
                    }
                    HStack {
                        Image(systemName: "person.text.rectangle.fill")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Nachname", text: viewModel.nachnameBinding)
                    }
                    HStack {
                        Image(systemName: "face.smiling")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Pfadiname (optional)", text: viewModel.pfadinameBinding)
                    }
                }
                Section {
                    HStack {
                        Image(systemName: "text.bubble")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextEditor(text: viewModel.bemerkungBinding)
                            .frame(height: 75)
                    }
                } header: {
                    Text("Bemerkung (optional)")
                }
                Section {
                    Picker("An-/Abmeldung", selection: viewModel.sheetModeBinding) {
                        ForEach(stufe.allowedAktivitaetInteractions, id: \.self) { interaction in
                            Label(interaction.nomen, systemImage: interaction.icon)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(viewModel.pickerTint)
                }
                Section {
                    SeesturmButton(
                        style: .primary,
                        action: .async(action: {
                            await viewModel.sendAnAbmeldung()
                        }),
                        title: "\(viewModel.state.selectedSheetMode.nomen) senden",
                        colors: .custom(contentColor: .white, buttonColor: viewModel.state.selectedSheetMode.color),
                        isLoading: viewModel.state.anAbmeldenState.isLoading
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .background(Color.customBackground)
            .navigationTitle("\(stufe.aktivitaetDescription) vom \(aktivitaet.startDayString) \(aktivitaet.startMonthString)")
            .navigationBarTitleDisplayMode(.inline)
            .actionSnackbar(
                action: viewModel.anAbmeldenStateBinding,
                events: [
                    .error(
                        dismissAutomatically: true,
                        allowManualDismiss: true
                    )
                ],
                defaultErrorMessage: "Beim Speichern der An-/Abmeldung ist ein unbekannter Fehler aufgetreten."
            )
            .navigationDestination(for: AktivitaetAnAbmeldenNavigationDestination.self) { destination in
                switch destination {
                case .gespeichertePersonen:
                    GespeichertePersonenView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if !personen.isEmpty {
                            Section("Gespeicherte Personen") {
                                ForEach(personen, id: \.id) { person in
                                    Button {
                                        viewModel.insertGespeichertePerson(person: person)
                                    } label: {
                                        Text(person.displayName)
                                    }
                                }
                            }
                        }
                        Section {
                            NavigationLink(value: AktivitaetAnAbmeldenNavigationDestination.gespeichertePersonen) {
                                Label("Person hinzufügen", systemImage: "person.badge.plus")
                            }
                        }
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .foregroundStyle(Color.SEESTURM_GREEN)
                    }
                }
            }
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

enum AktivitaetAnAbmeldenNavigationDestination: Hashable {
    case gespeichertePersonen
}

#Preview {
    AktivitaetAnAbmeldenView(
        viewModel: AktivitaetDetailViewModel(
            service: NaechsteAktivitaetService(
                repository: NaechsteAktivitaetRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                ),
                firestoreRepository: FirestoreRepositoryImpl(
                    db: Firestore.firestore(),
                    api: FirestoreApiImpl(
                        db: Firestore.firestore()
                    )
                )
            ),
            input: .object(object: TermineCardViewPreviewExtension().oneDayEventData()),
            stufe: .biber,
            userId: nil
        ),
        aktivitaet: TermineCardViewPreviewExtension().oneDayEventData(),
        stufe: .biber
    )
}
