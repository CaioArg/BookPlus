func splitIntoLines(_ text: String, charsPerLine: Int) -> String {
    var result = ""
    var currentLine = ""

    for word in text.split(separator: " ") {
        if currentLine.count + word.count + 1 > charsPerLine {
            result += currentLine + "\n"
            currentLine = String(word)
        } else {
            currentLine += currentLine.isEmpty ? word : " \(word)"
        }
    }

    result += currentLine

    return result
}
