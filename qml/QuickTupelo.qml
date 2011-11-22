import QtQuick 1.1
import com.nokia.meego 1.0
import "game.js" as Game
import "uiconstants.js" as UI

PageStackWindow {
    id: mainWindow
    initialPage: loginPage
    showToolBar: true
    property alias gameArea: gamePage.gameArea

    WorkerScript {
        id: worker
        source: "workerscript.js"
        onMessage: { Game.handleMessage(messageObject) }
    }

    EventQueue {
        id: eventQueue

        function scheduleClearTable() {
            // stop processing events and schedule timer for table clearing
            eventQueue.stop();
            tableClearTimer.start();
        }

        onCardPlayed: {
            var plr;
            plr = Game.getPlayerElemById(event.player.id);
            if (plr === undefined) {
                console.log("Could not find player!");
                return;
            }
            Game.createCard(plr.card, event.card.suit, event.card.value);
        }

        onMessageReceived: {
            console.log(JSON.stringify(event));
        }

        onTrickPlayed: {
            scheduleClearTable();
        }

        onTurnEvent: {
            // TODO: highlight the player in turn
        }

        onStateChanged: {
            var stateStr = undefined;
            if (event.game_state.state == Game.STATE_VOTING) {
                stateStr = "Voting";
            } else if (event.game_state.state == Game.STATE_ONGOING) { // VOTING => ONGOING
                scheduleClearTable();
                stateStr = event.game_state.mode == Game.NOLO ? "Playing NOLO": "Playing RAMI";
            }
            if (stateStr) {
                console.log(stateStr);
                gamePage.statusText = stateStr;
            }
        }
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
        id: tableClearTimer
        interval: 5000; running: false; repeat: false
        onTriggered: {
            gameArea.clearTable()
            eventQueue.start();
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

    GamePage {
        id: gamePage
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
                target: gamePage
                statusText: ""
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
