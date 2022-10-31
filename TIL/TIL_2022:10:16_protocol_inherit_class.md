### Today I Learned

----

2022.10.15 (토)



프로토콜이 UIView를 상속받을 수 있을까? 디자인컴포넌트를 만들 때, 팀원들이 컴포넌트를 바꾸지 말고 원하는 기능만 수행하게 만들고 싶은 상황입니다. 그래서 프로토콜 안에 해당 기능들을 담보하게 하는 방법이 가장 일반적으로 생각할 수 있습니다. 



Testable한 코드 작성하는 방법

- Protocols and parameterization
- Separating logic and effects



#### Protocols and parameterization

1. 뷰컨트롤러는 리소스가 크기 때문에 로직테스트에서는 생성할 필요가없다. 비즈니스 로직을 뷰컨트롤러에서 분리시키자
2. 뷰의 프로퍼티에 대한 값을 간접적으로 입력 받자 
3. UIApplication 인스턴스와 같이 테스트가 불가능한 부분은 Mock데이터를 만들어서 테스트하자
4. 테스트하는 함수의 Input을 제어할 수 있도록 하자.
5. 

- 







- https://stackoverflow.com/questions/58852513/protocol-inheritance-from-class
- https://developer.apple.com/documentation/xcode-release-notes/swift-5-release-notes-for-xcode-10_2
- https://www.swiftbysundell.com/articles/specializing-protocols-in-swift/
- https://twitter.com/johnsundell/status/1110491386636308480?lang=en