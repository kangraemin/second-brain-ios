import ComposableArchitecture
import Foundation

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        var appVersion: String = ""
        var savedContentCount: Int = 0
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action {
        case onAppear
        case contentCountLoaded(Int)
        case deleteAllTapped
        case deleteAllCompleted
        case deleteAllFailed
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {
            case confirmDelete
        }
    }

    @Dependency(\.contentClient) var contentClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                return .run { send in
                    let contents = try await contentClient.fetch()
                    await send(.contentCountLoaded(contents.count))
                }

            case .contentCountLoaded(let count):
                state.savedContentCount = count
                return .none

            case .deleteAllTapped:
                state.alert = AlertState {
                    TextState("전체 삭제")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDelete) {
                        TextState("삭제")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("저장된 모든 콘텐츠를 삭제합니다. 이 작업은 되돌릴 수 없습니다.")
                }
                return .none

            case .alert(.presented(.confirmDelete)):
                return .run { [contentClient] send in
                    do {
                        let contents = try await contentClient.fetch()
                        for content in contents {
                            try await contentClient.delete(content.id)
                        }
                        await send(.deleteAllCompleted)
                    } catch {
                        await send(.deleteAllFailed)
                    }
                }

            case .deleteAllCompleted:
                state.savedContentCount = 0
                return .none

            case .deleteAllFailed:
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
