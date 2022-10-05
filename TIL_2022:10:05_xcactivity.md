### Today I Learned

----

2020.10.05 (수)

<br />

### XCTActivity 알아보기

Activity를 이용하여 긴 테스트 메소드들을 substeps로 작게 나눌 수 있습니다. 각 Activity는 코드 블록으로 이루어졌고 이름이 있습니다.  여러개끼리 중첩할 수 있기 때문에 서로를 호출할 수도 있습니다. Xcode 테스트 리포트는 복잡하고, multistep 테스트들을 하나로 묶고 리팩토링을 통해 테스트를 간단히 만들 수 있습니다. 

1. **Organize Long Test Methods into Substeps<br />긴 테스트 메소드를 Substep으로 쪼개기**

바로 예를 들어보겠습니다. 로그인 UI 테스트는 3가지 단계로 나눌 수 있습니다. 1. Login Window 띄우기 2. 비밀번호 입력하기 3. Login Window 닫기. 아래 코드와 같이 각 단계의 activity에 이름을 지정할 수 있습니다.  Activity는 XCTContext로 표시되는 현재 테스트에 대해 실행됩니다. 아래와 같이 `XCTContext`의  [runActivityNamed:block:](https://developer.apple.com/documentation/xctest/xctcontext/2887132-runactivitynamed) 클래스 메소드를 호출하고 내부 실행 block을 실행합니다. 

```swift
// ✅ 긴 테스트 메소드를 substep으로 쪼갬 
// substep은 activity로 명세 
func testLogin() throws {
    openLoginWindow()
    enterPassword(for: .member)
    closeLoginWindow()
}

func openLoginWindow() {
    XCTContext.runActivity(named: "Open login window") { activity in
        let loginButton = app.buttons["Login"]
        
        XCTAssertTrue(loginButton.exists, "Login button is missing.")
        XCTAssertTrue(loginButton.isHittable, "Login button is not hittable.")
        XCTAssertFalse(app.staticTexts["Logged In"].exists, "Logged In label is visible and should not be.")

        loginButton.tap()
        
        let loginLabel = app.staticTexts["Login:"]
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 3.0), "Login label is missing.")
    }
}

```

2. **Build Utility Methods from Common Test Substeps<br />자주 사용되는 테스트 단계를 메소드로 만들기** 

어드민 로그인, 멤버 로그인 등 로그인할 수 있는 권한이 다양하여 모든 경우를 테스트해야하는 상황이 있습니다. 매번 아이디와 비밀번호를 입력해야하는 테스트 코드를 작성해야합니다. 이 경우 아이디 비밀번호를 입력하는 단계를 Activity로 만들어 재사용할 수 있습니다. 

```swift
// ✅ 자주 사용되는 테스트 단계 메소드로 만들기
// activity로 명세 
func login(for userType: TestUserType) -> Result<TestUserType, Error> {
    return XCTContext.runActivity(named: "Login") { activity in
        performLoginUITests(for: userType)
        
        guard app.staticTexts["Logged In"].exists else {
            let screenshot = app.windows.firstMatch.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.lifetime = .keepAlways
            activity.add(attachment)
            return .failure(TestLoginError.invalidLogin)
        }
        return .success(userType)
    }
}

func testAdminLoginFeatures() throws {
    let loginResult = login(for: .admin)
    try XCTAssertTrue(loginResult.get() == .admin)
    
    XCTAssertTrue(app.buttons["Admin Features"].exists, "Missing Admin Features button.")
    XCTAssertFalse(app.buttons["Member Features"].exists, "Member Features button is visible and should not be.")
}

func testMemberLoginFeatures() throws {
    let loginResult = login(for: .member)
    try XCTAssertTrue(loginResult.get() == .member)
    
    XCTAssertFalse(app.buttons["Admin Features"].exists, "Admin Features button is visible and should not be.")
    XCTAssertTrue(app.buttons["Member Features"].exists, "Missing Member Features button.")
}

```

`XCTContext`는 `XCTestCase` 서브클래스 안 뿐만 아니라 테스트 타겟 어디서든 사용할 수 있습니다. `XCUIApplication` 또는 `XCUIElement` 의 서브 클래스 메소드 내에서도 가능합니다. 

<br />

이 글을 읽으면 의문이 하나 듭니다. 테스트를 단계별로 나누기 위해, 또 재사용이 쉽도록 하기 위해서는 메소드로 만들기만 해도 가능합니다. 하지만 메소드로 리팩토링하면서 굳이 왜 Activity로 만드는 것일까?

### XCTActivity

> A named substep of a test method.

`XCTActivity` 타입은 테스트 메소드의 단계의 이름을 지정할 수 있게 해주기 때문입니다. 테스트 이름 뿐만 아니라, `XCTAttachment` 기능들을 제공합니다. 

### XCTContext

> A proxy for the current testing context

`XCTContext`는 테스트 케이스에서 직접 테스트에 대해 XCTActivity를 실행할 수 있는 방법을 제공합니다. 이 문장만 보면 뜻이 와닿지 않습니다. 하지만 위 글 [Grouping Tests into Substeps with Activities](https://developer.apple.com/documentation/xctest/activities_and_attachments/grouping_tests_into_substeps_with_activities)를 읽어보면 activity를 만들어주기 위한 객체라는 것을 알 수 있습니다. 긴 UI 테스트 또는 integration test(이게 뭐지)를 재사용을 위해 쪼갤 수 있고 테스트 리포트를 단순화시킬 수 있습니다. [runActivity(named:block:)](https://developer.apple.com/documentation/xctest/xctcontext/2923506-runactivity)메소드

를 이용하여 실행합니다. 

### runActivity(named:block:)

activity를 생성하고 실행합니다. class 타입 메소드로, name과 block을 매개변수로 받습니다. name은 activity 이름으로 테스트 결과에 표시될 이름이고, block은 해당 activity에서 수행될 테스트 코드입니다. 

```swift
class func runActivity<Result>(
    named name: String,
    block: (XCTActivity) throws -> Result
) rethrows -> Result
```

### XCTAttachment

> Data from a test method’s execution, such as a file, image, screenshot, data blob, or ZIP file<br />파일, 이미지, 스크린샷, 데이터 등과 같이 테스트 메소드으로부터 나오는 데이터들

[Adding Attachments to Tests, Activities, and Issues](https://developer.apple.com/documentation/xctest/activities_and_attachments/adding_attachments_to_tests_activities_and_issues)를 읽어야 합니다.

`XCTAttachment`는 여러가지 initializer가 있습니다.<br />Creating Attachments from...

- Data
- Files and Folders
-  Images and Screenshots
- Objects
- Strings

Attachment의 Lifetime도 설정할 수 있습니다. 

```swift
enum Lifetime: Int, @unchecked Sendable {
  case deleteOnSuccess 
	case keepAlways
}
```

Attachment의 Metadata도 설정할 수 있습니다. 

- name
- uniformTypeIdentifier: UTI 데이터 (무엇인지 모르곘습니다.)
- userInfo: 딕셔너리 형태로 여러 타입의 데이터 저장가능 





<br />

<br />

- https://developer.apple.com/documentation/xctest/activities_and_attachments/grouping_tests_into_substeps_with_activities
- https://developer.apple.com/documentation/xctest/xctcontext
- https://developer.apple.com/documentation/xctest/xctcontext/2923506-runactivity
- https://developer.apple.com/documentation/xctest/xctactivity