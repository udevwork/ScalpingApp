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