//
//  CustomError.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import Foundation

enum CustomError: Error {
    case INSERTION_FAILED
    case UPDATE_FAILED
    case CLEAN_FAILED
    case BAD_URL
    case BAD_REQUEST
    case DATA_MISS_MATCH
    case DATA_NOT_AVAILABLE
    
}

extension CustomError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .INSERTION_FAILED:
            return NSLocalizedString("Not able to save data.", comment: "")
        case .UPDATE_FAILED:
            return NSLocalizedString("Not able to update data.", comment: "")
        case .CLEAN_FAILED:
            return NSLocalizedString("Cleaning data failed", comment: "")
            
        case .BAD_URL:
            return NSLocalizedString("URL configured is wrong.", comment: "")
        case .BAD_REQUEST:
            return NSLocalizedString("Server not available.", comment: "")
        case .DATA_NOT_AVAILABLE:
            return NSLocalizedString("Data not available", comment: "")
        case .DATA_MISS_MATCH:
            return NSLocalizedString("Data conversion failed", comment: "")
        }
    }
}

extension CustomError: Identifiable {
    var id: String? {
        errorDescription
    }
}

