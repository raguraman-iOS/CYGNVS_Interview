//
//  JSONTransformer.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import Foundation

class JSONTransformer {
    /// Generic method that transform given data to the provided mode
    /// - Parameters data: the data that is needed to be transformed
    static func dataToModelConverter<ModelType: Decodable>(data: Data) -> ModelType? {
        let decoder = JSONDecoder()
        do {
            let modelData = try decoder.decode(ModelType.self, from: data)
            return modelData
        } catch {
            print(error)
            return nil
        }
    }
    
    /// Generic method that transform given model to disctionary representation
    /// - Parameters data: any model type that is needed to be converted
    static func modelToDataConverter<ModelType: Encodable>(data: ModelType) -> [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(data))) as? [String: Any] ?? [:]
    }
}
