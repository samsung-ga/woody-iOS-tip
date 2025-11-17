### Today I Learned

----

#### SwiftUI Instrument 소개 

- SwiftUI는 선언형 프레임워크로 UIKit처럼 Back trace로 디버깅하기 쉽지 않음
- 기본적으로 뷰가 언제업데이트되는지 찾기 어려움
- Xcode 26부터 SwiftUI를 인스트루먼트할 수 있는 기능 제공 
- 프로파일링에서 볼 수 있는 정보들 
  - Long View Body Updates: body가 실행되는데 오래 걸릴 때 표시 
  - Long Representable Updates: View, ViewController가 실행되는데 오래 걸릴 때 표시
  - Other Updates: 그 외 업데이트가 오래 걸릴 때 표시 
- 참고) 만약 Time Profiler에 그래프가 있는데, SwiftUI Profiler엔 아무런 문제가 없다면 뷰 외 다른 문제가 있다는 뜻

#### Time Profile 디버깅 방식

- SwiftUI 뷰가 계속 업데이트 되는 부분 영역 선택 
- 선택된 영역의 Timer Profiler 클릭
- Time Profiler에서 계속 업데이트가 되는 View 이름 검색 후 Stack Trace 확인 
- Stack Trace에서 왼쪽 Weight의 차이가 큰 부분 찾기 
- 차이가 큰 부분의 코드 확인하기 

#### Cause and Effects 기능

- SwiftUI가 뷰를 업데이트하는 방식 
  - 뷰 구조체에 대한 뷰 트리를 먼저 생성 
  - @State, @ObservedObject 등을 가진 속성을 저장소에 저장 
  - 속성이 변하면 새로운 뷰트리 생성후 기존 뷰트리와 비교하며 diffing 알고리즘 실행
    - 기존 속성에 대한 Transaction 생성하고, 영향 받는 뷰들에 outdated 표시
    - 새로 변경된 속성에 따라 outdated 표시된 뷰를 전부 비교
  - 변경된 UI 업데이트 
- 뷰가 언제 업데이트하는지 breakpoint를 걸어서 찾을 수 없음. 그래서 Cause and Effects 기능을 제공함
