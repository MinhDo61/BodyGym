var express = require('express');
var router = express.Router();

var db = require('@helpers/database');
var middleware = require('@helpers/middleware');
var jwt = require('../../../../../helpers/jwt');

router.get('/', middleware.UserAuth, (req, res) => {
    db.getConnection().then((connection) => {
        db.procedure('call sp_USER_PROFILE_GET(?)', [req.user.id], connection).then((resultProfile) => {
            db.procedure('call sp_CITY_LIST_GET()', [], connection, 'list').then((resultCities) => {
                db.procedure('call sp_STATE_LIST_GET(?)', [resultProfile.CITY_ID], connection, 'list').then((resultStates) => {
                    res.json({ status: 'success', profile: resultProfile, cities: resultCities, states: resultStates });
                })

            })
        })

        connection.release();
    }).catch((error) => {
        res.status(500).send();
    })
});

router.put('/', middleware.UserAuth, (req, res) => {
    let { newFirstname, newLastname, newGender, newCityId, newStateId, newAge } = req.body;

    if (newFirstname && newLastname && newGender && newAge) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_USER_PROFILE_UPDATE(?)', [req.user.id, newFirstname, newLastname, newGender, newAge, newCityId, newStateId], connection).then((result) => {
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
});

router.get('/sizes', middleware.UserAuth, (req, res) => {
    db.getConnection().then((connection) => {
        db.procedure('call sp_USER_LIST_CURRENT_GET(?)', [req.user.id], connection, 'list').then((result) => {
            res.json({ status: 'success', variables: result })
        })

        connection.release();
    }).catch((error) => {
        res.status(500).send();
    })
})

router.put('/sizes', middleware.UserAuth, (req, res) => {
    let { variables } = req.body;

    if (variables.length) {
        db.getConnection().then((connection) => {

            variables.map((item) => {
                db.procedure('call sp_USER_LIST_CURRENT_UPDATE(?)', [req.user.id, item.id, item.value], connection).then((result) => {

                })
            })
            res.json({ status: 'success' })

            connection.release();
        }).catch((error) => {
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
});

router.post('/sub/create', middleware.UserAuth, (req, res) => {
    let { variables, firstname, lastname, genderType, cityId, stateId, age } = req.body;

    if (variables.length && firstname && lastname && genderType && cityId && stateId && age) {
        db.getConnection().then((connection) => {

            db.procedure('call sp_USER_SUB_ACCOUNT_CREATE(?)', [req.user.id, firstname, lastname, genderType, age, cityId, stateId, req.ip], connection).then((result) => {
                if (result.STATUS === 'success') {
                    variables.map((item) => {
                        db.procedure('call sp_USER_LIST_CURRENT_SET(?)', [result.SUB_USER_ID, item.id, item.value], connection).then((result) => {

                        })
                    })
                    res.json({ status: 'success' })
                }
                else {
                    res.json({ status: 'error' });
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

router.get('/sub/accounts', middleware.UserAuth, (req, res) => {
    db.getConnection().then((connection) => {
        db.procedure('call sp_USER_SUB_ACCOUNT_LIST(?)', [req.user.id], connection, 'list').then((result) => {
            let tmpAccount = [];
            if (result.length) {
                result.map((user) => {
                    tmpAccount = [
                        ...tmpAccount,
                        {
                            userId: user.SUB_USER_ID,
                            firstname: user.SUB_FIRSTNAME,
                            lastname: user.SUB_LASTNAME,
                            createdDate: user.SUB_CREATED_DATE,
                            token: jwt.CreateToken({ id: user.SUB_USER_ID }),
                            main: false
                        }
                    ]
                })

                tmpAccount = [{
                    userId: result[0].MAIN_USER_ID,
                    firstname: result[0].MAIN_FIRSTNAME,
                    lastname: result[0].MAIN_LASTNAME,
                    createdDate: result[0].MAIN_CREATED_DATE,
                    token: jwt.CreateToken({ id: result[0].MAIN_USER_ID }),
                    main: true
                }, ...tmpAccount];

                res.json({ status: 'success', accounts: tmpAccount })
            }
            else {
                res.json({ status: 'success', accounts: [] });
            }


        })

        connection.release();
    }).catch((error) => {
        res.status(500).send();
    })
})

router.post('/sub/delete', middleware.UserAuth, (req, res) => {
    let { ids } = req.body;

    if (ids.length) {
        db.getConnection().then((connection) => {
            ids.map((id) => {
                db.procedure('call sp_USER_SUB_ACCOUNT_DELETE(?)', [req.user.id, id], connection).then((result) => {

                })
            })
            res.json({ status: 'success' })
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