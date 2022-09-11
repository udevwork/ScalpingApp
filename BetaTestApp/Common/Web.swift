import Foundation
import Starscream
import CryptoKit
import Combine
import BinanceResponce

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
        case spotSocket = "wss://stream.binance.com:9443/ws/"
        case futuresSocket = "wss://fstream.binance.com/ws/"
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
    
    private var publicKey: String?
    private var secretKey: String?
    
    public var timestamp = {
        return "recvWindow=30000&timestamp=" + String(Int64((Date().timeIntervalSince1970 * 1000.0).rounded()))
    }()
    
    public func testConnection(completion: @escaping (ServerError?)->()){
        if let request = self.request(.fapi, .get, .futures, .v1, "ping", "") {
            REST(request, EmptyResponse.self, completion: { _ in completion(nil) }, iferror: { error in completion(error) })
        } else {
            completion(ServerError(code: 0, msg: "No api keys"))
        }
    }
    
    public func setApiKeys(publicKey: String, secretKey: String){
        self.publicKey = publicKey
        self.secretKey = secretKey
    }
    
    public func request(_ api: API, _ method: Method, _ base: BaseAPI, _ v: Version, _ function: String, _ data: String, useSignature: Bool = true) -> URLRequest? {
        
        guard let secretKey = secretKey, let publicKey = publicKey, !secretKey.isEmpty, !publicKey.isEmpty else {
            print("Need to setup public and secret api keys!")
            return nil
        }
        
        let key = SymmetricKey(data: secretKey.data(using: .utf8)!)
        let signature = HMAC<SHA256>.authenticationCode(for: data.data(using: .utf8)!, using: key)
        let stringedSigrnature = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        let query = "?" + data + (useSignature ? ("&signature=" + stringedSigrnature) : "");
        let url = URL(string: base.rawValue + api.rawValue + v.rawValue + function + query)!
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
                        let error = try decode(ServerError.self, from: data)
                        print("Error \(String(describing: req.url?.absoluteString)) :  ", error.msg)
                        if error.msg.isEmpty == false {
                            iferror?(error)
                        }
                    } catch {
                        
                    }
                    
                    if let decoded = try? decode(T.self, from: data) {
                        DispatchQueue.main.async {
                            completion(decoded)
                        }
                    } else {
                        print("Cannot decode data to ", T.self, " =(")
                        iferror?(ServerError(code: 0, msg: "Cannot decode data"))
                    }

                } else {
                    print("Data is nil")
                }
            }
            
            task.resume()
        }
    }
    
    //btcusdt@kline_1m
    //btcusdt@depth5
    //wss://stream.binance.com:9443/ws/
    public func subscribe( _ api: BaseAPI, to stream: String, id: Int){
        if socket == nil {
            print("Create new stream connection with: ", stream, " ID: ", id)
            var request = URLRequest(url: URL(string: api.rawValue + stream)!)
            request.timeoutInterval = 2
            socket = WebSocket(request: request)
            socket?.delegate = self
            socket?.connect()
        } else {
            print("Subscribe to stream with: ", stream, " ID: ", id)
            let action = SocetAction(method: "SUBSCRIBE", params: [stream], id: id)
            if let encodedAction = try? encode(from: action) {
                socket?.write(string: encodedAction)
            }
            
        }
    }
    
    public func unsubscribe(from stream: String, id: Int){
        print("Unsubscribe to stream with: ", stream, " ID: ", id)
        let action = SocetAction(method: "UNSUBSCRIBE", params: [stream], id: id)
        if let encodedAction = try? encode(from: action) {
            socket?.write(string: encodedAction)
        }
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

struct SocetAction: Codable {
    var method: String
    var params: [String]
    var id: Int
}

struct RequestTemplate {
    var api: Web.API
    var method: Web.Method
    var base: Web.BaseAPI
    var v: Web.Version
    var function: String
    var data: String
    var useSignature: Bool
}
