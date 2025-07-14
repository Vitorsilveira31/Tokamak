// Copyright 2020 Tokamak contributors
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

import JavaScriptKit
import TokamakShim

@main
struct TokamakDemoApp: App {
  static let _configuration: _AppConfiguration = .init(
    reconciler: .fiber(useDynamicLayout: true)
  )

  @State private var fullText: String = "This is some editable text..."

  var body: some Scene {
    WindowGroup("Tokamak Demo") {
      Text("Hello, Tokamak!")
    }
  }
}
