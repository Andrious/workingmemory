///
/// Copyright (C) 2018 Andrious Solutions
///
/// This program is free software; you can redistribute it and/or
/// modify it under the terms of the GNU General Public License
/// as published by the Free Software Foundation; either version 3
/// of the License, or any later version.
///
/// You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  23 Jun 2018
///

import 'package:mxc_application/mvc.dart' show ViewMVC;

import 'package:workingmemory/src/controller/WorkingMemoryApp.dart' as con;

import 'package:workingmemory/src/view/TodosPage.dart' show TodosPage;

//import 'package:workingmemory/src/view/LoginInfo.dart' show LoginInfo;

/// Need to extend AppView to so to call controller's init() function.
class WorkingMemoryApp extends ViewMVC {
  factory WorkingMemoryApp() {
    if (_this == null) _this = WorkingMemoryApp._();
    return _this;
  }
  static WorkingMemoryApp _this;

  /// Allow for easy access to 'the View' throughout the application.
  static WorkingMemoryApp get view => _this;

  WorkingMemoryApp._()
      : idKey = _app.keyId,
        super(
          con: _app,
          title: 'Working Memory',
          home: TodosPage(),
        );

  /// Instantiate here so to get the 'keyId.'
  static final con.WorkingMemoryApp _app = con.WorkingMemoryApp();
  final String idKey;
}
