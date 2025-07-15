// Copyright 2022 Tokamak contributors
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
//
//  Created by Carson Katri on 5/30/22.
//

/// A type that can visit a `Scene`.
public protocol SceneVisitor: ViewVisitor {
  func visit<S: Scene>(_ scene: S)
}

extension Scene {
  public func _visitChildren<V: SceneVisitor>(_ visitor: V) {
    print("🎭 Scene._visitChildren called for:", String(describing: type(of: self)))

    // If the scene is a primitive (e.g., WindowGroup), visit itself instead of trying to visit its body
    if let primitiveScene = self as? any SceneDeferredToRenderer {
      print(
        "🎭 Found primitive scene with deferred view:",
        String(describing: primitiveScene.deferredBody))
      // Visit the primitive scene's deferred view
      visitor.visit(primitiveScene.deferredBody)
      return
    }

    print("🎭 Scene body type:", String(describing: type(of: body)))
    print("🎭 Scene visitor type:", String(describing: type(of: visitor)))
    visitor.visit(body)
  }
}

/// A type that creates a `Result` by visiting multiple `Scene`s.
protocol SceneReducer: ViewReducer {
  associatedtype Result
  static func reduce<S: Scene>(into partialResult: inout Result, nextScene: S)
  static func reduce<S: Scene>(partialResult: Result, nextScene: S) -> Result
}

extension SceneReducer {
  static func reduce<S: Scene>(into partialResult: inout Result, nextScene: S) {
    partialResult = reduce(partialResult: partialResult, nextScene: nextScene)
  }

  static func reduce<S: Scene>(partialResult: Result, nextScene: S) -> Result {
    var result = partialResult
    Self.reduce(into: &result, nextScene: nextScene)
    return result
  }
}

/// A `SceneVisitor` that uses a `SceneReducer`
/// to collapse the `Scene` values into a single `Result`.
final class SceneReducerVisitor<R: SceneReducer>: SceneVisitor {
  var result: R.Result

  init(initialResult: R.Result) {
    print("🎭 Creating SceneReducerVisitor with reducer type:", String(describing: R.self))
    result = initialResult
  }

  func visit<S>(_ scene: S) where S: Scene {
    print("🎭 SceneReducerVisitor.visit called for scene type:", String(describing: type(of: scene)))
    print("🎭 Scene value:", String(describing: scene))
    print("🎭 Reducer type:", String(describing: R.self))

    if let primitiveScene = scene as? any SceneDeferredToRenderer {
      print(
        "🎭 Found primitive scene with deferred view and title:",
        String(describing: primitiveScene.deferredBody), String(describing: primitiveScene.title))
      R.reduce(into: &result, nextView: primitiveScene.deferredBody)
      return
    }

    print("🎭 Scene body type:", String(describing: type(of: scene.body)))
    print("🎭 About to call reduce")
    R.reduce(into: &result, nextScene: scene)
    print("🎭 Successfully reduced scene")
  }

  func visit<V>(_ view: V) where V: View {
    print("🎭 SceneReducerVisitor.visit called for view type:", String(describing: type(of: view)))
    print("🎭 View value:", String(describing: view))
    print("🎭 Reducer type:", String(describing: R.self))

    // Check if this is a primitive view based on either:
    // 1. _PrimitiveView conformance or
    // 2. View with Never body type
    let isPrimitive = (view is any _PrimitiveView) || (V.Body.self == Never.self)

    if isPrimitive {
      print("🎭 Found primitive view, reducing directly")
      R.reduce(into: &result, nextView: view)
      return
    }

    print("🎭 View body type:", String(describing: type(of: view.body)))
    print("🎭 About to call reduce")
    R.reduce(into: &result, nextView: view)
    print("🎭 Successfully reduced view")
  }
}

extension SceneReducer {
  typealias SceneVisitor = SceneReducerVisitor<Self>
}
