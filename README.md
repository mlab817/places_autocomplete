# places_autocomplete

A fully-featured Google Places Autocomplete for Flutter with web support, 
overlay mode, and a controller-based API built on the Google Places API (New).

## Features

- 🔍 Google Places API (New) — no legacy API
- 🌐 Web support (CORS-safe)
- 🎯 Overlay and inline display modes
- 🧠 Debouncing and in-memory cache with TTL
- 📍 Place Details on demand via controller
- 📌 Location biasing and restriction
- 🧩 Drop-in TextField and TextFormField replacements
- 🔧 Fully custom widget via PlacesAutocompleteBuilder
- 🪶 Zero unnecessary dependencies

## Installation

```yaml
dependencies:
  places_autocomplete: ^0.0.2
```

## Requirements

- Flutter >= 3.10.0
- Dart >= 3.0.0
- Google Places API (New) enabled on your Google Cloud project

## Quick Start

### 1. Initialize the controller

```dart
final controller = PlacesAutocompleteController(
  apiKey: 'YOUR_API_KEY',
);
```

### 2. Use it in a widget

```dart
PlacesAutocompleteTextField(
  controller: controller,
  onSelected: (PlacePrediction prediction) {
    print(prediction.description);
    print(prediction.placeId);
  },
);
```

### 3. Dispose when done

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

### Controller Configuration

The `PlacesAutocompleteController` is the brain of the package. 
All API-level configuration goes here.

```dart
final controller = PlacesAutocompleteController(
  // required
  apiKey: 'YOUR_API_KEY',

  // optional — debounce delay before firing API call (default: 600ms)
  debounceTime: Duration(milliseconds: 600),

  // optional — how long to cache results (default: 5 minutes)
  cacheTTL: Duration(minutes: 5),

  // optional — restrict results to specific countries (max 15)
  countries: ['ph', 'us'],

  // optional — restrict results to specific place types
  includedPrimaryTypes: ['restaurant', 'cafe'],

  // optional — bias results toward a location (cannot use with locationRestriction)
  locationBias: PlacesLocationBias.circle(
    latitude: 14.5995,
    longitude: 120.9842,
    radius: 5000,
  ),

  // optional — restrict results to a location (cannot use with locationBias)
  locationRestriction: PlacesLocationRestriction.circle(
    latitude: 14.5995,
    longitude: 120.9842,
    radius: 5000,
  ),

  // optional — preferred language for results
  languageCode: 'en',

  // optional — origin for distance calculation
  origin: PlacesOrigin(
    latitude: 14.5995,
    longitude: 120.9842,
  ),
);
```

> ⚠️ `locationBias` and `locationRestriction` are mutually exclusive. 
> Using both will throw an `AssertionError`.

### Display Modes

Two display modes are available via `DisplayMode` enum.

#### Overlay (default)

Suggestions float above content, anchored to the text field.

```dart
PlacesAutocompleteTextField(
  controller: controller,
  displayMode: DisplayMode.overlay, // default
  overlayOffset: Offset(0, 4),      // optional, distance from text field
  maxSuggestionsHeight: 200.0,      // optional, default 200.0
  maxResults: 5,                    // optional, default 5, max 5
  onSelected: (prediction) {},
);
```

#### Inline

Suggestions appear below the text field and push content down.

```dart
PlacesAutocompleteTextField(
  controller: controller,
  displayMode: DisplayMode.inline,
  maxSuggestionsHeight: 200.0,
  maxResults: 5,
  onSelected: (prediction) {},
);
```

### Widgets

#### PlacesAutocompleteTextField

Drop-in replacement for Flutter's `TextField`.

```dart
PlacesAutocompleteTextField(
  controller: controller,

  // text field styling
  decoration: InputDecoration(
    hintText: 'Search places...',
    prefixIcon: Icon(Icons.search),
  ),

  // display
  displayMode: DisplayMode.overlay,
  maxResults: 5,
  maxSuggestionsHeight: 200.0,
  overlayOffset: Offset(0, 4),

  // custom suggestion item
  itemBuilder: (context, prediction) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(prediction.mainText),
      subtitle: Text(prediction.secondaryText),
    );
  },

  // state builders
  loadingBuilder: (context) {
    return Center(child: CircularProgressIndicator());
  },
  emptyBuilder: (context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text('No results found'),
    );
  },
  errorBuilder: (context, error) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text('Something went wrong'),
    );
  },

  onSelected: (PlacePrediction prediction) {
    print(prediction.description);
  },
);
```

#### PlacesAutocompleteTextFormField

Drop-in replacement for Flutter's `TextFormField`. Same API as
`PlacesAutocompleteTextField` with form support added.

```dart
PlacesAutocompleteTextFormField(
  controller: controller,
  decoration: InputDecoration(hintText: 'Search places...'),
  
  // validate against selected prediction and/or text input
  // value   — what the user typed
  // prediction — the selected PlacePrediction, null if none selected
  validator: (value, prediction) {
    if (prediction == null) return 'Please select a place from the suggestions';
    return null;
  },
  autovalidateMode: AutovalidateMode.onUserInteraction,

  onSelected: (PlacePrediction prediction) {},
);
```

#### PlacesAutocompleteBuilder

Full control — bring your own widget. The builder receives the current
state and an `onSelected` callback. Call `onSelected(prediction)` to
trigger selection; it resets the controller and invokes your `onSelected`
callback automatically.

```dart
PlacesAutocompleteBuilder(
  controller: controller,
  onSelected: (PlacePrediction prediction) {
    print(prediction.description);
  },
  builder: (context, state, onSelected) {
    return Column(
      children: [
        // your own text field
        MyCustomTextField(
          onChanged: controller.search,
        ),

        // render based on state
        switch (state) {
          PlacesStateIdle() => SizedBox.shrink(),
          PlacesStateLoading() => MyCustomLoader(),
          PlacesStateEmpty() => MyCustomEmpty(),
          PlacesStateError(error: final e) => MyCustomError(e),
          PlacesStateResults(predictions: final predictions) =>
            Column(
              children: predictions.map((prediction) {
                return ListTile(
                  title: Text(prediction.mainText),
                  subtitle: Text(prediction.secondaryText),
                  onTap: () => onSelected(prediction),
                );
              }).toList(),
            ),
        },
      ],
    );
  },
);
```

### Reactive State

Since the controller exposes a `ValueNotifier<PlacesAutocompleteState>`,
you can react to state changes anywhere in your widget tree.

```dart
final controller = PlacesAutocompleteController(apiKey: 'YOUR_API_KEY');

// listen to state changes outside the widget
ValueListenableBuilder<PlacesAutocompleteState>(
  valueListenable: controller.stateNotifier,
  builder: (context, state, _) {
    return PlacesAutocompleteTextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search places...',
        prefixIcon: switch (state) {
          PlacesStateLoading() => SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          PlacesStateError() => Icon(Icons.error, color: Colors.red),
          _ => Icon(Icons.search),
        },
        suffixIcon: switch (state) {
          PlacesStateError() => Icon(Icons.refresh),
          _ => null,
        },
      ),
      onSelected: (prediction) {},
    );
  },
);
```

#### Available States

```dart
sealed class PlacesAutocompleteState {}

/// Initial state, no search has been performed yet
class PlacesStateIdle extends PlacesAutocompleteState {}

/// API call in progress
class PlacesStateLoading extends PlacesAutocompleteState {}

/// API call returned no results
class PlacesStateEmpty extends PlacesAutocompleteState {}

/// API call failed
class PlacesStateError extends PlacesAutocompleteState {
  final Object error;
}

/// API call returned results
class PlacesStateResults extends PlacesAutocompleteState {
  final List<PlacePrediction> predictions;
}
```

### Place Details

Fetch full place details on demand using the controller.
This makes a separate API call to the Places API (New) and may
incur additional billing costs depending on the fields returned.

```dart
PlacesAutocompleteTextField(
  controller: controller,
  onSelected: (PlacePrediction prediction) async {
    // store the placeId
    setState(() => _placeId = prediction.placeId);
  },
);

// later, fetch details when you actually need them
// e.g. on form submit
Future<void> _onSubmit() async {
  if (_placeId == null) return;

  final details = await controller.fetchDetails(_placeId!);

  // use whatever fields you need
  print(details.formattedAddress);
  print(details.latitude);
  print(details.longitude);
  print(details.displayName);

  // construct LatLng for google_maps_flutter if needed
  final latLng = LatLng(details.latitude!, details.longitude!);
}
```

> ⚠️ `fetchDetails` requests all available fields from the API.
> Fields you don't use are still billed based on Google's pricing tiers.
> See [Place Data Fields](https://developers.google.com/maps/documentation/places/web-service/data-fields)
> for billing details.

### Location Biasing and Restriction

Use `locationBias` to prefer results near a location, or
`locationRestriction` to strictly limit results to an area.

> ⚠️ You can only use one at a time. Using both will throw an `AssertionError`.

#### Circle

```dart
final controller = PlacesAutocompleteController(
  apiKey: 'YOUR_API_KEY',

  // bias results toward a circle
  locationBias: PlacesLocationBias.circle(
    latitude: 14.5995,
    longitude: 120.9842,
    radius: 5000, // meters, max 50000
  ),
);
```

#### Rectangle

```dart
final controller = PlacesAutocompleteController(
  apiKey: 'YOUR_API_KEY',

  // restrict results to a rectangle
  locationRestriction: PlacesLocationRestriction.rectangle(
    lowLatitude: 14.4081,
    lowLongitude: 120.8976,
    highLatitude: 14.7579,
    highLongitude: 121.1234,
  ),
);
```

#### Using device location

Combine location biasing with the user's actual GPS position using the
[`geolocator`](https://pub.dev/packages/geolocator) package. This gives
the most relevant suggestions without restricting results to a fixed area.

Add `geolocator` to your `pubspec.yaml`:

```yaml
dependencies:
  geolocator: ^13.0.0
```

Then request permission and build the controller once the position is known:

```dart
import 'package:geolocator/geolocator.dart';

Future<PlacesAutocompleteController> buildController(String apiKey) async {
  // Check and request location permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // Fall back to a static bias if permission is denied
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return PlacesAutocompleteController(apiKey: apiKey);
  }

  final position = await Geolocator.getCurrentPosition();

  return PlacesAutocompleteController(
    apiKey: apiKey,
    locationBias: PlacesLocationBias.circle(
      latitude: position.latitude,
      longitude: position.longitude,
      radius: 5000, // meters
    ),
    origin: PlacesOrigin(
      latitude: position.latitude,
      longitude: position.longitude,
    ),
  );
}
```

> Setting `origin` alongside `locationBias` populates `distanceMeters` on
> each `PlacePrediction`, so you can show how far each result is from the
> user — without any extra API calls.

Platform setup required by `geolocator`:

- **Android** — add to `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  ```
- **iOS** — add to `ios/Runner/Info.plist`:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>This app uses your location to show nearby place suggestions.</string>
  ```

See the [geolocator setup guide](https://pub.dev/packages/geolocator#usage) for full platform instructions.

#### Distance from origin

Pass an `origin` to get `distanceMeters` populated in each `PlacePrediction`.

```dart
final controller = PlacesAutocompleteController(
  apiKey: 'YOUR_API_KEY',
  origin: PlacesOrigin(
    latitude: 14.5995,
    longitude: 120.9842,
  ),
);

// distanceMeters is now populated in predictions
PlacesAutocompleteTextField(
  controller: controller,
  itemBuilder: (context, prediction) {
    return ListTile(
      title: Text(prediction.mainText),
      subtitle: Text(prediction.secondaryText),
      trailing: prediction.distanceMeters != null
          ? Text('${prediction.distanceMeters}m')
          : null,
    );
  },
  onSelected: (prediction) {},
);
```

### Android Setup

Add the `INTERNET` permission to your app's `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    ...
</manifest>
```

> This permission is required for all HTTP requests on Android, including
> the Google Places API calls made by this package.

### Web Support

`places_autocomplete` supports Flutter Web out of the box.
The Places API (New) supports CORS, so no proxy is required when using
a properly restricted API key.

#### Restrict your API key

To prevent unauthorized use of your API key on the web, restrict it
to your domain in the Google Cloud Console:

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Navigate to **APIs & Services > Credentials**
3. Select your API key
4. Under **Application restrictions**, select **Websites**
5. Add your domain e.g. `https://yourdomain.com/*`

#### Usage

No additional configuration needed — just use the package as normal:

```dart
PlacesAutocompleteTextField(
  controller: PlacesAutocompleteController(
    apiKey: 'YOUR_WEB_API_KEY',
  ),
  onSelected: (prediction) {},
);
```

> ⚠️ Never hardcode your API key in production. Use environment
> variables or a secrets manager.
> ```dart
> // use --dart-define to pass your key at build time
> const apiKey = String.fromEnvironment('PLACES_API_KEY');
>
> final controller = PlacesAutocompleteController(apiKey: apiKey);
> ```
> Then build with:
> ```bash
> flutter build web --dart-define=PLACES_API_KEY=YOUR_KEY
> ```

### Form Validation

Use `PlacesAutocompleteTextFormField` inside a `Form` widget.
The validator receives both the typed text and the selected prediction
so you can validate against either or both.

```dart
final _formKey = GlobalKey<FormState>();
PlacePrediction? _selectedPrediction;

Form(
  key: _formKey,
  child: Column(
    children: [
      PlacesAutocompleteTextFormField(
        controller: PlacesAutocompleteController(apiKey: 'YOUR_API_KEY'),

        // validate against selected prediction and/or typed text
        validator: (value, prediction) {
          // strict — must select from suggestions
          if (prediction == null) {
            return 'Please select a place from the suggestions';
          }
          return null;
        },

        autovalidateMode: AutovalidateMode.onUserInteraction,
        onSelected: (prediction) {
          setState(() => _selectedPrediction = prediction);
        },
      ),

      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // form is valid, proceed
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
);
```

#### Loose validation — allow open text input

```dart
PlacesAutocompleteTextFormField(
  controller: controller,
  validator: (value, prediction) {
    // allow either a selected prediction or typed text
    if (prediction != null) return null;
    if (value != null && value.isNotEmpty) return null;
    return 'Please enter a location';
  },
  onSelected: (prediction) {},
);
```

#### Hybrid validation

```dart
PlacesAutocompleteTextFormField(
  controller: controller,
  validator: (value, prediction) {
    // prefer prediction but allow text
    if (prediction != null) return null;
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 3) return 'Too short';
    return null;
  },
  onSelected: (prediction) {},
);
```

## API Reference

### PlacesAutocompleteController

| Parameter | Type | Default | Description |
|---|---|---|---|
| `apiKey` | `String` | required | Your Google Places API key |
| `debounceTime` | `Duration` | `600ms` | Delay before firing API call |
| `cacheTTL` | `Duration` | `5 minutes` | How long to cache results |
| `countries` | `List<String>?` | `null` | Restrict to countries (max 15) |
| `includedPrimaryTypes` | `List<String>?` | `null` | Restrict to place types (max 5) |
| `locationBias` | `PlacesLocationBias?` | `null` | Bias results toward a location |
| `locationRestriction` | `PlacesLocationRestriction?` | `null` | Restrict results to a location |
| `languageCode` | `String?` | `null` | Preferred language for results |
| `origin` | `PlacesOrigin?` | `null` | Origin for distance calculation |

| Method | Returns | Description |
|---|---|---|
| `search(String query)` | `void` | Trigger a search manually |
| `fetchDetails(String placeId)` | `Future<PlaceDetails>` | Fetch full place details |
| `clearCache()` | `void` | Clear the in-memory cache |
| `cancelDebounce()` | `void` | Cancel a pending debounce timer without changing state |
| `reset()` | `void` | Cancel a pending debounce timer and reset state to idle |
| `dispose()` | `void` | Dispose the controller |

| Property | Type | Description |
|---|---|---|
| `stateNotifier` | `ValueNotifier<PlacesAutocompleteState>` | Current state notifier |
| `state` | `PlacesAutocompleteState` | Current state |

---

### PlacesAutocompleteTextField

| Parameter | Type | Default | Description |
|---|---|---|---|
| `controller` | `PlacesAutocompleteController` | required | The controller |
| `decoration` | `InputDecoration?` | `null` | Text field decoration |
| `displayMode` | `DisplayMode` | `DisplayMode.overlay` | Overlay or inline |
| `maxResults` | `int` | `5` | Max suggestions to show (max 5) |
| `maxSuggestionsHeight` | `double` | `200.0` | Max height of suggestions list |
| `overlayOffset` | `Offset` | `Offset(0, 4)` | Overlay position offset |
| `itemBuilder` | `Widget Function(BuildContext, PlacePrediction)?` | `null` | Custom suggestion item |
| `loadingBuilder` | `Widget Function(BuildContext)?` | `null` | Custom loading widget |
| `emptyBuilder` | `Widget Function(BuildContext)?` | `null` | Custom empty widget |
| `errorBuilder` | `Widget Function(BuildContext, Object)?` | `null` | Custom error widget |
| `onSelected` | `void Function(PlacePrediction)` | required | Called on selection |

---

### PlacesAutocompleteTextFormField

Same as `PlacesAutocompleteTextField` plus:

| Parameter | Type | Default | Description |
|---|---|---|---|
| `validator` | `String? Function(String? value, PlacePrediction? prediction)?` | `null` | Form validator |
| `autovalidateMode` | `AutovalidateMode?` | `null` | When to auto-validate |

---

### PlacesAutocompleteBuilder

| Parameter | Type | Default | Description |
|---|---|---|---|
| `controller` | `PlacesAutocompleteController` | required | The controller |
| `onSelected` | `void Function(PlacePrediction)` | required | Called after a prediction is selected and controller state is reset |
| `builder` | `Widget Function(BuildContext, PlacesAutocompleteState, void Function(PlacePrediction))` | required | Builder function — third arg is the `onSelected` callback to call on tap |

---

### PlacesLocationBias

| Constructor | Parameters | Description |
|---|---|---|
| `PlacesLocationBias.circle` | `latitude`, `longitude`, `radius` | Circle bias |
| `PlacesLocationBias.rectangle` | `lowLatitude`, `lowLongitude`, `highLatitude`, `highLongitude` | Rectangle bias |

---

### PlacesLocationRestriction

| Constructor | Parameters | Description |
|---|---|---|
| `PlacesLocationRestriction.circle` | `latitude`, `longitude`, `radius` | Circle restriction |
| `PlacesLocationRestriction.rectangle` | `lowLatitude`, `lowLongitude`, `highLatitude`, `highLongitude` | Rectangle restriction |

---

### DisplayMode

| Value | Description |
|---|---|
| `DisplayMode.overlay` | Suggestions float above content |
| `DisplayMode.inline` | Suggestions push content down |

---

### PlacesAutocompleteState

| State | Properties | Description |
|---|---|---|
| `PlacesStateIdle` | — | No search performed yet |
| `PlacesStateLoading` | — | API call in progress |
| `PlacesStateEmpty` | — | No results found |
| `PlacesStateError` | `error: Object` | API call failed |
| `PlacesStateResults` | `predictions: List<PlacePrediction>` | Results available |

---

### PlacePrediction

| Field | Type | Description |
|---|---|---|
| `placeId` | `String` | Unique place identifier |
| `name` | `String` | Resource name e.g. `places/ChIJ...` |
| `description` | `String` | Full human-readable description |
| `mainText` | `String` | Primary part e.g. place name |
| `secondaryText` | `String` | Secondary part e.g. address |
| `types` | `List<String>` | Place types |
| `distanceMeters` | `int?` | Distance from origin if set |

## Billing

`places_autocomplete` uses the Google Places API (New) which is a
paid service. You are responsible for all API costs incurred.

### Autocomplete

Every keystroke (after debounce) triggers an Autocomplete API call.
To minimize costs:

- Use `debounceTime` to reduce the number of calls (default 600ms)
- Use `cacheTTL` to cache results and avoid duplicate calls
- Use `countries` and `includedPrimaryTypes` to narrow results
- Use session tokens — the package handles this automatically via UUID v4

### Place Details

`controller.fetchDetails()` makes a separate API call billed based on
which fields are returned. All fields are requested by default.

See [Google Places API pricing](https://developers.google.com/maps/billing-and-pricing/pricing)
for full details.

> ⚠️ The package is not responsible for any charges incurred from
> Google Places API usage.

---

## Contributing

Contributions are welcome! Please open an issue first to discuss
what you'd like to change.

1. Fork the repo
2. Create your branch `git checkout -b feature/my-feature`
3. Commit your changes `git commit -m 'add my feature'`
4. Push to the branch `git push origin feature/my-feature`
5. Open a Pull Request

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Acknowledgements

Built on the [Google Places API (New)](https://developers.google.com/maps/documentation/places/web-service/op-overview).
