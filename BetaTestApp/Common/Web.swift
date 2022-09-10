import Foundation
import Starscream
import CryptoKit
import Combine

public struct ServerError: Codable {
    let code: Int
    let msg: String
}

class Web: WebSocketDelegate {
    
    public static var shared = Web()
    
    private init(){ }
    
    private var socket: WebSocket? = nil
    @Published var stream : Data = Data()
    
    public enum Method: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    public enum BaseAPI: String {
        case spot = "https://api.binance.com"
        case futures = "https://fapi.binance.com"
    }
    
    public enum Version: String {
        case v1 = "/v1/"
        case v2 = "/v2/"
        case v3 = "/v3/"
    }
    
    private var publicKey: String { "RXT3vk3FJAV9xRt0gws2K7EVFFh1osthrybAMi2MO3GvKm8VUSAblTsdFRORqrsj" }
    private var secretKey: String { "zLs7EKVerShwbJXUsHciCErQ3XSlL0UBsLTjwlIdJs5vjs5CXr0IocCCeg6sPukB" }
    
    public var timestamp = {
        return "recvWindow=30000&timestamp=" + String(Int64((Date().timeIntervalSince1970 * 1000.0).rounded()))
    }()
    
    public func request(_ method: Method, _ base: BaseAPI, _ v: Version, _ function: String, _ data: String, useSignature: Bool = true) -> URLRequest {
        let key = SymmetricKey(data: secretKey.data(using: .utf8)!)
        let signature = HMAC<SHA256>.authenticationCode(for: data.data(using: .utf8)!, using: key)
        let stringedSigrnature = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        let query = "?" + data + (useSignature ? ("&signature=" + stringedSigrnature) : "");
        let api = base == .futures ? "/fapi" : "/api"
        let url = URL(string: base.rawValue + api + v.rawValue + function + query)!
        print("Create request URL: ", url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(publicKey, forHTTPHeaderField: "X-MBX-APIKEY")
        return request
    }
    
    public func REST<T: Decodable>(_ req: URLRequest,_ type: T.Type, completion: @escaping (T)->(), iferror: ((ServerError)->())? = nil) {
        DispatchQueue.global(qos: .background).async {
            let session = URLSession.shared
            let task = session.dataTask(with: req) { (data, response, error) in
                
                if let httpResponse = response as? HTTPURLResponse {
                    //print("X-MBX-USED-WEIGHT: ", httpResponse)
                    
                    if let val =  httpResponse.value(forHTTPHeaderField: "x-mbx-used-weight"),
                       let val1m =  httpResponse.value(forHTTPHeaderField: "x-mbx-used-weight-1m") {
                        print("Used Weight: \(val), Used Weight 1m: \(val1m)")
                    }
                }
                
                if let error = error {
                    print("ERROR: ", error)
                    
                } else if let data = data {
                    let dataAsString = String(data: data, encoding: .utf8) ?? "_"
                    print("------- Respone for \(String(describing: req.url?.absoluteURL)):", "\nData: ", data, "\nString: ", dataAsString,"\n----------")
                    
                    do {
                        let error = try JSONDecoder().decode(ServerError.self, from: data)
                        print("Error \(String(describing: req.url?.absoluteString)) :  ", error.msg)
                        if error.msg.isEmpty == false {
                            iferror?(error)
                        }
                    } catch {
                        
                    }
                    
                    if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                        DispatchQueue.main.async {
                            completion(decoded)
                        }
                    }

                } else {
                    print("Data is nil")
                }
            }
            
            task.resume()
        }
    }
    
    
    public enum BaseSocketAPI: String {
        case spot = "wss://stream.binance.com:9443/ws/"
        case futures = "wss://fstream.binance.com/ws/"
    }
    
    //btcusdt@kline_1m
    //btcusdt@depth5
    //wss://stream.binance.com:9443/ws/
    public func subscribe( _ api: BaseSocketAPI, to stream: String, id: Int){
        if socket == nil {
            print("Create new stream connection with: ", stream, " ID: ", id)
            var request = URLRequest(url: URL(string: api.rawValue + stream)!)
            request.timeoutInterval = 2
            socket = WebSocket(request: request)
            socket?.delegate = self
            socket?.connect()
        } else {
            print("Subscribe to stream with: ", stream, " ID: ", id)
            let data =
"""
    { "method": "SUBSCRIBE", "params": [ "\(stream)" ], "id": \(id) }
"""
            socket?.write(string: data)
        }
    }
    
    public func unsubscribe(from stream: String, id: Int){
        print("Unsubscribe to stream with: ", stream, " ID: ", id)
        let data =
"""
{ "method": "UNSUBSCRIBE", "params": [ "\(stream)" ], "id": \(id) }
"""
        socket?.write(string: data)
    }
    
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        switch event {
            case .connected(let headers):
                //isConnected = true
                print("websocket is connected: \(headers)")
            case .disconnected(let reason, let code):
                //isConnected = false
                print("websocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
              //  print("Received text: \(string)")
                
                if let data = string.data(using: .utf8) {
                    self.stream = data
                }
                
                
            case .binary(let data):
                print("Received data: \(data.count)")
            case .ping(_):
                print("ping")
                break
            case .pong(_):
                print("pong")
                break
            case .viabilityChanged(_):
                print("viabilityChanged")
                break
            case .reconnectSuggested(_):
                print("reconnectSuggested")
                break
            case .cancelled:
                print("cancelled")
                //isConnected = false
            case .error(let error):
                print("error: ", error as Any)
                //isConnected = false
        }
    }
    
    
}
