import SwiftyJSON

public class GetCustomerId : JSONOperation<JSON> {
    
    public override init() {
        super.init()
        self.request = Request(method: .post, endpoint: "business/getBusinessId", params: [:])
        self.request?.body = RequestBody.json([:])
        self.onParseResponse = { json in
            return json
        }
    }
    
}
