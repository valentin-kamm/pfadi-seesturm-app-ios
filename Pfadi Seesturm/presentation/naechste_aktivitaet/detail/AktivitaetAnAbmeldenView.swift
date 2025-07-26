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
    
    @Binding private var viewModel: AktivitaetDetailViewModel
    private let aktivitaet: GoogleCalendarEvent
    private let stufe: SeesturmStufe
    
    init(
        viewModel: Binding<AktivitaetDetailViewModel>,
        aktivitaet: GoogleCalendarEvent,
        stufe: SeesturmStufe
    ) {
        self._viewModel = viewModel
        self.aktivitaet = aktivitaet
        self.stufe = stufe
    }
    
    @Query private var personenQuery: [GespeichertePersonDao]
    private var personen: [GespeichertePerson] {
        personenQuery.map { $0.toGespeichertePerson() }
    }
    
    var body: some View {
        NavigationStack {
            AktivitaetAnAbmeldenContentView(
                aktivitaet: aktivitaet,
                stufe: stufe,
                personen: personen,
                vorname: $viewModel.vorname,
                nachname: $viewModel.nachname,
                pfadiname: $viewModel.pfadiname,
                bemerkung: $viewModel.bemerkung,
                sheetMode: $viewModel.selectedSheetMode,
                anAbmeldenState: viewModel.anAbmeldenState,
                onUseGespeichertePerson: { person in
                    viewModel.useGespeichertePerson(person: person)
                },
                onSubmit: {
                    Task {
                        await viewModel.sendAnAbmeldung()
                    }
                }
            )
            .actionSnackbar(
                action: $viewModel.anAbmeldenState,
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
            
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

private struct AktivitaetAnAbmeldenContentView: View {
    
    private let aktivitaet: GoogleCalendarEvent
    private let stufe: SeesturmStufe
    private let personen: [GespeichertePerson]
    private let vorname: Binding<String>
    private let nachname: Binding<String>
    private let pfadiname: Binding<String>
    private let bemerkung: Binding<String>
    private let sheetMode: Binding<AktivitaetInteractionType>
    private let anAbmeldenState: ActionState<AktivitaetInteractionType>
    private let onUseGespeichertePerson: (GespeichertePerson) -> Void
    private let onSubmit: () -> Void
    
    init(
        aktivitaet: GoogleCalendarEvent,
        stufe: SeesturmStufe,
        personen: [GespeichertePerson],
        vorname: Binding<String>,
        nachname: Binding<String>,
        pfadiname: Binding<String>,
        bemerkung: Binding<String>,
        sheetMode: Binding<AktivitaetInteractionType>,
        anAbmeldenState: ActionState<AktivitaetInteractionType>,
        onUseGespeichertePerson: @escaping (GespeichertePerson) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        self.aktivitaet = aktivitaet
        self.stufe = stufe
        self.personen = personen
        self.vorname = vorname
        self.nachname = nachname
        self.pfadiname = pfadiname
        self.bemerkung = bemerkung
        self.sheetMode = sheetMode
        self.anAbmeldenState = anAbmeldenState
        self.onUseGespeichertePerson = onUseGespeichertePerson
        self.onSubmit = onSubmit
    }
    
    private enum AnAbmeldenFormFields: String, FocusControlItem {
        case vorname
        case nachname
        case pfadiname
        case bemerkung
        var id: AnAbmeldenFormFields { self }
    }
    
    var body: some View {
        FocusControlView(allFields: AnAbmeldenFormFields.allCases) { focused in
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Vorname", text: vorname)
                            .focused(focused, equals: .vorname)
                            .submitLabel(.next)
                            .onSubmit {
                                focused.wrappedValue = .nachname
                            }
                    }
                    HStack {
                        Image(systemName: "person.text.rectangle.fill")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Nachname", text: nachname)
                            .focused(focused, equals: .nachname)
                            .submitLabel(.next)
                            .onSubmit {
                                focused.wrappedValue = .pfadiname
                            }
                    }
                    HStack {
                        Image(systemName: "face.smiling")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Pfadiname (optional)", text: pfadiname)
                            .focused(focused, equals: .pfadiname)
                            .submitLabel(.next)
                            .onSubmit {
                                focused.wrappedValue = .bemerkung
                            }
                    }
                }
                Section {
                    HStack {
                        Image(systemName: "text.bubble")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextEditor(text: bemerkung)
                            .frame(height: 75)
                            .focused(focused, equals: .bemerkung)
                    }
                } header: {
                    Text("Bemerkung (optional)")
                }
                Section {
                    Picker("An-/Abmeldung", selection: sheetMode) {
                        ForEach(stufe.allowedAktivitaetInteractions) { interaction in
                            Label(interaction.nomen, systemImage: interaction.icon)
                                .labelStyle(.titleAndIcon)
                                .tag(interaction)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(sheetMode.wrappedValue.color)
                }
                Section {
                    SeesturmButton(
                        type: .primary,
                        action: .sync(action: {
                            onSubmit()
                        }),
                        title: "\(sheetMode.wrappedValue.nomen) senden",
                        colors: .custom(contentColor: .white, buttonColor: sheetMode.wrappedValue.color),
                        isLoading: anAbmeldenState.isLoading
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
        }
        .background(Color.customBackground)
        .navigationTitle("\(stufe.aktivitaetDescription) vom \(aktivitaet.startDayFormatted) \(aktivitaet.startMonthFormatted)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if !personen.isEmpty {
                        Section("Gespeicherte Personen") {
                            ForEach(personen) { person in
                                Button {
                                    onUseGespeichertePerson(person)
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
}

enum AktivitaetAnAbmeldenNavigationDestination: Hashable {
    case gespeichertePersonen
}

#Preview("Loading") {
    AktivitaetAnAbmeldenContentView(
        aktivitaet: DummyData.aktivitaet1,
        stufe: .biber,
        personen: [],
        vorname: .constant(""),
        nachname: .constant(""),
        pfadiname: .constant(""),
        bemerkung: .constant(""),
        sheetMode: .constant(.abmelden),
        anAbmeldenState: .loading(action: .abmelden),
        onUseGespeichertePerson: { _ in },
        onSubmit: {}
    )
}
#Preview("Idle") {
    AktivitaetAnAbmeldenContentView(
        aktivitaet: DummyData.aktivitaet1,
        stufe: .biber,
        personen: [],
        vorname: .constant(""),
        nachname: .constant(""),
        pfadiname: .constant(""),
        bemerkung: .constant(""),
        sheetMode: .constant(.anmelden),
        anAbmeldenState: .idle,
        onUseGespeichertePerson: { _ in },
        onSubmit: {}
    )
}
