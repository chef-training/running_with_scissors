var express = require('express');
var router = express.Router();
var syllable = require('syllable');

router.get('/', function(req, res, next) {
  console.log("Loading Index Page");
  res.render('index', {});
});

module.exports = router;
