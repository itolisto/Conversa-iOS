
@objcMembers class NetworkingManager : NSObject {

    static private func getFirebaseHeaders(tokenId: String) -> HeadersDict {
        var headersBuilder: HeadersDict = [:]
        headersBuilder["Accept"] = "application/json"
        headersBuilder["Content-Type"] = "text/json; Charset=UTF-8"
        headersBuilder["X-Conversa-Application-Id"] = "def"
//        headersBuilder["X-Conversa-Client-Version"] = BuildConfig.VERSION_NAME
        headersBuilder["X-Conversa-Client-Key"] = "fdas"
        headersBuilder["Authorization"] = "Bearer \(tokenId)"
        return headersBuilder;
    }

    static func getCustomerId(token: String) {
        let cfg = ServiceConfig.appConfig()
        let service = Service(cfg!)
        service.headers = service.headers.merging(getFirebaseHeaders(tokenId: token)) { (first, _) -> String in
            first
        }

        GetCustomerId().execute(in: service).then { (json) in
            print(json)
        }.catch { (error) in
            print(error)
        }
    }

    static func getCategories(language: String, token: String, completion: (_ result: String) -> Void) {
        let cfg = ServiceConfig.appConfig()
        let service = Service(cfg!)
        service.headers = service.headers.merging(getFirebaseHeaders(tokenId: token)) { (first, _) -> String in
            first
        }

        GetCategories(businessId: "", language: language).execute(in: service).then { (json) in
            print(json)
        }.catch { (error) in
            print(error)
        }
    }

    static func searchBusiness() {
        let cfg = ServiceConfig.appConfig()
        let service = Service(cfg!)

        //        SearchBusiness(businessId: "", conversaId: "").execute(in: service).then { json in
        //            print(json)
        //        }.catch({ err in
        //            print(err)
        //        })
    }
    
}
