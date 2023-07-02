const cacheName = "retavortaro-2i";
const preload_files = [
  "/revo/offline.html",
  "/revo/dlg/index-2i.html",
  "/revo/stl/revo-2i-min.css",
  "/revo/jsc/revo-2i-min.js",
  "/revo/dok/datumprotekto.html",
  "/revo/dlg/redaktilo-2i.html",
  "/revo/dlg/redaktmenu-2i.html",
  "/revo/dlg/titolo-2i.html",
  "/revo/dlg/titolo.jpg",
  "/revo/dlg/404.html",
  "/revo/dlg/zamenhof_legas.jpg",
  "/revo/smb/duckduckgo.svg",
  "/revo/smb/ecosia.svg",
  "/revo/smb/revo64.png",
  "/revo/smb/revo.svg",
  "/revo/smb/revo.png",
  "/revo/smb/i_index.svg",
  "/revo/smb/i_kash_ch.png",
  "/revo/smb/i_kash_ch.svg",
  "/revo/smb/i_kash.png",
  "/revo/smb/i_kash.svg",
  "/revo/smb/i_mkash_ch.png",
  "/revo/smb/i_mkash_ch.svg",
  "/revo/smb/i_mkash.png",
  "/revo/smb/i_mkash.svg",
  "/revo/smb/i_mtez.png",
  "/revo/smb/i_mtez.svg",
  "/revo/smb/i_okul.png",
  "/revo/smb/i_okul.svg",
  "/revo/smb/i_start.png",
  "/revo/smb/i_start.svg",
  "/revo/smb/i_tez.png",
  "/revo/smb/i_tez.svg",
  "/revo/smb/i_titol.png",
  "/revo/smb/i_titol.svg",
  "/revo/smb/i_wiki.png",
  "/revo/smb/i_wiki.svg",
  "/revo/smb/i_xml.png",
  "/revo/smb/i_xml.svg",
  "/revo/smb/r_ant.svg",
  "/revo/smb/r_dif.svg",
  "/revo/smb/r_ekz.svg",
  "/revo/smb/r_hom.svg",
  "/revo/smb/r_lst.svg",
  "/revo/smb/r_malprt.svg",
  "/revo/smb/r_prt.svg",
  "/revo/smb/r_sin.svg",
  "/revo/smb/r_sub.svg",
  "/revo/smb/r_super.svg",
  "/revo/smb/r_url.svg",
  "/revo/smb/r_vid.svg"
];

self.addEventListener("install", function(event) {
  event.waitUntil(preLoad());
});

var preLoad = function(){
  console.log("Instalante la retapon");
  return caches.open(cacheName).then(function(cache) {
    console.log("konservante bazajn paĝojn");
    return cache.addAll(preload_files);
  });
};

self.addEventListener("fetch", function(event) {
  event.respondWith(checkResponse(event.request).catch(function() {
    return returnFromCache(event.request);
  }));
  event.waitUntil(addToCache(event.request));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keyList) => {
      return Promise.all(
        keyList.map((key) => {
          if (key === cacheName) {
            return;
          }
          return caches.delete(key);
        })
      );
    })
  );
});

var checkResponse = function(request){
  return new Promise(function(fulfill, reject) {
    fetch(request).then(function(response){
      if(response.status !== 404) {
        fulfill(response);
      } else {
        reject();
      }
    }, reject);
  });
};

var addToCache = function(request){
  return caches.open("offline").then(function (cache) {
    return fetch(request.clone()).then(function (response) {
      console.log(response.url + " estas konservita");
      return cache.put(request, response);
    });
  });
};

var returnFromCache = function(request){
  return caches.open("offline").then(function (cache) {
    return cache.match(request).then(function (matching) {
      if(!matching || matching.status == 404) {
        return cache.match("offline.html");
      } else {
        return matching;
      }
    });
  });
};