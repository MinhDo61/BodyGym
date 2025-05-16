var express = require('express');
var router = express.Router();
var axios = require('axios').default;

var db = require('@helpers/database');
var jwt = require('@helpers/jwt');
var validator = require('@helpers/validator');

router.post('/', (req, res) => {
    let { email, password } = req.body;

    if (validator.IsEmail(email) && password && password.length >= 8) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_USER_LOGIN_WITH_EMAIL(?)', [email], connection).then((result) => {
                if (result.STATUS === undefined) {
                    if (jwt.ComparePassword(password, result.PASSWORD_HASH)) {
                        let token = jwt.CreateToken({ id: result.USER_ID, hash: result.PASSWORD_HASH, provider: 'email' });

                        res.json({
                            status: 'success',
                            userId: result.USER_ID,
                            token,
                            profile: {
                                firstname: result.FIRSTNAME,
                                lastname: result.LASTNAME,
                                email: result.EMAIL,
                                gender: result.GENDER,
                                age: result.AGE
                            },
                            provider: 'email',
                            bodyStatus: result.BODY_STATUS
                        })
                    }
                    else {
                        res.json({ status: 'email-or-password-wrong' })
                    }
                }
                else {
                    res.json({ status: result.STATUS })
                }
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

router.post('/with/google', function (req, res) {
    let { accessToken } = req.body;

    if (accessToken) {
        axios.get(process.env.GOOGLE_WITH_LOGIN_OAUTH2_API, { headers: { 'Authorization': `Bearer ${accessToken}` } }).then((resp) => {
            if (resp.data.email) {
                let { given_name, family_name, email } = resp.data;

                db.getConnection().then((connection) => {
                    db.procedure('call sp_USER_LOGIN_WITH_EMAIL(?)', [email], connection).then((result) => {
                        if (result.STATUS != 'account-unverified' && result.STATUS !== 'email-or-password-wrong') {
                            let token = jwt.CreateToken({ id: result.USER_ID, provider: 'google' });
                            res.json({ 'status': 'success', 'token': token, userId: result.USER_ID, bodyStatus: result.BODY_STATUS });
                        }
                        else {
                            db.procedure('call sp_USER_REGISTER_WITH_GOOGLE(?)', [given_name, family_name, email, req.ip], connection).then((regResult) => {
                                if (regResult.STATUS == 'success') {
                                    let token = jwt.CreateToken({ id: regResult.USER_ID, provider: 'google' });
                                    res.json({ 'status': 'success', 'token': token, userId: regResult.USER_ID, bodyStatus: 'body-size-not-found' });
                                }
                            }).catch((error) => {
                                //console.log(error)
                                res.status(500).send();
                            })
                        }
                    }).catch((error) => {
                        console.log(error)
                        res.status(500).send();
                    });

                    connection.release();
                }).catch((error) => {
                    res.status(500).send();
                })
            }
            else {
                res.status(400).send();
            }
        }).catch((error) => {
            res.status(400).json(error.response.data);
        })
    }
    else {
        res.status(400).send();
    }
});

router.post('/with/facebook', (req, res) => {
    let { facebookUserId, accessToken } = req.body;

    if (facebookUserId && accessToken) {
        axios.get(`https://graph.facebook.com/${facebookUserId}?fields=first_name,email,last_name&access_token=${accessToken}`).then((resp) => {
            let { first_name, last_name, email, id } = resp.data;

            db.getConnection().then((connection) => {
                //
                db.procedure('call sp_USER_LOGIN_WITH_FACEBOOK(?)', [id], connection).then((result) => {
                    if (result.STATUS != 'user-not-found') {
                        let token = jwt.CreateToken({ id: result.USER_ID, provider: 'facebook' });
                        res.json({ 'status': 'success', 'token': token, userId: result.USER_ID, bodyStatus: result.BODY_STATUS });
                    }
                    else {
                        db.procedure('call sp_USER_REGISTER_WITH_FACEBOOK(?)', [first_name, last_name, email, req.ip, id], connection).then((result) => {

                            if (result.STATUS == 'success') {
                                let token = jwt.CreateToken({ id: result.USER_ID, provider: 'facebook' });
                                res.json({ 'status': 'success', 'token': token, userId: result.USER_ID, bodyStatus: 'body-size-not-found' });
                            }
                            else {
                                res.status(500).send();
                            }
                        }).catch((error) => {
                            res.status(500).send();
                        });
                    }
                }).catch((error) => {
                    res.status(500).send();
                });

                connection.release();
            }).catch((error) => {
                res.status(500).send();
            });
        }).catch((error) => {
            res.status(400).json(error.response.data);
        })
    }
    else {
        res.status(400).send();
    }
});


module.exports = router;