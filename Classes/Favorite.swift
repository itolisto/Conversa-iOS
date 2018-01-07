//
//  Favorite.swift
//  Conversa
//
//  Created by Edgar Gomez on 11/30/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit

class Favorite {

    let processingQueue = OperationQueue()
    let objectId : String
    let name : String
    let avatarUrl : String

    init(objectId : String, name : String, avatarUrl : String) {
        self.objectId = objectId
        self.name = name
        self.avatarUrl = avatarUrl
    }

    static func getFavorites(customerId: String, skip : Int, completion : @escaping (_ results: FavoriteSearchResults?, _ error : Error?) -> Void) {
        PFCloud.callFunction(inBackground: "getCustomerFavs",
                             withParameters: ["customerId":customerId, "skip":0])
        {(results : Any?, error : Error?) in
            if let aerror = error {
                let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"\(aerror.localizedDescription)"])
                completion(nil, APIError)
            } else {
                do {
                    let json = results as? NSString
                    let data = json?.data(using: String.Encoding.utf8.rawValue)

                    guard let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [[String: Any]] else {
                        let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                        completion(nil, APIError)
                        return
                    }

                    var flickrPhotos = [Favorite]()

                    for photoObject in resultsDictionary {

                        guard let objectId = photoObject["oj"] as! String!,
                            let name = photoObject["dn"] as! String!,
                            let avatarUrl = photoObject["av"] as! String! else {
                                break
                        }

                        let flickrPhoto = Favorite(objectId: objectId, name: name, avatarUrl: avatarUrl)
                        flickrPhotos.append(flickrPhoto)
                    }

                    OperationQueue.main.addOperation({
                        completion(FavoriteSearchResults(searchTerm: "", searchResults: flickrPhotos), nil)
                    })
                } catch _ {
                    completion(nil, nil)
                    return
                }
            }
        }
    }

}
