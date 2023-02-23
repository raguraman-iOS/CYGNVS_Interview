//
//  AlbumCard.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import SwiftUI

struct AlbumCard: View {
    let title: String
    let imageURL: String?
    
    var body: some View {
        HStack(spacing: 15) {
            RemoteImage(url: imageURL)
                .frame(width: 60, height: 60)
                .clipped()
            
            Text(self.title)
            
            Spacer()
        }
        
    }
}

struct AlbumCard_Previews: PreviewProvider {
    static var previews: some View {
        AlbumCard(title: "sample title", imageURL: "")
    }
}
