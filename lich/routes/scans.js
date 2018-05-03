var express = require('express');
var router = express.Router();
var Scans = require('./../models/scans');


/* GET scans - index */
router.get('/', function(req, res, next) {
  Scans.all({ success: function(data) {
    res.send(JSON.stringify(data));
  }, error: function(message) {
    res.send({ success: false, message: message });
  }});
});

/* GET scans/INDEX - show */
router.get('/:scanId', function(req, res, next) {

  var scanId = req.params.scanId;

  Scans.get(scanId, function(data) {
    res.send(data);
  }, function(error) {
    res.send({ success: false, message: error });
  });

});

/* POST scans - create */
router.post('/', function(req, res, next) {
  var data = JSON.stringify(req.body);

  Scans.save(data, function(err, other) {
    if (err) {
      res.send({ success: false, message: err });
    } else {
      res.send({ success: true, id: other });
    }
  });
});

/* DELETE scans - delete */
router.delete('/:scanId', function(req, res, next) {

  var scanId = req.params.scanId;

  var result = Scans.delete(scanId, function(err, id) {
    if (err) {
      console.log('Failed to Deleted!');
      res.send({ success: false , message: err });
    } else {
      console.log('Deleted!');
      res.send({ succes: true, id: id });
    }
  });
});

module.exports = router;
