//
//  Carousel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import SwiftUI

fileprivate enum Direction {
    case left, right
    
    var animation: AnyTransition {
        switch self {
        case .right:
            return AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
        case .left:
            return AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
        }
    }
}

struct Carousel<Content, Item: Hashable>: View where Content: View {
    let items: [Item]
    let columns: Int
    let height: CGFloat
    let horizontalPadding: CGFloat
    let content: (Item) -> Content
    
    @State private var group: Int = 0
    @State private var direction: Direction = .right
    @State private var transitioning = false
    @State private var hoveringLeft = false
    @State private var hoveringRight = false
    
    private var chunks: [[Item]] {
        return items.chunked(into: columns)
    }
    
    private var extraCells: [Int] {
        let remainder = items.count % columns
        if remainder == 0 { return [] }
        
        let count = columns - remainder
        var cells = [Int]()
        for c in 0..<count {
            cells.append(c)
        }
        return cells
    }
    
    init(_ items: [Item], columns: Int = 1, height: CGFloat, horizontalPadding: CGFloat = 0, _ content: @escaping (Item) -> Content) {
        self.items = items
        self.columns = columns
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            if group < chunks.count && group >= 0 {
                HStack(spacing: 0) {
                    ForEach(chunks[group], id: \.self) { item in
                        content(item)
                            .frame(maxWidth: .infinity)
                            .frame(height: height)
                    }
                    
                    if group == chunks.count - 1 {
                        ForEach(extraCells, id: \.self) { _ in
                            Color.clear
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .frame(width: geometry.size.width)
                .transition(direction.animation)
                .id(group)
            }
            
            Button {
                direction = .left
                withAnimation(.spring(duration: 0.3)) {
                    if (group == 0) {
                        group = chunks.count - 1
                    } else { group -= 1 }
                }
            } label: {
                ZStack {
                    Color.black.opacity(hoveringLeft ? 0.3: 0.15)
                    
                    if hoveringLeft {
                        Image(systemName: "arrowshape.backward")
                            .font(.system(size: horizontalPadding * 0.4))
                            .opacity(0.3)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .foregroundStyle(.white)
                .clipShape(.rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 4,
                    topTrailingRadius: 4
                ))
//                .offset(CGSize(width: hoveringLeft ? 0: -horizontalPadding / 2, height: 0))
                .onHover { h in withAnimation { hoveringLeft = h } }
            }
            .padding(.trailing, 4)
            .frame(width: horizontalPadding, height: height)
            .buttonStyle(.plain)
            .disabled(transitioning)
            
            Button {
                direction = .right
                withAnimation(.spring(duration: 0.3)) {
                    group = (group + 1) % (chunks.count)
                }
            } label: {
                ZStack {
                    Color.black.opacity(hoveringRight ? 0.3: 0.15)
                    
                    if hoveringRight {
                        Image(systemName: "arrowshape.forward")
                            .font(.system(size: horizontalPadding * 0.4))
                            .opacity(0.3)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .clipShape(.rect(
                    topLeadingRadius: 4,
                    bottomLeadingRadius: 4,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                ))
//                .offset(CGSize(width: hoveringRight ? 0: horizontalPadding / 2, height: 0))
                .onHover { h in withAnimation { hoveringRight = h } }
            }
            .padding(.leading, 4)
            .frame(width: horizontalPadding, height: height)
            .buttonStyle(.plain)
            .offset(CGSize(width: geometry.size.width - horizontalPadding, height: 0))
            .disabled(transitioning)
        }
        .frame(height: height)
        .onChange(of: group) { _, _ in
            transitioning = true
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                transitioning = false
            }
        }
    }
}
