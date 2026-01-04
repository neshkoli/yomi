import SwiftUI

struct DraggableDivider: View {
    enum Orientation {
        case horizontal
        case vertical
    }
    
    let orientation: Orientation
    let onDrag: (CGFloat) -> Void
    
    @State private var isDragging = false
    
    var body: some View {
        Group {
            if orientation == .vertical {
                verticalDivider
            } else {
                horizontalDivider
            }
        }
    }
    
    private var verticalDivider: some View {
        Rectangle()
            .fill(Color(white: 0.5, opacity: 0.3))
            .frame(width: 4)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                        }
                        onDrag(value.translation.width)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 20)
                    .contentShape(Rectangle())
            )
    }
    
    private var horizontalDivider: some View {
        Rectangle()
            .fill(Color(white: 0.5, opacity: 0.3))
            .frame(height: 4)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                        }
                        onDrag(value.translation.height)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
                    .contentShape(Rectangle())
            )
    }
}

#Preview {
    HStack {
        Rectangle()
            .fill(Color.blue.opacity(0.3))
            .frame(width: 200)
        
        DraggableDivider(orientation: .vertical) { _ in }
        
        Rectangle()
            .fill(Color.green.opacity(0.3))
            .frame(width: 200)
    }
    .frame(height: 400)
}

