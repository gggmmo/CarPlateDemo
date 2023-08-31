//
//  ContentView.swift
//  CarPlateDemo
//
//  Created on 17/8/2023.
//

import SwiftUI

struct ImageContainer: Hashable {
    var name: String
}

struct ContentView: View {
    var imageNames: [ImageContainer] = {
        var arr : [ImageContainer] = []
        for i in 0...4 {
            arr.append(ImageContainer(name: "car\(i)"))
        }
        return arr
    }()
    @State var selectedImageCon: ImageContainer?
    
    var body: some View {
        NavigationView {
            List(imageNames, id: \.name) { imgCon in
                Button {
                    selectedImageCon = imgCon
                } label: {
                    Image(imgCon.name)
                }

            }
            
            ResultView(imageContainer: $selectedImageCon)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
