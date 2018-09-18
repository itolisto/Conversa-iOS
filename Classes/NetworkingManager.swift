
@objcMembers class NetworkingManager : NSObject {
    
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
