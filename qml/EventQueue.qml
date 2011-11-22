import QtQuick 1.0
import "EventQueue.js" as EventQueueJS

Item {
    id: eventQueue
    property alias running: eventProcessTimer.running

    signal cardPlayed (variant event)
    signal messageReceived (variant event)
    signal trickPlayed (variant event)
    signal turnEvent (variant event)
    signal stateChanged (variant event)

    function queueEvent(event) {
        return EventQueueJS.queueEvent(event);
    }

    function start() {
        eventProcessTimer.start();
    }

    function stop() {
        eventProcessTimer.stop();
    }

    Timer {
        id: eventProcessTimer
        interval: 100; running: false; repeat: true
        onTriggered: {
            if (! EventQueueJS.processEvent()) {
                eventProcessTimer.stop();
            }
        }
    }
}
