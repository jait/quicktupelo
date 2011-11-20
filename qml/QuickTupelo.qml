import QtQuick 1.1
import com.nokia.meego 1.0
import "game.js" as Game
import "uiconstants.js" as UI

PageStackWindow {
    id: mainWindow
    initialPage: loginPage
    showToolBar: true

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
        onLoginClicked: {
            mainWindow.state = "REGISTERING";
            worker.sendMessage({action: "register", playerName: playerName});
            // TODO: there should be a sensible timeout for the operation
        }
    }

    GameListPage {
        id: gameListPage
        onQuickGame: {
            worker.sendMessage({action: "quickStart"});
            mainWindow.pageStack.push(gamePage);
        }
    }

    Page {
        id: gamePage

        tools: ToolBarLayout {
            ToolIcon {
                platformIconId: "toolbar-back"
                onClicked: leaveDialog.open()
            }

            ToolButton {
                //anchors.centerIn: parent
                text: qsTr("Sign off")
                onClicked: quitDialog.open()
            }
        }

        Column {
            anchors.fill: parent
            spacing: 10

            PageHeader {
                id: statusRow
            }

            GameArea {
                id: gameArea
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

        QueryDialog {
            id: leaveDialog
            titleText: qsTr("Leave game?")
            message: qsTr("Leaving the ongoing game will end the game for other players as well.")
            acceptButtonText: qsTr("Yes")
            rejectButtonText: qsTr("No")
            onAccepted: worker.sendMessage({action: "leaveGame"})
        }

        onStatusChanged: {
            if (status === PageStatus.Inactive) {
                gameArea.clearAll();
                tableClearTimer.stop();
                statusRow.title = "";
            }
        }
    }

    //Component.onCompleted: theme.inverted = true

    states: [
        State {
            name: "REGISTERING"
            PropertyChanges {
                target: loginPage
                state: "REGISTERING"
            }
        },
        State {
            name: "REGISTERED"
            PropertyChanges {
                target: statusRow
                title: ""
            }
        },
        State {
            name: "IN_GAME"
            PropertyChanges {
                target: eventFetchTimer
                running: true
            }
        }
    ]
}
