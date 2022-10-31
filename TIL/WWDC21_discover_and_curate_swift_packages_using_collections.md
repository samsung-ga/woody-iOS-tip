# Discover and curate Swift Packages using collections



- [New "Add Package"  Workflow](#new-add-package-workflow)
- [Using Collections](#using-collections)
- [Creating Collection](#creating-collection)
  - [Signing key와 certificate 만들기](#signing-key와-certificate-만들기)



## New Add Package Workflow

Xcode13부터 Swift package를 쉽게 추가하는 방법이 생겼습니다. <br />

1. Numerics 모듈이 추가되지 않은 프로젝트 파일에 import한다면 아래와 같이 오류가 납니다. 

<img width="960" alt="스크린샷 2022-10-02 오후 11 38 07" src="https://user-images.githubusercontent.com/56102421/193465950-b0ea6426-22fc-46c8-8321-ebaeb22e12ca.png">

2. Search 버튼을 누르면 swift-numerics 패키지를 추가하는 플로우로 이동합니다.

<img width="1082" alt="스크린샷 2022-10-02 오후 11 40 07" src="https://user-images.githubusercontent.com/56102421/193465968-8f652ad6-a236-4f35-a47b-6bfa717691b9.png">

3. 이곳에서는 많은 정보를 확인할 수 있습니다. 최신 버전, 만든 이, 저작권, 리드미 등등.. <br />또한 Release History에서 릴리즈 노트까지 확인 가능합니다.  

4. Add Packages 버튼을 클릭하면 xcode가 해당 버전에 대한 선택 가능한 프로덕트를 제공합니다. 원하는 프로덕트를 선택하고 타겟에  추가합니다. 

<img width="1081" alt="스크린샷 2022-10-02 오후 11 45 54" src="https://user-images.githubusercontent.com/56102421/193465970-7ea2cab2-7c2d-4731-9662-a00c76a7f4e3.png">

5. 추가된 Package는 2곳에서 확인이 가능합니다. 

- Project 선택 -> Swift Packages Tab에서 확인 (현재 Xcode 14.0.1에선 Package Depedency 탭입니다.) 
- Target 선택 -> Frameworks, Libraries, and Embedded Content phase에서 확인 



## Using Collections

Collections는 HTTPS 통신으로 받아오는 JSON 파일입니다. package URL 리스트, 메타데이터(서머리, 패키지 버전에 관한 자세한 정보)를 포함하고 있습니다. 아래 사진은 collection의 JSON의 일부입니다. 리드미 URL, 서머리(요약), 패키지 URL, 그리고 버전에 관한 정보들이 있는 것을 확인할 수 있습니다.

<img width="700" alt="스크린샷 2022-10-02 오후 11 56 02" src="https://user-images.githubusercontent.com/56102421/193465973-6a14a92f-b157-40ff-beee-9d37bc3deafa.png">

Swift Package Manager(SwiftPM)는 이 collectino을 캐싱해놓고 맥에서 사용할 수 있도록 관리합니다. 즉, 버전 관리 툴입니다. 



## Creating Collection

[swift package collection generator](https://github.com/apple/swift-package-collection-generator)에 가서 클론 받고 자신의 collection을 만들 수 있습니다. 이 툴은 collection을 생성하는데 필요한 정보들을 자동으로 모아주고 항상 모든 output을 최신 버전으로 생성해줍니다. 이 툴은 패키지 URL들로 작성된 JSON 파일을 인풋으로 받습니다. collection에 서명하는 툴도 있습니다. 서명하는 것은 옵셔널이긴 하지만, 작성자를 확인할 수 있고, collection의 무결성을 보호할 수 있습니다.

아래는 collection을 만들기 위해 필요한 input JSON파일입니다. 약간의 메타 정보를 필요로 합니다. 이름, 키워드, 오버뷰, 작성자에 대한 정보. 모두 Xcode에 collection이 추가될 때 보여질 정보들입니다. 여기서 가장 중요한 것은 package URL입니다.

<img width="1024" alt="스크린샷 2022-10-03 오전 12 22 39" src="https://user-images.githubusercontent.com/56102421/193465977-cb1f04e3-adff-472d-b011-fcd8724a3da4.png">

이 정보뿐만 아니라 package에 대한 추가 메타 데이터도 작성이 가능합니다.

<img width="800" alt="스크린샷 2022-10-03 오전 12 29 52" src="https://user-images.githubusercontent.com/56102421/193466018-fd16fd36-06b5-4367-a08f-e3a720cfee06.png">

<br />

Collection을 생성하는 과정은 아래와 같습니다. 

1. generator가 input.json 파일을 통해 collection.json 파일을 만듭니다.
2. Signing key와 Certificate를 추가하여 collection에 서명을 합니다. (옵셔널)
   - 만일 서명한다면 무기한 서명 collection입니다. 만료되지 않습니다.
3. 서명된 collection, 또는 서명되지 않은 collection을 배포합니다. (웹서버에 등록, 혹은 바로 추출)

<img width="1658" alt="스크린샷 2022-10-03 오전 12 29 02" src="https://user-images.githubusercontent.com/56102421/193466014-97856a99-2f8a-4998-b960-b93a691e739e.png">

certificate, Signing key 그리고 input.json 모두 준비가 되었고, generator까지 다운로드 받았으면 해당 루트 디렉토리에서 아래 명령어를  실행합니다.

```swift
// collection.json 생성하기
package-collection-generate input.json collection.json --verbose --auth-token [깃헙토큰]

// collection-signed.json 생성하기 (서명)
package-collection-sign collection.json collection-signed.json developer-key.pem developer-cert.cer
```

그리고 collection을 웹 서버에 올려주고 해당 URL을 이용하여 swift package-collection에 추가합니다. (참고로 저는 Github에 올렸습니다.)

```swift
swift package-collection list
swift package-collection add https://raw.githubusercontent.com/wody-d/spm-collections/main/collection.json
swift package-collection refresh
swift package-collection search --keywords wwdc21

swift package-collection remove https://raw.githubusercontent.com/wody-d/spm-collections/main/collection.json
```

<img width="1087" alt="스크린샷 2022-10-03 오전 1 50 31" src="https://user-images.githubusercontent.com/56102421/193466063-67b667a5-2448-42c9-8bdf-da8479e19351.png">



### cf1) Signing key와 certificate 만들기

2가지를 만들기 위해서는 애플 개밝자 계정이 있어야 합니다. 먼저 키체인 접근에서 인증서 지원 -> 인증 기관에서 인증서 요청을 누르고 `CertificateSigningRequest.certSigningRequest` 파일을 생성합니다. 이때 해당 파일을 더블 클릭한 후, 이메일을 체크하고 디스크에 저장 옵션을 선택한 후 계속 버튼을 눌러 파일을 생성합니다. 

생성된 파일을 [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)에 가서 Certificates 옆에 + 버튼을 누르고 Swift Package Collection Certificate 옵션을 선택한 후 다음 버튼을 누릅니다. 미리 생성해둔 certSigningRequest 파일을 넣고 다음 버튼을 누릅니다. Certificate가 생성되면 다운로드합니다. 생성된 Certificate를 더블 클릭한 후 로컬 키체인에 등록합니다. 키체인 접근에서 등록된 certificate을 오른쪽 클릭한 후 내보내기를 선택합니다. p12파일로 비밀번호를 입력한 후 내보내기를 누릅니다. 해당 파일을 아래와 같은 명령어를 입력하면 private key(pem키)를 얻을 수 있습니다.

```bash
openssl pkcs12 -nocerts -in developer-key.p12 -out developer-key.pem && openssl rsa -in developer-key.pem -out developer-key.pem
```



<br />

- https://developer.apple.com/videos/play/wwdc2021/10197/
- https://theswiftdev.com/how-to-create-a-swift-package-collection/
