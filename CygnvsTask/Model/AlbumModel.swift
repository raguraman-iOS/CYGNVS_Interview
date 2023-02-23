//
//  AlbumModel.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import Foundation

struct AlbumModel: Codable {
    var albumId: Int
    var id: Int
    var title: String
    var url: String?
    var thumbnailUrl: String?
}

extension AlbumModel {
    var dictionaryValue: [String: Any] {
        return JSONTransformer.modelToDataConverter(data: self)
    }
}
