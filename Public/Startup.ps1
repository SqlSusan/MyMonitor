import-module "C:\Users\costco\Documents\GitHub\SqlSusan\MyMonitor\MyMonitor.psm1"

get-command -module mymonitor

import-module pssqlite

get-command -module pssqlite

$C = New-SQLiteConnection -DataSource "C:\Names.SQLite"
