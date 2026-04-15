const { distanceInMeters, isInsideGeozone } = require("./geo");

function geozoneKindToStatus(kind) {
  if (kind === "home") {
    return "home";
  }

  if (kind === "study") {
    return "study";
  }

  if (kind === "work") {
    return "work";
  }

  return "custom_place";
}

function getMovementStatus(previousLocation, nextLocation) {
  if (!previousLocation || !previousLocation.lastSeenAt) {
    return "idle";
  }

  const elapsedMs = new Date(nextLocation.lastSeenAt).getTime() - new Date(previousLocation.lastSeenAt).getTime();
  if (elapsedMs <= 0) {
    return "idle";
  }

  const distance = distanceInMeters(
    previousLocation.lat,
    previousLocation.lng,
    nextLocation.lat,
    nextLocation.lng
  );

  const speedMetersPerSecond = distance / (elapsedMs / 1000);
  return speedMetersPerSecond >= 1.4 ? "on_the_way" : "idle";
}

function resolveSmartStatus({ isOnline, geozones, point, previousLocation, nextLocation }) {
  if (!isOnline) {
    return "offline";
  }

  const activeZone = geozones.find((geozone) => isInsideGeozone(point, geozone));
  if (activeZone) {
    return geozoneKindToStatus(activeZone.kind);
  }

  return getMovementStatus(previousLocation, nextLocation);
}

module.exports = {
  resolveSmartStatus
};
