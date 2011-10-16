import QtQuick 1.1
import com.nokia.meego 1.0
import "game.js" as Game

PageStackWindow {
    color: systemPalette.window;
    id: mainWindow
    initialPage: loginPage
    showStatusBar: false
    showToolBar: true

    SystemPalette { id: systemPalette }

    WorkerScript {
        id: worker
        source: "workerscript.js"
        onMessage: { Game.handleMessage(messageObject) }
    }

    Timer {
        id: eventFetchTimer
        interval: 2000; running: false; repeat: true
        onTriggered: { worker.sendMessage({action: "pollEvents"}) }

        function triggerNow() {
            var wasRunning = eventFetchTimer.running;
            if (wasRunning) {
                eventFetchTimer.stop();
            }
            worker.sendMessage({action: "pollEvents"});
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

    MyDialog {
        id: errorDialog
        anchors.centerIn: parent
        z: 200
        color: "#ffcccc"
        autoClose: true
    }

    LoginPage {
        id: loginPage
        onLoginClicked: worker.sendMessage({action: "register", playerName: playerName})
        // TODO: need a REGISTERING state to disable the UI fields and show a spinner/something
    }

    Page {
        id: gamePage

        tools: ToolBarLayout {
            ToolButton {
                anchors.centerIn: parent
                text: qsTr("Sign off")
                onClicked: quitDialog.open()
            }
        }

        Column {
            anchors.fill: parent
            spacing: 10

            Row {
                id: statusRow
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
            }

            GameArea {
                id: gameArea
                color: mainWindow.color
                height: parent.height - statusRow.height - parent.spacing
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
        QueryDialog {
            id: quitDialog
            titleText: qsTr("Sign off?")
            message: qsTr("Leaving the ongoing game will end the game for other players as well.")
            acceptButtonText: qsTr("Yes")
            rejectButtonText: qsTr("No")
            onAccepted: worker.sendMessage({action: "quit"})
        }
    }

    states: [
        State {
            name: "REGISTERED"
            PropertyChanges {
                target: statusRow
                name: loginPage.playerName
                gameState: ""
            }
            StateChangeScript {
                script: mainWindow.pageStack.push(gamePage);
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
                name: loginPage.playerName
            }
        }
    ]
}
