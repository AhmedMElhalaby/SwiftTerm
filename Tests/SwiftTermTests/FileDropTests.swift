import Testing
import Foundation
@testable import SwiftTerm

#if os(macOS)
final class FileDropTests {
    @Test("shellEscape leaves a plain path unchanged")
    func plainPathUnchanged() {
        #expect(TerminalView.shellEscape("/Users/me/file.txt") == "/Users/me/file.txt")
    }

    @Test("shellEscape backslash-escapes spaces")
    func escapesSpaces() {
        #expect(TerminalView.shellEscape("/Users/me/My Notes.txt") == "/Users/me/My\\ Notes.txt")
    }

    @Test("shellEscape escapes quotes and shell metacharacters")
    func escapesMetacharacters() {
        #expect(TerminalView.shellEscape("/tmp/a'b\"c$d.txt") == "/tmp/a\\'b\\\"c\\$d.txt")
    }

    @Test("filePasteText joins multiple escaped paths with a space")
    func joinsMultiplePaths() {
        let urls = [URL(fileURLWithPath: "/tmp/one two.txt"), URL(fileURLWithPath: "/tmp/three.txt")]
        #expect(TerminalView.filePasteText(for: urls) == "/tmp/one\\ two.txt /tmp/three.txt")
    }
}
#endif
