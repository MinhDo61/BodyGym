const express = require('express');
const router = express.Router();
const google = require('../helpers/google');
const db = require('../helpers/database');
const jwt = require('../helpers/jwt');

const handleDbConnection = async (procedure, params = [], resultKey = null) => {
    const connection = await db.getConnection();
    try {
        const result = await db.procedure(procedure, params, connection, resultKey);
        return result;
    } finally {
        connection.release();
    }
};

router.post('/google', async (req, res) => {
    const { credential } = req.body;

    if (!credential) {
        return res.status(400).send({ error: 'Credential is required' });
    }

    try {
        const userInfo = await google.VerifyToken(credential);
        const { email, given_name, family_name } = userInfo;
        const result = await handleDbConnection('call sp_COACH_LOGIN_WITH_GOOGLE(?, ?, ?, ?)', 
                                                 [email, given_name, family_name, req.ip]);

        const token = jwt.CreateToken({ id: result.COACH_ID, provider: 'google' });

        res.redirect(`${process.env.APP_DOMAIN}/coach?token=${token}&firstname=${result.FIRSTNAME}&lastname=${result.LASTNAME}&provider=google`);
    } catch (error) {
        console.error(error);
        res.status(500).send({ error: 'Internal Server Error' });
    }
});

router.get('/cities', async (req, res) => {
    try {
        const cities = await handleDbConnection('call sp_CITY_LIST_GET()', [], 'list');
        res.json({ status: 'success', cities });
    } catch (error) {
        console.error(error);
        res.status(500).send({ error: 'Internal Server Error' });
    }
});

router.get('/state/:cityId', async (req, res) => {
    const { cityId } = req.params;

    if (!cityId) {
        return res.status(400).send({ error: 'City ID is required' });
    }

    try {
        const states = await handleDbConnection('call sp_STATE_LIST_GET(?)', [cityId], 'list');
        res.json({ status: 'success', states });
    } catch (error) {
        console.error(error);
        res.status(500).send({ error: 'Internal Server Error' });
    }
});

module.exports = router;
