console.log("Hello from thread ID " +
    Process.getCurrentThreadId());

function onStanza(stanza) {
    if (stanza.name === "request-status") {
        var threads = [];
        Process.enumerateThreads({
            onMatch: function (thread) {
                threads.push(thread);
            },
            onComplete: function () {
                send({
                    name: "status",
                    payload: threads
                });
            }
        });
    }
    recv(onStanza);
}
recv(onStanza);
send({
    name: "hello",
    payload: {
        threadId: Process.getCurrentThreadId()
    }
});
