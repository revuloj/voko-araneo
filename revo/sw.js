const cacheName = "retavortaro-2g";
const preload_files = [
  "/offline.html",
  "/dlg/index-2g.html",
  "/stl/revo-2g-min.css",
  "/jsc/revo-2g-min.js",
  "/dok/datumprotekto.html",
  "/dlg/redaktilo-2g.html",
  "/dlg/redaktmenu-2g.html",
  "/dlg/titolo-2g.html",
  "/dlg/titolo.jpg",
  "/dlg/404.html",
  "/dlg/zamenhof_legas.jpg",
  "/smb/duckduckgo.svg",
  "/smb/ecosia.svg",
  "/smb/favicon.ico",
  "/smb/revo64.png",
  "/smb/revo.svg",
  "/smb/revo.png",
  "/smb/i_index.svg",
  "/smb/i_kash_ch.png",
  "/smb/i_kash_ch.svg",
  "/smb/i_kash.png",
  "/smb/i_kash.svg",
  "/smb/i_mkash_ch.png",
  "/smb/i_mkash_ch.svg",
  "/smb/i_mkash.png",
  "/smb/i_mkash.svg",
  "/smb/i_mtez.png",
  "/smb/i_mtez.svg",
  "/smb/i_okul.png",
  "/smb/i_okul.svg",
  "/smb/i_start.png",
  "/smb/i_start.svg",
  "/smb/i_tez.png",
  "/smb/i_tez.svg",
  "/smb/i_titol.png",
  "/smb/i_titol.svg",
  "/smb/i_wiki.png",
  "/smb/i_wiki.svg",
  "/smb/i_xml.png",
  "/smb/i_xml.svg",
  "/smb/r_ant.svg",
  "/smb/r_dif.svg",
  "/smb/r_ekz.svg",
  "/smb/r_hom.svg",
  "/smb/r_lst.svg",
  "/smb/r_malprt.svg",
  "/smb/r_prt.svg",
  "/smb/r_sin.svg",
  "/smb/r_sub.svg",
  "/smb/r_super.svg",
  "/smb/r_url.svg",
  "/smb/r_vid.svg"
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
    return fetch(request).then(function (response) {
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