[![Build Status](https://travis-ci.org/LightDependency/LightDependency.svg?branch=master)](https://travis-ci.org/LightDependency/LightDependency)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/LightDependency.svg)
[![pod](https://img.shields.io/cocoapods/v/LightDependency.svg)](https://cocoapods.org/pods/LightDependency)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# LightDependency
Inversion of Control Container for Swift

## Installation
### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'LightDependency'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, run command:

```bash
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

Add next line to `Cartfile`:

```
github "LightDependency/LightDependency"
```

Then run:
```bash
$ carthage update --platform ios
```

## Usage

### Simple example

```swift
let container = LightContainer.createRootContainer()
container.configure(defaults: .registerSingletons) { context in
    context.register { MyApiClient() as MyApiClientType }
    context.register { resolver in
        try MyService(apiClient: resolver.resolve())
    }
}

let service: MyService = try container.resolve()
```

Where definitions of the protocols and classes are:
```swift
protocol MyApiClientType {
    // ...
}

final class MyApiClient: MyApiClientType {
    // ...
}

final class MyService {
    init(apiClient: MyApiClientType) {
        // ...
    }

    // ...
}
```

### Example 2
```swift
let container = LightContainer.createRootContainer()
container.configure(defaults: .registerSingletons) { context in
    context.register { ItemService() }
        .asDependency(ofType: { $0 as ItemsProvider })
        .asDependency(ofType: { $0 as DetailInfoProvider })
}

container.configure(defaults: .createNewInstancePerResolve) { context in
    context.initContext.register(ItemListViewModel.init)
    context.initContext.register(ItemDetailsViewModel.init)
    context.factoryContext.register(ItemDetailsViewModelFactory.self)
}

let itemListViewModel: ItemListViewModel = try container.resolve()
```

<details><summary>Definitions</summary>
<p>

```swift
final class ItemService: ItemsProvider, DetailInfoProvider {
    // ...
}

protocol ItemsProvider {
    // ...
}

protocol DetailInfoProvider {
    // ...
}

typealias ItemDetailsViewModelFactory = (ItemModel) -> ItemDetailsViewModel

final class ItemModel {
    // ...
}

final class ItemListViewModel {
    init(itemsProvider: ItemsProvider, itemDetailsFactory: @escaping ItemDetailsViewModelFactory) {
        // ...
    }

    // ...
}

final class ItemDetailsViewModel {
    init(itemModel: ItemModel, detailInfoProvider: DetailInfoProvider) {
        // ...
    }

    // ...
}
```
</p>
</details>