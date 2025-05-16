var express = require('express');
var router = express.Router();
const { customAlphabet } = require('nanoid');
const nanoid = customAlphabet('1234567890', 6)

var db = require('@helpers/database');
var jwt = require('@helpers/jwt');
var mailer = require('@helpers/mailer');
var validator = require('@helpers/validator');
var middleware = require('@helpers/middleware');

//#region Password Reset
router.post('/reset', (req, res) => {
    let { email } = req.body;

    if (validator.IsEmail(email)) {
        db.getConnection().then((connection) => {
            let uniqCode = nanoid();

            db.procedure('call sp_COACH_PASSWORD_RESET_CREATE(?)', [email, uniqCode, req.ip], connection).then((result) => {
                if (result.STATUS === 'success') {
                    let token = jwt.CreateToken({ email: email, code: uniqCode });
                    let url = `${process.env.APP_DOMAIN}/coach/password/reset/${token}`;

                    let sendStatus = mailer.SendMail('FULLBODYGYM', email, 'Şifre Sıfırlama', `Aşağıdaki bağlantı ile şifrenizi sıfırlayın.\n\n${url}`);
                }

                res.json({ status: result.STATUS }).send();
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

router.get('/reset/verify/:verifyToken', (req, res) => {
    let { verifyToken } = req.params;

    if (verifyToken) {
        jwt.TokenVerify(verifyToken).then((decoded) => {
            db.getConnection().then((connection) => {
                db.procedure('call sp_COACH_PASSWORD_RESET_CODE_VERIFY(?)', [decoded.email, decoded.code], connection).then((result) => {
                    res.json({ 'status': result.STATUS });
                })
                connection.release();
            }).catch((error) => {
                res.status(500).send();
            })
        }).catch((error) => {
            res.json({ status: 'invalid-code' });
        })
    }
    else {
        res.status(400).send();
    }
});

router.put('/new', (req, res) => {
    let { verifyToken, newPassword } = req.body;

    if (verifyToken) {
        jwt.TokenVerify(verifyToken).then((decoded) => {
            db.getConnection().then((connection) => {
                db.procedure('call sp_COACH_PASSWORD_RESET_CODE_VERIFY(?)', [decoded.email, decoded.code], connection).then((result) => {

                    if (result.STATUS === 'success') {
                        let newPasswordHash = jwt.CreatePasswordHash(newPassword);
                        
                        db.procedure('call sp_COACH_NEW_PASSWORD_SET(?)', [result.COACH_ID, decoded.code, newPasswordHash], connection).then((result) => {
                            res.json({ 'status': result.STATUS });
                        })
                    }
                    else {
                        res.json({ 'status': result.STATUS });
                    }
                })
                connection.release();
            }).catch((error) => {
                res.status(500).send();
            })
        }).catch((error) => {
            res.json({ status: 'invalid-code' });
        })
    }
    else {
        res.status(400).send();
    }
});
//#endregion

//#region Password Update
router.put('/update', middleware.CoachAuth, (req, res) => {
    let {currentPassword, newPassword} = req.body;

    if(currentPassword && newPassword && newPassword.length >= 8) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_AUTH(?)', [req.user.id], connection).then((result) => {
                if(jwt.ComparePassword(currentPassword, result.PASSWORD_HASH)) {
                    let newPasswordHash = jwt.CreatePasswordHash(newPassword);
                    db.procedure('call sp_COACH_PASSWORD_UPDATE(?)', [req.user.id, newPasswordHash], connection).then((result) => {
                        res.json({status: result.STATUS});
                    })
                }
                else {
                    res.json({status: 'current-password-wrong'});
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
//#endregion
module.exports = router;