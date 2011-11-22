
var RULE_ERROR = 2;
var STATE_VOTING = 1;
var STATE_ONGOING = 2;
var NOLO = 0;

function createCard(parent, suit, value) {
    var component = Qt.createComponent("Card.qml");
    if (component.status === Component.Error) {
        console.log(component.errorString());
    }
    var card = component.createObject(parent);
    if (card === null) {
        console.log("Error creating object");
        return undefined;
    }

    card.suit = suit;
    card.value = value;
    return card;
}

function updateHand(newHand) {
    gameArea.hand.clear();
    var i = 0;
    for (i = 0; i < newHand.length; i++) {
        gameArea.hand.appendCard(newHand[i].suit, newHand[i].value);
    }
}

function getPlayerElemByIndex(index) {
    // TODO: there must be an easier way to do this
    var i, plr;
    for (i = 0; i < gameArea.players.length; i++) {
        plr = gameArea.players[i];
        if (plr.index === index) {
            return plr;
        }
    }
    return undefined;
}

function getPlayerElemById(id) {
    // TODO: there must be an easier way to do this
    var i, plr;
    for (i = 0; i < gameArea.players.length; i++) {
        plr = gameArea.players[i];
        if (plr.playerId === id) {
            return plr;
        }
    }
    return undefined;
}

function onGameInfo(result, state) {
    console.log(JSON.stringify(result));
    var i, myIndex, pl, index, elem;
    for (i = 0; i < result.length; i++) {
        if (result[i].id == state.id) {
            myIndex = i;
            break;
        }
    }
    for (i = 0; i < result.length; i++) {
        pl = result[i];
        // place where the player goes when /me is always at the bottom
        index = (i - myIndex) % 4;
        // TODO: set player id and name
        elem = getPlayerElemByIndex(index);
        if (elem === undefined) {
            console.log("Umm... could not get elem");
            continue;
        }
        elem.name = pl.player_name;
        elem.playerId = pl.id;
    }
}

function handleMessage(message) {
    var i;
    //console.log("handling message");
    switch (message.action) {
    case "register":
        if (message.success) {
            mainWindow.pageStack.push(gameListPage);
            mainWindow.state = "REGISTERED";
        } else {
            mainWindow.state = "";
            console.log("Register failed!");
            errorDialog.show("Could not sign on!");
        }
        break;
    case "quit":
        if (! message.success) {
            console.log("Quit failed!");
        }
        mainWindow.state = "";
        // TODO: wrap these behind a state change
        gameListPage.model.clear();
        gameListPage.model.updated = false;
        eventFetchTimer.stop();
        mainWindow.pageStack.pop(loginPage);
        break;
    case "leaveGame":
        if (! message.success) {
            console.log("leaveGame failed!");
        }
        if (mainWindow.state === "IN_GAME") {
            mainWindow.pageStack.pop();
            mainWindow.state = "REGISTERED";
        }
        break;
    case "startGame":
    case "startGameWithBots":
        if (! message.success) {
            console.log("startGame failed!");
            break;
        }
        mainWindow.state = "IN_GAME";
        worker.sendMessage({action: "getGameInfo"});
        worker.sendMessage({action: "getGameState"});
        break;
    case "pollEvents":
        if (! message.success) {
            console.log("pollEvents failed!");
            break;
        }
        //console.log(JSON.stringify(message.response));
        // add events to queue
        if (message.response.length > 0) {
            for (i = 0; i < message.response.length; i++) {
                // TODO: how about queueEvents()?
                eventQueue.queueEvent(message.response[i]);
            }
            // kick the event queue if it's not running
            if (! tableClearTimer.running) {
                eventQueue.start();
            }
        }
        break;
    case "getGameState":
        if (! message.success) {
            console.log("getGameState failed!");
            break;
        }
        if (message.response.hand !== undefined) {
            updateHand(message.response.hand);
        }
        // TODO: update state
        break;
    case "getGameInfo":
        if (! message.success) {
            console.log("getGameInfo failed!");
            break;
        }
        onGameInfo(message.response, message.state);
        break;
    case "listGames":
        if (! message.success) {
            console.log("listGames failed!");
        }
        gameListPage.listGamesCompleted(message);
        break;
    case "playCard":
        if (! message.success) {
            console.log("playCard failed!");
            console.log(message.response.code + " - " + message.response.message);
            if (message.response.code == RULE_ERROR) {
                errorDialog.show(message.response.message);
            }
            break;
        }
        worker.sendMessage({action: "getGameState"});
        eventFetchTimer.triggerNow();

        break;
    default:
        console.log("Unsupported action " + message.action);
        break;
    }
}
