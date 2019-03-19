import Foundation

class NetworkOutput : NSObject, PipelineOutput {
    private var _description: String = ""
    override var description: String {
        get {
            return _description
        }
    }
    
    private let server: NetworkOutputServer
    
    init?(address: String, port: Int) {
        guard let server = NetworkOutputServer(address, port: Int32(port)) else {
            return nil
        }
        self.server = server
        super.init()
        if address.isEmpty {
            self._description = "(check wifi):\(port)"
        } else {
            self._description = "\(address):\(port)"
        }
    }
        
    func pipelineDidOutput(data: Data) {
        _ = data.withUnsafeBytes {
            self.server.send($0, maxLength: data.count)
        }
    }
    
    func pipelineDidDrop() {
    }
}
