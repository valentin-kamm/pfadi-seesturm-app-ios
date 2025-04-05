//
//  FirebaseCloudFunctionsApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 05.03.2025.
//
import Foundation
import FirebaseFunctions

protocol CloudFunctionsApi {
    
    var functions: FirebaseFunctions.Functions { get }
    
    func invokeCloudFunction<I: Encodable, O: Decodable>(name: String, data: I?) async throws -> O
}

class CloudFunctionsApiImpl: CloudFunctionsApi {
    
    var functions: FirebaseFunctions.Functions
    init(functions: FirebaseFunctions.Functions) {
        self.functions = functions
        /*
        #if DEBUG
        functions.useEmulator(withHost: "127.0.0.1", port: 5001)
        #endif
         */
    }
    
    func invokeCloudFunction<I: Encodable, O: Decodable>(name: String, data: I? = nil) async throws -> O {
        
        let jsonInputData = try JSONEncoder().encode(data)
        let jsonInputObject = try JSONSerialization.jsonObject(with: jsonInputData)
        
        let result = try await functions.httpsCallable(name).call(jsonInputObject)
        
        let jsonOutputData = try JSONSerialization.data(withJSONObject: result.data)
        return try JSONDecoder().decode(O.self, from: jsonOutputData)
    }
}
