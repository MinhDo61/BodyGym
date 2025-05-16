var express = require('express');
var router = express.Router();

var db = require('@helpers/database');
var middleware = require('@helpers/middleware');

router.get('/', middleware.CoachAuth, (req, res) => {
    db.getConnection().then((connection) => {
        db.procedure('call sp_COACH_LIST_TABLE(?)', [req.user.id], connection, 'list').then((result) => {
            res.json({ status: 'success', list: result });
        })

        connection.release();
    }).catch((error) => {
        res.status(500).send();
    })
});

router.get('/get/:listId', middleware.CoachAuth, (req, res) => {
    let { listId } = req.params;

    if (listId) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_LIST(?)', [req.user.id, listId], connection, 'list').then((resultList) => {
                db.procedure('call sp_COACH_LIST_VARIABLE(?)', [listId], connection, 'list').then((resultVariable) => {
                    res.json({
                        status: 'success',
                        list: resultList[0] || [],
                        variables: resultVariable
                    })
                })
            })

            connection.release();
        }).catch((error) => {
            console.log(error);
            res.status(500).send();
        })
    }
    else {
        res.status(400).send();
    }
});



router.post('/', middleware.CoachAuth, (req, res) => {
    let { categoryId, listCode, listName, hallName, genderType, measureType, weightType, variables } = req.body;

    if (categoryId && listCode && listName && hallName && genderType && measureType && weightType) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_LIST_CREATE(?)', [
                req.user.id,
                categoryId,
                listCode,
                listName,
                hallName,
                genderType,
                measureType,
                weightType
            ], connection).then((result) => {
                if (result.STATUS === 'success') {
                    if (variables.length) {
                        variables.map((item) => {
                            if (item !== null) {
                                db.procedure('call sp_COACH_LIST_VARIABLE_ADD(?)', [result.LIST_ID, item.id, item.value], connection).then((result) => {

                                })
                            }
                        })
                    }

                    res.json({ status: 'success' })
                }
                else {
                    res.json({ status: result.STATUS })
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

router.delete('/:listId', middleware.CoachAuth, (req, res) => {
    let { listId } = req.params;

    if (listId) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_LIST_DELETE(?)', [req.user.id, listId], connection).then((result) => {
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

router.put('/', middleware.CoachAuth, (req, res) => {
    let { listId, categoryId, listCode, listName, hallName, genderType, measureType, weightType, variables } = req.body;

    if (listId && categoryId && listCode && listName && hallName && genderType && measureType && weightType) {
        db.getConnection().then((connection) => {
            db.procedure('call sp_COACH_LIST_UPDATE(?)', [
                req.user.id,
                listId,
                categoryId,
                listName,
                hallName,
                genderType,
                measureType,
                weightType
            ], connection).then((result) => {
                if (result.STATUS === 'success') {
                    if (variables.length) {
                        variables.map((item) => {
                            if (item !== null) {
                                db.procedure('call sp_COACH_LIST_VARIABLE_ADD(?)', [listId, item.id, item.value], connection).then((result) => {

                                })
                            }
                        })
                    }

                    res.json({ status: 'success' })
                }
                else {
                    res.json({ status: result.STATUS })
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



router.get('/options', middleware.CoachAuth, (req, res) => {
    db.getConnection().then((connection) => {
        db.procedure('call sp_COACH_LIST_CATEGORY_GET()', [], connection, 'list').then((resultCategory) => {

            db.procedure('call sp_COACH_LIST_VARIABLE_GET()', [], connection, 'list').then((resultVariable) => {
                res.json({
                    status: 'success',
                    categories: resultCategory,
                    variables: resultVariable
                })
            })
        })

        connection.release();
    }).catch((error) => {
        res.status(500).send();
    })
});

module.exports = router;