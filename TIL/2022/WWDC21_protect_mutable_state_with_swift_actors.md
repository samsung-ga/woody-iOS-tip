### Protect mutable state with Swift actors

----

2022.10.12 (수)

동시성 프로프래밍을 할 때 주의해야하는 기본적인 문제 중 하나는 **data race**입니다. data race는 두 개이상의 쓰레드가 하나의 공유 자원에 접근할 때, 하나 이상의 작업이 공유자원을 바꾸는 write작업일 때 일어납니다. 

하나의 예제를 봅시다.

```swift
class Counter {
    var value = 0

    func increment() -> Int {
        value = value + 1
        return value
    }
}
```

숫자를 카운팅하는 Counter 클래스가 있습니다.

```swift
struct ContentView: View {

    var body: some View {
        Button("Data Race 체크", role: .destructive) {
            let counter = Counter()

            Task.detached {
                print("첫 번째:", counter.increment()) // data race
            }

            Task.detached {
                print("두 번째:", counter.increment()) // data race
            }
        }
    }
}
```

버튼이 눌릴 때, 카운터의 숫자를 증가시킵니다. 이 작업은 `Task.detached`로 인해 해당 작업들은 병렬적으로 실행되어 Data race가 발생할 수 있는 상황입니다. print 결과로 (1,2) (2,1) (2,2) (1,1)... 다양하게 나올 수 있습니다.

> 직접 해봤지만 (1,2)의 결과만 나옵니다. 더 복잡한 형태로 구성하여야 Data Race가 일어나는 것을 확인할 수 있을 것 같습니다. 

Data race를 방지하는 방법은 value 타입을 사용하는 것입니다. value-type을 `let` 으로 선언하는 것이야말로 정말 변하지 않는 state를 만들기 때문에 동시에 실행되는 여러 task들의 접근에서부터 안전할 수 있습니다.

그럼 struct으로 선언해보겠습니다. 그리고 `increment`메소드는 mutating 키워드를 붙이고, Counter는 struct 타입이므로 `var` 선언하겠습니다.

```swift
struct Counter {
    var value = 0

    mutating func increment() -> Int {
        value = value + 1
        return value
    }
}

var counter = Counter()

Task.detached {
    print(counter.increment()) // data race
}

Task.detached {
    print(counter.increment()) // data race
}
```

이 또한 Data Race가 발생합니다. 왜냐하면 각각의 Task에서 counter가 캡처되기 때문입니다. 아예 빌드가 되지 않고 컴파일 에러가 납니다.

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-11%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%209.45.31.png" width="800" >



비동기적인 작업들이 하나의 공유 자원을 공유하고 있을 경우, 동기화가 필요해보입니다. 기존에는 Atomics, Locks, Serial dispatch queue와 같은 도구들을 사용했습니다. ~~(Atomics와 Locks는 처음 들어봅니다.)~~ 이 도구들을 사용할 때 신중을 가하지 않으면 data race는 쉽게 일어나고 맙니다. 그래서 Actor가 등장했습니다. 

![zzal](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/zzal.jpeg)

 ### Actor의 등장

Actor는 공유 자원의 동기화 작업을 도와줍니다. 자신만의 state를 가지고 있기 때문에 프로그램과는 고립되어 있습니다. state에 접근하는 유일한 방법은 actor를 통해 접근하는 것입니다. 기존 data race 해결 방식으론 *개발자로 인한 생길 수 있는 오류*가 많았다면 actor는 컴파일 에러를 통해 예방합니다. 

> Actor는 Swift의 새로운 타입입니다. 
> class와 struct과 같이 actor는 프로퍼티, 메소드, initializer, subcript 등과 같은 일반적인 기능들을 제공합니다. 또한 protocol을 채택할 수 있고, extension을 통해 확장 가능합니다. 그리고 자원을 공유하기 위한 용도이기 때문에 Class와 마찬가지로 레퍼런스 타입입니다. 오직 다른 점 하나는, actor의 인스턴스 데이터들은 프로그램으로부터 고립시키기 때문에 동기화가 보장됩니다.

바로 사용해보도록 합시다.

```swift
actor Counter {
    var value = 0

    func increment() -> Int {
        value = value + 1
        return value
    }
}
struct ContentView: View {
    var body: some View {
        Button("Data Race 체크", role: .destructive) {
            let counter = Counter()
            Task.detached { // Task 1
                print(await counter.increment()) 
            }

            Task.detached { // Task 2
                print(await counter.increment())
            }
        }
    }
}
```

class와 마찬가지로 프로퍼티와 메소드가 선언되었습니다. 하지만 다른 점은, value 값에 동시에 접근이 불가합니다. 이 뜻은 actor 내의 코드가 동작되고 있다면, increment 메소드는 그 코드가 끝난 이후에 작동된다는 것입니다. 이제 결과로 Task 1과 Task 2의 결과로 (1,2), (2,1)이 나올 수 있습니다. 

여기서, Task2가 Task1이 동작하고 있을 때 기다린다는 것을 보장하기 위해 `await`키워드가 사용됩니다. Task가 actor에 작업을 요청할 때, actor에서 코드가 작동되고 있다면 CPU는 해당 Task를 중지하고 다른 Task를 실행합니다. 그리고 actor가 자유로워지면 다시 해당 Task를 실행합니다. 

```swift
extension Counter {
    func resetSlowly(to newValue: Int) {
        value = 0
        for _ in 0..<newValue {
            increment()
        }
        assert(value == newValue)
    }
}
```

위 코드는 value를 다시 0으로 설정한 뒤 적절한 횟수만큼 `increment()`를 호출해서 value를 새로운 값으로 가지고 오는 함수입니다. 이 함수는 increment 함수를 호출하고 있지만 `await`키워드가 사용되지 않습니다. 왜냐하면 actor가 실행중이라는 것을 이미 알고 있어 대기할 필요가 없기 때문입니다. (actor의 메소드가 작동되고 있는 이상 다른 코드는 실행되고 있지 않다는 것이 이미 보장되었습니다.) 즉, Actor의 상태에 직접 접근할 수 있고, Actor내의 다른 함수를 동기적으로 호출할 수 있습니다. 

### Actor reentrnacy

동기 코드는 중단 없이 실행되지만 Actor는 다른 비동기 코드와 상호작용을 할 수도 있습니다. 비동기 코드와 상호작용하는 Actor를 알아보겠습니다.

```swift
actor ImageDownloader {
    private var cache: [URL: Image] = [:]

    func image(from url: URL) async throws -> Image? {
        if let cached = cache[url] {
            return cached
        }

        let image = try await downloadImage(from: url)

        // Potential bug: `cache` may have changed.
        cache[url] = image
        return image
    }
}
```

이미지 다운로드 Actor입니다. 다른 서비스에서 이미지를 다운로드하는 역할입니다. 또한 다운로드한 이미지를 캐시에 저장해 동일한 이미지는 여러번 다운로드 하지 않도록 합니다. 

Actor의 동기화 매커니즘은 한 번에 하나의 작업만 캐시 인스턴스에 접근하도록 보장하므로 캐시가 손상될 수 있는 경우는 없다고 생각할테지만, `await`키워드가 문제입니다. `await`으로 인해 코드 실행이 중지될 때마다 프로그램의 다른 코드가 실행될 수 있고, 실행되는 다른 함수로 인해 이상이 생길 수 있습니다.

![R1280x0](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/R1280x0.png)

 예를 들어 동일한 이미지를 동시에 가지고 오려고 하는 2개의 concurrent task가 있다고 합시다. 첫 번째는 캐시에 이미지가 없음을 확인하고 서버에서 웃는 고양이 이미지 다운로드를 시작한 뒤 다운로드하는 동안 CPU는 해당 작업을 중지하고 다른 함수를 시작합니다. 이렇게 첫 번째 작업이 웃는 고양이 이미지를 다운로드하는 동안 새로운 우는 고양이 이미지가 서버에 올라옵니다. 그리고 두 번째 이미지 다운로드 작업이 실행됩니다. 

![111](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/111.png)

두 번째 작업이 서버에서 이미지를 가져오는데 첫 번째 작업이 완료가 되지 았았기 때문에 아직 캐시에 이미지가 저장되지 않아 동일한 URL이미지 다운로드를 시작합니다. 물론 이 경우에도 CPU는 작업을 중단합니다. 하지만 결과를 보았을 때 동일한 URL 주소인데 다른 고양이 이미지가 다운로드되는 것을 알 수 있습니다. `await` 키워드로 인해 버그가 발생한 것입니다. 

이를 수정하기 위해서는 `await`후에 잘 수행되는지 확인해야합니다. 첫 번째 방법으로는 cache에 이미지가 저장되어있다면, 이미지 저장을 생략하는 방식입니다. 하지만 더 나은 해결 방식은 불필요한 이미지 다운로드를 제거하는 것입니다. 아래 코드는 중복되는 URL인 경우 아예 다운로드하지 못하게 막는 방법입니다. 

```swift
actor ImageDownloader {

    private enum CacheEntry {
        case inProgress(Task<Image, Error>)
        case ready(Image)
    }

    private var cache: [URL: CacheEntry] = [:]

    func image(from url: URL) async throws -> Image? {
        if let cached = cache[url] {
            switch cached {
            case .ready(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }

        let task = Task {
            try await downloadImage(from: url)
        }

        cache[url] = .inProgress(task)

        do {
            let image = try await task.value
            cache[url] = .ready(image)
            return image
        } catch {
            cache[url] = nil
            throw error
        }
    }
}
```

Actor reentrancy(Actor 재진입) 문제는 `await`키워드로 인해 발생합니다. 따라서 이를 예방하는 방법으로 첫 번째, 동기 코드 내에서만 Actor의 상태변경을 수행하면 됩니다. (동기 함수 내에서 모든 상태변경이 되도록 캡슐화하기) 두 번째 방법은 코드가 중단된 시점에 Actor의 상태가 변할 수 있다는 것을 생각하고, await 이전의 일관성을 다시 복원해야 합니다. 따라서 `await`이후 global state, clocks와 같은 것들을 확인해줍니다. 

>  영상에서는 gloabl state, clocks, timer와 같은 것들을 확인하라고 하는데 왜 저것들을 확인해주어야하는지 이해가 가지 않네요. Actor의 상태가 변했는지 안변했는지 확인하는 것이 중요한 것 아닌가?

### Actor isolation

Actor isolation은 Actor 타입의 동작의 기본입니다. 아까 Actor 외부에서 일어나는 비동기 함수들과 상호작용하는 Actor 타입의 isolation에 대해서 알아보았다면 이번에는 프로토콜 채택, 클로저, 클래스 등 다른 기능들과 어떻게 isolation을 유지하며 상호작용하는지 알아보겠습니다. 

1. 프로토콜

```swift
actor LibraryAccount {
    let idNumber: Int
    var booksOnLoan: [Book] = []
}

extension LibraryAccount: Equatable {
    static func ==(lhs: LibraryAccount, rhs: LibraryAccount) -> Bool {
        lhs.idNumber == rhs.idNumber
    }
}
```

먼저, `Equatable`프로토콜을 채택하게 되면 `==(lhs:rhs:)` 함수를 구현해야합니다. 이 함수는 static이므로 인스턴스가 없기 때문에 Actor에 의해 isolated되지 않았습니다. 외부에서 매개변수로 2개의 Actor를 받아 처리하기 때문에 Actor isolation과는 무관합니다. 

```swift
actor LibraryAccount {
    let idNumber: Int
    var booksOnLoan: [Book] = []
}

extension LibraryAccount: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(idNumber)
    }
}
```

하지만 `Hashable`프로토콜을 채택하게 될 경우, hash함수를 구현해야 하는데 이 함수는 Actor 외부에서 호출할 수 있지만 내부의 값을 바꿀 수 있습니다. 즉, isolation하게 유지해야합니다. 하지만 `Hashable` 프로토콜에 이미 구현되어 있는 함수이기 때문에 비동기함수로 다시 구현할 수도 없습니다. 이럴 경우 `nonisolated`키워드를 앞에 붙입니다. 해당 키워드는 Actor 외부에 있는 것처럼 처리하여 Actor의 mutable state를 참조할 수 없게 합니다. 위 코드에선 `idNumber`는 let선언되어 immutable state이므로 오류가 나지 않지만 만일 booksOnLoon을 참조하게 된다면 컴파일 오류가 납니다. 

![스크린샷 2022-10-12 오전 2.08.19](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-12%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.08.19.png)

> 🤔 바로 위에선 actor isolation을 지키기 위해선 async 함수여야한다고 하는데 이전에 생성한 increment 함수는 async 함수였나? 아니었는데 거기선 왜 컴파일 오류가 나지 않았을까? 
> 함수 자체에서 actor 프로퍼티에 접근해 값을 수정하는지 안하는지를 보는 것 같습니다. 

2. 클로저 

클로저는 actor isolation을 지킬 수 있습니다.

```swift
 extension LibraryAccount {
    func readSome(_ book: Book) -> Int { ... }
    
    func read() -> Int {
        booksOnLoan.reduce(0) { book in
            readSome(book)
        }
    }
 }
```

위 예제는 하나의 actor 내의 함수를 클로저 내에서 호출한 상황입니다. 이 상황에선 actor isolation합니다. readSome 함수에 `await`도 없고, `read` 함수 자체만으로 이미 isolated합니다. 또한, reduce 고차함수는 순차적으로 작동하기 때문에 안전합니다. 

```swift
extension LibraryAccount {
    func readSome(_ book: Book) -> Int { ... }
    func read() -> Int { ... }
    
    func readLater() {
        Task.detached {
            await read()
        }
    }
}
```

다른 경우를 살펴보겠습니다. 나중에 읽는 경우를 생각해봅시다. `detached` Task를 통해 Actor가 실행하고 있는 다른 작업도 동시에 실행시킵니다. 따라서 클로저가 하나의 Actor 내에서 실행되고 있지 않기 때문에 Data Race가 발생할 수 있습니다. 따라서 이런 경우 클로저는 Actor와 nonisolated합니다. read()메소드(isolated한 함수)를 호출하기 위해서는 `await`키워드를 넣어야 합니다. 



퍼런스 타입



- 레퍼런스 타입



- 레퍼런스 타입
- protocol을 채택할 수 있고, extension을 통해 확장 가능 
- 프로퍼티, 메소드, initializer, subscript 등 제공 
- 
