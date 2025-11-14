### Today I Learned 

----

2022.10.11 (화)

ps) 이 글을 작성하다가 swift-book에서 swift 문법 오류 발견해서 [PR](https://github.com/apple/swift-book/pull/45)날림. 😅 😆


### **Concurrency - Swift5.5 이전**

Swfit언어는 비동기 처리와 병렬 처리를 위한 작업을 도와주도록 설게되었습니다. 기존의 Swift언어에서는 비동기작업을 completion handler를 이용하여 처리했습니다. 하지만 이는 단점이 몇가지가 있습니다. <br />예를 들어, 이미지이름 리스트를 불러오고 첫번째 이미지를 다운로드한 후, 화면에 보여주는 상황이라면,

```swift
listPhotos(inGallery: "Summer Vacation") { photoNames in
    let sortedNames = photoNames.sorted()
    let name = sortedNames[0]
    downloadPhoto(named: name) { photo in
        show(photo)
    }
}
```

이미 중첩 클로저를 통해 읽기 어려운 코드가 될뿐더러, 비동기 작업이 더 추가된다면 더 중첩되어 복잡해질 겁니다. <br />그리고 해당 작업이 어떤 스레드에서 작업될 지 모르기 때문에 UI와 관련된 작업은 `DispatchQueue.main`으로 감싸주어야 합니다. 

```swift
listPhotos(inGallery: "Summer Vacation") { photoNames in
    let sortedNames = photoNames.sorted()
    let name = sortedNames[0]
    downloadPhoto(named: name) { photo in
				DispatchQueme.main { // ✅
		        show(photo)           
        }
    }
}
```

한가지 더, 해당 작업이 두번 쓰이기 때문에 함수화시켜야 할 경우, 모든 상황(에러가 난 경우)에서 completion handler를 반환했는지 고려해야합니다. 아래 코드는 에러처리를 고려하지 않았습니다. 만일 고려한다면 `listPhotos`, `downloadPhoto`의 completion handler가 `Result`타입으로 리턴되게 수정하고 해당 오류에 맞게 `showPhoto`의 completion handler를 반환해주어야 합니다. 여기서 *개발자의 실수로 인해 발생할 수 있는 오류*가 다수 생깁니다. 

```swift
func showPhoto(completion: @escpaing ((UIImage) -> Void)) {
    listPhotos(inGallery: "Summer Vacation") { photoNames in
        let sortedNames = photoNames.sorted()
        let name = sortedNames[0]
        downloadPhoto(named: name) { photo in                        
						completion(photo) // ✅
        }
    }
}
```

마지막으로, retain cycle이 발생할 가능성이 있습니다. 클로저 내부에 self 프로퍼티를 이용해서 접근할 때 어느 쓰레드에서 접근하게 될 것인지 고려해야 합니다. escaping closure의 경우 일반 클로저와는 다르게, 레퍼런스 카운팅이 되기 때문에 추가적인 메모리 관리를 해주어야합니다. `[weak self]`를 통해 레퍼런스 카운팅을 제거하여 retain cycle 발생을 예방해야 하지만, 무분별한 `[weak self]`의 사용은 런타임 오버헤드를 일으키고, 옵셔널을 체크해줘야 하는 번거로움이 생깁니다.

```swift
listPhotos(inGallery: "Summer Vacation") { [weak self] photoNames in // ✅
    let sortedNames = self?.photoNames.sorted() ?? [defaultImageName] // ✅
    let name = sortedNames[0]
    downloadPhoto(named: name) { [weak self] photo in // ✅
				DispatchQueme.main { [weak self] // ✅
		        self?.show(photo) // ✅     
        }
    }
}
```

completion handler의 단점을 정리하면 아래와 같은 것들이 있습니다. 

- 중첩클로저로 인해 코드의 가독성 저하 
- 개발자의 실수로 인해 발생할 수 있는 다수의 오류 상황 존재
  - self capture -> retain cycle
  - 에러 핸들링



### 비동기 함수 선언 및 호출하기

비동기 함수(asynchrounous function/method)는 실행 도중 멈출 수 있는 특별한 종류의 함수입니다. 타입을 반환하거나, 에러를 던지거나, 아예 반환하지 않는 기존 함수와는 조금 다릅니다. 3가지 중 하나를 하긴 하지만, 작업 중간에 멈출 수 있습니다. 

비동기 함수를 작성할 때는 파라미터 뒤에 `async` 키워드를 사용합니다. 그리고 값을 반환할 경우엔 타입을 화살표(->) 뒤에 작성합니다. 그리고 오류를 던질 수 있는 비동기 함수일 경우엔 `async throws`로 작성할 수 있습니다.

```swift
func listPhotos(inGallery name: String) async -> [String] {
    let result = // ... some asynchronous networking code ...
    return result
}
```

함수의 작동을 중간에 멈추는 키워드는 `await`입니다. 

```swift
let photoNames = await listPhotos(inGallery: "Summer Vacation") // ⛔️
let sortedNames = photoNames.sorted()
let name = sortedNames[0]
let photo = await downloadPhoto(named: name) // ⛔️
show(photo)
```

completion handler의 예제코드를 async/await을 이용하여 코드를 작성해보면 위와 같습니다. 사진들의 이름을 불러오는 작업이 시작되면 해당 줄에서 함수는 멈추고, 작업을 맡고 있던 스레드는 다른 작업을 실행합니다. 모두 불러와졌다면 해다아 줄부터 다시 작업을 시작하여 `photoNames`에 결과를 할당하고 다음 줄로 넘어갑니다. `await`키워드가 붙어있다면, 위와 같이 동작하고 아니라면 일반 함수처럼 동기적으로 동작합니다.

`await`키워드가 표시된 코드는 해당 작업이 완료되어 반환될 때까지 다음 작업 실행을 멈추고, 기다리라는 의미입니다. 이 뜻은 *yielding the thread*라고도 합니다. 왜냐하면 Swift가 작업이 동작되고 있던 스레드에서 해당 작업을 멈추고 다른 코드를 동작시키기 때문입니다. `await`에서만 실행을 멈출 수 있기 때문에 특정 부분에서만 비동기 함수를 호출할 수 있습니다. 

- 비동기 메소드 및 프로퍼티 내부 
- `@main`키워드로 표시된 structure, main, enum
- Unstructured child task 내부 (아래에서 설명)

### 비동기 스트림 (Asynchronous Sequeunce)

`listPhotos(inGallery:)` 함수는 모든 이미지 리스트를 불러온 다음에 다음 작업이 실행됩니다. Swift의 비동기 스트림을 이용하면 이미지 리스트와 같이 collection타입인 경우 하나의 element만 불러올 때까지만 기다리게 할 수 있습니다. 

```swift
import Foundation

let handle = FileHandle.standardInput
for try await line in handle.bytes.lines {
    print(line)
}
```

`for - await - in` 구문을 통해 각 iteration마다 값이 준비될때까지 멈추고 값이 준비되면 다시 동작하게끔할 수 있습니다. 만약 iteration이 10번이라면 총 10번 멈출 것입니다. `AsyncSequence`프로토콜을 채택한 타입이라면 `for-await-in`구문을 사용할 수 있습니다.

### 병렬적으로 비동기 함수 호출하기 

`await`키워드로 비동기 함수를 호출하는 것은 오직 한번에 하나입니다. 즉, caller(비동기함수를 부르는 함수)가 비동기 함수를 부르고 있다면 다음 코드로 넘어가지 않습니다. 예를 들어, 이미지 3개를 동시에 다운받는 상황이리고 합시다.

```swift
let firstPhoto = await downloadPhoto(named: photoNames[0])
let secondPhoto = await downloadPhoto(named: photoNames[1])
let thirdPhoto = await downloadPhoto(named: photoNames[2])

let photos = [firstPhoto, secondPhoto, thirdPhoto]
show(photos)
```

위와 같이 코드를 작성하면 첫번째 이미지가 다운로드된 후, 두번째 이미지가 다운로드되고, 두번째 이미지가 다운로드된 후 세번째 이미지가 다운로드됩니다. 모두 순차적으로 다운로드가 진행되지만, 이미지 다운로드는 모두 독립적으로, 즉 병렬적으로 진행되어야하는 작업입니다. 

비동기 함수를 병렬적으로 호출하기 위해서는 `async`키워드를 `let`키워드 앞에 붙입니다. 그리고 해당 상수를 사용할 때 `await`	키워드를 붙입니다.

```swift
async let firstPhoto = downloadPhoto(named: photoNames[0])
async let secondPhoto = downloadPhoto(named: photoNames[1])
async let thirdPhoto = downloadPhoto(named: photoNames[2])

let photos = await [firstPhoto, secondPhoto, thirdPhoto]
show(photos)
```

시스템 자원이 충분하다면, 이미지 3개 다운로드 작업이 동시에 진행됩니다. 다운로드하는 비동기함수로 인행 실행이 멈추지 않기 때문에 `await`키워드로 표시되지 않습니다. 대신에, photos 상수가 할당될 때, 비동기 함수를 호출하고 3개의 비동기 함수가 모두 완료될 때까지 caller의 실행이 중단됩니다.

**await과 async-let 정리**

|           | 공통점                                                       | 차이점                                                       |
| --------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| await     | 1. caller는 중단되고 다른 코드가 실행된다.<br />2. 모두 `await`키워드를 통해 실행 중인 작업이 중단된다. | 1. 다음 코드가 비동기함수의 결과에 의존하고 있을 경우 사용한다. <br />2. 순차적 진행 |
| async-let | 위와 같음                                                    | 1. 다음 코드가 비동기함수의 결과에 의존하고 있지 않을 경우 사용한다.<br />2. 병렬적 진행 |

### Task and Task Groups

비동기적으로 처리해야할 작업을 처리할 때 실행되는 작업의 단위입니다. 모든 비동기 코드들은 task의 일부로서 작동됩니다. 위에서 설명한 `async-let` 키워드는 자동으로 자식 Task를 생성하여 처리합니다. Swift는 개발자가 직접 task group을 생성하고 자식 Task를 삽입할 수 있도록 하여 Task별 우선순위와 cancellation를 컨트롤할 수 있게 해줍니다. 

Task는 계층적(hierarchy)으로 정리됩니다. Task Group내의 각 Task는 같은 부모 Task를 가지고, 각 Task는 자식 Task를 가질 수 있습니다. Task와 Task Group이라는 명시적인 관계가 있기 때문에 이를 *structured concurrency*라고도 부릅니다. Task와 Task Group을 사용함으로서, 개발자의 실수가 조금 생길지라도, 명시적인 관계를 통해 Swift는 컴파일 타임에 오류를 찾아낼 수 있고, `부모 Cancellation -> 자식 Cancellation`와 같은 작업도 할 수 있습니다.

```swift
await withTaskGroup(of: Data.self) { taskGroup in
    let photoNames = await listPhotos(inGallery: "Summer Vacation")
    for name in photoNames {
        taskGroup.addTask { await downloadPhoto(named: name) }
    }
}
```

**Unstructured Concurrency**

부모 Task를 가지지 않는 Task도 존재하는데 이를 *Unstructured Concurrency*라고 합니다. 개발자가 Task를 전부 관리하기 때문에 개발자의 실수로 인해 발생할 오류들이 생깁니다. 현재 actor에서 unstructured concurreny task를 생성하는 방법은 `Task.init(priority: operation:)` initializer입니다. 현재 actor에서 생성하지 않고 다른 actor로 생성하는 방법은 `Task.detached(priority:operation:)` 클래스 메소드를 호출하는 것입니다. *(detatched task*라고 알려져있음) 이 두가지 메소드는 개발자가 상호작용(비동기 메소드 결과 기다리기, 취소하기)할 수 있는 Task를 반환합니다. (Actor는 밑에서!)

```swift
let newPhoto = // ... some photo data ...
let handle = Task {
    return await add(newPhoto, toGalleryNamed: "Spring Adventures")
}
let result = await handle.value
```

Spring Adeventures라는 갤러리에 새로운 사진을 추가하는 Task를 생성하는 예제입니다. Task에 대해선 문서를 보면서 더 자세히 공부해야겠습니다.

**Task Cancellation**

Swift 동시성은 공통의 cancellation 모델을 사용합니다. 각 Task는 적절한 실행시점에서 취소되었는지 체크하고 적절한 방식으로 취소에 응답합니다. 여기서 적절한 실행시점이란 아래의 상황입니다.

- `CancellationError`와 같은 에러를 던질 때 
- nil이나 빈 collection을 반환할 때 
- 부분적으로 완료된 작업을 반환할 때 

`cancellation`을 체크하기 위해서는 2가지 방법이 있습니다. Task가 취소될 때 `CancellationError`를 던지는 `Task.checkCancellation()`을 호출하거나 `Task.isCancelled`의 값을 체크해서 취소된 상황을 핸들링하는 것입니다. 예를 들어 갤러리에서 사진을 다운로드하는 Task에서는 부분적인 다운로드를 제거하고 네트워크 연결을 닫는 작업이 있을 것입니다.

### Actors

이제 개발자들은 프로그램을 동시에 작동할 수 있는 Task 조각으로 쪼갤 수 있습니다. 이 Task 조각들은 각각 독립되어 동시에 작동하여 서로로부터 안전하지만, Task 사이에서 공유되는 자원들은 안전하지 않습니다. Actor는 동시성 코드로부터 공유 자원을 안전하게 관리해줍니다.

Actor는 레퍼런스 타입입니다. 하지만 클래스와 달리, 한번에 하나의 Task만이 State에 접근하여 변경할 수 있어 여러개의 Task들로부터 하나의 actor 인스턴스에 접근하는 것을 방지합니다. 예를들어, 기온을 기록하는 actor가 있다고 합시다.

```swift
actor TemperatureLogger {
    let label: String
    var measurements: [Int]
    private(set) var max: Int

    init(label: String, measurement: Int) {
        self.label = label
        self.measurements = [measurement]
        self.max = measurement
    }
}
```

`TemperatureLogger` actor는 외부에서 접근 가능한 프로퍼티 `label`과 `measurements`를 가지고 있고 `max`와 같이 actor 내부에서만 접근하여 수정가능한 프로퍼티가 있습니다. 

이제 class와 structure과 같은 initializer를 이용해 actor 인스턴스를 생성합니다. Actor의 프로퍼티와 메소드에 접근할 땐, `await` 키워드를 이용하여 정지할 포인트를 표시합니다.

```swift
let logger = TemperatureLogger(label: "Outdoors", measurement: 25)
print(await logger.max)
// Prints "25"
```

예제에서는, `logger.max`부분에 정지하도록 했습니다. 왜냐하면 actor는 한번에 하나의 Task만이 이 값에 접근가능하도록 해야하기 때문입니다. 만약 다른 Task가 이미 logger와 상호작용하고 있다면, 이 코드는 프로퍼티에 접근 가능할 때까지 기다립니다. 

반대로, Actor내부의 코드는 `await`키워드를 사용해서 Actor 프로퍼티에 접근하지 않습니다. 예를 들어, 기온을 새로 업데이트하는 메소드가 있다고 합시다.

```swift
extension TemperatureLogger {
    func update(with measurement: Int) {
        measurements.append(measurement)
        if measurement > max {
            max = measurement
        }
    }
}
```

`update(with:)`메소드는 이미 actor에 있기 때문에, `await`키워드를 사용해 `max` 프로퍼티에 않아도 됩니다. 이 메소드는 왜 Actor가 한번에 하나의 Task만이 접근가능하게 하는 지에 대해서도 알려줍니다. 1번 Task는 `measurements`프로퍼티에 새로운 기온을 저장하고 최고 기온을 업데이트하는 작업입니다. 1번 Task가 실행하는 도중, `measurements`프로퍼티만 새로 업데이트가 되었을 때, 2번 Task에서 `max`프로퍼티에 접근해 읽는 상황이 있다고 합시다. 그리고 1번 Task가 마무리되어, 새로운 `max`프로퍼티를 갱신했다면, 1번 Task와 2번 Task는 다른 `max`프로퍼티를 가지게 된 상황이 생길뿐더러, 2번 Task는 유효하지 않은 최고 기온값을 가지게 됩니다. 이 문제를 예방하기 위해 actor는 한번에 하나의 Task를 허용해줍니다. `update(with:)`메소드는 그 어떤 정지 포인트(suspension point)를 가지고 있지 않기 때문에, 그 어떤 코드도 업데이트 도중 데이터에 접근할 수 없습니다. (만일 `await`를 가지고 있다면 업데이트도 중간에 멈출 것이고, actor는 다른 Task한테 열린 상태가 될 것입니다. - 추측)

만약 actor외부에서 아래와 같이 프로퍼티에 접근한다면, 컴파일 타임 에러가 납니다.

```swift
print(logger.max)  // Error ☠️
```

Swift는 Actor내부의 코드만이 Actor의 지역변수에 바로 접근을 보장합니다. 이것을 *actor isolation*이라고도 합니다. (용어가 중요한가?라고 할 수 있지만 나중에 언제 나올지 모르니 알아는 두자. 까먹을 수 있으니 종종 읽어보자)

> actor isoliation: swift가 actor외부에서 actor 내부 지역변수에 바로 접근이 불가능하고 내부에서만 접근이 가능한 것을 보장하는 상황 (외부에서 접근하기 위해선 await키워드를 추가해야 한다.)

### Sendable Types

라는 것도 있는데 2022-09-12 가장 최근에 문서에 추가되었습니다. 이것은 위 프로퍼티와 메소들에 대해 더 공부해보고 다시 읽어보려고 합니다!

<br />





- https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html
- https://docs.swift.org/swift-book/RevisionHistory/RevisionHistory.html
- https://tech.devsisters.com/posts/crunchy-concurrency-swift/
