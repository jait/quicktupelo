import QtQuick 1.0

Rectangle {
    width: 100
    height: 25
    color: "white"
    border.color: "black"
    radius: 4
    property alias text: textInput.text

    TextInput {
        anchors.centerIn: parent
        id: textInput
        width: parent.width - 4
        /*
        height: 20
        */
        font.family: "Lucida Grande"
        font.pixelSize: 12
        onFocusChanged: { if (focus) { text = "" } }
    }
}
