var nodemailer = require('nodemailer');

var transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
	port: process.env.EMAIL_PORT,
	secure: true,
	auth: {
		user: process.env.EMAIL_ADDRESS,
		pass: process.env.EMAIL_PASSWORD,
	},
});

module.exports = {
    SendMail: function (title, to, subject, content) {
        var mailOptions = {
            from: `"${title}" <${process.env.EMAIL_ADDRESS}>`, //Gönderici adres
            to: to, //alıcı adres
            subject: subject, //konu 
            text: content, // içerik
        };

        
        transporter.sendMail(mailOptions, function (error, info) {
            
            if (error) {
                return false;
            }
            else {
                return true;
            }
        });
    },
}