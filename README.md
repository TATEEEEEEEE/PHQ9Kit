# PHQ9Kit
PHQ-9 depression screening and scoring.

## Features

- Standard PHQ-9 scoring

- Nine questions scored from 0 to 3

- Total score from 0 to 27

- Minimal, mild, moderate, moderately severe, and severe classifications

- Separate item 9 follow-up signal

- English and Simplified Chinese support

- Reusable SwiftUI questionnaire view

- Swift Testing unit tests

## Requirements

- iOS 17 or later

- macOS 14 or later

- Swift 6.4 or later

## Installation

In Xcode:

1. Open your project.

2. Select **File → Add Package Dependencies…**

3. Enter this repository URL.

4. Select the version you want to use.

5. Add `PHQ9Kit` to your app target.

## Scoring

```swift

import PHQ9Kit

let responses: [PHQ9Response] = [

    .notAtAll,

    .severalDays,

    .notAtAll,

    .moreThanHalfTheDays,

    .notAtAll,

    .severalDays,

    .notAtAll,

    .notAtAll,

    .notAtAll

]

let result = try PHQ9Scorer.score(responses)

print(result.totalScore)

print(result.severity)

print(result.item9Positive)

```

## SwiftUI

```swift

import SwiftUI

import PHQ9Kit

struct ContentView: View {

    var body: some View {

        PHQ9QuestionnaireView(

            language: .english,

            accentColor: .blue

        ) { result in

            print(result.totalScore)

            print(result.severity)

            print(result.item9Positive)

        }

    }

}

```

## Simplified Chinese

```swift

PHQ9QuestionnaireView(

    language: .simplifiedChinese

) { result in

    print(result.totalScore)

    print(result.severity)

    print(result.item9Positive)

}

```

## Severity

| Score | Severity |
|------:|----------|
| 0–4 | Minimal |
| 5–9 | Mild |
| 10–14 | Moderate |
| 15–19 | Moderately severe |
| 20–27 | Severe |

## Item 9

`item9Positive` becomes `true` when the response to item 9 is anything other than `notAtAll`.

This value indicates that appropriate follow-up may be needed. It does not determine immediate risk by itself.

## Important Notice

PHQ-9 is a screening instrument and does not by itself establish a clinical diagnosis.

Applications using this package should provide appropriate context, privacy protections, and professional follow-up guidance.

## License

The source code in this repository is available under the MIT License.
