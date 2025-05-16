var express = require('express');
var router = express.Router();

var db = require('@helpers/database');
var middleware = require('@helpers/middleware');
var validator = require('@helpers/validator');
var jwt = require('@helpers/jwt');

router.get('/variables/with/title/:listId', middleware.CoachAuth, (req, res) => {
    let { listId } = req.params;

    if (listId) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_LIST_VARIABLE_WITH_TITLE(?)', [listId], connection, 'list').then((result) => {
                res.json({
                    status: 'success',
                    variables: result
                });
            })

            connection.release();
        }).catch((error) => {
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
});

router.post('/account/create', middleware.CoachAuth, (req, res) => {
    let { firstname, lastname, email, genderType, age, password, variables, selectedCityId, selectedStateId } = req.body;

    if (firstname && lastname && validator.IsEmail(email) && genderType && age && password && variables && selectedCityId && selectedStateId) {

        db.getConnection().then((connection) => {
            let passwordHash = jwt.CreatePasswordHash(password);

            db.procedure('call sp_COACH_USER_REGISTER(?)', [req.user.id, firstname, lastname, email, genderType, age, selectedCityId, selectedStateId, passwordHash], connection).then((result) => {
                if (result.STATUS === 'success') {

                    if (variables.length) {
                        variables.map((item) => {
                            if (item !== null) {
                                db.procedure('call sp_COACH_USER_REGISTER_VARIABLE_ADD(?)', [result.USER_ID, item.id, item.value], connection).then((result) => {

                                })
                            }
                        })
                    }

                    res.json({ status: 'success' })
                }
                else {
                    res.json({ status: result.STATUS });
                }
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

router.get('/', middleware.CoachAuth, (req, res) => {
    db.getConnection().then((connection) => {
        db.procedure('call sp_COACH_USER_TABLE(?)', [req.user.id], connection, 'list').then((result) => {
            res.json({ status: 'success', students: result })
        })

        connection.release();
    }).catch((error) => {
        res.status(500).send();
    })
});

router.delete('/:userId', middleware.CoachAuth, (req, res) => {
    let { userId } = req.params;

    if (userId) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_USER_DELETE(?)', [req.user.id, userId], connection).then((result) => {
                res.json({ status: result.STATUS })
            })

            connection.release();
        }).catch((error) => {
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
});

router.get('/profile/:userId', middleware.CoachAuth, (req, res) => {
    let { userId } = req.params;

    if (userId) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_USER_PROFILE(?)', [req.user.id, userId], connection, 'list').then((result) => {
                if (result.length) {
                    db.procedure('call sp_COACH_USER_PROFILE_VARIABLE(?)', [userId], connection, 'list').then((resultVariable) => {
                        res.json({
                            status: 'success',
                            profile: result[0],
                            variables: resultVariable
                        })
                    })

                }
                else {
                    res.json({ status: 'user-not-found' });
                }
            })

            connection.release();
        }).catch((error) => {
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
});

router.get('/status/:userId/:listId', middleware.CoachAuth, (req, res) => {
    let { userId, listId } = req.params;

    if (userId && listId) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_USER_PROFILE_VARIABLE(?)', [req.user.id, userId, listId], connection, 'list').then((result) => {
                console.log(result)
                res.json({ status: 'success', data: result });
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