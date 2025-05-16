var express = require('express');
var router = express.Router();
var db = require('@helpers/database');

router.get('/', function (req, res) {
    db.getConnection().then((connection) => {
        db.procedure('call sp_PUBLIC_APP_ABOUT(?)', [true], connection).then((result) => {
            res.json({ 'status': 'success', 'content': result.TERMS });
        }).catch((error) => {
            res.status(500).send();
        });

        connection.release();
    }).catch((error) => {
        res.status(500).send();
    });
});

module.exports = router;