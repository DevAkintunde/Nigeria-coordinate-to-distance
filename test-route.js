const OSRM = require('@project-osrm/osrm');
const osrmTextInstructions = require('osrm-text-instructions')('v5'); // Initialize for OSRM v5
const path = require('path');

// 1. Initialize the engine by pointing to your generated .osrm file
// OSRM will automatically find the .partition, .cells, etc. in the same folder
const osrm = new OSRM({
    path: path.join(__dirname, ".nigeria-osrm/bike/lagos-ogun.osrm"),
    algorithm: 'MLD' // This matches the partition/customize steps you ran
});

// 2. Define your start and end coordinates [longitude, latitude]
// These should be within the Lagos-Ogun region you extracted
const query = {
    coordinates: [
        [3.3792, 6.5244], // Example: Start in Lagos
        [3.3500, 7.1500]  // Example: End in Abeokuta (Ogun)
    ],
    alternateRoute: false,
    steps: true,// for steps by step direction
    geometries: 'geojson' // if there is a need to draw the route on a map (like Leaflet or Mapbox)
};

// 3. Run the route request
osrm.route(query, (err, result) => {
    if (err) {
        console.error("❌ Routing Error:", err.message);
        return;
    }

    const route = result.routes[0];
    console.log("✅ Route Found!");
    console.log(`Distance: ${(route.distance / 1000).toFixed(2)} km`);
    console.log(`Duration: ${(route.duration / 60).toFixed(2)} minutes`);
    //result.routes[0].geometry will now contain a GeoJSON LineString
    console.log('Geometry', JSON.stringify(result.routes[0].geometry));

    console.log(`--- Turn-by-Turn Directions ---`);
    // Routes are divided into "legs" (between waypoints)
    route.legs.forEach((leg) => {
        leg.steps.forEach((step, index) => {
          // without extra library
            // const instruction = step.maneuver.type;
            // const modifier = step.maneuver.modifier || "";
            // const name = step.name || "unnamed road";
            // const distance = step.distance.toFixed(0);
            // console.log(`${index + 1}. ${instruction} ${modifier} onto ${name} (${distance}m)`);

            // WIth OSRM text library
            const instruction = osrmTextInstructions.compile('en', step);
            console.log(`- ${instruction} (${step.distance.toFixed(0)}m)`);
        });
    });

    console.log(`-------------------------------`);
    console.log(`Total: ${(route.distance / 1000).toFixed(2)} km`);
});
