const manifestUri =
    'http://localhost:8080/dash/testsrc.mp4/manifest.mpd';

function initApp() {
  // Install built-in polyfills to patch browser incompatibilities.
  shaka.polyfill.installAll();

  // Check to see if the browser supports the basic APIs Shaka needs.
  if (shaka.Player.isBrowserSupported()) {
    // Everything looks good!
    initPlayer();
  } else {
    // This browser does not have the minimum set of APIs we need.
    console.error('Browser not supported!');
  }
}

async function initPlayer() {
  // Create a Player instance.
  const video = document.getElementById('video');
  const player = new shaka.Player(video);

  // Attach player to the window to make it easy to access in the JS console.
  window.player = player;

  // Listen for error events.
  player.addEventListener('error', onErrorEvent);
  
  playerConfig = {
                drm: {
                    servers: {
                        'http://test.playready.microsoft.com/service/rightsmanager.asmx': licenseUri
                    }
                }
            };

  player.getNetworkingEngine().registerRequestFilter(function (type, request) {
                // Only add headers to license requests:
                if (type == shaka.net.NetworkingEngine.RequestType.LICENSE) {
                    console.log("request :" + request.body);
                    request.headers['pallycon-customdata-v2'] = playreadyToken;
                }
            });

  // Try to load a manifest.
  // This is an asynchronous process.
    player.load(contentUri).then(function () {
        // This runs if the asynchronous load is successful.
        console.log('The video has now been loaded!');
    }).catch(onError); 

   player.configure(playerConfig);
}
