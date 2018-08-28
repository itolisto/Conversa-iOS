import SwiftyJSON

public class GetCategoryBusiness : JSONOperation<JSON> {
    
    public init(language: String) {
        super.init()
        self.request = Request(method: .post, endpoint: "public/getOnlyCategories", params: [:])
        self.request?.body = RequestBody.json(["language" : language])
        self.onParseResponse = { json in
            return json
        }
    }
    
}
