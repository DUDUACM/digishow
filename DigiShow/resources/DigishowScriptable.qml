import QtQml 2.12
import DigiShow 1.0

DigishowEnvironment {

    property Utilities utilities: Utilities { }

    function onStart() { }
    function onStop() { }

    function alert(message) { app.messageNotify(message, DigishowApp.MsgAlert) }
    function toast(message) { app.messageNotify(message, DigishowApp.MsgToast) }
    function popup(message) { app.messageNotify(message, DigishowApp.MsgPopup) }

    function execute(script, value, range) { var r = eval(script); return (r === null ? -1 : r) }
}
