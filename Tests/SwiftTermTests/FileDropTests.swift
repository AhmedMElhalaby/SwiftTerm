import Testing
import Foundation
@testable import SwiftTerm

#if os(macOS)
final class FileDropTests {
    @Test("shellQuote wraps a plain path in single quotes")
    func plainPathQuoted() {
        #expect(TerminalView.shellQuote("/Users/me/file.txt") == "'/Users/me/file.txt'")
    }

    @Test("shellQuote keeps spaces literal inside single quotes")
    func spacesStayLiteral() {
        #expect(TerminalView.shellQuote("/Users/me/My Notes.txt") == "'/Users/me/My Notes.txt'")
    }

    @Test("shellQuote escapes an embedded single quote the POSIX way")
    func escapesEmbeddedQuote() {
        #expect(TerminalView.shellQuote("/tmp/a'b.txt") == "'/tmp/a'\\''b.txt'")
    }

    @Test("filePasteText joins multiple single-quoted paths with a space")
    func joinsMultiplePaths() {
        let urls = [URL(fileURLWithPath: "/tmp/one two.txt"), URL(fileURLWithPath: "/tmp/three.txt")]
        #expect(TerminalView.filePasteText(for: urls) == "'/tmp/one two.txt' '/tmp/three.txt'")
    }
}
#endif
