import QtQuick 1.0
import com.nokia.meego 1.0

Page {
    id: gamePage
    property alias gameArea: gameArea
    property alias statusText: pageHeader.title

    function onCardClicked(card) {
        worker.sendMessage({"action": "playCard",
                             "card": {"suit": card.suit, "value": card.value}});
    }

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: leaveDialog.open()
        }

        ToolButton {
            anchors.centerIn: parent
            text: qsTr("Sign off")
            onClicked: quitDialog.open()
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10

        PageHeader {
            id: pageHeader
        }

        GameArea {
            id: gameArea
            height: parent.height - pageHeader.height - parent.spacing
            Component.onCompleted: cardClicked.connect(gamePage.onCardClicked)
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
            statusText = "";
        }
    }
}
