require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");
const ejs = require("ejs");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const cookieParser = require("cookie-parser");
const session = require("express-session");
const https = require("https");
const fs = require("fs");
const port = 80;
const app = express();

//For Removing Cache
const setNoCache = (req, res, next) => {
    res.setHeader('Cache-Control', 'no-store');
    next();
};

//Connect to DB mongodb+srv://Vivek:<password>@login.pmby6rc.mongodb.net/?retryWrites=true&w=majority
mongoose.connect("mongodb+srv://Vivek:Vivek@login.pmby6rc.mongodb.net/login?retryWrites=true&w=majority")
.catch((err)=>{
    console.log(err);
})

//Creating a Schema
const userSchema = new mongoose.Schema({
    name: {
        required: true,
        type: String
    },
    username: {
        required: true,
        type: String
    },
    password: {
        required: true,
        type: String
    }
});

//Creating a collections based on the schema
const User = new mongoose.model("User", userSchema);

//For Session Management
app.use(cookieParser());
app.use(session({
  secret: 'abcd1234',
  resave: false,
  saveUninitialized: false
}));

//Basic COnfiguration
app.set("view engine", "ejs")
app.use(bodyParser.urlencoded({extended:true}));
app.use(express.static("public"));

//Get Requests
app.get("/", (req, res)=>{
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    res.render("login", {message: null});
});

app.get("/signup", (req, res)=>{
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    res.render("signup", {msg: null});
});

app.get("/loggedIn", setNoCache, (req, res)=>{
    if(!req.session.username){
        res.render("login", {message: null});
    }
    else{
        res.render("loggedIn", {nameOfUser: req.session.name})
    }
});

//Post Requests
app.post("/signup", (req, res)=>{
    User.findOne({username: req.body.username})
    .catch((err)=>{
        console.log(err);
    })
    .then((foundUser)=>{
        if(foundUser){
            res.render("signup", {msg: "Username Already Exists - Choose Another One!"})
        }
        else{
            bcrypt.hash(req.body.password, 10, function(err, hash){
                const newUser = new User({
                    name: req.body.Name,
                    username: req.body.username,
                    password: hash
                });
        
                newUser.save()
                .catch((err)=>{
                    console.log(err)
                })
                .then(()=>{
                    res.render("login", {message:"Signup Successful - You can login now!"});
                });
            });
        }
    });    
});

app.post("/", (req, res)=>{
    User.findOne({username: req.body.username})
    .catch((err)=>{
        console.log(err);
    })
    .then((foundUser)=>{
        if(!foundUser){
            res.render("login", {message: "User Not Found!"});
        }
        else{
            bcrypt.compare(req.body.password, foundUser.password, function(err, result){
                if(err){
                    console.log(err);
                }
                else{
                    if(result){
                        req.session.username = req.body.username;
                        req.session.name = foundUser.name;
                        res.redirect("/loggedIn");
                    }
                    else{
                        res.render("login", {message: "Incorrect Password!"})
                    }
                }
            })
        }
    });  
});

app.post("/logout", (req, res)=>{
    req.session.destroy();
    res.setHeader('Cache-Control', 'no-store');
    res.render("login", {message: "Logout Successful"});
});

app.post("/delete", (req, res)=>{
    User.findOneAndDelete({username: req.session.username})
    .then(()=>{
        req.session.destroy();
        res.render("login", {message: "Account Successfully Deleted"})
    });
});

//Port
app.listen(port);

//HTTPS
/*
const options = {
    key: fs.readFileSync('/home/shantanu/key.pem'),
    cert: fs.readFileSync('/home/shantanu/cert.pem')
};

const server = https.createServer(options, app);

server.listen(3000);

*/
