const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_WITH_LOGIN_CLIENT_ID);

module.exports = {
    VerifyToken: function (token) {
        return new Promise(function (resolve, reject) {
            client.verifyIdToken({
                idToken: token,
                audience: process.env.GOOGLE_WITH_LOGIN_CLIENT_ID,
            }).then((ticket) => {
                const payload = ticket.getPayload();
                const userid = payload['sub'];
                resolve(payload)
            }).catch((error) => {
                reject(error);
            })
        })
    }
}