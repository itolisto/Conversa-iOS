import SwiftyJSON

public class GetCustomerFavs : JSONOperation<JSON> {
    
    public init(businessId: String, categories: Date, limit: Int) {
        super.init()
        self.request = Request(method: .post, endpoint: "business/updateBusinessCategory", params: [:])
        self.request?.body = RequestBody.json(["businessId" : businessId, "categories" : categories, "limit" : limit])
        self.onParseResponse = { json in
            return json
        }
    }
    
}
