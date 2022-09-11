//
//  CodableHelper.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 31.08.2022.
//

import Foundation

func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
    return try JSONDecoder().decode(T.self, from: data)
}

func encode(from object: Codable) throws -> String {
    let encodedData = try JSONEncoder().encode(object)
    if let jsonString = String(data: encodedData, encoding: .utf8){
        return jsonString
    }
    fatalError()
}
