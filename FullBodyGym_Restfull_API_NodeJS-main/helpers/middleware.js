var db = require('./database');
var jwt = require('./jwt');

module.exports = {
    CoachAuth: function (req, res, next) {
        let token = req.headers['token'];
        /* Token boş gelmesi durumda yasaklı olduğunu bildiriyor */
        if (!token) {
            return res.status(403).send();
        }

        jwt.TokenVerify(token).then((decoded) => {
            req.user = decoded;
            next();
        }).catch((error) => {
            /* Tokenin yanlış gelmesi durumunda yasaklı olduğunu bildiriyor */
            
            return res.status(403).send();
        })
    },
    UserAuth: function (req, res, next) {
        let token = req.headers['token'];
        /* Token boş gelmesi durumda yasaklı olduğunu bildiriyor */
        if (!token) {
            return res.status(403).send();
        }
        
        jwt.TokenVerify(token).then((decoded) => {
            req.user = decoded;
            next();
        }).catch((error) => {
            /* Tokenin yanlış gelmesi durumunda yasaklı olduğunu bildiriyor */
            return res.status(403).send();
        })
    }
}