//
//  TutorialScrollViewItem.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import SwiftUI

struct TutorialScrollViewItem: View {
    let content: TutorialContent
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
                .frame(height: 10)
            
            StopMotionAnimationView(
                updateInterval: 0.4,
                contentList: content.imageNames.map({ imageName in
                    AnyView(Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit))
                })
            )
            
            Spacer()
                .frame(height: 6)
            
            Text(content.title)
                .foregroundStyle(Color.blackSteel)
                .font(.custom("Copperplate Bold", size: 30))
                .frame(height: 35)
            
            Text(content.description)
                .foregroundStyle(Color.blackSteel)
                .font(.custom("Copperplate", size: 20))
                .frame(height: 40)
            
            Spacer()
                .frame(height: 15)
        }
    }
}

#Preview {
    GeometryReader { geometry in
        let height = geometry.size.height * 0.685
        CenterPreviewView(backgroundColor: .black) {
            TutorialScrollViewItem(content: TutorialConst.contents[0])
                .frame(width: height * 1.33, height: height)
                .background(.white)
        }
    }
}
