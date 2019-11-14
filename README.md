# IOS 앱 구성도
- 전체적으로 RxSwift를 통해 데이터 흐름에서 변형을 감지하여 동작하는 방식으로 구현
- VC에 과도한 코드 작성을 피할 수 있는 구조

## ViewController
- 유저인터페이스 구현 (UI Control과 이벤트 전달 역할)
- ViewModel에게 이벤트 전달

## ViewModel
- ViewController에서 전달받은 이벤트에 대해 Model을 거칠지 거치지 않을지 판단
- Model을 변환하여 ViewController에 보여질 ViewData에 대한 로직 구현

## Model
- 앱의 메인 데이터
- Model에 대한 변환 로직 구현
- ViewModel에게 변환 이벤트 전달

## Router
- DefaultRouter를 통해 기초동작 설정
- 화면전환 요청에 대한 로직 구현

## API
- RxSwift Request(Network)
- Response 데이터
- JSON Fetcher

## Extension
- String (Query문 파싱 함수)


