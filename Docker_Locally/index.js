const express = require("express");
const app = express();
const port = 80;

app.get('/', (req, res)=>{
    res.sendFile(__dirname + "/hello.html");
})

app.listen(port, ()=>{
    console.log("Server Running");
})

