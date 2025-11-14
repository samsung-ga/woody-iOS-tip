### Today I Learned

----

2022.10.14 (금)



### Tuist 빌드 시 오류 발생한 라이브러리 

- [FlexLayout](https://github.com/layoutBox/FlexLayout)
  - SPM으로 설정시 "Not Found "yoga.m" 오류 발생
  - 원인을 찾을 수 없었기 때문에 Carthage로 변경 -> 해결 

- [PlinLayout](https://github.com/layoutBox/PinLayout)

  - PinLayout 라이브러리 경로를 찾지 못함

  ```bash
  # 캐시처리가 되었지만 라이브리러를 다운받지 않은 상태에서 캐시처리가 되었기 때문에 에러 발생하여 Dependencies 삭제하고 빌드함 
  $ rm -rf Tuist/Dependencies
  $ tuist fetch
  ```

  - Carthage로 빌드시 projphx 파일을 찾을 수 없다는 오류를 만남 

  ```bash
  # PinLayout에서 해당 폴더를 빌드하기 때문에 에러 발생하여, TestProjects를 삭제하고 Carthage를 이용하여 PinLayout를 빌드함.
  $ rm -rf Tuist/Dependencies/Carthage/Checkouts/PinLayout/TestProjects
  $ carthage build PinLayout --project-directory Tuist/Dependencies --platform iOS --use-xcframeworks --no-use-binaries --use-netrc --cache-builds --verbose
  
  # 계속 서드파티 라이브러리를 빌드함
  $ tuist fetch
  ```



### 기본적인 오류 해결 

```bash
$ tuist clean
$ tuist fetch
$ tuist generate
```



### 참고 

- https://github.com/minsOne/iOSApplicationTemplate
- https://github.com/layoutBox/FlexLayout
- https://github.com/layoutBox/PinLayout