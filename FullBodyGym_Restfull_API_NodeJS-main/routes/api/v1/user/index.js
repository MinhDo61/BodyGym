var express = require('express');
var userRouter = express.Router();

// Modules
var register = require('./modules/register');
var password = require('./modules/password');
var login = require('./modules/login');
var terms = require('./modules/terms');
var privacy = require('./modules/privacy');
var profile = require('./modules/profile');
var list = require('./modules/list');

// Routes
userRouter.use('/register', register);
userRouter.use('/password', password);
userRouter.use('/login', login);
userRouter.use('/terms', terms);
userRouter.use('/privacy', privacy);
userRouter.use('/profile', profile);
userRouter.use('/list', list);

module.exports = userRouter;
