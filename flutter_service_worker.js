'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"index.html": "e4ed067ff1d8816ead0dbfc2ddc0913f",
"/": "e4ed067ff1d8816ead0dbfc2ddc0913f",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "2b38bc2bdf1b7071061e89b28d7f508f",
"manifest.json": "261feb52de72c26770e654acf054efcc",
"favicon.png": "c5932d08dc23137c804035c6939187d4",
"assets/packages/csc_picker_plus/lib/assets/countries.json": "6d8c87433326342b0afebda246424e52",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/flutter_iconly/fonts/iconly_bold.ttf": "d8984bdaada3bfac387c9482c753047c",
"assets/packages/flutter_iconly/fonts/IconlyLight.ttf": "a2023f2e6ebf4b9fc99a8371297f0265",
"assets/packages/flutter_iconly/fonts/IconlyBroken.ttf": "29154d8260b60657e92db7e3f9003518",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/ionicons/assets/fonts/Ionicons.ttf": "757f33cf07178f986e73b03f8c195bd6",
"assets/fonts/MaterialIcons-Regular.otf": "d79146beeab5285f0432af4066130e94",
"assets/assets/images/design%2520%2520laucher%2520image%2520for%2520%2520duka%2520letu%2520%2520flutter%2520app.jpg": "312e826b661b32c6a6168db8bdc5f442",
"assets/assets/images/rounded_map.png": "6b2a10cab01c891fadf5952a0d434c1d",
"assets/assets/images/banners/banner1.png": "170293636e602ba17962c51938309d74",
"assets/assets/images/banners/banner2.png": "2404abdd4c798fc69015b279a76f1b56",
"assets/assets/images/banners/banner3.jpg": "4b3181cd641ee0547576b5502843d823",
"assets/assets/images/profile/logout.png": "fad00e84db95cd110d93fb5a1518c3cb",
"assets/assets/images/profile/address.png": "7f78e5e86641a57601f4a88ae979244d",
"assets/assets/images/profile/theme.png": "b635d89ba9014e4c03cede689e21e7c4",
"assets/assets/images/profile/login.png": "160a9c341661747259f3abb86c157b68",
"assets/assets/images/profile/privacy.png": "0b4c460faae658f09109ff7e0ffe5abe",
"assets/assets/images/profile/recent.png": "3f1a50bae1f3035a4753d446df3f9d5a",
"assets/assets/images/warning.png": "df04537c6ba3ef3c651e4e5d3b81d330",
"assets/assets/images/forgot_password.jpg": "fc17e3d292d1b1bccb7770c106e70aa1",
"assets/assets/images/empty_search.png": "daa081579e934227dd9020adbb7734a1",
"assets/assets/images/successful.png": "d1c9b94aca7e34d8882b8f9e1435a11d",
"assets/assets/images/categories/electronics.png": "41563a9b009c977dec259802071592dc",
"assets/assets/images/categories/watch.png": "a9afae59ead4763a8f8c23eaf01bd4ab",
"assets/assets/images/categories/book_img.png": "fa3d931dac5bbbe6908b515ae15af01b",
"assets/assets/images/categories/cosmetics.png": "684397239b9242fabf61cc68796ba15f",
"assets/assets/images/categories/shoes.png": "83885764f6ce4e588a05b41b23349b15",
"assets/assets/images/categories/pc.png": "2f023f0058fe7ba2639849f4e01fadee",
"assets/assets/images/categories/mobiles.png": "c8ce3872df23d539e7f5f697f7abeaea",
"assets/assets/images/categories/fashion.png": "2576e5e1326b8274d0895f3876027a8f",
"assets/assets/images/address_map.png": "e438609bb969d310d0fcfa9df76035f2",
"assets/assets/images/error.png": "1fc784623c7400939b69f406614c3172",
"assets/assets/images/bag/shopping_cart.png": "786fc22cef54463ae76bf550c14e7677",
"assets/assets/images/bag/wishlist_svg.png": "1354cc33babdfd5a7070eb466a71457d",
"assets/assets/images/bag/order_svg.png": "8818326d3c06b710a1bdc67532fe57b4",
"assets/assets/images/bag/shopping_basket.png": "e1b7452d5cf4392e466c42451cd70feb",
"assets/assets/images/bag/order.png": "a03356b2fdc8abdb9802d50f2af3c21c",
"assets/assets/images/bag/bag_wish.png": "d7991b64bf11080b9ccfcc8653a9840f",
"assets/AssetManifest.json": "b35538ee8801069fa152b47265a0cfc7",
"assets/AssetManifest.bin": "ed93f28f19ceea9555d37d184a8c6678",
"assets/NOTICES": "84ab5fba915bd703ce9ea22c96619cd1",
"assets/FontManifest.json": "381b4989bd47d990517a8831572e62fb",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "06efb8588238cf4359980813125504ba",
"main.dart.js": "f59c3a08c9066f2b09e9bbd7c6e70550",
"icons/Icon-maskable-192.png": "c51147e3a74bc5d1d55eebe54e613c13",
"icons/Icon-maskable-512.png": "317d48db50c50b503f6155e5f7398873",
"icons/Icon-512.png": "317d48db50c50b503f6155e5f7398873",
"icons/Icon-192.png": "c51147e3a74bc5d1d55eebe54e613c13",
"version.json": "5792383601a303dada127cdb55a9e1b8"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
