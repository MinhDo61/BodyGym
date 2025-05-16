var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cors = require('cors');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var bodyParserErrorHandler = require('express-body-parser-error-handler');
require('dotenv').config();
require('module-alias/register');

var indexRouter = require('./routes');
var apiRouter = require('./routes/api/v1');
var app = express();

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(logger('dev'));
app.set('trust proxy', true);
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(bodyParserErrorHandler());

app.use(express.static(path.join(__dirname, 'public')));

app.use(cors());

app.get('/', function(req, res, next) {
  res.send('Welcome to FullBodyGym API');
});

app.use('/api/v1', apiRouter);

app.use('/', indexRouter);

app.use(function (req, res, next) {
  next(createError(404));
});

app.use(function (err, req, res, next) {
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};
  res.status(err.status || 500);
  res.render('error');
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
