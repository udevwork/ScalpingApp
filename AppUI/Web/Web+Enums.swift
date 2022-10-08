import Foundation

extension Web {
    public enum Method: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    public enum BaseAPI: String {
        case spot = "api.binance.com"
        case futures = "fapi.binance.com"
        case spotSocket = "wss://stream.binance.com:9443/ws/"
        case futuresSocket = "wss://fstream.binance.com/ws/"
    }
    
    public enum TestNetBaseAPI: String {
        case futures = "testnet.binancefuture.com"
        case futuresSocket = "wss://stream.binancefuture.com/ws/"
    }
    
    public enum API: String {
        case api = "/api"
        case fapi = "/fapi"
        case dapi = "/dapi"
    }
    
    public enum Version: String {
        case v1 = "/v1/"
        case v2 = "/v2/"
        case v3 = "/v3/"
    }
}
