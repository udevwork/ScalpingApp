import Foundation
import Starscream

extension Web: WebSocketDelegate {

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
    
    public func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
            case .connected(_):
                self.socketConnected = true
                print("websocket is connected")
            case .disconnected(let reason, let code):
                self.socketConnected = false
                print("websocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
              //    print("Received text: \(string)")
                
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

fileprivate struct SocetAction: Codable {
    var method: String
    var params: [String]
    var id: Int
}
