//
//  PositionUpdateStream.swift
//  BinanceResponce
//
//  Created by Denis Kotelnikov on 17.09.2022.
//

import Foundation
public struct PositionUpdateStream: Codable {
    public  let welcomeE: String
    public  let t, e: Int
    public  let o: O

    enum CodingKeys: String, CodingKey {
        case welcomeE = "e"
        case t = "T"
        case e = "E"
        case o
    }
}

// MARK: - O
public struct O: Codable {
    let oS, c, s, o: String
    let f, q, p, ap: String
    public let sp, oX, x: String
    let i: Int
    let oL, z, l, oN: String
    let n: String
    let t, oT: Int
    let b, a: String
    let m, r: Bool
    let wt, ot, ps: String
    let cp: Bool
    let rp: String
    let pP: Bool
    let si, ss: Int

    enum CodingKeys: String, CodingKey {
        case oS = "s"
        case c
        case s = "S"
        case o, f, q, p, ap, sp
        case oX = "x"
        case x = "X"
        case i
        case oL = "l"
        case z
        case l = "L"
        case oN = "n"
        case n = "N"
        case t = "T"
        case oT = "t"
        case b, a, m
        case r = "R"
        case wt, ot, ps, cp, rp, pP, si, ss
    }
}
