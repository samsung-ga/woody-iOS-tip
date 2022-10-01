### Today I Learned

----

2022.10.01 (토)

<br />
<br />
개발을 하다보면 종종 mock 데이터, dummy 데이터에 대한 얘기가 많이 나와요. 저는 이 두 용어가 같은 의미라고 생각했기 때문에 임의의 데이터가 필요한 경우 "mock 데이터 만들어서 테스트해주세요." "dummy 데이터 만들어주세요"라며 사용하곤 했습니다. 점점 TDD와 아키텍처에 관심을 갖다 보니 stub과 mock에 대한 자료도 보이며 제가 기존에 알고 있던 용어들에 관해서도 급격히 혼란이 왔습니다. 🥲 그래서 오늘 드디어 공부해봤습니다.



###  Test Doubles (테스트 대역)

> Test Double is a generic term for any case where you replace a production object for testing purposes. — Martin Fowler 

유닛 테스트를 작성할 때, production과 동일하게 작동하지만 조금 더 단순화된 버전의 객체가 필요합니다. 이런 종류의 객체들이 Test Double입니다.<br />그럼 이게 왜 필요할까요? 👋🏻<br />한 가지 예시를 들어볼게요.

```swift

protocol LogoutUseCase {
    func logout() -> Observable<AuthModels.Empty.Response>
}

final class LogoutUseCaseImpl: LogoutUseCase {
    private let authRepository: AuthRepository
    private let accessTokenRepository: AccessTokenRepository
    private let userAccountRepository: UserAccountRepository
    init(
        authRepository: AuthRepository,
        accessTokenRepository: AccessTokenRepository,
        userAccountRepository: UserAccountRepository
    ) {
        self.authRepository = authRepository
        self.accessTokenRepository = accessTokenRepository
        self.userAccountRepository = userAccountRepository
    }
    
    func logout() -> Observable<AuthModels.Empty.Response> {
        authRepository.logout()
            .do { [weak self] _ in
                _ = self?.accessTokenRepository.deleteAccessToken()
                _ = self?.userAccountRepository.deleteLocalUserAccount()
            }
    }
}

```

위 코드는 로그아웃 기능을 구현한 예시입니다. <br />LogoutUseCaseImpl 객체를 테스트하기 위해선 3가지 프로퍼티가 필요해요. (조금 단순화시킴) <br />`AuthRepository`, `AccessTokenRepository`, `UserAccountRepository` <br />logout 메소드에 대해 테스트 할 때 오류가 난다면, 어디서 난 오류인지 바로 캐치할 수 있을까여? 로그아웃 네트워크 실패일 수도 있고, 토큰을 저장하는 로컬 디비에서 삭제할 때 실패할 수도 있어요.  

즉, 객체를 테스트하기 위해서는 해당 객체가 완전히 독립적이어야 합니다. (의존성 0%) <br />

하지만 객체들끼리 의존할 수 밖에 없기 때문에 해당 메소드를 테스트하기 위해 의존하는 객체들에 대한 대역을 만들어야 합니다. 위 예시에선 `AuthRepository`와 `AccessTokenRepository`, `UserAccountRepository` 3가지 객체들에 대한 대역을 이용해 logout 메소드를 테스트해볼 수 있습니다.

<br />블로그에 나온 다른 예시를 하나 더 들어볼게요.

ViewModel이 Repository 프로퍼티를 가지고 있다고 해봅니다. <br />이때 ViewModel 테스트 코드를 작성할 때, 실제 네트워크 통신하는 Repository가 필요할까요?
<br />

아닙니다. UseCase를 테스트하는데 실제 Repository가 있다면 어디서 오류가 어디서 날 지 알 수 없습니다. 또한 해당 UseCase에서 2개 이상의 Repository를 사용한다면 더욱 혼란이 올거예요. Repository는 Repository Test를 별도로 작성해서 네트워크 통신이 잘 되는지 테스트를 작성하면 됩니다. ViewModel에서는 ViewModel이 가진 로직만 테스트하면 됩니다.

즉, 현재 테스트 대상에 대해서만 집중해야 합니다.

위의 예시처럼 test double은 실제 객체를 대신해서 동작하는 대역이지만, 테스트 목적에 따라 테스트 대역들이 여러가지가 있고 쓰임이 제각각 다릅니다.

- Dummy
- Fake
- Stub
- Mock
- Spy

### Dummy

**정의**

Dummy 객체는 가장 기본적인 테스트 대역입니다. `placeholder`와 같이 아무런 기능을 수행하지 않는 인스턴스화 된 객체입니다. (단지 자리만 채워주는 역할) sut가 의존하고 있기 때문에 인스턴스화된 객체는 필요하지만, 테스트 할 때 사용하지 않아요. 

저는 이때까지 tableview나 collectionview를 테스트할 때 생성하는 객체들을 더미라고 불렀어요. 😓 하지만, 그것들은 데이터로써 쓰임이 있기 때문에 dummy가 아니라는 사실을 알게 되었네요.

**Unit Test에서 사용하기**

객체를 초기화해줄 때 사용됩니다. 아래 코드는 `DatabaseReader`와 `EmailServiceHelper`의 더미 서비스의 구현입니다.

```swift
// Dummy DatabaseReader
class DummyDatabaseReader: DatabaseReader {
  func getAllStock() -> Result<[Television], Error> {
	   return .success([])
  }
}

// Dummy EmailServiceHelper
class DummyEmailServiceHelper: EmailServiceHelper {
  func sendEmail(to address: String) {}
}

```

이 더미들은 `TelevisionWarehouse`의 초기화를 테스트하는데 사용합니다. 더미들은 아무런 기능을 수행하지 않아요.

```swift
func testWarehouseInitSuccess() {
  // given
  let dummyReader = DummyDatabaseReader()
  let dummyEmailService = DummyEmailServiceHelper()
  // when
  let warehouse = TelevisionWarehouse(dummyReader, emailServiceHelper: dummyEmailService)
  // then
  XCTAssertNotNil(warehouse)
}
```

### Fake

**정의**

Fake는 실제 객체와 핵심 로직은 동일하게 작성 되어 있지만, 다른 불필요 요소는 제거 되어 있는 객체입니다. (불필요 요소: 시간이 걸리거나 복잡한 configuration 등등) 

즉, 실제 객체보다 훨씬 간단한 버전으로 작성된 객체입니다. 

sut가 의존하는 객체의 핵심 로직이 제대로 수행되어야 테스트가 가능한 경우에 사용합니다. 실제 객체만큼 정교하진 않지만 동작의 구현 일부만 담당하게 돼요. 예를 들어, 데이터베이스와 연결하거나 네트워크 요청을 보낼 때가 있습니다. 로그를 남기거나 실제로 외부 의존성에 의존해야 하는 부분들을 제거할 수 있어요. 

**Unit Test에서 사용하기**

(이해가 쉬워서 [이 블로그](https://jiseobkim.github.io/swift/2022/02/06/Swift-Test-Double(부제-Mock-&-Stub-&-SPY-이런게-뭐지-).html)에서 가져온 예시입니다!)

계산기 메소드 중 sum이라는 것은 a+b값을 리턴하는 로직을 테스트해야 합니다. 단순히 a와 b의 합을 리턴하는지를 확인하면 되는데 실제 코드에선 sum에 대한 로그를 서버에 남기기 위해 통신 하는 코드가 들어 있거나, 결과를 다른 객체에 전달하는 역할을 하는 코드도 들어가 있을 수 있습니다.

```swift
protocol Calculator {
    func sum(x: Int, y: Int) -> Int
}
class CalculatorImp: Calculator {
    let b: Some
    let c: Some2

    init(b: Some, c: Some2) {
        self.b = b
        self.c = c
    }

    func sum(x: Int, y: Int) -> Int {
        // 불필요
        b.callMethod()
        b.callMethod2()
        b.callMethod3()
    
        // 불필요
        if x > 0 {
            c.callLogMethod()
        }
        
        // 핵심 코드
        let result = x + y
        return result
    }
}

```

주석에 쓰여진 작업들은 핵심로직이 아니므로 불필요합니다. <br />이런 경우 아래와 같이 간소화할 수 있어요. 

```swift
class CalculatorFake: Calculator {
    func sum(x: Int, y: Int) -> Int {
        let result = x + y
        return return
    }
}
```

### Stub

**정의**

Stub은 미리 정해진 데이터들을 항상 반환하는 기능을 가진 가짜 객체입니다. 실제 환경에서 테스트하기 어려운 것들을 테스트하고 싶을 때 굉장히 용이하다고 하네요. 이것도 네트워크 연결 오류나 서버 오류 같은 상황에 적합하다고 합니다. (이렇게 말하는 이유가 있다.. Fake랑 다른점을 모르겠지만 일단 ㅇㅋ...)

**Unit Test에서 사용하기**

데이터베이스를 읽는 과정에서 오류가 난 상황을 테스트해본다고 하면, 아래와 같이 정해진 오류를 리턴하는 기능을 가진 Stub 객체를 만들 수 있어요. 

```swift
class StubDatabaseReader: DatabaseReader {
    
    enum StubDatabaseReaderError: Error {
        case someError
    }

    func getAllStock() -> Result<[Television], Error> {
        return .failure(StubDatabaseReaderError.someError)
    }
}
```



### Stub vs Fake

<div align="center"><img src="https://miro.medium.com/max/1400/0*snrzYwepyaPu3uC9.png" width="350"> <img src="https://miro.medium.com/max/1400/0*KdpZaEVy6GNnrUpB.png" width="350"></div>

Fake와 Stub이 언뜻 비슷해보입니다. 만일 Repository를 프로퍼티로 가지는 UseCase를 테스트하는 상황이라고 하면, 이 Repository는 Fake 객체로도, Stub 객체로도 만들 수 있어요. 여기서, 차이점은 Stub은 미리 지정된 객체만 리턴이 된다는 것이고, Fake는 요청을 받고 응답을 리턴한다라고 할 수 있습니다. Repository를 데이터베이와 연결된 객체라고 한다면, Fake 객체는 데이터베이스를 배열로 대체하여 실제 기능처럼 구현하고 Stub 객체는 미리 지정한 값으로 구현합니다.  

```swift
class FakeRepositoryImpl: DatabaseReader {
  var storedArray: [String] = []
  
  func readUsersNickname() -> [String] {
    return storedArray
  }
}

class StubRepositoryImpl: DatabaseReader {
  func readUsersNickname() -> [String] {
    return ["미리", "지정된", "객체"]
  }
}
```



### Mock

**정의**

리턴값과 콜백값이 중요하지 않고 **해당 메소드가 잘, 얼마나 실행 되었는 지** 중요할 때 사용하는 객체입니다. 리턴값과 콜백이 없는 메소드는 state로 테스트하기 어렵고, 실제 환경에서 메소드가 제대로 작동되었는 지 확인하기 어려울 때 사용합니다. 예시로, 이메일 시스템이 있어요. 이메일 시스템은 테스트할 때마다 실제로 이메일을 보내면 안될 뿐더러 실제로 이메일이 제대로 갔는지 확인하기도 어렵습니다. 이런 상황엔 이메일 시스템이 제대로 호출되었는 지를 확인해야 하고 mock 객체를 사용합니다. 

**Unit Test에서 사용하기**

(이것두 이해가 쉬워서 [이 블로그](https://jiseobkim.github.io/swift/2022/02/06/Swift-Test-Double(부제-Mock-&-Stub-&-SPY-이런게-뭐지-).html)에서 가져온 예시입니다!)

네트워크 호출 코드가 잘 작동했는지에 대해 테스트할 때도 Mock 객체를 사용합니다,

```swift
class NetworkMock: Network {
    
    var networkCallCount = 0
    
    func network(handler: @escaping (Void) -> Void) {
        var networkCallCount += 1
    }
}
```

`networkCallCount` 변수를 만들고 

```swift
class MockTests: XCTestCase {
    private var sut: Company!
    private var printerMock: PrinterMock!
    
    override func setUp() {
        printerMock = PrinterMock()
        // 1. PrintImp 대신 Mock을 넣어준다.
        sut = Company(printer: printerMock)
    }
    
    func test_call_network() {
        // given
        // when
        sut.submit()
        
        // then
        // 2. printerMock에 메소드가 잘 호출되었는지 테스트 한다.
        XCTAssertEqual(printerMock.networkCallCount, 1)
    }
}
```

해당 메소드가 잘 호출되었는 지 확인합니다.

### Spy

**정의**

Mock + Stub, 상태도 행위도 테스트하는 객체라고 합니다! 미리 지정한 결과를 리턴해주고 해당 메소드가 제대로 불렸는지 확인하는 `count` 변수를 만들어서 카운팅해줍니다. 그런데 굳이 이 객체를 써야할 상황이 올까라는 의문이 듭니다.. 리턴이 온다는 것은 해당 메소드가 제대로 불렸다는 것을 입증하는 것인데.? 🤔

----

### 마무리 

다른 개발자와 의사소통시 사소하지만 조금이라도 명확한 의사소통을 할 수 있게 된 것 같네용! test double을 상황에 맞게 사용하는 훈련하기!



- https://medium.com/mobil-dev/unit-testing-and-test-doubles-in-swift-5b5e93e68512
- https://jiseobkim.github.io/swift/2022/02/06/Swift-Test-Double(부제-Mock-&-Stub-&-SPY-이런게-뭐지-).html
- https://tecoble.techcourse.co.kr/post/2020-09-19-what-is-test-double/
- https://velog.io/@leeyoungwoozz/Test-Doubles
- https://swiftsenpai.com/testing/test-doubles-in-swift/
- https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da
