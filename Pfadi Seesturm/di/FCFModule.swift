//
//  FCFModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 05.03.2025.
//
import FirebaseFunctions

protocol FCFModule {
    
    var fcfApi: CloudFunctionsApi { get }
    var fcfRepository: CloudFunctionsRepository { get }
}

class FCFModuleImpl: FCFModule {
    
    private let functions: FirebaseFunctions.Functions
    init(functions: FirebaseFunctions.Functions = Functions.functions()) {
        self.functions = functions
    }
    
    lazy var fcfApi: CloudFunctionsApi = CloudFunctionsApiImpl(functions: functions)
    
    lazy var fcfRepository: CloudFunctionsRepository = CloudFunctionsRepositoryImpl(api: fcfApi)
}
