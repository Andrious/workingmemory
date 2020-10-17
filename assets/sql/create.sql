
-- Drop the table first
DROP TABLE IF EXISTS working;

-- TODO Timezone stored in VARCHAR seems a waste of space.
-- SQL Statement to create a new database.
-- Note: if the database names change, change the code in appModel.ToDoList()
CREATE TABLE IF NOT EXISTS working (
id integer primary key autoincrement
, Item VARCHAR
, KeyFld VARCHAR
, DateTime VARCHAR
, DateTimeEpoch Long
, TimeZone VARCHAR
, ReminderChk integer default 0
, LEDColor integer default 0
, Fired integer default 0
, SetAlarm integer default 1
, deleted integer default 0
);

-- Drop the table first
DROP TABLE IF EXISTS icons;

CREATE TABLE IF NOT EXISTS icons(
id integer primary key autoincrement
, resid integer not null
,FOREIGN KEY (resid) REFERENCES working(id)
);