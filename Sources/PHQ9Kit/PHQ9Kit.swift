import Foundation
import SwiftUI

// MARK: - Core model

/// A response to one PHQ-9 item.
public enum PHQ9Response: Int, CaseIterable, Codable, Sendable, Identifiable {
    case notAtAll = 0
    case severalDays = 1
    case moreThanHalfTheDays = 2
    case nearlyEveryDay = 3

    public var id: Int { rawValue }
}

/// Standard PHQ-9 symptom-severity bands.
public enum PHQ9Severity: String, Codable, Sendable, CaseIterable {
    case minimal
    case mild
    case moderate
    case moderatelySevere
    case severe
}

/// The result of scoring nine PHQ-9 responses.
public struct PHQ9Result: Equatable, Codable, Sendable {
    public let totalScore: Int
    public let severity: PHQ9Severity

    /// `true` when item 9 is answered with anything other than “Not at all”.
    /// This is a follow-up signal, not an assessment of immediate danger.
    public let item9Positive: Bool

    public init(totalScore: Int, severity: PHQ9Severity, item9Positive: Bool) {
        self.totalScore = totalScore
        self.severity = severity
        self.item9Positive = item9Positive
    }
}

public enum PHQ9Error: Error, Equatable, Sendable {
    case invalidResponseCount(expected: Int, actual: Int)
}

/// Scores a complete set of nine PHQ-9 responses.
public enum PHQ9Scorer {
    public static let itemCount = 9
    public static let minimumScore = 0
    public static let maximumScore = 27

    public static func score(_ responses: [PHQ9Response]) throws -> PHQ9Result {
        guard responses.count == itemCount else {
            throw PHQ9Error.invalidResponseCount(
                expected: itemCount,
                actual: responses.count
            )
        }

        let total = responses.reduce(0) { $0 + $1.rawValue }

        return PHQ9Result(
            totalScore: total,
            severity: severity(for: total),
            item9Positive: responses[8] != .notAtAll
        )
    }

    public static func severity(for score: Int) -> PHQ9Severity {
        switch score {
        case ...4:
            return .minimal
        case 5...9:
            return .mild
        case 10...14:
            return .moderate
        case 15...19:
            return .moderatelySevere
        default:
            return .severe
        }
    }
}

// MARK: - Questionnaire content

public enum PHQ9Language: String, Codable, Sendable, CaseIterable {
    case english
    case simplifiedChinese
}

public struct PHQ9Item: Identifiable, Equatable, Codable, Sendable {
    public let id: Int
    public let englishText: String
    public let simplifiedChineseText: String

    public init(id: Int, englishText: String, simplifiedChineseText: String) {
        self.id = id
        self.englishText = englishText
        self.simplifiedChineseText = simplifiedChineseText
    }

    public func text(for language: PHQ9Language) -> String {
        switch language {
        case .english:
            return englishText
        case .simplifiedChinese:
            return simplifiedChineseText
        }
    }
}

public enum PHQ9Questionnaire {
    public static let items: [PHQ9Item] = [
        PHQ9Item(id: 1, englishText: "Little interest or pleasure in doing things.", simplifiedChineseText: "做事时提不起劲或没有兴趣。"),
        PHQ9Item(id: 2, englishText: "Feeling down, depressed, or hopeless.", simplifiedChineseText: "感到心情低落、沮丧或绝望。"),
        PHQ9Item(id: 3, englishText: "Trouble falling or staying asleep, or sleeping too much.", simplifiedChineseText: "入睡困难、睡不安稳，或睡得过多。"),
        PHQ9Item(id: 4, englishText: "Feeling tired or having little energy.", simplifiedChineseText: "感到疲倦或没有活力。"),
        PHQ9Item(id: 5, englishText: "Poor appetite or overeating.", simplifiedChineseText: "食欲不振或吃得过多。"),
        PHQ9Item(id: 6, englishText: "Feeling bad about yourself, or that you are a failure or have let yourself or your family down.", simplifiedChineseText: "觉得自己很糟、很失败，或让自己或家人失望。"),
        PHQ9Item(id: 7, englishText: "Trouble concentrating, such as when reading or watching television.", simplifiedChineseText: "难以集中注意力，例如阅读或看电视时。"),
        PHQ9Item(id: 8, englishText: "Moving or speaking so slowly that other people could have noticed, or being unusually restless.", simplifiedChineseText: "动作或说话慢到别人可能察觉，或相反地烦躁、动来动去。"),
        PHQ9Item(id: 9, englishText: "Thoughts that you would be better off dead or of hurting yourself in some way.", simplifiedChineseText: "出现过不如死去或以某种方式伤害自己的念头。")
    ]

    public static func responseLabel(
        for response: PHQ9Response,
        language: PHQ9Language
    ) -> String {
        switch (response, language) {
        case (.notAtAll, .english): return "Not at all"
        case (.severalDays, .english): return "Several days"
        case (.moreThanHalfTheDays, .english): return "More than half the days"
        case (.nearlyEveryDay, .english): return "Nearly every day"
        case (.notAtAll, .simplifiedChinese): return "完全没有"
        case (.severalDays, .simplifiedChinese): return "有几天"
        case (.moreThanHalfTheDays, .simplifiedChinese): return "一半以上时间"
        case (.nearlyEveryDay, .simplifiedChinese): return "几乎每天"
        }
    }
}

// MARK: - SwiftUI questionnaire

/// A reusable PHQ-9 questionnaire view.
///
/// The view returns a `PHQ9Result` through `onComplete`. PHQ-9 is a screening
/// instrument and does not by itself establish a diagnosis.
public struct PHQ9QuestionnaireView: View {
    private let language: PHQ9Language
    private let accentColor: Color
    private let onComplete: (PHQ9Result) -> Void

    @State private var currentIndex = 0
    @State private var responses: [PHQ9Response?] = Array(
        repeating: nil,
        count: PHQ9Scorer.itemCount
    )

    public init(
        language: PHQ9Language = .english,
        accentColor: Color = .blue,
        onComplete: @escaping (PHQ9Result) -> Void
    ) {
        self.language = language
        self.accentColor = accentColor
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: 24) {
            header
            questionCard
            navigationButtons
            disclaimer
        }
        .padding()
        .animation(.easeInOut(duration: 0.25), value: currentIndex)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(language == .english ? "PHQ-9" : "PHQ-9 抑郁筛查")
                .font(.largeTitle.bold())

            Text(language == .english ? "Over the last two weeks" : "请根据过去两周的情况作答")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(
                value: Double(currentIndex + 1),
                total: Double(PHQ9Scorer.itemCount)
            )
            .tint(accentColor)
        }
    }

    private var questionCard: some View {
        let item = PHQ9Questionnaire.items[currentIndex]

        return VStack(alignment: .leading, spacing: 18) {
            Text("\(currentIndex + 1) / \(PHQ9Scorer.itemCount)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)

            Text(item.text(for: language))
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                ForEach(PHQ9Response.allCases) { response in
                    Button {
                        responses[currentIndex] = response
                    } label: {
                        HStack {
                            Text(PHQ9Questionnaire.responseLabel(for: response, language: language))
                            Spacer()
                            if responses[currentIndex] == response {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    responses[currentIndex] == response
                                    ? accentColor.opacity(0.16)
                                    : Color.secondary.opacity(0.08)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    responses[currentIndex] == response
                                    ? accentColor
                                    : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
        )
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            Button(language == .english ? "Previous" : "上一题") {
                guard currentIndex > 0 else { return }
                currentIndex -= 1
            }
            .buttonStyle(.bordered)
            .disabled(currentIndex == 0)

            Spacer()

            Button(
                currentIndex == PHQ9Scorer.itemCount - 1
                ? (language == .english ? "Complete" : "完成")
                : (language == .english ? "Next" : "下一题")
            ) {
                advanceOrComplete()
            }
            .buttonStyle(.borderedProminent)
            .tint(accentColor)
            .disabled(responses[currentIndex] == nil)
        }
    }

    private var disclaimer: some View {
        Text(
            language == .english
            ? "This questionnaire is a screening tool and is not a diagnosis. Item 9 requires appropriate follow-up when positive."
            : "本问卷仅用于筛查，不构成诊断。第 9 题若为阳性，需要进行适当的进一步评估。"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }

    private func advanceOrComplete() {
        guard responses[currentIndex] != nil else { return }

        if currentIndex < PHQ9Scorer.itemCount - 1 {
            currentIndex += 1
            return
        }

        let completedResponses = responses.compactMap { $0 }
        guard let result = try? PHQ9Scorer.score(completedResponses) else { return }
        onComplete(result)
    }
}
