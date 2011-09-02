
var EVENTS = [];

function createCard(parent, suit, value) {
    var component = Qt.createComponent("Card.qml");
    var card = component.createObject(parent);
    if (card === null) {
        console.log("Error creating object");
        return undefined;
    }

    card.suit = suit;
    card.value = value;
    return card;
}

function clearTable() {
    // stop processing events and schedule timer for table clearing
    eventProcessTimer.stop();
    tableClearTimer.start();
}

function onCardPlayed(event) {
    var plr;
    plr = getPlayerElemById(event.player.id);
    if (plr === undefined) {
        console.log("Could not find player!");
        return;
    }
    createCard(plr.card, event.card.suit, event.card.value);
}

function onMessageReceived(event) {
    console.log(JSON.stringify(event));
}

function onTrickPlayed(event) {
    clearTable();
}

function onTurnEvent(event) {
    // TODO: highlight the player in turn
}

function onStateChanged(event) {
    var stateStr = undefined;
    if (event.game_state.state == 1) {
        stateStr = "Voting";
    } else if (event.game_state.state == 2) { // VOTING => ONGOING
        clearTable();
        stateStr = event.game_state.mode == 0 ? "Playing NOLO": "Playing RAMI";
    }
    if (stateStr) {
        console.log(stateStr);
        statusRow.gameState = stateStr;
    }
}

function onCardClicked(card) {
    myWorker.sendMessage({"action": "playCard",
                         "card": {"suit": card.suit, "value": card.value}});
}

function processEvent() {
    var event;
    if (EVENTS.length === 0) {
        console.log("no events to process");
        return;
    }
    event = EVENTS.shift();
    console.log("processing " + event);

    if (event.game_state !== undefined) {
        //updateGameState(event.game_state);
    }
    switch (event.type) {
        case 1:
            onCardPlayed(event);
            break;
        case 2:
            onMessageReceived(event);
            break;
        case 3:
            onTrickPlayed(event);
            break;
        case 4:
            onTurnEvent(event);
            break;
        case 5:
            onStateChanged(event);
            break;
        default:
            console.log("unknown event " + event.type);
            break;
    }

    return (EVENTS.length > 0);
}

function queueEvent(event) {
    EVENTS.push(event);
}

function updateHand(newHand) {
    gameArea.handModel.clear();
    var i = 0;
    for (i = 0; i < newHand.length; i++) {
        gameArea.handModel.append({"csuit": newHand[i].suit,
                            "cvalue": newHand[i].value});
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
            mainRect.state = "REGISTERED";
            // go play straight away
            myWorker.sendMessage({action: "quickStart"});
        } else {
            console.log("Register failed!");
        }
        break;
    case "quit":
        if (! message.success) {
            console.log("Quit failed!");
        }
        mainRect.state = "";
        // TODO: wrap these behind a state change
        gameArea.handModel.clear();
        gameArea.clearTable();
        eventFetchTimer.stop();
        tableClearTimer.stop();
        statusRow.gameState = "";
        break;
    case "startGame":
    case "startGameWithBots":
        if (! message.success) {
            console.log("startGame failed!");
            break;
        }
        mainRect.state = "IN_GAME";
        myWorker.sendMessage({action: "getGameInfo"});
        myWorker.sendMessage({action: "getGameState"});
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
                queueEvent(message.response[i]);
            }
            // kick the timer if it's not running
            eventProcessTimer.maybeStart();
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
    case "playCard":
        if (! message.success) {
            console.log("playCard failed!");
            break;
        }
        myWorker.sendMessage({action: "getGameState"});
        eventFetchTimer.triggerNow();
        break;
    default:
        console.log("Unsupported action " + message.action);
        break;
    }
}
