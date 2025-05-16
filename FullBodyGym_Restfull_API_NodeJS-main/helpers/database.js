var mysql = require('mysql');

// Veri tabanı bağlantısı.
const connectionPool = mysql.createPool({
    connectionLimit: process.env.DB_POOL_CONNECTION_LIMIT,
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
});

// MySQL prosedürlerinden gelecek verileri parçalamak için kullanılacak.
function DataParse(results, type = 'item') {
	if(results.length) {
        let temp = []
        let temp1 = {};
        results.map((item) => {
            try {
                item.map((subItem) => {
                    temp = [...temp, subItem];
                })
            } catch (e) {
                //
            }
        });
        
        temp.map((item) => {
            temp1 = { ...temp1, ...item };
        })

        if(type == 'item') {
            return temp1;
        }
        else if(type == 'list') {
            return temp
        }
    }
    else {
        return []
    }
}

module.exports = {
    getConnection: function () {
        return new Promise(function (resolve, reject) {
            connectionPool.getConnection(function (err, connection) {
               
                if (err) { 
                    reject(err);
                    console.log('MySQL --> Connection error!', err);
                   
                } else { 
                    resolve(connection); 
                    /* console.log(`All Connections ${connectionPool._allConnections.length}`);
                    console.log(`Acquiring Connections ${connectionPool._acquiringConnections.length}`);
                    console.log(`Free Connections ${connectionPool._freeConnections.length}`);
                    console.log(`Queue Connections ${connectionPool._connectionQueue.length}`);
                    console.log(`connecting to db with id: ${connection.threadId}`); */

                    //console.log('MySQL --> Connection successfully!') 
                }
            })
        })
    },
    
    procedure: function (query, data, connection, returnType = 'item') {
        return new Promise(function (resolve, reject) {
            connection.query(query, [data], function (error, results) {
               
                if (error) {
                    reject(error);
                }
                else {
                    resolve(DataParse(results, returnType));
                }
            })
        })
    },
}