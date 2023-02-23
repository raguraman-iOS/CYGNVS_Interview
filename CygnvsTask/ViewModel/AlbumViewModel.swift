//
//  AlbumViewModel.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import Foundation

class AlbumViewModel: ObservableObject {
    @Published var error: CustomError? = nil {
        didSet {
            self.showError = error != nil
        }
    }
    @Published var showError: Bool = false
    @Published var isLoading: Bool = false
}

extension AlbumViewModel {
    /// load the album data from URL
    func loadData() {
        do {
            try CoreDataManager.shared.clearData()
        } catch {
            self.error = CustomError.CLEAN_FAILED
        }
        self.isLoading = true
        APIManager.getData(from: "https://jsonplaceholder.typicode.com/photos") {[weak self] data in
            
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            guard let albumList = self?.convertData(data) else {
                return
            }
            
            self?.saveData(albumList)
            
        } onError: {[weak self] error in
            self?.isLoading = false
            self?.error = error
        }

    }
    
    /// responsiable for data conversion
    private func convertData(_ data: Data) -> [AlbumModel]? {
        guard let albumList: [AlbumModel] = JSONTransformer.dataToModelConverter(data: data) else {
            DispatchQueue.main.async {
                self.error = CustomError.DATA_MISS_MATCH
            }
            return nil
        }
        
        guard albumList.count > 0 else {
            DispatchQueue.main.async {
                self.error = CustomError.DATA_NOT_AVAILABLE
            }
            return nil
        }
        
        return albumList
    }
    
    /// responsiable for saveing data
    /// - Parameters albumList: `[AlbumModel]` that is needed to be stored
    private func saveData(_ albumList: [AlbumModel]) {
        do {
            try CoreDataManager.shared.saveAlbums(from: albumList)
        } catch {
            DispatchQueue.main.async {
                self.error = CustomError.INSERTION_FAILED
            }
        }
        
    }
    
    /// responsiable for updating the data
    /// - Parameters title: `String` the title that is needed to be updated
    /// - Parameters album: `Album` the album for which the title is needed to be updated.
    func update(title: String, for album: Album) {
        do {
            try CoreDataManager.shared.update(title: title, for: album)
        } catch {
            DispatchQueue.main.async {
                self.error = CustomError.UPDATE_FAILED
            }
        }
    }
    
    func clearError() {
        self.error = nil
    }
}
