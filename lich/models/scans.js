var nconf = require('nconf');
var db = require('../db');

var Scans = {
  all: function(handlers) {
    db.all("SELECT id, data FROM scans", function(err, rows) {
      if (err) {
        handlers.error(err);
      } else {
        handlers.success(rows);
      }
    });
  },
  get: function(id, successHandler, errorHandler) {
    db.get("SELECT id, data FROM scans WHERE id = ?", [ id ], function(err, row) {
      if (err) {
          errorHandler(err);
      } else {
        if (row === undefined) {
          errorHandler("No record found with ID");
        } else {
          successHandler(row);
        }
      }
    });
  },
  save: function(data,resultHandler) {
    db.run("INSERT INTO scans (data) VALUES (?)", [data], function(err) {
      resultHandler(err,this.lastID);
    });
  },
  delete: function(id, resultHandler) {
    db.run("DELETE FROM scans WHERE id = ?", [ id ], function(err) {
      resultHandler(err,this.lastID);
    });
  }
}

module.exports = Scans;
