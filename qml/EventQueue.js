
var EVENTS = [];

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
            eventQueue.cardPlayed(event);
            break;
        case 2:
            eventQueue.messageReceived(event);
            break;
        case 3:
            eventQueue.trickPlayed(event);
            break;
        case 4:
            eventQueue.turnEvent(event);
            break;
        case 5:
            eventQueue.stateChanged(event);
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
