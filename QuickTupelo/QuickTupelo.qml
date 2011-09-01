import QtQuick 1.0
import "game.js" as Game

Rectangle {
    width: 640
    height: 480
    color: "#edecec"
    id: mainRect

    WorkerScript {
        id: myWorker
        source: "workerscript.js"

        onMessage: {
            console.log("received something from worker");
            Game.handleMessage(messageObject);
        }
    }

    Timer {
        id: eventFetchTimer
        interval: 2000; running: false; repeat: true
        onTriggered: {
            myWorker.sendMessage({action: "pollEvents"});
        }
    }

    Timer {
        id: eventProcessTimer
        interval: 100; running: false; repeat: true
        onTriggered: {
            if (! Game.processEvent()) {
                eventProcessTimer.stop()
            }
        }
    }

    Column {
        id: column1
        x: 0
        y: 0
        anchors.fill: parent
        spacing: 10
        Row {
            id: loginRow
            spacing: 10
            //anchors.centerIn: parent
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            /*
            Text {
                id: loginLabel
                anchors.centerIn: parent
                text: "Your name"
                font.pixelSize: 12
            }
            */
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                id: nameInputItem
                width: 80
                height: 25
                color: "white"
                border.color: "black"

                TextInput {
                    anchors.centerIn: parent
                    id: nameInput
                    width: 80
                    /*
                    height: 20
                    */
                    text: "Your name"
                    cursorVisible: true
                    font.family: "Lucida Grande"
                    font.pixelSize: 12
                    onFocusChanged: { if (focus) { text = "" } }
                }
            }
            Button {
                height: 25
                anchors.verticalCenter: parent.verticalCenter
                text: "Sign on"
                onClicked: myWorker.sendMessage({action: "register", playerName: nameInput.text})
                // TODO: need a REGISTERING state to disable the UI fields and show a spinner/something
            }
        }
        Row {
            id: statusRow
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            height: 50
            spacing: 10
            Text {
                anchors.verticalCenter: parent.verticalCenter
                id: loggedLabel
                text: "<none>"
                font.pixelSize: 12
                opacity: 0
            }
            Button {
                anchors.verticalCenter: parent.verticalCenter
                text: "Sign off"
                onClicked: myWorker.sendMessage({action: "quit"})
            }
        }

        GameArea {
            visible: false
            id: gameArea
            color: mainRect.color
            Component.onCompleted: cardClicked.connect(Game.onCardClicked)
        }
    }
    states: [
        State {
            name: "REGISTERED"

            PropertyChanges {
                target: statusRow
                visible: true
            }

            PropertyChanges {
                target: loginRow
                visible: false
            }

            PropertyChanges {
                target: loggedLabel
                text: "Signed on as " + nameInput.text
                opacity: 1
            }
        },
        State {
            name: "IN_GAME"

            PropertyChanges {
                target: eventFetchTimer
                running: true
            }

            PropertyChanges {
                target: statusRow
                visible: true
            }

            PropertyChanges {
                target: loginRow
                visible: false
            }

            PropertyChanges {
                target: loggedLabel
                text: "Signed on as " + nameInput.text
                opacity: 1
            }

            PropertyChanges {
                target: gameArea
                visible: true
            }
        }
    ]
}
