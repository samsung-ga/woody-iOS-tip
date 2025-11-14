### Today I Learned

----

2022.10.15 (토)



**UINavigationController 테스트하기**

iOS에서 화면전환은 UINavigationController을 이용하거나 present 메소드를 이용합니다. 화면전환이 제대로 이루어졌다는 것을 테스트하려면 먼저 MockNavigationController를 만듭니다. 

```swift
final class MockNavigationController: UINavigationController {
    var pushViewControllerCalled: Bool = false
    var pushedViewController: UIViewController?
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        pushViewControllerCalled = true
        pushedViewController = viewController
    }
}
```

만든 Mock 데이터를 코디네이터에 주입하여 해당 메소드가 잘 실행되었는 지 확인합니다. 

> 아래 코드에선 푸쉬 메소드가 제대로 불렸는 지, 그리고 푸쉬된 VC 타입을 확인해주는데 푸쉬된 VC의 타입만 확인해주면 제대로 푸쉬되었는 지 알 수 있습니다. 

```swift
final class IntroCoordinatorTests: XCTestCase {
    var sut: IntroCoordinatorProtocol!
    var mockNavigationController: MockNavigationController!

    override func setUp() {
        super.setUp()
        mockNavigationController = MockNavigationController(rootViewController: .init())
        sut = IntroCoordinator(navigationController: mockNavigationController)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testIntroCoordinator_이메일입력_화면으로_전환합니다() {
        // when
        sut.coordinateToEnterEmailScene()

        // then
        XCTAssertEqual(mockNavigationController.pushViewControllerCalled, true)
        XCTAssertTrue(mockNavigationController.pushedViewController is EnterEmailViewController)
    }
}
```

