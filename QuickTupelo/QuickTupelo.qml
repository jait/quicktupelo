import QtQuick 1.0
import "game.js" as Game

Rectangle {
    width: 640
    height: 480
    //color: "#edecec"
    color: systemPalette.window;
    id: mainRect

    SystemPalette { id: systemPalette }

    WorkerScript {
        id: myWorker
        source: "workerscript.js"

        onMessage: { Game.handleMessage(messageObject) }
    }

    Timer {
        id: eventFetchTimer
        interval: 2000; running: false; repeat: true
        onTriggered: { myWorker.sendMessage({action: "pollEvents"}) }

        function triggerNow() {
            var wasRunning = eventFetchTimer.running;
            if (wasRunning) {
                eventFetchTimer.stop();
            }
            myWorker.sendMessage({action: "pollEvents"});
            if (wasRunning) {
                eventFetchTimer.start();
            }
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
        function maybeStart() {
            if (! tableClearTimer.running) {
                eventProcessTimer.start();
            }
        }
    }

    Timer {
        id: tableClearTimer
        interval: 5000; running: false; repeat: false
        onTriggered: {
            gameArea.clearTable()
            eventProcessTimer.start()
        }
    }

    Dialog {
        id: errorDialog
        anchors.centerIn: parent
        z: 20
        color: "#ffcccc"
        autoClose: true
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

            TextInputBox {
                anchors.verticalCenter: parent.verticalCenter
                id: nameInput
                width: 100
                height: 25
                text: "Your name"
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
            property string name
            property alias gameState: gameStateText.text
            onNameChanged: { loggedLabel.text = "Signed on as " + name }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                id: gameStateText
                font.pixelSize: 12
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                id: loggedLabel
                text: "<none>"
                font.pixelSize: 12
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
            onTableClicked: {
                if (tableClearTimer.running) {
                    tableClearTimer.stop()
                    gameArea.clearTable()
                    eventProcessTimer.start()
                }
            }
        }
    }
    states: [
        State {
            name: "REGISTERED"

            PropertyChanges {
                target: statusRow
                visible: true
                name: nameInput.text
                gameState: ""
            }

            PropertyChanges {
                target: loginRow
                visible: false
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
                name: nameInput.text
            }

            PropertyChanges {
                target: loginRow
                visible: false
            }

            PropertyChanges {
                target: gameArea
                visible: true
            }
        }
    ]
}
