//
//  OnboardingView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 28.06.2025.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    
    @AppStorage("showOnboardingView\(Constants.ONBOARDING_SCREEN_VERSION)") private var showOnboardingScreen: Bool = true
    @State private var viewModel: PushNotificationVerwaltenViewModel
    
    // user defaults from previous version of app to determine whether it is an update or a fresh install
    @AppStorage("alreadySeenOnboardingScreen") private var hadPreviousAppVersionInstalled: Bool = false
    
    init(
        viewModel: PushNotificationVerwaltenViewModel
    ) {
        self.viewModel = viewModel
    }
    
    @Query private var topicsQuery: [SubscribedFCMNotificationTopicDao]
    private var subscribedTopicsState: UiState<[SeesturmFCMNotificationTopic]> {
        do {
            let topics = try topicsQuery.map { try $0.getTopic() }
            return .success(data: topics)
        }
        catch {
            return .error(message: "Abonnierte Push-Nachrichten konnten nicht ermittelt werden. Installiere die App neu, um den Fehler zu beheben.")
        }
    }
    
    var body: some View {
        OnboardingContentView(
            onHideOnboardingScreen: {
                withAnimation {
                    showOnboardingScreen = false
                }
            },
            subscribedTopicsState: subscribedTopicsState,
            actionState: viewModel.actionState,
            onToggle: { topic, isSwitchingOn in
                Task {
                    await viewModel.toggleTopic(topic: topic, isSwitchingOn: isSwitchingOn)
                }
            },
            hadPreviousAppVersionInstalled: hadPreviousAppVersionInstalled
        )
        .alert(
            "Push-Nachrichten nicht aktiviert",
            isPresented: $viewModel.showSettingsAlert,
            actions: {
                Button("Einstellungen") {
                    viewModel.goToAppSettings()
                }
                Button("OK", role: .cancel) {}
            },
            message: {
                Text("Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
            }
        )
        .actionSnackbar(
            action: $viewModel.actionState,
            events: [
                .error(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                ),
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ],
            defaultErrorMessage: "Beim Bearbeiten von Push-Nachrichten ist ein unbekannter Fehler aufgetreten."
        )
    }
}

private struct OnboardingContentView: View {
    
    private let firstTab = 0
    private let lastTab = 4
    @State private var selectedTab: Int = 0
    
    private let onHideOnboardingScreen: () -> Void
    private let subscribedTopicsState: UiState<[SeesturmFCMNotificationTopic]>
    private let actionState: ActionState<SeesturmFCMNotificationTopic>
    private let onToggle: (SeesturmFCMNotificationTopic, Bool) -> Void
    private let hadPreviousAppVersionInstalled: Bool
    
    init(
        onHideOnboardingScreen: @escaping () -> Void,
        subscribedTopicsState: UiState<[SeesturmFCMNotificationTopic]>,
        actionState: ActionState<SeesturmFCMNotificationTopic>,
        onToggle: @escaping (SeesturmFCMNotificationTopic, Bool) -> Void,
        hadPreviousAppVersionInstalled: Bool
    ) {
        self.onHideOnboardingScreen = onHideOnboardingScreen
        self.subscribedTopicsState = subscribedTopicsState
        self.actionState = actionState
        self.onToggle = onToggle
        self.hadPreviousAppVersionInstalled = hadPreviousAppVersionInstalled
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                
                ScrollView {
                    VStack(alignment: .center, spacing: 32) {
                        ZStack(alignment: .topTrailing) {
                            Image("onboarding_welcome_image")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                            Image("LogoSplashScreen")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 125, height: 125)
                                .padding()
                                .padding(.top, 32)
                        }
                        Text("Willkommen in der Pfadi Seesturm App!")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Text("Mit der Pfadi Seesturm App sind alle Informationen zur Pfadi Seesturm nur einen Fingertipp entfernt.\n\nDie wichtigsten Funktionen stellen wir dir nun vor.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea(.container, edges: .top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollBounceBehavior(.basedOnSize)
                .tag(0)
                .padding(.bottom, 48)
                
                ScrollView {
                    VStack(alignment: .center, spacing: 32) {
                        HStack {
                            Spacer(minLength: .none)
                            Image("onboarding_ios_aktivitaet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 250)
                                .cornerRadius(16)
                                .shadow(color: Color.seesturmGreenCardViewShadowColor.opacity(0.3), radius: 5, x: 0, y: 0)
                                .padding([.horizontal, .top])
                            Spacer(minLength: .none)
                        }
                        Text("Nächste Aktivität")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("Unter «Nächste Aktivität» findest du die Infos zu den anstehenden Aktivitäten aller Stufen.\n\nDie Infos werden jeweils im Verlauf der Woche aufgeschaltet und können in deinen persönlichen Kalender importiert werden. So werden sie laufend synchronisiert.")
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(1)
                .scrollBounceBehavior(.basedOnSize)
                .padding()
                .padding(.bottom, 32)
                
                ScrollView {
                    VStack(alignment: .center, spacing: 32) {
                        HStack {
                            Spacer(minLength: .none)
                            Image("onboarding_ios_abmelden")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 250)
                                .cornerRadius(16)
                                .shadow(color: Color.seesturmGreenCardViewShadowColor.opacity(0.3), radius: 5, x: 0, y: 0)
                                .padding([.horizontal, .top])
                            Spacer(minLength: .none)
                        }
                        Text("An- und Abmeldungen")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("Melde dich direkt in der Pfadi Seesturm App ab, wenn du einmal nicht an eine Aktivität kommen kannst.\n\nDu kannst Personen, die du häufig an- oder abmeldest, in der App speichern. So musst du die Angaben nicht jedes Mal neu eintragen.")
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(2)
                .scrollBounceBehavior(.basedOnSize)
                .padding()
                .padding(.bottom, 32)
                
                ScrollView {
                    VStack(alignment: .center, spacing: 32) {
                        HStack {
                            Spacer(minLength: .none)
                            Image("onboarding_ios_anlaesse")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 250)
                                .cornerRadius(16)
                                .shadow(color: Color.seesturmGreenCardViewShadowColor.opacity(0.3), radius: 5, x: 0, y: 0)
                                .padding([.horizontal, .top])
                            Spacer(minLength: .none)
                        }
                        Text("Anlässe")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("Der Pfadi-Kalender zeigt dir auf einen Blick alle wichtigen Anlässe der Pfadi Seesturm.\n\nDamit du nie mehr einen Anlass verpasst, kannst du den Kalender abonnieren. So werden alle Anlässe automatisch deinem persönlichen Kalender hinzugefügt.")
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(3)
                .scrollBounceBehavior(.basedOnSize)
                .padding()
                .padding(.bottom, 32)
                
                PushNotificationVerwaltenContentView(
                    subscribedTopicsState: subscribedTopicsState,
                    actionState: actionState,
                    onToggle: onToggle,
                    additionalTopContent: {
                        Text("Push-Nachrichten")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    },
                    additionalBottomContent: {
                        Group {
                            if hadPreviousAppVersionInstalled {
                                SnackbarContentView(
                                    type: .info,
                                    message: "Push-Nachrichten müssen neu abonniert werden, da eine neue App Version installiert wurde."
                                )
                            }
                            else {
                                EmptyView()
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                )
                .tag(4)
                .padding(.bottom, 48)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            HStack(alignment: .bottom) {
                if selectedTab > firstTab {
                    Button {
                        withAnimation {
                            selectedTab = selectedTab - 1
                        }
                    } label: {
                        Text("Zurück")
                    }
                    .tint(Color.SEESTURM_GREEN)
                }
                Spacer()
                if selectedTab < lastTab {
                    Button {
                        withAnimation {
                            selectedTab = selectedTab + 1
                        }
                    } label: {
                        Text("Weiter")
                    }
                    .tint(Color.SEESTURM_GREEN)
                }
                else {
                    SeesturmButton(
                        type: .primary,
                        action: .sync(action: onHideOnboardingScreen),
                        title: "Fertig"
                    )
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom)
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(Color.customBackground)
    }
}

#Preview {
    OnboardingContentView(
        onHideOnboardingScreen: {},
        subscribedTopicsState: .success(data: []),
        actionState: .idle,
        onToggle: { _, _ in },
        hadPreviousAppVersionInstalled: true
    )
}
