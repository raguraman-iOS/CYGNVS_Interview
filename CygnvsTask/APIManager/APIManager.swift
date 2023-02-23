//
//  APIManager.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import Foundation

///`APIManager` is responsiable for all the API intraction of the app
class APIManager {
    typealias onSuccess = (Data) -> ()
    typealias onError = (CustomError) -> ()
    
    /// method to get data from the given URL
    /// - Parameters urlString: has a `String` type, reptesent the URL to which the APIIcall is to be made
    /// - Parameters onSuccess: `onSuccess` is a `Closur` that will get called if the API responce is success
    /// - Parameters onError: `onError` is a `Closur` that will get called if the API responce is failes
    static func getData(from urlString: String, onSuccess: @escaping onSuccess, onError: @escaping onError) {
        guard let url = URL(string: urlString) else {
            onError(.BAD_URL)
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                onError(.BAD_REQUEST)
                return
            }
            let res = response as? HTTPURLResponse
            guard res != nil && res!.statusCode == 200 else {
                onError(.BAD_REQUEST)
                return
            }
            onSuccess(data)
        }.resume()
        
    }
}
