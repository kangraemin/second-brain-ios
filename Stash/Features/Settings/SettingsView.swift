import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        List {
            Section("일반") {
                HStack {
                    Label("저장된 콘텐츠", systemImage: "tray.full")
                    Spacer()
                    Text("\(store.savedContentCount)개")
                        .foregroundStyle(.secondary)
                }

                Button(role: .destructive) {
                    store.send(.deleteAllTapped)
                } label: {
                    Label("전체 삭제", systemImage: "trash")
                }
            }

            Section("앱 정보") {
                HStack {
                    Label("버전", systemImage: "info.circle")
                    Spacer()
                    Text(store.appVersion)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            store: Store(initialState: SettingsFeature.State()) {
                SettingsFeature()
            }
        )
    }
}
