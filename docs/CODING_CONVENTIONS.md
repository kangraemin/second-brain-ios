# Coding Conventions

---

## 1. 네이밍

| 대상 | 규칙 | 예시 |
|------|------|------|
| 타입 | UpperCamelCase | `SavedContent`, `ContentType` |
| 함수, 변수 | lowerCamelCase | `fetchContent()`, `searchQuery` |
| TCA Feature | `{화면명}Feature` | `HomeFeature` |
| TCA View | `{화면명}View` | `HomeView` |
| Action (사용자) | `{동사}{목적어}` | `saveButtonTapped` |
| Action (내부) | `{명사}{결과}` | `contentSaveResponse` |
| Client | `{도메인}Client` | `ContentClient` |
| SwiftData 모델 | `SD{도메인명}` | `SDContent` |
| 도메인 모델 | 접두사 없음 | `SavedContent` |

---

## 2. 파일 구성

- 파일당 하나의 주요 타입.
- TCA: `{Name}Feature.swift` + `{Name}View.swift` 쌍.

---

## 3. 접근 제어

- 기본 `internal` (명시 안 함). 파일 내부만 `private`.
- `open` 사용하지 않음.

---

## 4. import 정렬

```swift
import ComposableArchitecture
import SwiftData
import SwiftUI
```

알파벳 순, 빈 줄 없이.

---

## 5. TCA 규칙

- Side effect는 `Effect`로 래핑.
- 동기 작업은 State 직접 변경 + `.none` 반환.
- Navigation: `@Presents` / `StackState` 사용.

---

## 6. SwiftUI 규칙

- View body 100줄 초과 시 하위 View 분리.
- 모든 View에 `#Preview` 작성.
- iOS 17+ `@Bindable` + `@ObservableState` 조합.

---

## 7. 주석

- **Why**만 적는다. What은 코드로.
- `// MARK: -`로 섹션 구분.
- TODO: `// TODO: 설명`
