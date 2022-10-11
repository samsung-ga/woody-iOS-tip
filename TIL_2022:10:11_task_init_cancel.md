### Today I Learned

----

2022.10.11 (화)

<br />

<br />

### Task

Task 인스턴스를 생성할 때, 실행할 작업이 포함될 클로저가 제공됩니다. Task는 생성 즉시 실행되며 개발자가 직접 실행하거나 스케쥴링하지 않아도 됩니다. Task 인스턴스를 생성한 후엔, 해당 Task 인스턴스와 상호작용할 수 있습니다. Task에 대한 레퍼런스만 들고 있다면 ~~Task는 실행되지만~~Task에 대한 상호작용이 가능하지만, 만약 레퍼런스를 버린다면, 상호작용이 불가능합니다. (Task의 결과를 받고 취소할 수 없습니다.)

Swift는 현재(current) Task에서 분리된 작업이나 하위 작업을 지원하기 위해 `yield()`클래스 메소드를 지원합니다. 이 메소드는 비동기식이기 때문에 항상 기존 Task에서 호출됩니다. 기존 Task의 일부로 실행되는 코드에서만 해당 Task와 상호작용할 수 있습니다. 해당 Task에서 기존 Task와 상호작용하려면 Task의 static method를 호출해야합니다.

> 이 말은 이해가 되지 않았지만, 현재 이해한 바로는 Task A와 A에서 파생된 B,C Task가 있다고 한다면, B와 C는 무조건 Task A 내부에서 사용해야 하고, B, C에서 Task A와 상호작용하고 싶다면 static method를 호출해야한다고 이해했습니다.

Task의 실행은 Task가 실행되는 진행도라고 볼 수 있습니다. 이 진행도는 Task가 중단되거나 완료될 때 종료됩니다. 이 진행도는 `PartialAsyncTask`의 인스턴스로 표시됩니다. 사용자 지정 실행자를 구현하지 않는 한, `PartialAsyncTask`와는 상호작용할 수 없습니다.

> 여기까지는 개념 설명이고, Task가 언제 사용되는지, 이 시점이 가장 궁금했습니다. 
> Task를 개발자가 명시적으로 사용하는 곳은 동시성을 지원하지 않는 환경에서 비동기함수를 부르고 싶을 때 사용합니다.
> 즉, Task는 concurrency 환경을 제공해줍니다.

### Task Cancellation

Task는 Cancellation을 나타내는 공유 매커니즘은 있지만 Cancellation을 처리하는 방법은 공유하지 않습니다. 즉, Task마다 작업을 중지하는 방법은 다릅니다. 마찬가지로, Task가 필요한 부분에 Cancellation 여부를 확인해야합니다. 긴 작업의 경우 여러 지점에서 Cancellation을 확인하고 각 지점마다 다르게 처리할 수 있습니다. 취소 여부를 확인하는 방법엔 2가지가 있습니다. 

첫 번째로, `Task.checkCancellation()` 함수를 호출하여 취소 여부를 확인할 수 있습니다. 취소에 대한 다른 응답으로는, 지금까지 완료한 작업을 반환하거나 빈 결과를 반환 혹은 0 반환이 있습니다.

두 번째로, `Cancellation`입니다. 이 프로퍼티는 Bool 타입으로 취소 사유와 같은 추가 정보를 포함할 수 없습니다. 

### Task 초기화하기

1. `init(priority: TaskPriority?, operation: () async -> Success)` 

우선수위는 옵셔널이므로 수행할 작업을 클로저형태로 받습니다. 

```swift
let readTask = Task {
    return "Star Link"
}

print(await readTask.value)
// Star Link
```

2. `init(priority: TaskPriority?, operation: () async throws-> Success)`

수행할 작업이 에러를 던질 수도 있습니다. 

```swift
enum ReadError: Error {
    case cantread
}
let readTask = Task {

    throw ReadError.cantread
}

do {
    print(try await readTask.value)
} catch {
    print("Read task failed with error: \(error)")
}
// Basic task failed with error: cantread
```

> 여기서 중요한 점은, Task는 생성 즉시 실행된다는 점입니다. 아래와 같이 작성해도 출력이 됩니다. 다시 말해, Task는 따로 실행시킬 필요가 없습니다.
>
> ```swift
> let readTask = Task {
>     print("readTask")
>     return "Star Link"
> }
> // readTask
> ```

### Task 사용하기 

위에서도 설명하긴 했지만 동시성을 지원하지 않는 환경에서 비동기함수를 부르고 싶을 때 사용합니다. 아래 예시에서는 `executeTask()`비동기 함수는 `onAppear`메소드 내에서 호출되어야 하는 상황이지만, `onAppear`는 동시성을 지원하지 않는 modifier라 바로 호출하게 되면 컴파일 오류가 납니다. 이 때 `Task`를 통해 동시성 환경을 제공합니다.

```swift
var body: some View {
    Text("Hello, world!")
        .padding()
        .onAppear {
            Task {
                await executeTask()
            }
        }
}

func executeTask() async {
    let basicTask = Task {
        return "This is the result of the task"
    }
    print(await basicTask.value)
}
The task creates a concurre
```

⛔️ 하지만 이곳에서 중요한 점이 있습니다. Task는 레퍼런스를 들고 있어야 한다고 방금 문서에서 읽었습니다. 레퍼런스를 들고 있지 않는다면, Task의 결과와 Task의 취소 작업을 할 수 없다고 했습니다. 그런데 위에서는 Task 인스턴스에 대한 레퍼런스를 가지고 있지 않습니다. Combine의 경우도 생각해보면, Publisher 구독은 값이 방출되기 전까지 강한 레퍼런스 참조를 유지해야합니다. 그런데 Task는 대체 무슨 일? 

Task는 레퍼런스를 가지고 있든 가지고 있지 않든 상관없이 무조건 작동합니다. 레퍼런스를 가지고 있는 이유는 오직 결과를 기다리고 작업을 취소하는 기회를 가지기 위해서입니다.

### Task Cancellation 해보기 

아래 예제는 splash에서 랜덤이미지를 가져옵니다.

```swift
struct ContentView: View {
    @State var image: UIImage?

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
            } else {
                Text("Loading...")
            }
        }.onAppear {
            Task {
                do {
                    image = try await fetchImage()
                } catch {
                    print("Image loading failed: \(error)")
                }
            }
        }
    }

    func fetchImage() async throws -> UIImage? {
        let imageTask = Task { () -> UIImage? in
            let imageURL = URL(string: "https://source.unsplash.com/random")!
            print("Starting network request...")
            let (imageData, _) = try await URLSession.shared.data(from: imageURL)
            return UIImage(data: imageData)
        }
        return try await imageTask.value
    }
}
```

랜덤 이미지를 불러오기 요청을 보내는 Task를 생성하자마자 바로 취소해보겠습니다. 

```swift
func fetchImage() async throws -> UIImage? {
    let imageTask = Task { () -> UIImage? in
        let imageURL = URL(string: "https://source.unsplash.com/random")!
        print("Starting network request...")
        let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        return UIImage(data: imageData)
    }
    imageTask.cancel() // ✅
    return try await imageTask.value
}

// Starting network request...
// Image loading failed: Error Domain=NSURLErrorDomain Code=-999 "cancelled"

```

Task를 취소했지만 위와 같이 프린트가 찍힙니다. 그 이유는 Task가 생성 즉시 실행되고, 실행되는 도중, 취소되어버려 이미지를 불러오지 못한 상황입니다. 

>  만약 정말 빠르게 API가 동작한다면 imageData를 불러와서 UI에 랜덤이미지가 렌더링됐을 것입니다.

위의 취소 예제에서는 어떤 시점에서 취소체크가 일어나는 지 정확하지 않습니다. (print문을 통해 어느시점인지 대략적으로는 알 수 있습니다.)
하지만 취소를 체크할 수 있는 static method를 통해 취소되는 시점을 지정할 수 있습니다. 첫 번째 메소드는 `Task.checkCancellation()`입니다.

```swift
let imageTask = Task { () -> UIImage? in
    let imageURL = URL(string: "https://source.unsplash.com/random")!

    try Task.checkCancellation() // ✅

    print("Starting network request...")
    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
    return UIImage(data: imageData)
}
imageTask.cancel()

// Image loading failed: CancellationError()
```

다른 방법은, `Task.isCancalled` 프로퍼티를 통해 확인하는 것입니다. 

```swift
let imageTask = Task { () -> UIImage? in
    let imageURL = URL(string: "https://source.unsplash.com/random")!

    guard Task.isCancelled == false else {
        // Perform clean up
        print("Image request was cancelled")
        return nil
    }

    print("Starting network request...")
    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
    return UIImage(data: imageData)
}
// Cancel the image request right away:
imageTask.cancel()

```

사실 여기까지 보았을 때, 왜 취소체크 메소드와 프로퍼티를 통해 취소 여부를 확인하는지 이해가지 않습니다. Task의 다음 코드가 실행되기 전에 취소여부를 확인하는 절차가 없어도 그 시점에 취소가 되면 자동으로 Task가 취소가 되는 것이 아닌가? 이해가 되지는 않지만 사용해보면서 이해가 되면 다시 돌아와야겠습니다.

<br />



### Ref 

- https://developer.apple.com/documentation/swift/task
- https://www.avanderlee.com/concurrency/tasks/

<br />




### 질문

- Task 취소 체크가 왜 필요한가? 
  아래 2가지를 비교해보았을 때, 왜 다르게 동작하는 지 잘 이해가 가지 않는다. 실행되는 스레드의 속도에 따라서 매번 다른 결과가 나오지 않을까? (실제로 돌려보았을 때는 항상 아래 print문의 결과가 나옴) 위나 아래나 cancel되는 시점에 이미 Task는 수행되고 있지 않나? 왜 저렇게 다르게 나오지..

```swift
let imageTask = Task { () -> UIImage? in
    let imageURL = URL(string: "https://source.unsplash.com/random")!
    print("네트워크 요청 시작..")
    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
    print("이미지 데이터 받아옴..")
    return UIImage(data: imageData)
}
imageTask.cancel()

// print문
// "네트워크 요청 시작..
```

```swift
let imageTask = Task { () -> UIImage? in
    let imageURL = URL(string: "https://source.unsplash.com/random")!

    try Task.checkCancellation() // ✅

    print("Starting network request...")
    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
    return UIImage(data: imageData)
}
imageTask.cancel()

// print문
// X
```

