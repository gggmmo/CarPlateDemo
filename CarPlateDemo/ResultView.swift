//
//  ResultView.swift
//  CarPlateDemo
//
//  Created on 17/8/2023.
//

import SwiftUI

struct ResultView: View {
    @Binding var imageContainer: ImageContainer?
    @State var outputImg: UIImage?
                
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            if let imgCon = imageContainer {
                VStack {
                    Image(imgCon.name)
                        .resizable()
                        .scaledToFit()
                    if let outputUIImg = outputImg {
                        Image(uiImage: outputUIImg)
                            .resizable()
                            .scaledToFit()
                    }
                }
            } else {
                Text ("Please select an image")
                    .foregroundColor(Color.white)
            }
            
        }.onChange(of: imageContainer, perform: { newValue in
            if let imgCon = imageContainer {
                let srcImg = UIImage(named: imgCon.name)
                outputImg = OpenCVWrapper.toBlur(srcImg);
            }
        })
    }
}

struct ResultView_Previews: PreviewProvider {
    @State static var imageContainer: ImageContainer?
    
    static var previews: some View {
        ResultView(imageContainer: $imageContainer)
    }
}
