var express = require('express');
var router = express.Router();
const { customAlphabet } = require('nanoid');
const nanoid = customAlphabet('1234567890', 6)

var db = require('@helpers/database');
var mailer = require('@helpers/mailer');
var validator = require('@helpers/validator');
var jwt = require('@helpers/jwt');

router.post('/', (req, res) => {
    let { firstname, lastname, email, genderType, cityId, stateId, age, password } = req.body;

    if (firstname && lastname && validator.IsEmail(email) && genderType && age && password.length >= 8) {
        db.getConnection().then((connection) => {
            let uniqCode = nanoid();
            let passwordHash = jwt.CreatePasswordHash(password);

            db.procedure('call sp_USER_REGISTER_WITH_EMAIL(?)', [
                firstname,
                lastname,
                email,
                genderType,
                age,
                cityId,
                stateId,
                passwordHash,
                uniqCode,
                req.ip
            ], connection).then((result) => {
                if(result.STATUS === 'success') {
                    let token = jwt.CreateToken({id: result.USER_ID, code: uniqCode});
                    let url = `${process.env.APP_DOMAIN}/user/verify.html?token=${token}`;

                    let sendStatus = mailer.SendMail('FULLBODYGYM', email, 'Kursiyer Hesap Doğrulama', `Aşağıdaki bağlantı ile hesabınızı doğrulayabilirsiniz.\n\n${url}`);
                }

                res.json({ status: result.STATUS });
            })

            connection.release();
        }).catch((error) => {
            console.log(error)
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
});

router.get('/verify/:verifyToken', (req, res) => {
    let {verifyToken} = req.params;

    if(verifyToken) {
        jwt.TokenVerify(verifyToken).then((decoded) => {
            db.getConnection().then((connection) => {
                db.procedure('call sp_USER_VERIFY_ACCOUNT(?)', [decoded.id, decoded.code], connection).then((result) => {
                    res.json({ 'status': result.STATUS });
                })
                connection.release();
            }).catch((error) => {
                res.status(500).send();
            })
        }).catch((error) => {
            res.json({status: 'invalid-code'});
        })
    }
    else {
        res.status(400).send();
    }
});

module.exports = router;