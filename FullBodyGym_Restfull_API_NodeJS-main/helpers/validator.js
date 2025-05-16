module.exports = {
    IsEmail: function(email) {
        var emailRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{3,3})+$/;
        var res = emailRegex.exec(email);
        return !!res;
    }
}