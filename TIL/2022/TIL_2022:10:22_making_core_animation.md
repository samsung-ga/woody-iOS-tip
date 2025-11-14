### Today I Learned 

----

2022.10.22 (토)



오늘의 애니메이션은 아직 성공하지 못했습니다. ㅠ 거의 80%가량 성공한 것 같은데 매끄럽게 이어지지가 않아서 좀 더 손봐야할 것 같아요. 공부한 내용은 [블로그](https://wodyios.tistory.com/72?category=897235)에 작성했습니다. (연습이었을 뿐 진짜 구현할 애니메이션은 아니에요.) 

`KeyFrameAnimation` 클래스의 프로퍼티들을 살펴보게 되었습니다. `fillMode` / `keyTimes` / `timeOFfset` 등등.. 애니메이션 시간과 관련된 프로퍼티들이 많아서 Core Animation의 시간과 관련된 문서를 읽어봤습니다. 근데 이 내용이 조금 어렵고 복잡해서 전부는 이해하진 못했지만 내일도 읽어봐서 되도록 다 이해해야 할 것 같습니당

----



### KeyframeAnimation

- `values` : An array of objects that specify the keyframe values to use for the animation.
  애니메이션에 사용될 keyframe 값들을 지정해줍니다. `CAKeyframeAnimation`에서 애니메이션을 주기 위해서 꼭 필요한 값입니다. 이 값은 `path` 프로퍼티가 nil일 때만 사용가능합니다! 동시에 사용하면 X. 
- `keyTimes` : An optional array of `NSNumber` objects that define the time at which to apply a given keyframe segment.
  0~1 사이의 숫자로 이루어진 배열입니다. 위에서 준 values를 언제 애니메이션을 줄 지 타이밍과 관련된 요소입니다.  `values`의 배열과 같은 개수를 가지거나 `path` 프로퍼티의 control point와 개수가 같아야 의도대로 동작합니다. 
  이 값은 `calucationMode` 프로퍼티와 연관이 깊습니다. `calucationMode`가 linear, cubic이라면, 위의 규칙과 일치해야합니다. (개수가 같아야함. 처음과 마지막 값은 0과 1) 만약 discrete이라면 개수보다 하나가 더 많아야합니다. cubicPaced 또는 paced라면 이 프로피터는 무시됩니다. 이 규칙을 지키지 않을 경우에도 이 프로퍼티는 무시됩니다. 

- `fillMode` : Determines if the receiver’s presentation is frozen or removed once its active duration has completed.
  애니메이션의 움직임이 끝났을 때, 해당 레이어의 프레젠테이션, 즉 보여지는 것은 멈추거나 혹은 제거되거나 혹은 남아있거나를 정해주는 프로퍼티입니다. backwards, forwards, removed, both가 있는데 이것도 CAMediaTiming 프로토콜과 관련이 있습니다.

>  CAMediaTiming 프로토콜은 애니메이션을 주는데 정말 중요한 요소구나

- `isRemovedOnCompletion` : Determines if the animation is removed from the target layer’s animations upon completion.
  애니메이션의 움직임이 끝났을 때 해당 애니메이션을 레이어에서 제거할 것인지 말것인지에 대한 여부입니다.

> 애니메이션이 끝나고 해당 위치를 유지하고 싶은 경우 애니메이션을 지우지않고(isRemovedOnCompletion = false), fillMode를 forwards로 설정하면 된다.

- `isAdditive` : Determines if the value specified by the animation is added to the current render tree value to produce the new render tree value.
  현재 위치 기준에서 애니메이션 할 건지 안할 건지에 대한 여부입니다. 현재 레이어 렌더 트리에 새로운 렌더트리 값을 생성해서 추가합니다. 

- `timeOffset` : Specifies an additional time offset in active local time. 
  현재 애니메이션이 실행되고 있는 시간에 추가 시간을 더하는 것입니다. 만약 position을 0에서 10으로 이동시키는 애니메이션이 있다고 가정하면 timeOffset이 4초라고 하면 4 -> 10 -> 0 -> 4로 이동합니다. 즉, 4에서부터 애니메이션이 시작합니다. 

- `beginTime` : Specifies the begin time of the receiver in relation to its parent object, if applicable.

  애니메이션 시작 시간

### CAMediaTiming

절대적인 시간은 단위 "초"로 계산됩니다. [`CACurrentMediaTime()`](https://developer.apple.com/documentation/quartzcore/1395996-cacurrentmediatime)는 절대적인 현재 시각을 쉽게 가져올 수 있습니다. 부모의 시간에서 지역 시간 (from parent time to local tiem)으로 변환하는 과정은 두 단계가 있습니다. 

1. "active local time"으로 변환
2. "active local time"에서 "basic local time"으로 변환 

1번 단계에서는 현재 객체가 부모 객체의 시간 속에서 어디에 나타날 지 포인트를 알 수 있습니다. 그리고 두번째 단계에서는 타이밍 모델은 해당 애니메이션을 반복할 수 있고, 뒤로 되돌릴 수 있도록 도와줍니다. 

> 여기까지 문서를 읽어보면 정확하게 어떤 건지 감이 오지는 않지만, 대략적으로 어떻게 작동할 건지는 감이 옵니다. 
> Timing 또한 뷰계층처럼 계층으로 이루어져있고 frame과 bound처럼 부모와의 상대적인 시간과 나의 절대적인 시간이 있다고 이해할 수 있습니다. 
> 그래서 [Customizing the Timing of an Animation](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/AdvancedAnimationTricks/AdvancedAnimationTricks.html#//apple_ref/doc/uid/TP40004514-CH8-SW1) 문서를 읽어봤습니다.

위에서 이해한대로, 각 레이어는 각자의 로컬 시간을 가지고 있고, 각각의 시간 차이는 유저가 차이를 느끼지 못할 정도로 작습니다. 만약, 레이어의 [속도](https://developer.apple.com/documentation/quartzcore/camediatiming/1427647-speed)를 변경하게 된다면 애니메이션의 duration도 변경될 것이고 다른 레이어와 다르게 작동하겠죠.

> 만일 속도=0이면? 그냥 애니메이션이 작동안할 것 같습니다. 

CAKeyframeAnimation 문서에서 `beginTime` 프로퍼티에 대한 설명을 읽었을 때는 잘 이해가 되지 않았었는데.. 여기서도 설명이 나와있습니다. `beginTime` 프로퍼티는 애니메이션을 시작 시각을 지정하기 위해서 사용합니다. 애니메이션 두가지를 연달아 이용하기 위해서는 한개의 애니메이션이 끝나는 시간을 다른 하나의 애니메이션의 시작시간으로 설정하면 됩니다. 결국 beginTime도 절대시간인 것 같습니다.