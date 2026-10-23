// The kit is not a desktop shell: this entry point exists so Quickshell registers
// the root directory as the `qs` import module. Import resolution needs a directory
// config; running an app directly goes through its own file instead:
//
//   qs -p kit-specimen.qml     # the full specimen sheet
//   qs -p app-template.qml     # the starter
import Quickshell

Item {}
