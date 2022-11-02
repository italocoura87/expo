// Copyright 2021-present 650 Industries. All rights reserved.

import ABI47_0_0React

/**
 Custom component data extending `ABI47_0_0RCTComponentData`. Its main purpose is to handle event-based props (callbacks),
 but it also simplifies capturing the view config so we can omit some reflections that ABI47_0_0React Native executes.
 */
@objc(ABI47_0_0EXComponentData)
public final class ComponentData: ABI47_0_0RCTComponentData {
  /**
   Weak pointer to the holder of a module that the component data was created for.
   */
  weak var moduleHolder: ModuleHolder?

  /**
   Initializer that additionally takes the original view module to have access to its definition.
   */
  @objc
  public init(viewModule: ViewModuleWrapper, managerClass: ViewModuleWrapper.Type, bridge: ABI47_0_0RCTBridge) {
    self.moduleHolder = viewModule.wrappedModuleHolder
    super.init(managerClass: managerClass, bridge: bridge, eventDispatcher: bridge.eventDispatcher())
  }

  // MARK: ABI47_0_0RCTComponentData

  /**
   Creates a setter for the specific prop. For non-event props we just let ABI47_0_0React Native do its job.
   Events are handled differently to conveniently use them in Swift.
   */
  public override func createPropBlock(_ propName: String, isShadowView: Bool) -> ABI47_0_0RCTPropBlockAlias {
    // Expo Modules Core doesn't support shadow views yet, so fall back to the default implementation.
    if isShadowView {
      return super.createPropBlock(propName, isShadowView: isShadowView)
    }

    // If the prop is defined as an event, create our own event setter.
    if moduleHolder?.viewManager?.eventNames.contains(propName) == true {
      return createEventSetter(eventName: propName, bridge: self.manager?.bridge)
    }

    // Otherwise also fall back to the default implementation.
    return super.createPropBlock(propName, isShadowView: isShadowView)
  }

  /**
   The base `ABI47_0_0RCTComponentData` class does some Objective-C dynamic calls in this function, but we don't
   need to do these slow operations since the Sweet API gives us necessary details without reflections.
   */
  public override func viewConfig() -> [String: Any] {
    var propTypes: [String: Any] = [:]
    var directEvents: [String] = []
    let superClass: AnyClass? = managerClass.superclass()

    if let eventNames = moduleHolder?.viewManager?.eventNames {
      for eventName in eventNames {
        directEvents.append(ABI47_0_0RCTNormalizeInputEventName(eventName))
        propTypes[eventName] = "BOOL"
      }
    }

    return [
      "propTypes": propTypes,
      "directEvents": directEvents,
      "bubblingEvents": [String](),
      "baseModuleName": superClass?.moduleName() as Any
    ]
  }
}

/**
 Creates a setter for the event prop. Used only by Paper.
 */
private func createEventSetter(eventName: String, bridge: ABI47_0_0RCTBridge?) -> ABI47_0_0RCTPropBlockAlias {
  return { [weak bridge] (target: ABI47_0_0RCTComponent, value: Any) in
    installEventDispatcher(forEvent: eventName, onView: target) { [weak target] (body: [String: Any]) in
      if let target = target {
        let componentEvent = ABI47_0_0RCTComponentEvent(name: eventName, viewTag: target.abi47_0_0ReactTag, body: body)
        bridge?.eventDispatcher().send(componentEvent)
      }
    }
  }
}
