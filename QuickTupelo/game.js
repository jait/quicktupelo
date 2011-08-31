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
        index = (4 + i - myIndex) % 4;
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
    console.log("handling message");
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
        gameArea.handModel.clear();
        eventTimer.running = false;
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
        console.log(JSON.stringify(message.response));
        // TODO: add events to queue
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
    default:
        console.log("Unsupported action " + message.action);
        break;
    }
}