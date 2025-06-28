//
//  FirebaseCloudFunctionsApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 05.03.2025.
//
import Foundation
import FirebaseFunctions

protocol CloudFunctionsApi {
    
    func invokeCloudFunction<F: SeesturmCloudFunction>(function: F.Type, input: F.Payload) async throws -> F.Response
}

class CloudFunctionsApiImpl: CloudFunctionsApi {
    
    var functions: FirebaseFunctions.Functions
    
    init(functions: FirebaseFunctions.Functions) {
        self.functions = functions
    }
    
    func invokeCloudFunction<F: SeesturmCloudFunction>(function: F.Type, input: F.Payload) async throws -> F.Response {
        return try await invokeCloudFunction(name: F.functionName, data: input)
    }
    
    private func invokeCloudFunction<I: Encodable, O: Decodable>(name: String, data: I? = nil) async throws -> O {
        
        let jsonInputData = try JSONEncoder().encode(data)
        let jsonInputObject = try JSONSerialization.jsonObject(with: jsonInputData)
        
        let result = try await functions.httpsCallable(name).call(jsonInputObject)
        
        let jsonOutputData = try JSONSerialization.data(withJSONObject: result.data)
        return try JSONDecoder().decode(O.self, from: jsonOutputData)
    }
}


protocol SeesturmCloudFunction {
    associatedtype Payload: Encodable
    associatedtype Response: Decodable
    static var functionName: String { get }
}
enum SeesturmCloudFunctions {
    enum getFirebaseAuthToken: SeesturmCloudFunction {
        typealias Payload = CloudFunctionTokenRequestDto
        typealias Response = CloudFunctionTokenResponseDto
        static let functionName = "getfirebaseauthtokenv2"
    }
    enum publishGoogleCalendarEvent: SeesturmCloudFunction {
        typealias Payload = CloudFunctionAddEventRequestDto
        typealias Response = CloudFunctionAddEventResponseDto
        static let functionName = "addcalendareventv2"
    }
    enum updateGoogleCalendarEvent: SeesturmCloudFunction {
        typealias Payload = CloudFunctionUpdateEventRequestDto
        typealias Response = CloudFunctionUpdateEventResponseDto
        static let functionName = "updatecalendareventv2"
    }
    enum sendPushNotificationToTopic: SeesturmCloudFunction {
        typealias Payload = CloudFunctionPushNotificationRequestDto
        typealias Response = CloudFunctionPushNotificationResponseDto
        static let functionName = "sendpushnotificationtotopicv2"
    }
}
