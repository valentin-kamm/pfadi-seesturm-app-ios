//
//  WordpressModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//
import SwiftUI
import FirebaseFirestore

protocol WordpressModule {
    
    var wordpressApi: WordpressApi { get }
    
    var firestoreRepository: FirestoreRepository { get }
    
    var aktuellRepository: AktuellRepository { get }
    var aktuellService: AktuellService { get }
    
    var anlaesseRepository: AnlaesseRepository { get }
    var anlaesseService: AnlaesseService { get }
    
    var weatherRepository: WeatherRepository { get }
    var weatherService: WeatherService { get }
    
    var photosRepository: PhotosRepository { get }
    var photosService: PhotosService { get }
    
    var documentsRepository: WordpressDocumentRepository { get }
    var documentsService: WordpressDocumentsService { get }
    
    var leitungsteamRepository: LeitungsteamRepository { get }
    var leitungsteamService: LeitungsteamService { get }
    
    var naechsteAktivitaetRepository: NaechsteAktivitaetRepository { get }
    var naechsteAktivitaetService: NaechsteAktivitaetService { get }
}

class WordpressModuleImpl: WordpressModule {
    
    let firestoreRepository: FirestoreRepository
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    lazy var wordpressApi: WordpressApi = WordpressApiImpl(
        baseUrl: Constants.SEESTURM_API_BASE_URL
    )
    
    lazy var aktuellRepository: AktuellRepository = AktuellRepositoryImpl(api: wordpressApi)
    lazy var aktuellService: AktuellService = AktuellService(repository: aktuellRepository)
    
    lazy var anlaesseRepository: AnlaesseRepository = AnlaesseRepositoryImpl(api: wordpressApi)
    lazy var anlaesseService: AnlaesseService = AnlaesseService(repository: anlaesseRepository)
    
    lazy var weatherRepository: WeatherRepository = WeatherRepositoryImpl(api: wordpressApi)
    lazy var weatherService: WeatherService = WeatherService(repository: weatherRepository)
    
    lazy var photosRepository: PhotosRepository = PhotosRepositoryImpl(api: wordpressApi)
    lazy var photosService: PhotosService = PhotosService(repository: photosRepository)
    
    lazy var documentsRepository: WordpressDocumentRepository = WordpressDocumentRepositoryImpl(api: wordpressApi)
    lazy var documentsService: WordpressDocumentsService = WordpressDocumentsService(repository: documentsRepository)
    
    lazy var leitungsteamRepository: LeitungsteamRepository = LeitungsteamRepositoryImpl(api: wordpressApi)
    lazy var leitungsteamService: LeitungsteamService = LeitungsteamService(repository: leitungsteamRepository)
    
    lazy var naechsteAktivitaetRepository: NaechsteAktivitaetRepository = NaechsteAktivitaetRepositoryImpl(api: wordpressApi)
    lazy var naechsteAktivitaetService: NaechsteAktivitaetService = NaechsteAktivitaetService(
        repository: naechsteAktivitaetRepository,
        firestoreRepository: firestoreRepository
    )

}

struct WordpressModuleKey: EnvironmentKey {
    static let defaultValue: WordpressModule = WordpressModuleImpl(
        firestoreRepository: FirestoreRepositoryImpl(db: Firestore.firestore(), api: FirestoreApiImpl(db: Firestore.firestore()))
    )
}
extension EnvironmentValues {
    var wordpressModule: WordpressModule {
        get { self[WordpressModuleKey.self] }
        set { self[WordpressModuleKey.self] = newValue }
    }
}
