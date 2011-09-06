import QtQuick 1.0

Rectangle {
    width: 100
    height: 25
    color: "white"
    border.color: "black"
    radius: 4
    property alias text: textInput.text
    property bool modified: (textInput.state == "modified")

    TextInput {
        anchors.centerIn: parent
        id: textInput
        width: parent.width - 4
        color: "#666666"
        /*
        height: 20
        */
        font.family: "Lucida Grande"
        font.pixelSize: 12
        onFocusChanged: {
            if (focus && state !== "modified") {
                state = "modified";
            }
        }
        states: [
            State {
                name: "modified"
                PropertyChanges {
                    target: textInput
                    text: ""
                    color: "black"
                }
            }
        ]
    }
}
