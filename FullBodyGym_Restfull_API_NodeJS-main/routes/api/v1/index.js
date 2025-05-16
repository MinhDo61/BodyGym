var express = require('express');
var rootRouter = express.Router();

//Modüller
var coach = require('./coach');
var user = require('./user');

//Routes
rootRouter.use('/coach', coach);
rootRouter.use('/user', user);

module.exports = rootRouter;