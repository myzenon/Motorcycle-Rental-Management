module.exports = function (ipcMain, mysqlPool) {
  ipcMain.on('add-motorcycle', function (event, data) {
    mysqlPool.getConnection(function(error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        return;
      }
      else {
        query_command = 'CALL insert_motorcycle(@brand_id, "@brand_new", "@model", "@plate_number", @cost, @collateral, @price_per_day, @price_per_month)'
          .replace('@brand_id', data.brand.id)
          .replace('@brand_new', data.brand_new)
          .replace('@model', data.model)
          .replace('@plate_number', data.plate_number)
          .replace('@cost', data.cost)
          .replace('@collateral', data.collateral)
          .replace('@price_per_day', data.price_per_day === '' ? null : data.price_per_day)
          .replace('@price_per_month', data.price_per_month === '' ? null : data.price_per_month)
        ;
        console.log(query_command);
        connection.query(query_command, function(error) {
          if(error) {
            event.sender.send('mysql-error', error);
          }
          else {
            event.sender.send('add-motorcycle-complete');
          }
          connection.release();
        });
      }
    });
  });
  ipcMain.on('edit-motorcycle', function (event, data) {
    mysqlPool.getConnection(function(error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        return;
      }
      else {
        query_command = 'CALL edit_motorcycle(@id, @brand_id, "@brand_new", "@model", "@plate_number", @cost, @collateral, @price_per_day, @price_per_month)'
          .replace('@id', data.id)
          .replace('@brand_id', data.brand.id)
          .replace('@brand_new', data.brand_new)
          .replace('@model', data.model)
          .replace('@plate_number', data.plate_number)
          .replace('@cost', data.cost)
          .replace('@collateral', data.collateral)
          .replace('@price_per_day', data.price_per_day === '' ? null : data.price_per_day)
          .replace('@price_per_month', data.price_per_month === '' ? null : data.price_per_month)
        ;
        console.log(query_command);
        connection.query(query_command, function(error) {
          if(error) {
            event.sender.send('mysql-error', error);
          }
          else {
            event.sender.send('edit-motorcycle-complete');
          }
          connection.release();
        });
      }
    });
  });
  ipcMain.on('delete-motorcycle', function (event, id) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        connection.query('CALL delete_motorcycle(' + id + ')', function(error, rows) {
          if(error) {
            event.sender.send('mysql-error', error);
            event.returnValue = null;
          }
          else {
            event.returnValue = true;
          }
          connection.release();
        });
      }
    });
  });
  ipcMain.on('get-brand', function (event) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        connection.query('SELECT * FROM brand', function(error, rows) {
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
  ipcMain.on('get-motorcycle-list', function (event, data) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        $query_command = 'SELECT * FROM motorcycle_list';
        if(data.filter) {
          $query_command += ' WHERE status = "avaliable"';
        }
        connection.query($query_command, function(error, rows) {
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
  ipcMain.on('get-motorcycle-list-search', function (event, data) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        $query_command = 'SELECT * FROM motorcycle_list WHERE (CONCAT(brand_name, " ", model) LIKE "%' + data.search  + '%" OR plate_number LIKE "%' + data.search  + '%")';
        if(data.filter) {
          $query_command += ' AND status = "avaliable"'
        }
        connection.query($query_command, function(error, rows) {
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
  ipcMain.on('get-motorcycle-view', function (event, id) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        connection.query('SELECT * FROM motorcycle_view WHERE id = ' + id, function(error, rows) {
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
  ipcMain.on('get-motorcycle-repair', function (event, id) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        connection.query('SELECT * FROM repair_view WHERE date_send IS NULL = 0 AND date_return IS NULL = 0 AND motorcycle_id = ' + id, function(error, rows) {
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
  ipcMain.on('get-motorcycle-rental', function (event, id) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        connection.query('SELECT * FROM rental_list WHERE motorcycle_id = ' + id, function(error, rows) {
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
  ipcMain.on('get-repair-n', function (event, id) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        connection.query('SELECT * FROM repair_view WHERE date_send IS NULL = 1', function(error, rows) {
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
  ipcMain.on('get-repair-w', function (event, id) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        connection.query('SELECT * FROM repair_view WHERE date_send IS NULL = 0 AND date_return IS NULL = 1', function(error, rows) {
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
  ipcMain.on('get-repair-view', function (event, id) {
    mysqlPool.getConnection(function (error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        event.returnValue = null;
        return;
      }
      else {
        connection.query('SELECT * FROM repair_view WHERE id = ' + id, function(error, rows) {
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
  ipcMain.on('update-repair', function (event, data) {
    mysqlPool.getConnection(function(error, connection) {
      if(error) {
        event.sender.send('mysql-error', error);
        return;
      }
      else {
        query_command = 'CALL update_repair(@id, "@problem", @cause, @cost)'
          .replace('@id', data.id)
          .replace('@problem', data.problem)
          .replace('@cause', data.cause === null ? null : '"' + data.cause + '"')
          .replace('@cost', data.cost)
        ;
        console.log(query_command);
        connection.query(query_command, function(error) {
          if(error) {
            event.sender.send('mysql-error', error);
          }
          else {
            event.sender.send('update-repair-complete');
          }
          connection.release();
        });
      }
    });
  });
};
