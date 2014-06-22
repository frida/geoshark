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

var socketModule = {
    "windows": "ws2_32.dll",
    "darwin": "libSystem.B.dylib",
    "linux": "libc-2.19.so"
};
var socketFunctionPrefixes = [
    "connect",
    "recv",
    "send",
    "read",
    "write"
];
function isSocketFunction(name) {
    return socketFunctionPrefixes.some(function (prefix) {
        return name.indexOf(prefix) === 0;
    });
}
var ips = {};
Module.enumerateExports(socketModule[Process.platform], {
    onMatch: function (exp) {
        if (exp.type === "function"
                && isSocketFunction(exp.name)) {
            Interceptor.attach(exp.address, {
                onEnter: function (args) {
                    this.fd = args[0].toInt32();
                },
                onLeave: function (retval) {
                    var fd = this.fd;
                    if (Socket.type(fd) !== "tcp")
                        return;
                    var address = Socket.peerAddress(fd);
                    if (address === null)
                        return;
                    if (!ips[address.ip]) {
                        ips[address.ip] = true;
                        send({
                            name: "new-ip-address",
                            payload: address.ip
                        });
                    }
                }
            });
        }
    },
    onComplete: function () {
    }
});
