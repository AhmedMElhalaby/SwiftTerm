import Testing
import Foundation
@testable import SwiftTerm

/// Byte-level mouse-report regression tests. Each test enables a real mouse
/// mode via its DEC private sequence, then drives the Terminal send path and
/// asserts the exact bytes emitted to the delegate — the automated form of the
/// AIN-111 byte-diff against Terminal.app/iTerm.
final class MouseReportTests {
    private let esc = "\u{1b}"

    private func sgrAnyEvent() -> (Terminal, TerminalTestDelegate) {
        let (t, d) = TerminalTestHarness.makeTerminal(cols: 80, rows: 24)
        t.feed(text: "\(esc)[?1006h")   // SGR encoding
        t.feed(text: "\(esc)[?1003h")   // any-event tracking
        return (t, d)
    }

    private func lastString(_ d: TerminalTestDelegate) -> String {
        String(decoding: d.sentData.last ?? [], as: UTF8.self)
    }

    @Test("hover with no button emits a motion report (M, code 35) — not a release")
    func hoverEmitsMotionNotRelease() {
        let (t, d) = sgrAnyEvent()
        let cb = t.encodeButton(button: 3, release: false, shift: false, meta: false, control: false)
        t.sendMotion(buttonFlags: cb, x: 2, y: 4, pixelX: 2, pixelY: 4)
        #expect(lastString(d) == "\(esc)[<35;3;5M")
    }

    @Test("SGR left press then release preserve the button code and use M/m")
    func sgrPressReleasePreserveButton() {
        let (t, d) = sgrAnyEvent()
        let press = t.encodeButton(button: 0, release: false, shift: false, meta: false, control: false)
        t.sendEvent(buttonFlags: press, x: 2, y: 4, pixelX: 2, pixelY: 4, release: false)
        #expect(lastString(d) == "\(esc)[<0;3;5M")

        let rel = t.encodeButton(button: 0, release: true, shift: false, meta: false, control: false)
        t.sendEvent(buttonFlags: rel, x: 2, y: 4, pixelX: 2, pixelY: 4, release: true)
        #expect(lastString(d) == "\(esc)[<0;3;5m")
    }

    @Test("wheel up/down encode as buttons 64/65 in SGR")
    func wheelEncodesAs64And65() {
        let (t, d) = sgrAnyEvent()
        let up = t.encodeButton(button: 4, release: false, shift: false, meta: false, control: false)
        t.sendEvent(buttonFlags: up, x: 2, y: 4, pixelX: 2, pixelY: 4, release: false)
        #expect(lastString(d) == "\(esc)[<64;3;5M")

        let down = t.encodeButton(button: 5, release: false, shift: false, meta: false, control: false)
        t.sendEvent(buttonFlags: down, x: 2, y: 4, pixelX: 2, pixelY: 4, release: false)
        #expect(lastString(d) == "\(esc)[<65;3;5M")
    }

    @Test("legacy X10 still carries release as button code 3")
    func legacyX10ReleaseIsButtonThree() {
        let (t, d) = TerminalTestHarness.makeTerminal(cols: 80, rows: 24)
        t.feed(text: "\(esc)[?1000h")   // vt200 tracking, default (x10) encoding
        let press = t.encodeButton(button: 0, release: false, shift: false, meta: false, control: false)
        t.sendEvent(buttonFlags: press, x: 0, y: 0, pixelX: 0, pixelY: 0, release: false)
        #expect(d.sentData.last == Array("\(esc)[M".utf8) + [32, 33, 33])

        let rel = t.encodeButton(button: 0, release: true, shift: false, meta: false, control: false)
        t.sendEvent(buttonFlags: rel, x: 0, y: 0, pixelX: 0, pixelY: 0, release: true)
        #expect(d.sentData.last == Array("\(esc)[M".utf8) + [35, 33, 33])
    }
}
