import QtQuick 1.0

Rectangle {
    id: dialog
    property int animationSpeed: 500
    property bool autoClose: false

    signal opened
    signal closed


    function show(text) {
        dialog.opened();
        dialogText.text = text;
        dialog.opacity = 1;
    }

    function maybeClose() {
        if (dialog.visible && dialog.autoClose) {
            closeTimer.start();
        }
    }

    function forceClose() {
        if (dialog.opacity == 0) {
            return; //already closed
        }
        dialog.closed();
        dialog.opacity = 0;
    }

    Timer {
        id: closeTimer
        interval: dialog.animationSpeed; running: false; repeat: false;
        onTriggered: { dialog.forceClose(); }
    }

    width: dialogText.width + 20; height: dialogText.height + 20
    color: "white"
    border.width: 1
    radius: 5
    opacity: 0
    visible: opacity > 0

    Behavior on opacity {
        SequentialAnimation {
            NumberAnimation { duration: animationSpeed }
            ScriptAction { script: dialog.maybeClose(); }
        }
    }

    Text { id: dialogText; anchors.centerIn: parent; text: "Hello!" }

    MouseArea { anchors.fill: parent; onClicked: forceClose(); }
}
