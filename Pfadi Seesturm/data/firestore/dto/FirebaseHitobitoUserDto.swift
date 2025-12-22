//
//  FirestoreHitobitoUserDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.03.2025.
//
import FirebaseFirestore
import Foundation

struct FirebaseHitobitoUserDto: FirestoreDto {
    @DocumentID var id: String?
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
    var email: String?
    var firstname: String?
    var lastname: String?
    var pfadiname: String?
    var role: String
    var profilePictureUrl: String?
    var fcmToken: String?
    
    func contentEquals(_ other: FirebaseHitobitoUserDto) -> Bool {
        return id == other.id &&
        email == other.email &&
        firstname == other.firstname &&
        lastname == other.lastname &&
        pfadiname == other.pfadiname &&
        role == other.role &&
        profilePictureUrl == other.profilePictureUrl &&
        fcmToken == other.fcmToken
    }
    
    init(_ dto: HitobitoUserInfoDto, role: String) {
        self.id = dto.sub
        self.created = nil
        self.modified = nil
        self.email = dto.email
        self.firstname = dto.firstName
        self.lastname = dto.lastName
        self.pfadiname = dto.nickname
        self.role = role
        self.profilePictureUrl = nil
        self.fcmToken = nil
    }
    
    init(from oldUser: FirebaseHitobitoUserDto, newFcmToken: String) {
        self.id = oldUser.id
        self.created = oldUser.created
        self.modified = nil
        self.email = oldUser.email
        self.firstname = oldUser.firstname
        self.lastname = oldUser.lastname
        self.pfadiname = oldUser.pfadiname
        self.role = oldUser.role
        self.profilePictureUrl = oldUser.profilePictureUrl
        self.fcmToken = newFcmToken
    }
    
    init(from oldUser: FirebaseHitobitoUserDto, newProfilePictureUrl: String?) {
        self.id = oldUser.id
        self.created = oldUser.created
        self.modified = nil
        self.email = oldUser.email
        self.firstname = oldUser.firstname
        self.lastname = oldUser.lastname
        self.pfadiname = oldUser.pfadiname
        self.role = oldUser.role
        self.profilePictureUrl = newProfilePictureUrl
        self.fcmToken = oldUser.fcmToken
    }
    
    init(jsonString: String) throws {
        
        struct Plain: Decodable {
            let userId: String
            let email: String?
            let firstname: String?
            let lastname: String?
            let pfadiname: String?
            let role: String
            let profilePictureUrl: String?
            let fcmToken: String?
        }
        
        guard let data = jsonString.data(using: .utf8) else {
            throw PfadiSeesturmError.unknown(message: "Data conversion for \(jsonString) did not work.")
        }
        
        let decoded = try JSONDecoder().decode(Plain.self, from: data)
        
        self.id = decoded.userId
        self.created = Timestamp()
        self.modified = Timestamp()
        self.email = decoded.email
        self.firstname = decoded.firstname
        self.lastname = decoded.lastname
        self.pfadiname = decoded.pfadiname
        self.role = decoded.role
        self.profilePictureUrl = decoded.profilePictureUrl
        self.fcmToken = decoded.fcmToken
    }
}
