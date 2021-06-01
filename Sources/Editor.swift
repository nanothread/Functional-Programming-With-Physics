import SwiftUI

class EditorModel: ObservableObject {
    // Share settings across multiple simulations
    static let shared = EditorModel()
    
    @Published var isSlowEnabled = false
    @Published var isRotationEnabled = true
}

struct Editor: View {
    @ObservedObject var model: EditorModel
    
    var releaseNextValue: () -> Void
    var reset: () -> Void
    
    var body: some View {
        HStack {
            VStack {
                Button(action: releaseNextValue) {
                    Text("Next Value")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.blue)
                        )
                }
                
                Button(action: reset) {
                    Label("Reset", systemImage: "arrow.clockwise")
                }
            }
            
            Spacer()
            
            VStack {
                Toggle("Slow Mode", isOn: $model.isSlowEnabled)
                Toggle("Rotation", isOn: $model.isRotationEnabled)
            }
            .animation(.easeInOut)
            .frame(maxWidth: 150)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}
