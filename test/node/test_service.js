const https = require("https");
const fs = require("fs");
const WebSocket = require("ws");


/**
 * 创建 HTTPS 服务
 */
const httpsServer = https.createServer({

    key: fs.readFileSync("./cert/localhost+2-key.pem"),

    cert: fs.readFileSync("./cert/localhost+2.pem")

});



/**
 * 创建 WSS 服务
 */
const wss = new WebSocket.Server({

    server: httpsServer

});


/**
 * 保存所有连接
 */
const clients = new Set();


/**
 * 定时发送消息
 */
function broadcast(data) {


    const message =
        JSON.stringify(data);

    for (const client of clients) {

        if (client.readyState
            === WebSocket.OPEN) {


            client.send(message);

        }

    }

}



httpsServer.listen(8443, () => {

    console.log(
        "WSS server started:"
    );

    console.log(
        "wss://localhost:8443"
    );
});

/**
 * 模拟推送任务
 */
setInterval(() => {


    broadcast({

        type: "notification",

        category: "WORK",

        title: "日报提醒",

        content: "请提交今日日报",

        time: new Date()

    });


}, 10000);






/**
 * 心跳检测
 */
setInterval(() => {


    for (const ws of clients) {


        if (ws.isAlive === false) {

            ws.terminate();

            continue;

        }


        ws.isAlive = false;

        ws.ping();

    }


}, 30000);

/**
 * 有客户端连接
 */
wss.on("connection", (ws, req) => {


    console.log(
        "new websocket client:",
        req.socket.remoteAddress
    );


    clients.add(ws);



    /**
     * 接收客户端消息
     */
    ws.on("message", message => {

        console.log(
            "receive:",
            message.toString()
        );

    });



    /**
     * 客户端关闭
     */
    ws.on("close", () => {

        clients.delete(ws);

        console.log(
            "client disconnected"
        );

    });


    /**
     * 心跳
     */
    ws.isAlive = true;


    ws.on("pong", () => {

        ws.isAlive = true;

    });


});