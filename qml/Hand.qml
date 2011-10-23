import QtQuick 1.0
import "game.js" as Game
import "uiconstants.js" as UI

Flickable {
    id: flickable
    height: UI.CARD_HEIGHT
    contentHeight: UI.CARD_HEIGHT
    contentWidth: rowContainer.width
    flickableDirection: Flickable.HorizontalFlick
    signal cardClicked (variant card)
    property bool enableMagnify: true

    function clear() {
        for (var i = cardContainer.children.length - 1; i >= 0; i--) {
            cardContainer.children[i].destroy();
        }
    }

    function onCardPressAndHold(card) {
        card.magnify(UI.MAGNIFY_KEEP_BOTTOM);
    }

    function onCardReleased(card) {
        card.stopMagnify();
    }

    function appendCard(suit, value) {
        var card = Game.createCard(cardContainer, suit, value);
        card.clicked.connect(cardClicked);
        if (enableMagnify) {
            card.pressAndHold.connect(onCardPressAndHold);
            card.released.connect(onCardReleased);
        }
    }

    // TODO: this looks stupid, but when Flickable is flicked, the cards no longer get released mouse event
    onMovementStarted: {
        if (enableMagnify) {
            for (var i = cardContainer.children.length - 1; i >= 0; i--) {
                cardContainer.children[i].stopMagnify();
            }
        }
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
