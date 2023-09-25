// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../app_appbar.dart';
import '../../app_drawer.dart';

class ExampleScreen extends StatelessWidget {
  TextStyle textStyle = GoogleFonts.openSans(
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8);

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: App_AppBar(),
      drawer: AppDrawer(),
      body: Text("Example"),
    );
  }
}
