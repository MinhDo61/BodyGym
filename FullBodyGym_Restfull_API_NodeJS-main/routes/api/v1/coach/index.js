var express = require('express');
var rootRouter = express.Router();

//Modüller
var register = require('./modules/register');
var login = require('./modules/login');
var password = require('./modules/password');
var profile = require('./modules/profile');
var list = require('./modules/list');
var student = require('./modules/student');

//Routes
rootRouter.use('/register', register);
rootRouter.use('/login', login);
rootRouter.use('/password', password);
rootRouter.use('/profile', profile);
rootRouter.use('/list', list);
rootRouter.use('/student', student);

module.exports = rootRouter;