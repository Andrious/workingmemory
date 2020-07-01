///
/// Copyright (C) 2018 Andrious Solutions
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
/// http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  15 Nov 2018

import 'package:auth/auth.dart';

import 'package:workingmemory/src/app/controller/working_memory_app.dart';

import 'package:workingmemory/src/model.dart' show OnLoginListener;

class AppModel implements OnLoginListener {
  void onLogin() {}
//
//
//  appView mAppView;
//
//  Context mContext;
//
//  // Variable to hold the database instance
//  dbInterface mDBHelper;
//
//  dbInterface m2ndDB;
//
//  // An insert of a record will produce the rowid assigned the last record inserted.
//  double mLastRowID = 0;
//
//  bool mShowDeleted;
//
//  bool mOnlineData;
//
//
//
//  appModel(appView mVc){
//
//    mAppView = mVc;
//
//    mContext = mAppView.getContext();
//
////        mDBHelper = getDBHelper(mVc);
//
//    mDBHelper = dbSQLlite.getInstance(mAppView.getContext());
//
//    onDBSetup dbSetup = onDBSetup();
//
//    // Set a listener when the database is first created.
//    ((dbSQLlite) mDBHelper).setOnCreateListener(dbSetup);
//    ((dbSQLlite) mDBHelper).setOnConfigureListener(dbSetup);
//
//    m2ndDB = dbFireBase.getInstance(mAppView);
//
//    dbCloud.addOnLoginListener(this);
//  }
//
//
//
//  dbInterface getDBHelper(appView mVc){
//
//    return dbSQLlite.getInstance(mVc.getContext());
//  }
//
//
//
//  dbInterface resetDBHelper(){
//
//    if (mAppView == null){ return null; }
//
//    if (mDBHelper != null){
//
//      mDBHelper.onDestroy();
//
//      mDBHelper = null;
//    }
//
//    mDBHelper = getDBHelper(mAppView);
//
//    return mDBHelper;
//  }
//
//
//
//  bool open(){
//
//    bool opened = mDBHelper != null && mDBHelper.open().isOpen();
//
//    if (opened){
//
//      opened = mDBHelper.createCurrentRecs();
//
//      if (!opened){
//
//        mDBHelper.close();
//      }
//    }
//
//    return opened;
//  }
//
//
//
//  appView getView(){
//
//    return mAppView;
//  }
//
//
//
//  AppController getController(){
//
//    return mAppView.getController();
//  }
//
//
//
//  void close(){
//
//    mDBHelper.close();
//
//    m2ndDB.close();
//  }
//
//
//
//  double getLastRowID(){
//
//    if (mLastRowID == 0){
//
//      mLastRowID = mDBHelper.getLastRowID();
//    }
//
//    return mLastRowID;
//  }
//
//
//
//  bool save(ToDoItem itemToDo){
//
//    bool save = mDBHelper.save(itemToDo);
//
//    if (save){
//
//      bool sync = m2ndDB.isOpen();
//
//      if (sync){
//
//        String key = itemToDo.getKey();
//
//        // New if the key is empty.
//        itemToDo.newItem(key.isEmpty);
//
//        sync = m2ndDB.save(itemToDo);
//
//        if (sync){
//
//          if (key.isEmpty){
//
//            mDBHelper.save(itemToDo);
//          }
//
//          dbCloud.insert(itemToDo.getKey(), "UPDATE");
//        }
//      }
//
//      if (!sync){
//
//        dbCloud.save(itemToDo.getId(), itemToDo.getKey());
//      }
//    }
//    return save;
//  }
//
//
//
//  bool delete(ToDoItem itemToDo){
//
//    double id = itemToDo.getId();
//
//    bool delete = delete(id);
//
//    if (delete){
//
//      itemToDo.isDeleted(true);
//
//      if (!m2ndDB.isOpen() || !((dbFireBase) m2ndDB).markRec(itemToDo.getKey())){
//
//        // Record the deletion for the next sync.
//        dbCloud.delete(id, itemToDo.getKey());
//      }else{
//
//        if (dbCloud.insert(itemToDo.getKey(), "DELETE")){
//
//          itemToDo.setKey("");
//        }
//      }
//    }
//
//    return delete;
//  }
//
//
//
//  bool delete(double id){
//
//    return mDBHelper.markRec(id);
//  }
//
//
//
//  bool trueDelete(ToDoItem itemToDo){
//
//    return mDBHelper.deleteRec(itemToDo.getId()) > 0;
//  }
//
////    // Returns the database
////    SQLiteDatabase getDatabase(){
////
////        return mDBHelper.getDatabase();
////    }
//
//
//
//  bool showDeleted(){
//
//    return mShowDeleted;
//  }
//
//
//
//  bool showDeleted(bool showDeleted){
//
//    mShowDeleted = showDeleted;
//
//    return mShowDeleted;
//  }
//
//
//
//  List<ToDoItem> ToDoList(){
//
//    // Determine if deleted records are to be displayed.
//    mDBHelper.showDeleted(showDeleted(getBoolean("show_deleted", false)));
//
//    mDBHelper.clearResultSet();
//
//    return ToDoList(mDBHelper.getResultSet());
//  }
//
//
//
//  List<ToDoItem> ToDoList(Cursor recs){
//
//    return mDBHelper.ToDoList(recArrayList(recs));
//  }
//
//
//
//  List<ToDoItem> ToDoList(List<Map <String, String>> recs){
//
//    return mDBHelper.ToDoList(recs);
//  }
//
//
//
//
//  @Override
//  void onLogin(){
//
//    dbCloud.reSave(mDBHelper);
//  }
//
//
//
//
//  List<Map <String, String>> recArrayList(Cursor query){
//
//    List<Map <String, String>> list = List<>();
//
//    String value;
//
//    while (query.moveToNext()){
//
//      Map row = Map<String, String>();
//
//      //iterate over the columns
//      for (int col = 0; col < query.getColumnNames().length; col++){
//
//        //TODO You've got to use getType() and return  List<Map<String, Object>>   No?
//        value = query.getString(col);
//
//        if (value == null){
//
//          // Type String
//          if (query.getType(col) == 3){
//
//            value = "";
//          }else{
//
//            value = "-1";
//          }
//        }
//
//        row.put(query.getColumnName(col), value);
//      }
//
//      list.add(row);
//    }
//
//    return list;
//  }
//
//
//
//  // Returns the records
//  Cursor getRecs(){
//
//    return mDBHelper.getRecs();
//  }
//
//
//
//
//  Cursor getRecs(String whereClause){
//
//    return mDBHelper.getRecs(whereClause);
//  }
//
//
//
//
//  Cursor getRecord(int rowId){
//
//    return mDBHelper.getRecord(rowId);
//  }
//
//
//
//
//  void importRec(String columnName, String value){
//
//    mDBHelper.bindRecValues(columnName, value);
//  }
//
//
//
//  bool importRec2(){
//
//    return mDBHelper.importRec();
//  }
//
//
//
//  bool createEmptyTemp(){
//
//    return mDBHelper.createEmptyTemp();
//  }
//
//
//
//  bool insertTempRec(){
//
//    return mDBHelper.insertTempRec() > 0;
//  }
//
//
//
//  Cursor getNewTempRecs(){
//
//    return mDBHelper.getNewTempRecs();
//  }
//
//
//
//  bool insertIfNewRec(){
//
//    bool newRec = mDBHelper.ifNewRec();
//
//    if (newRec){
//
//      newRec = mDBHelper.importRec();
//    }
//
//    return newRec;
//  }
//
//
//
//
//  void sync(){
//
//    dbCloud.sync(mDBHelper, m2ndDB, this);
//  }
//
//
//  void onStart(){
//
//    open();
//
//    // Signed either anonymously or Google or Facebook
//    if(Auth.isSignedIn()){
//
//      Auth.onStart();
//
//      ((dbFireBase)m2ndDB).open(dbFireBase.OnDataListener(){
//
//      void onDownload(List<Map<String, String>> dataArrayList){
//
//      mAppView.getModel().sync();
//      }
//      });
//    }else{
//
//      Auth.onStart(OnSuccessListener<AuthResult>(){
//
//      void onSuccess(AuthResult result){
//
//      ((dbFireBase)m2ndDB).open(dbFireBase.OnDataListener(){
//
//      void onDownload(List<Map<String, String>> dataArrayList){
//
//      mAppView.getModel().sync();
//      }
//      });
//      }
//      });
//    }
//  }
//
//
//
//  // The App might get destroyed with calling onDestroy, and so take no chances.
//  void onStop(){
//
//    // close the db connection...
//    close();
//
//    Auth.onStop();
//  }
//
//
//
//  void onRestart(){
//
//    // db likely closed.
//    //       open();
//  }
//
//
//
//  void onDestroy(){
//
//    mAppView = null;
//
//    mContext = null;
//
//    mDBHelper.onDestroy();
//
//    mDBHelper = null;
//
//    m2ndDB.onDestroy();
//
//    m2ndDB = null;
//
//    Auth.dispose();
//  }
//
//
//
//
//  class onDBSetup implements dbSQLlite.OnCreateListener, dbSQLlite.OnConfigureListener{
//
//  void onCreate(SQLiteDatabase db){
//
//  if(db.getVersion() == 0){
//
//  // A this device reference to the cloud.
//  dbCloud.setDeviceDirectory();
//  }
//  }
//
//
//
//  void onConfigure(SQLiteDatabase db){
//
////            db.setVersion(0);
//
//  if (!db.isReadOnly()) {
//  // Enable foreign key constraints
//  db.execSQL("PRAGMA foreign_keys=ON;");
//  }
//  }
//  }
}
