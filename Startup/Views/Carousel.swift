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
    let padding: CGFloat
    let geometry: GeometryProxy
    let content: (Item) -> Content
    
    @State private var group: Int = 0
    @State private var id = UUID()
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
    
    private var buttonWidth: CGFloat {
        return geometry.size.width * 0.06
    }
    
    init(_ items: [Item], columns: Int = 1, padding: CGFloat = 6, geometry: GeometryProxy, _ content: @escaping (Item) -> Content) {
        self.items = items
        self.columns = columns
        self.padding = padding
        self.geometry = geometry
        self.content = content
    }
    
    var body: some View {
        ZStack {
            if group < chunks.count && group >= 0 {
                HStack(spacing: padding) {
                    ForEach(chunks[group], id: \.self) { item in
                        content(item)
                    }
                    
                    if group == chunks.count - 1 {
                        ForEach(extraCells, id: \.self) { _ in
                            Color.clear
                        }
                    }
                }
                .padding(.horizontal, padding)
                .transition(direction.animation)
                .id("\(id) \(group)")
                .offset(x: hoveringRight && chunks[group].count >= columns ? -buttonWidth: 0, y: 0)
                .offset(x: hoveringLeft ? buttonWidth: 0, y: 0)
            }
            
            if items.count > columns {
                GeometryReader { geometry in
                    BackwardButton(geometry: geometry)
                    ForwardButton(geometry: geometry)
                }
            }
        }
        .onChange(of: group) { _, _ in
            transitioning = true
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                transitioning = false
            }
        }
    }
}

// MARK: Views
extension Carousel {
    @ViewBuilder private func ForwardButton(geometry: GeometryProxy) -> some View {
        Button {
            direction = .right
            withAnimation(.spring(duration: 0.3)) {
                group = (group + 1) % (chunks.count)
            }
        } label: {
            ZStack {
                Color.black
                
                if hoveringRight {
                    Image(systemName: "arrowshape.forward")
                        .font(.system(size: buttonWidth * 0.4))
                        .opacity(0.3)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundStyle(.white)
            .clipShape(.rect(
                topLeadingRadius: 4,
                bottomLeadingRadius: 4,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            ))
            .opacity(hoveringRight ? 0.4: 0)
            .offset(CGSize(width: hoveringRight ? 0: buttonWidth, height: 0))
            .onHover { h in withAnimation { hoveringRight = h } }
        }
        .padding(.leading, 4)
        .frame(width: buttonWidth, height: geometry.size.height)
        .buttonStyle(.plain)
        .offset(CGSize(width: geometry.size.width - buttonWidth, height: 0))
        .disabled(transitioning)
    }
    
    @ViewBuilder private func BackwardButton(geometry: GeometryProxy) -> some View {
        Button {
            direction = .left
            withAnimation(.spring(duration: 0.3)) {
                if (group == 0) {
                    group = chunks.count - 1
                } else { group -= 1 }
            }
        } label: {
            ZStack {
                Color.black
                
                if hoveringLeft {
                    Image(systemName: "arrowshape.backward")
                        .font(.system(size: buttonWidth * 0.4))
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
            .opacity(hoveringLeft ? 0.4: 0)
            .offset(CGSize(width: hoveringLeft ? 0: -buttonWidth, height: 0))
            .onHover { h in withAnimation { hoveringLeft = h } }
        }
        .padding(.trailing, 4)
        .frame(width: buttonWidth, height: geometry.size.height)
        .buttonStyle(.plain)
        .disabled(transitioning)
    }
}
