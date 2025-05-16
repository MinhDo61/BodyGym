var express = require('express');
var router = express.Router();

var db = require('@helpers/database');
var middleware = require('@helpers/middleware');
var validator = require('@helpers/validator');

router.put('/', middleware.CoachAuth, (req, res) => {
    let { newFirstname, newLastname } = req.body;

    if (newFirstname && newLastname) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_PROFILE_UPDATE(?)', [req.user.id, newFirstname, newLastname], connection).then((result) => {
                res.json({ status: result.STATUS });
            });

            connection.release();
        }).catch((error) => {
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
});

router.put('/email', middleware.CoachAuth, (req, res) => {
    let { newEmail } = req.body;

    if (validator.IsEmail(newEmail)) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_EMAIL_UPDATE(?)', [req.user.id, newEmail], connection).then((result) => {
                res.json({ status: result.STATUS });
            })

            connection.release();
        }).catch((error) => {
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
})
module.exports = router;