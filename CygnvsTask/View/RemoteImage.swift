//
//  RemoteImage.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct RemoteImage: View {
    var url: String?
    
    var body: some View {
        ZStack {
            Color.gray
            
            if url != nil {
                    
                WebImage(url: URL(string: url!))
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .indicator(.activity)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            }
            
        }
        .clipped()
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic")
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
            .frame(width: 200, height: 200)
            .clipped()
    
    }
}
