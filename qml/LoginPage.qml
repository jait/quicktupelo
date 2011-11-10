import QtQuick 1.1
import com.nokia.meego 1.0
import "uiconstants.js" as UI

Page {
    signal loginClicked (string playerName)
    property alias playerName: nameInput.text

    PageHeader {
        title: "Tupelo"

        BusyIndicator {
            id: busyIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: UI.DEFAULT_MARGIN
            visible: running
            running: false
        }
    }

    TextField {
        anchors.horizontalCenter: parent.horizontalCenter
        width: loginButton.width
        id: nameInput
        placeholderText: qsTr("Your name")
        anchors.bottom: loginButton.top
        anchors.bottomMargin: UI.DEFAULT_MARGIN
    }
    Button {
        id: loginButton
        anchors.horizontalCenter: parent.horizontalCenter
        y: 300 // centering to parent moves the components up. don't want that
        text: qsTr("Sign on")
        onClicked: {
            if (nameInput.text === "") {
                errorDialog.show(qsTr("Please enter your name first"));
            } else {
                loginClicked(nameInput.text);
            }
        }
    }

    MouseArea {
        id: eventEater
        anchors.fill: parent
        visible: false
    }

    states: [
        State {
            name: "REGISTERING"
            PropertyChanges {
                target: busyIndicator
                running: true
            }
            PropertyChanges {
                target: eventEater
                visible: true
            }
        }
    ]
}
