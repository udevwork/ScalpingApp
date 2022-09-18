//
//  NewOrder.swift
//  BinanceResponce
//
//  Created by Denis Kotelnikov on 17.09.2022.
//

import Foundation

public struct NewOrder: Codable {
    public let orderID: Int
    public let symbol, status, clientOrderID, price: String
    public let avgPrice, origQty, executedQty, cumQty: String
    public let cumQuote, timeInForce, type: String
    public let reduceOnly, closePosition: Bool
    public let side, positionSide, stopPrice, workingType: String
    public let priceProtect: Bool
    public let origType: String
    public let updateTime: Int

    enum CodingKeys: String, CodingKey {
        case orderID = "orderId"
        case symbol, status
        case clientOrderID = "clientOrderId"
        case price, avgPrice, origQty, executedQty, cumQty, cumQuote, timeInForce, type, reduceOnly, closePosition, side, positionSide, stopPrice, workingType, priceProtect, origType, updateTime
    }
}
