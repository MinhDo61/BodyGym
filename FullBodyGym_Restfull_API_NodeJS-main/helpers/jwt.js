var bcrypt = require('bcryptjs');
const jwt = require("jsonwebtoken");

module.exports = {
    CreatePasswordHash: function(password) {
        let encryptedPassword = bcrypt.hashSync(password, 10);
        return encryptedPassword;
    },
    CreateToken: function(data) {
        let token = jwt.sign(data, process.env.JWT_TOKEN_KEY, { expiresIn: process.env.JWT_EXPIRES_IN });
        return token;
    },
    ComparePassword: function(requestPassword, savedPassword) {
        let result = bcrypt.compareSync(requestPassword, savedPassword);
        return result;
    },
    TokenVerify: function(token) {
        return new Promise(function (resolve, reject) {
            try {
                let decoded = jwt.verify(token, process.env.JWT_TOKEN_KEY, {algorithms: 'HS256'});
                resolve(decoded);
            }
            catch (error) {
                reject(error);
            }
        })
        
    }
}