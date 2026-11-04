## 0.0.2

* Fix `onSelected` not firing when a suggestion is clicked with a mouse (desktop, web) and the overlay closed before the tap completed ([#1](https://github.com/mlab817/places_autocomplete/issues/1)).
* Fix rows from a custom `itemBuilder` not being selectable ([#1](https://github.com/mlab817/places_autocomplete/issues/1)).

## 0.0.1

* Initial release.
* `PlacesAutocompleteTextField` — drop-in `TextField` replacement with overlay and inline display modes.
* `PlacesAutocompleteTextFormField` — drop-in `TextFormField` replacement with form validation support.
* `PlacesAutocompleteBuilder` — headless builder widget for fully custom UIs.
* `PlacesAutocompleteController` — controller-based API with debouncing, TTL cache, session token management, and `fetchDetails`.
* Location biasing and restriction via circle or rectangle geometries.
* Distance-from-origin support via `PlacesOrigin`.
* Web support — no proxy required (Google Places API New supports CORS).
* Built on the Google Places API (New); no legacy API dependency.
