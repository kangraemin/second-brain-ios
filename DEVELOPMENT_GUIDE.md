# Second Brain iOS - Development Guide

프로젝트 전체 규칙과 단계 관리 지침. 모든 에이전트가 참조하는 최상위 문서.

---

## 1. 프로젝트 개요

| 항목 | 선택 |
|------|------|
| 언어 | Swift 6 |
| UI | SwiftUI |
| 아키텍처 | TCA (The Composable Architecture) |
| DI | Factory + TCA Dependencies |
| 로컬 DB | SwiftData |
| AI 처리 | Apple Foundation Models (iOS 26+) |
| 시맨틱 검색 | NLContextualEmbedding (iOS 17+) |
| 테스트 | Swift Testing + TCA TestStore |
| 최소 타겟 | iOS 26 |
| 코딩 스타일 | Kodeco Swift Style Guide |
| 패키지 관리 | Swift Package Manager |

---

## 2. 단계별 개발 원칙

### 2.1 단계 구조
- 모든 개발은 **큰 단계(Phase) → 작은 단계(Step)** 로 쪼갠다.
- 각 단계는 **의미 단위**로 구성한다. 하나의 단계 = 하나의 기능 또는 하나의 관심사.
- 한 단계에서 여러 관심사를 섞지 않는다.

### 2.2 단계 완료 조건
- 모든 단계는 **해당 단계가 완료되었음을 증명하는 테스트**가 있어야 한다.
- 테스트가 **모두 통과**해야만 다음 단계로 넘어간다.
- **빌드가 성공**해야 한다. (warning 0 유지)
- 빌드가 깨진 상태로 다음 단계에 진입하지 않는다.

### 2.3 단계 진행 체크리스트

각 단계를 완료하기 전에 반드시 확인:

- [ ] 해당 단계의 기능이 의미 단위로 완성되었는가?
- [ ] 단계 완료를 증명하는 테스트가 작성되었는가?
- [ ] 모든 테스트가 통과하는가?
- [ ] 빌드가 성공하는가? (warning 0)
- [ ] DI 규칙을 지켰는가? (직접 생성 없음, Protocol 추상화)
- [ ] 코딩 컨벤션을 따랐는가?
- [ ] 필요한 주석이 달려있는가? (why 위주)
- [ ] 불필요한 코드/주석이 없는가?

---

## 3. Git 컨벤션

### 3.1 브랜치
- `main`: 항상 빌드 성공 상태
- `develop`: 개발 통합 브랜치
- `feature/단계명`: 각 개발 단계별 브랜치

### 3.2 커밋 메시지
```
type(scope): 간결한 설명

본문 (선택)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

**type:**
- `feat`: 새 기능
- `fix`: 버그 수정
- `refactor`: 리팩토링 (동작 변경 없음)
- `test`: 테스트 추가/수정
- `chore`: 빌드, 설정 등
- `docs`: 문서

### 3.3 단계 완료 시
- 해당 단계의 모든 테스트 통과 확인
- 빌드 성공 확인
- `develop`에 머지
- 태그: `phase-X.step-Y`

---

## 4. 팀 구성

| 역할 | 에이전트 | 담당 |
|------|---------|------|
| Lead | `.claude/agents/lead.md` | 단계 설계, 태스크 생성/배정, 리뷰, 조율 |
| Dev | `.claude/agents/dev.md` | 기능 구현, 코딩 컨벤션 준수 |
| QA | `.claude/agents/qa.md` | 테스트 작성, 빌드 검증, 단계 완료 판정 |

### 4.1 워크플로우
```
Lead: 단계 설계 → 태스크 생성
  ↓
Dev: 태스크 수행 → 구현 완료 보고
  ↓
QA: 테스트 작성/실행 → 빌드 검증 → 통과/반려
  ↓
Lead: 단계 완료 확인 → 다음 단계 진행
```

### 4.2 소통 규칙
- 태스크는 TaskList/TaskUpdate로 관리한다.
- 에이전트 간 소통은 SendMessage로 한다.
- 단계 완료 판정은 QA가 하되, Lead가 최종 확인한다.
