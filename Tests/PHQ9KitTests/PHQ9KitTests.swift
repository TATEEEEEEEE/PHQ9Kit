import Testing
@testable import PHQ9Kit

@Test
func allZeroResponsesProduceMinimalResult() throws {
    let responses = Array(
        repeating: PHQ9Response.notAtAll,
        count: PHQ9Scorer.itemCount
    )

    let result = try PHQ9Scorer.score(responses)

    #expect(result.totalScore == 0)
    #expect(result.severity == .minimal)
    #expect(result.item9Positive == false)
}

@Test
func maximumResponsesProduceSevereResult() throws {
    let responses = Array(
        repeating: PHQ9Response.nearlyEveryDay,
        count: PHQ9Scorer.itemCount
    )

    let result = try PHQ9Scorer.score(responses)

    #expect(result.totalScore == 27)
    #expect(result.severity == .severe)
    #expect(result.item9Positive == true)
}

@Test
func item9IsReportedSeparately() throws {
    var responses = Array(
        repeating: PHQ9Response.notAtAll,
        count: PHQ9Scorer.itemCount
    )
    responses[8] = .severalDays

    let result = try PHQ9Scorer.score(responses)

    #expect(result.totalScore == 1)
    #expect(result.severity == .minimal)
    #expect(result.item9Positive == true)
}

@Test(arguments: [
    (0, PHQ9Severity.minimal),
    (4, PHQ9Severity.minimal),
    (5, PHQ9Severity.mild),
    (9, PHQ9Severity.mild),
    (10, PHQ9Severity.moderate),
    (14, PHQ9Severity.moderate),
    (15, PHQ9Severity.moderatelySevere),
    (19, PHQ9Severity.moderatelySevere),
    (20, PHQ9Severity.severe),
    (27, PHQ9Severity.severe)
])
func severityBoundaries(score: Int, expected: PHQ9Severity) {
    #expect(PHQ9Scorer.severity(for: score) == expected)
}

@Test
func invalidResponseCountThrows() {
    let responses = Array(
        repeating: PHQ9Response.notAtAll,
        count: PHQ9Scorer.itemCount - 1
    )

    #expect(throws: PHQ9Error.self) {
        try PHQ9Scorer.score(responses)
    }
}

@Test
func questionnaireContainsNineOrderedItems() {
    #expect(PHQ9Questionnaire.items.count == PHQ9Scorer.itemCount)
    #expect(PHQ9Questionnaire.items.map(\.id) == Array(1...9))
}
