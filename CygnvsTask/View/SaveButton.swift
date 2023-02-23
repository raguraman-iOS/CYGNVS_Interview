//
//  SaveButton.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import SwiftUI

struct SaveButton: View {
    @Binding var editMode: EditMode
    var action: () -> Void = {}
    var body: some View {
        Button {
            withAnimation {
                if editMode == .active {
                    action()
                    editMode = .inactive
                }
            }
        } label: {
                Text("Save").bold()
        }
    }
}

struct SaveButton_Previews: PreviewProvider {
    static var previews: some View {
        SaveButton(editMode: .constant(.inactive))
        SaveButton(editMode: .constant(.active))
        SaveButton(editMode: .constant(.transient))
    }
}
