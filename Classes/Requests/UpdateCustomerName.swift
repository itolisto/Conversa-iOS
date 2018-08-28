import SwiftyJSON

public class UpdateCustomerName : JSONOperation<JSON> {
    
    public init(businessId: String, displayName: String) {
        super.init()
        self.request = Request(method: .post, endpoint: "customer/updateCustomerName", params: [:])
        self.request?.body = RequestBody.json(["businessId" : businessId, "displayName" : displayName])
        self.onParseResponse = { json in
            return json
        }
    }
    
}
