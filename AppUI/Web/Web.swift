import Foundation
import Starscream
import CryptoKit
import Combine

public class Web {
    
    public static var shared = Web()
    public let testnet: Bool = true
    public let debug: Bool = true
    
    internal let scheme:String = "https"
    internal var socket: WebSocket? = nil
    internal var publicKey: String? = nil
    internal var secretKey: String? = nil
    
    @Published public var stream : Data = Data()
    @Published public var socketConnected : Bool = false
    
    private init(){
        
    }
    
    public func testConnection(completion: @escaping (ServerError?)->()){
        if let request = self.request(.fapi, .get, .futures, .v1, "ping", useTimestamp: false ,useSignature: false) {
            REST(request, EmptyResponse.self, completion: { _ in completion(nil) }, iferror: { error in completion(error) })
        } else {
            completion(ServerError(code: 0, msg: "No api keys"))
        }
    }
    
    public func setApiKeys(publicKey: String, secretKey: String){
        self.publicKey = publicKey
        self.secretKey = secretKey
    }
    
    public func request(_ api: API,
                        _ method: Method,
                        _ base: BaseAPI,
                        _ v: Version,
                        _ function: String,
                        _ params: [URLQueryItem]? = nil,
                        useTimestamp: Bool = true,
                        useSignature: Bool = true) -> URLRequest? {
        
        guard let secretKey = secretKey, let publicKey = publicKey, !secretKey.isEmpty, !publicKey.isEmpty else {
            print("Need to setup public and secret api keys!")
            return nil
        }
        
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = base.rawValue
        components.path = api.rawValue + v.rawValue + function
        components.queryItems = params ?? []
        
        if useTimestamp {
            let timestamp = String(Int64((Date().timeIntervalSince1970 * 1000.0).rounded()))
            let query = [URLQueryItem(name: "recvWindow", value: "30000"), URLQueryItem(name: "timestamp", value: timestamp)]
            components.queryItems?.append(contentsOf: query)
        }
        
        if useSignature {
            let srtingedParams = (components.queryItems?.compactMap({ item -> String in
                return "\(item.name)=\(item.value!)"
            }) ?? []).joined(separator: "&").replacingOccurrences(of: "\"", with: "")
            let key = SymmetricKey(data: secretKey.data(using: .utf8)!)
            let authCodeData = srtingedParams.data(using: .utf8) ?? Data()
            let signature = HMAC<SHA256>.authenticationCode(for: authCodeData, using: key)
            let stringedSigrnature = Data(signature).map { String(format: "%02hhx", $0) }.joined()
            let query = [URLQueryItem(name: "signature", value: stringedSigrnature)]
            components.queryItems?.append(contentsOf: query)
        }
        
        if let url = components.url {
            //print("Create request URL: ", components.string ?? "error")
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue(publicKey, forHTTPHeaderField: "X-MBX-APIKEY")
            return request
        } else {
            print("Fail to create request for function: ", function)
            return nil
        }
    }
    
    public func REST<T: Decodable>(_ req: URLRequest,_ type: T.Type, completion: @escaping (T)->(), iferror: ((ServerError)->())? = nil) {
        DispatchQueue.global(qos: .background).async {
            let session = URLSession.shared
            let task = session.dataTask(with: req) { (data, response, error) in
                if self.debug {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("X-MBX-USED-WEIGHT: ", httpResponse)
                        
                        if let val =  httpResponse.value(forHTTPHeaderField: "x-mbx-used-weight"),
                           let val1m =  httpResponse.value(forHTTPHeaderField: "x-mbx-used-weight-1m") {
                            print("Used Weight: \(val), Used Weight 1m: \(val1m)")
                        }
                    }
                }
                if let error = error {
                    print("ERROR: ", error)
                    
                } else if let data = data {
                    if self.debug {
                        let dataAsString = String(data: data, encoding: .utf8) ?? "_"
                        print("------- Respone for \(String(describing: req.url?.absoluteURL)):", "\nData: ", data, "\nString: ", dataAsString,"\n----------")
                    }
                    do {
                        let error = try decode(ServerError.self, from: data)
                        print("Error \(String(describing: req.url?.absoluteString)) :  ", error.msg)
                        if error.msg.isEmpty == false {
                            DispatchQueue.main.async {
                                iferror?(error)
                            }
                        }
                        return
                    } catch {
                        
                    }
                    
                    if let decoded = try? decode(T.self, from: data) {
                        DispatchQueue.main.async {
                            completion(decoded)
                        }
                    } else {
                        print("Cannot decode data to ", T.self, " =(")
                        DispatchQueue.main.async {
                            iferror?(ServerError(code: 0, msg: "Cannot decode data"))
                        }
                    }
                    
                } else {
                    print("Data is nil")
                }
            }
            
            task.resume()
        }
    }
}

