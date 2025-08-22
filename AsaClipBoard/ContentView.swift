import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("AsaClipBoard")
                .font(.title)
                .padding()
            
            Text("クリップボード管理ツール")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            Button("設定を開く") {
                // 設定画面を開く処理
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}

#Preview {
    ContentView()
}