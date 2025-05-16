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
            db.procedure('call sp_COACH_LOGIN_WITH_EMAIL(?)', [email], connection).then((result) => {
                if (result.STATUS === undefined) {
                    if (jwt.ComparePassword(password, result.PASSWORD_HASH)) {
                        let token = jwt.CreateToken({ id: result.COACH_ID, hash: result.PASSWORD_HASH, provider: 'email' });

                        res.json({
                            status: 'success',
                            token,
                            profile: {
                                firstname: result.FIRSTNAME,
                                lastname: result.LASTNAME,
                                email: result.EMAIL,
                            },
                            provider: 'email'
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

router.post('/with/facebook', (req, res) => {
    let { accessToken, userId } = req.body;

    if (accessToken && userId) {
        const FACEBOOK_VERIFY_URI = `https://graph.facebook.com/${userId}?fields=first_name,last_name,email&access_token=${accessToken}`;

        axios.get(FACEBOOK_VERIFY_URI).then((resp) => {
            db.getConnection().then((connection) => {
                let {id, first_name, last_name, email} = resp.data;

                db.procedure('call sp_COACH_LOGIN_WITH_FACEBOOK(?)', [id,first_name, last_name, email, req.ip], connection).then((result) => {
                    if(result.STATUS === 'success') {
                        let token = jwt.CreateToken({id: result.COACH_ID, fid: id, provider: 'facebook' });

                        res.json({
                            status: 'success',
                            token,
                            profile: {
                                firstname: result.FIRSTNAME,
                                lastname: result.LASTNAME,
                            },
                            provider: 'facebook'
                        })
                    }
                    else {
                        res.status(400).send();
                    }
                })

                connection.release();
            }).catch((error) => {
                res.status(500).send();
            })

        }).catch((err) => {
            res.status(400).send();
        })
    }
    else {
        res.status(400).send();
    }
});
module.exports = router;