import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("一般")
                }
            
            SecuritySettingsView()
                .tabItem {
                    Image(systemName: "lock")
                    Text("セキュリティ")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("一般設定")
                .font(.title2)
                .padding(.bottom)
            
            // 設定項目を追加
            Text("設定項目がここに表示されます")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SecuritySettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("セキュリティ設定")
                .font(.title2)
                .padding(.bottom)
            
            // セキュリティ設定項目を追加
            Text("セキュリティ設定項目がここに表示されます")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SettingsView()
}