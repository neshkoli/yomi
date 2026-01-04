import SwiftUI

struct SettingsView: View {
    @Binding var fontSize: CGFloat
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("הגדרות")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)
            
            VStack(spacing: 16) {
                Text("גודל גופן")
                    .font(.system(size: 18, weight: .semibold))
                
                HStack(spacing: 20) {
                    Button(action: {
                        if fontSize > 12 {
                            fontSize -= 2
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                    
                    Text("\(Int(fontSize))pt")
                        .font(.system(size: 20, weight: .medium))
                        .frame(minWidth: 60)
                    
                    Button(action: {
                        if fontSize < 40 {
                            fontSize += 2
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            
            Spacer()
            
            Button("סגור") {
                dismiss()
            }
            .padding(.bottom, 20)
        }
        .frame(width: 300, height: 200)
        .background(Color(white: 1.0))
    }
}

