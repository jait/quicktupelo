var CONFIG = {server: "http://localhost"};
var ME = {id: undefined, akey: undefined};

function ajax(params) {
    var qstring = "", qparams = [];
    var uri = CONFIG.server + params.uri, key;

    if (params.data !== undefined) {
        for (key in params.data) {
            if (params.data.hasOwnProperty(key)) {
                qparams.push(encodeURIComponent(key) + "=" + encodeURIComponent(params.data[key]));
            }
        }
        qstring = qparams.join("&");
    }
    if (qstring !== "") {
        uri = uri + "?" + qstring;
    }

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function () {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            console.log("HEADERS_RECEIVED");
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            console.log("DONE");
            console.log(doc.responseText);
            if (params.success !== undefined) {
                params.success(eval("(" + doc.responseText + ")"));
            }
        }
    }

    console.log("ajaxing to " + uri);
    doc.open("GET", uri);
    doc.send();
}

function register(playerName) {
    console.log("registering " + playerName);
    var player = {player_name: playerName};
    ajax({uri: "/ajax/player/register", data: {player: JSON.stringify(player)},
        success: function (response) {
             ME.id = response.player_id;
             ME.akey = response.akey;
             console.log("id is " + ME.id + ", akey is " + ME.akey);
             WorkerScript.sendMessage({action: "register", success: true, response: response});
        }});
}

function quit() {
    console.log("quitting");
    ajax({uri: "/ajax/player/quit", data: {akey: ME.akey},
        success: function (response) {
             ME.id = undefined;
             ME.akey = undefined;
             WorkerScript.sendMessage({action: "quit", success: true, response: response});
        }});
}

function createGame(callback) {
    ajax({uri: "/ajax/game/create", data: {akey: ME.akey},
        success: function (response) {
             ME.gameId = response;
             console.log("game ID " + ME.gameId);
             if (callback !== undefined) {
                 callback();
             } else {
                 WorkerScript.sendMessage({action: "createGame", success: true, response: response});
             }
        }});
}

function pollEvents() {
    console.log("polling");
    ajax({uri: "/ajax/get_events", data: {akey: ME.akey},
        success: function (response) {
             console.log("got events");
             WorkerScript.sendMessage({action: "pollEvents", success: true, response: response});
         }});
}

function startGameWithBots() {
    ajax({uri: "/ajax/game/start_with_bots", data: {akey: ME.akey, game_id: ME.gameId},
        success: function (response) {
             console.log("game started");
             //ME.eventTimer = setInterval(pollEvents, 2000); // MOO! setInterval does not work here!
             WorkerScript.sendMessage({action: "startGameWithBots", success: true, response: response});
        }});
}

function quickStart() {
    createGame(startGameWithBots);

}

function getGameState() {
    ajax({uri: "/ajax/game/get_state", data: {akey: ME.akey, game_id: ME.gameId},
         success: function (response) {
             WorkerScript.sendMessage({action: "getGameState", success: true, response: response});
         }});
}

function getGameInfo() {
    ajax({uri: "/ajax/game/get_info", data: {game_id: ME.gameId},
         success: function (response) {
             WorkerScript.sendMessage({action: "getGameInfo", success: true, response: response, state:ME});
         }});
}

function playCard(card) {
    ajax({uri: "/ajax/game/play_card", data: {akey: ME.akey, game_id: ME.gameId, card: JSON.stringify(card)},
         success: function (response) {
             WorkerScript.sendMessage({action: "playCard", success: true, response: response});
         }});
}

WorkerScript.onMessage = function (message) {
    console.log("onMessage");
    console.log(JSON.stringify(message));
    switch (message.action) {
    case "register":
        register(message.playerName);
        break;
    case "quit":
        quit();
        break;
    case "quickStart":
        quickStart();
        break;
    case "pollEvents":
        pollEvents();
        break;
    case "getGameState":
        getGameState();
        break;
    case "getGameInfo":
        getGameInfo();
        break;
    case "playCard":
        playCard(message.card);
        break;
    default:
        break;
    }
}

