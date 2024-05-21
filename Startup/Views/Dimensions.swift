//
//  Dimensions.swift
//  Startup
//
//  Created by David Rozmajzl on 5/21/24.
//

import SwiftUI

struct DimensionsViewModifier: ViewModifier {
    @Binding var dimension: CGSize
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geometry in
                    Path { path in
                        let size = geometry.size
                        DispatchQueue.main.async {
                            if self.dimension != size {
                                self.dimension = size
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    func dimensions(_ dimension: Binding<CGSize>) -> some View {
        modifier(DimensionsViewModifier(dimension: dimension))
    }
}

