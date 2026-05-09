# Coordinate to Distance 
  - THis allows to calculate distances between two places using open source OSRM in a completely self-hosted environment without external service provider.
  - This uses the @project-osrm/osrm node package.
  - Note: Package manager of choice here is pnpm
  - Most important step: ensure you have the osm.pbf file for your region. Nigeria is being used here, and since file size is over 600mb - you will have to download this. See here: https://download.geofabrik.de/africa/nigeria.html
  - In my use case, I needed Lagos and Ogun state, so I identitied the bounding box for this states and hard-cored that for my need.
  - Full script is available in osrmBin.sh, and can be modified to fit your need.
    + Ensure Osmium is install on your machine. WSL(debian) for windows is used, but I will assume osmium should be installable on any modern machine and OS. You would have to figure that out.
    + Additionally, Osmium may need additional tools/library for your OS. You can easily catch this once you run the script.
    + Since this is a node binding, obviously @project-osrm/osrm is required. So run pnpm install.
    + I needed both bike and car distance estimates, so the script is setup for that.
    + Feel free to modify script as needed, and be sure to rename the .osm.pbf file to the version you downloaded

# To Run
 - `wsl` -- Run if using wsl on windows machine
 - `sudo apt install osmium-tool` -- on linux
 - `sudo apt install -y libtbbmalloc2 libtbb12 libtbb-dev liblua5.2-0` -- Additional tool likely needed
 - clone repo into your prefer directory
 - `pnpm install`
 - `sh osrmBin.sh` or `pnpm run build`
 - To test: `node test-route.js` or `pnpm run test`


