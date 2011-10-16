import QtQuick 1.0
import "game.js" as Game
import "uiconstants.js" as UI

Flickable {
    id: flickable
    height: UI.CARD_HEIGHT
    contentHeight: UI.CARD_HEIGHT
    contentWidth: rowContainer.width
    flickableDirection: Flickable.HorizontalFlick
    signal cardClicked(variant card)

    function clear() {
        for (var i = cardContainer.children.length - 1; i >= 0; i--) {
            cardContainer.children[i].destroy();
        }
    }

    function appendCard(suit, value) {
        var card = Game.createCard(cardContainer, suit, value);
        card.clicked.connect(cardClicked);
    }

    Item {
        id: rowContainer
        width: cardContainer.width > flickable.width ? cardContainer.width : flickable.width
        //onWidthChanged: console.log("rowContainer w: " + width)
        height: UI.CARD_HEIGHT
        Row {
            id: cardContainer
            anchors.centerIn: parent
            spacing: 5
            width: children.length > 0 ? children.length * (UI.CARD_WIDTH + spacing) - spacing : 0
            height: parent.height
            //onWidthChanged: console.log("cardContainer w: " + width)
        }
    }
}
