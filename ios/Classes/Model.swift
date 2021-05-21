// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct FullJson: Codable {
    let accessKey: String
    let registrationToken: RegistrationToken
    let attributes: [Attribute]
}

// MARK: - Attribute
public struct Attribute: Codable {
    
    
    public init(fieldName : String,alias : String, value: String ) {
        
        if String.isNilOrEmpty(string: fieldName)
            || String.isNilOrEmpty(string: alias) || String.isNilOrEmpty(string: value)
        {
            print("CLPushNotifications: Mandatory parameters of attribute must not be empty.")

        }
        self.alias = alias
        self.fieldName = fieldName
        self.value = value
    }
    public var alias, fieldName, value: String

   public enum CodingKeys: String, CodingKey {
        case alias
        case fieldName = "field_name"
        case value
    }
}

// MARK: - RegistrationToken
struct RegistrationToken: Codable {
    let os, longitude, phoneModel, sdkVersion: String
    let latitude, token, uniqueID: String

    enum CodingKeys: String, CodingKey {
        case os, longitude, phoneModel, sdkVersion, latitude, token
        case uniqueID = "uniqueId"
    }
}


// MARK: - Encode/decode helpers

class JSONNull: Codable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

  

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

// MARK: for failed json

// MARK: - Welcome
struct ServerResponse: Codable {
    let response: Response
    let result: JSONNull?
}

// MARK: - Response
struct Response: Codable {
    let responseCode: Int
    let responseMessage: String
}

 
