var express = require('express');
var router = express.Router();
const { customAlphabet } = require('nanoid');
const nanoid = customAlphabet('1234567890', 8)

var db = require('../../../../../helpers/database');
var middleware = require('../../../../../helpers/middleware');

router.get('/all', middleware.UserAuth, (req, res) => {
    db.getConnection().then((connection) => {
        db.procedure('call sp_LIST_CURRENT_NAME_GET(?)', [req.user.id], connection, 'list').then((result) => {
            res.json({
                status: 'success',
                lists: result || []
            })
        })

        connection.release();
    }).catch((error) => {
        res.status(500).send();
    })
})

router.get('/variables', middleware.UserAuth, (req, res) => {
    db.getConnection().then((connection) => {
        db.procedure('call sp_COACH_LIST_VARIABLE_GET()', [], connection, 'list').then((result) => {
            res.json({ status: 'success', variables: result })
        })

        connection.release();
    }).catch((error) => {
        res.status(500).send();
    })
})

router.get('/:listCode', middleware.UserAuth, (req, res) => {
    let { listCode } = req.params;

    if (listCode) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_USER_LIST_GET(?)', [listCode, req.user.id], connection).then((result) => {
                if (result.LIST_ID) {
                    if (result.STATUS === 'already-use-list') {
                        res.json({ status: result.STATUS });
                    }
                    else {
                        db.procedure('call sp_COACH_LIST_VARIABLE_WITH_TITLE(?)', result.LIST_ID, connection, 'list').then((variableResult) => {
                            res.json({ status: 'success', list: result, variable: variableResult })
                        })
                    }
                }
                else {
                    db.procedure('call sp_USER_LIST_GET_WITHOUT_SHARED(?)', [listCode, req.user.id], connection).then((result) => {
                        if (result.LIST_ID) {
                            if (result.STATUS === 'already-use-list') {
                                res.json({ status: result.STATUS });
                            }
                            else {
                                db.procedure('call sp_COACH_LIST_VARIABLE_WITH_TITLE(?)', result.LIST_ID, connection, 'list').then((variableResult) => {
                                    res.json({ status: 'success', list: result, variable: variableResult })
                                })
                            }
                        }
                        else {
                            res.json({ status: 'list-not-found' });
                        }
                    })
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
})

router.post('/', middleware.UserAuth, (req, res) => {
    let { variables } = req.body;

    if (variables.length) {
        db.getConnection().then((connection) => {

            variables.map((item) => {
                db.procedure('call sp_USER_LIST_CURRENT_SET(?)', [req.user.id, item.id, item.value], connection).then((result) => {

                })
            })
            res.json({ status: 'success' })

            connection.release();
        }).catch((error) => {
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
})

router.post('/save', middleware.UserAuth, (req, res) => {
    let { listId } = req.body;

    if (listId) {
        let uniqCode = nanoid();

        db.getConnection().then((connection) => {
            db.procedure('call sp_USER_LIST_SAVE(?)', [req.user.id, listId, uniqCode], connection).then((result) => {
                res.json({ status: result.STATUS });
            })

            connection.release();
        }).catch((error) => {
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
})

router.post('/detail', middleware.UserAuth, (req, res) => {
    let { listCode } = req.body;

    if (listCode) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_USER_LIST_GET(?)', [listCode, req.user.id], connection).then((result) => {
                if (result.LIST_ID) {
                    db.procedure('call sp_USER_LIST_DETAIL(?)', [req.user.id, result.LIST_ID], connection, 'list').then((variableResult) => {
                        res.json({ status: 'success', list: result, variable: variableResult })
                    })
                }
                else {
                    res.json({ status: 'list-not-found' });
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

router.delete('/:listId', middleware.UserAuth, (req, res) => {
    let { listId } = req.params;

    if (listId) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_USER_LIST_DETAIL_DELETE(?)', [req.user.id, listId], connection).then((result) => {
                res.json({ status: result.STATUS });
            })

            connection.release();
        }).catch((error) => {
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
})

router.post('/sub', (req, res) => {
    let { code } = req.body;

    if (code) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_USER_LIST_GET_WITH_CODE(?)', [code], connection).then((result) => {
                if (result.USER_ID) {
                    db.procedure('call sp_USER_LIST_GET(?)', [result.LIST_ID, result.USER_ID], connection).then((resultList) => {
                        if (result.LIST_ID) {
                            db.procedure('call sp_USER_LIST_DETAIL(?)', [result.USER_ID, resultList.LIST_ID], connection, 'list').then((variableResult) => {
                                res.json({ status: 'success', list: resultList, variable: variableResult })
                            })
                        }
                        else {
                            res.json({ status: 'list-not-found' });
                        }
                    })
                }
                else {
                    res.json({ status: 'code-not-found' });
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


module.exports = router;