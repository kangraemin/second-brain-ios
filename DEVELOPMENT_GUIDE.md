# Stash - Development Guide

프로젝트 전체 규칙의 허브. 모든 에이전트(`~/.claude/agents/`)가 이 문서를 먼저 읽는다.

---

## 1. 프로젝트 개요

| 항목 | 선택 |
|------|------|
| 앱 이름 | **Stash** |
| 플랫폼 | iOS (Swift) |
| UI | SwiftUI |
| 아키텍처 | TCA (The Composable Architecture) |
| 데이터 | SwiftData (로컬 우선) |
| AI/검색 | Core ML (온디바이스 임베딩 + 시맨틱 검색) |
| 최소 타겟 | iOS 17+ |
| 번들 ID | com.kangraemin.stash |
| App Group | group.com.kangraemin.stash |
| 테스트 | Swift Testing + TCA TestStore |
| GitHub | [kangraemin/stash-ios](https://github.com/kangraemin/stash-ios) |

### 핵심 기능

- **Share Extension**: 1탭 저장 (인스타, 유튜브, 사파리, 네이버지도, 구글맵, 쿠팡 등)
- **자동 카테고리**: URL 도메인 기반 콘텐츠 타입 자동 분류
- **시맨틱 검색**: Core ML 온디바이스 임베딩 기반 자연어 검색
- **딥링크**: 저장된 콘텐츠에서 원본 앱으로 바로 이동

### UX 원칙

> **저장은 1탭, 정리는 앱이, 검색은 AI가.**

---

## 2. 상세 가이드

| 문서 | 내용 |
|------|------|
| [Architecture](docs/ARCHITECTURE.md) | TCA 패턴, 프로젝트 구조, DI, 데이터 흐름 |
| [Coding Conventions](docs/CODING_CONVENTIONS.md) | 네이밍, 파일 구성, 코드 스타일 |
| [Testing](docs/TESTING.md) | Swift Testing + TestStore 패턴, 빌드 명령 |
| [SwiftUI + TCA Guide](docs/SWIFTUI_GUIDE.md) | View-Store 연결, Navigation, 비동기 패턴 |
| [UX Guide](docs/UX_GUIDE.md) | 저장 플로우, 화면 구성, 카드 디자인, 검색 |
| [단계별 개발 원칙](~/.claude/guides/common/phase-development.md) | Phase/Step 구조, 완료 조건 (글로벌) |
| [팀 워크플로우](~/.claude/guides/common/team-workflow.md) | Lead/Dev/QA 역할 (글로벌) |
| [Git Rules](~/.claude/rules/git-rules.md) | 커밋, 푸시, PR 규칙 (글로벌) |

---

## 3. 환경 요구사항

| 항목 | 필요 |
|------|------|
| macOS | 13.5+ (Xcode 15용) |
| Xcode | 15+ |
| Swift | 5.9+ |

---

## 4. 의존성

| 패키지 | 용도 |
|--------|------|
| [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) | TCA |

SPM(Swift Package Manager)으로 관리.

---

## 5. Git 컨벤션

`~/.claude/rules/git-rules.md` 참조. 추가로 이 프로젝트에서는:

- `develop` 브랜치를 개발 통합 브랜치로 사용
- `feature/<단계명>` 브랜치로 각 Step 작업
- 단계 완료 시 `develop`에 머지 후 태그: `phase-X.step-Y`
