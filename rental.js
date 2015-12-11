module.exports = function (ipcMain, mysqlPool, debug) {
  ipcMain.on('add-rental', function (event, data) {
    mysqlPool.getConnection(function(error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        return;
      }
      else {
        var query_command = 'CALL insert_rental (@motorcycle_id, "@firstname", "@lastname", "@cznum", "@dlnum", "@phone", "@type", @amount, "@date_return_expect")'
          .replace('@motorcycle_id', data.motorcycle_id)
          .replace('@firstname', data.firstname)
          .replace('@lastname', data.lastname)
          .replace('@cznum', data.cznum)
          .replace('@dlnum', data.dlnum)
          .replace('@phone', data.phone)
          .replace('@type', data.type)
          .replace('@amount', data.amount)
          .replace('@date_return_expect', data.date_return_expect)
        ;
        if(debug) {
          console.log(query_command);
        }
        connection.query(query_command, function(error) {
          if(error) {
            event.sender.send('mysql-error', error);
          }
          else {
            event.sender.send('add-rental-complete', data.total_cost);
          }
          connection.release();
        });
      }
    });
  });
  ipcMain.on('get-rental-list', function (event) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        var query_command = 'SELECT * FROM rental_list';
        if(debug) {
          console.log(query_command);
        }
        connection.query(query_command, function(error, rows) {
          if(error) {
            event.sender.send('mysql-error', error);
            event.returnValue = null;
          }
          else {
            event.returnValue = rows;
          }
          connection.release();
        });
      }
    });
  });
  ipcMain.on('get-rental-list-search', function (event, data) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        var query_command = 'SELECT * FROM rental_list WHERE';
        query_command += ' (CONCAT(brand_name, " ", model) LIKE "%' + data  + '%"';
        query_command += ' OR plate_number LIKE "%' + data + '%"';
        query_command += ' OR id LIKE "%' + data + '%")';
        query_command += ' OR (CONCAT(firstname, " ", lastname) LIKE  "%' + data + '%")';
        if(debug) {
          console.log(query_command);
        }
        connection.query(query_command, function(error, rows) {
          if(error) {
            event.sender.send('mysql-error', error);
            event.returnValue = null;
          }
          else {
            event.returnValue = rows;
          }
          connection.release();
        });
      }
    });
  });
  ipcMain.on('get-rental-view', function (event, id) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        var query_command = 'SELECT * FROM rental_view';
        if(id) {
          query_command += ' WHERE id = ' + id;
        }
        if(debug) {
          console.log(query_command);
        }
        connection.query(query_command, function(error, rows) {
          if(error) {
            event.sender.send('mysql-error', error);
            event.returnValue = null;
          }
          else {
            event.returnValue = rows;
          }
          connection.release();
        });
      }
    });
  });
  ipcMain.on('return-rental', function (event, data) {
    mysqlPool.getConnection(function(error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        return;
      }
      else {
        query_command = 'CALL return_rental(@id, @nrepair, @fine)'
          .replace('@id', data.id)
          .replace('@nrepair', data.nrepair)
          .replace('@fine', data.fine)
        ;
        if(debug) {
          console.log(query_command);
        }
        connection.query(query_command, function(error) {
          if(error) {
            event.sender.send('mysql-error', error);
          }
          else {
            var refund = data.collateral - data.fine;
            event.sender.send('return-rental-complete', refund);
          }
          connection.release();
        });
      }
    });
  });
};
