var CONFIG = {server: "http://localhost:8052"};
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
        var json = undefined;
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            console.log("HEADERS_RECEIVED");
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            console.log("DONE " + doc.status);
            console.log(doc.responseText);
            if (doc.status == 200) {
                json = eval("(" + doc.responseText + ")");
                if (params.success !== undefined) {
                    params.success(json);
                }
                else {
                    // default
                    WorkerScript.sendMessage({action: params.action, success: true, response: json});
                }
            } else {
                if (doc.status == 403) {
                    try {
                        json = eval("(" + doc.responseText + ")");
                    } catch (err) {
                        // console.log("failed to parse response: " + doc.responseText);
                        // try to dig the stuff from headers instead
                        json = {"code": doc.getResponseHeader("X-Error-Code"),
                                "message": doc.getResponseHeader("X-Error-Message")};
                    }
                }
                if (params.error !== undefined) {
                    params.error(doc, json);
                } else {
                    // default error handler
                    WorkerScript.sendMessage({action: params.action, success: false, response: json});
                }
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
         action: "register",
         success: function (response) {
             ME.id = response.id;
             ME.akey = response.akey;
             console.log("id is " + ME.id + ", akey is " + ME.akey);
             WorkerScript.sendMessage({action: "register", success: true, response: response});
        }});
}

function quit() {
    console.log("quitting");
    ajax({uri: "/ajax/player/quit", data: {akey: ME.akey},
         action: "quit",
         success: function (response) {
             ME.id = undefined;
             ME.akey = undefined;
             WorkerScript.sendMessage({action: "quit", success: true, response: response});
        }});
}

function createGame(callback) {
    ajax({uri: "/ajax/game/create", data: {akey: ME.akey},
         action: "createGame",
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

function startGameWithBots() {
    ajax({uri: "/ajax/game/start_with_bots", data: {akey: ME.akey, game_id: ME.gameId},
         action: "startGameWithBots"});
}

function getGameInfo() {
    ajax({uri: "/ajax/game/get_info", data: {game_id: ME.gameId},
         action: "getGameInfo",
         success: function (response) {
             WorkerScript.sendMessage({action: "getGameInfo", success: true, response: response, state:ME});
         }});
}

function listGames(model) {
    ajax({uri: "/ajax/game/list",
             action: "listGames",
             success: function (response) {
                          var game;
                          //console.log("listGames: " + JSON.stringify(response));
                          model.clear();
                          for (var gameId in response) {
                              if (response.hasOwnProperty(gameId)) {
                                  // TODO: should get joinable from server
                                  game = {"gameId": gameId, "joinable": response[gameId].length < 4 };
                                  // generate a string with player names
                                  try {
                                      game.players = response[gameId].map(function (i) { return i.player_name; }).join(", ");
                                  } catch (error) {
                                      console.log("could not get players: " + error);
                                  }
                                  model.append(game);
                              }
                          }
                          model.sync();
                          WorkerScript.sendMessage({action: "listGames", success: true});
                      }});
}

WorkerScript.onMessage = function (message) {
    console.log("onMessage " + JSON.stringify(message));
    switch (message.action) {
    case "register":
        register(message.playerName);
        break;
    case "quit":
        quit();
        break;
    case "leaveGame":
        ajax({uri: "/ajax/game/leave", data: {akey: ME.akey, game_id: ME.gameId},
                 action: message.action,
                 success: function (json) {
                              ME.gameID = undefined;
                              WorkerScript.sendMessage({action: message.action, success: true, response: json});
                          },
                 error: function (doc, json) {
                            ME.gameID = undefined;
                            WorkerScript.sendMessage({action: message.action, success: false, response: json});
                        }
             });
        break;
    case "quickStart":
        createGame(startGameWithBots);
        break;
    case "pollEvents":
        ajax({uri: "/ajax/get_events", data: {akey: ME.akey}, action: message.action});
        break;
    case "getGameState":
        ajax({uri: "/ajax/game/get_state", data: {akey: ME.akey, game_id: ME.gameId},
             action: message.action});
        break;
    case "getGameInfo":
        getGameInfo();
        break;
    case "listGames":
        listGames(message.model);
        break;
    case "playCard":
        ajax({uri: "/ajax/game/play_card", data: {akey: ME.akey, game_id: ME.gameId,
             card: JSON.stringify(message.card)}, action: "playCard"});
        break;
    default:
        break;
    }
}

