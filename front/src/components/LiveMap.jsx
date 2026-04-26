import { useEffect, useRef } from 'react'
import maplibregl from 'maplibre-gl'

const baseStyle = {
  version: 8,
  sources: {
    osm: {
      type: 'raster',
      tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
      tileSize: 256,
      attribution: '&copy; OpenStreetMap contributors',
    },
  },
  layers: [
    {
      id: 'osm',
      type: 'raster',
      source: 'osm',
    },
  ],
}

function buildMarker(label, avatar, avatarAlt, tone = 'primary') {
  const marker = document.createElement('div')
  marker.className = tone === 'primary' ? 'zenly-map-marker zenly-map-marker-primary' : 'zenly-map-marker'

  if (avatar) {
    marker.classList.add('zenly-map-marker-avatar')
    const image = document.createElement('img')
    image.src = avatar
    image.alt = avatarAlt
    image.className = 'zenly-map-avatar'
    marker.appendChild(image)
    return marker
  }

  marker.textContent = label
  return marker
}

function buildLabel(text) {
  const label = document.createElement('div')
  label.className = 'zenly-map-label'
  label.textContent = text
  return label
}

export default function LiveMap({ currentUser, places, onLocationChange, avatarAlt = 'Avatar' }) {
  const mapRef = useRef(null)
  const containerRef = useRef(null)
  const currentUserMarkerRef = useRef(null)
  const placeMarkersRef = useRef([])
  const lastSavedCoordinatesRef = useRef(null)
  const hasCenteredOnLiveLocationRef = useRef(false)
  const onLocationChangeRef = useRef(onLocationChange)

  useEffect(() => {
    onLocationChangeRef.current = onLocationChange
  }, [onLocationChange])

  useEffect(() => {
    if (!containerRef.current || mapRef.current) {
      return undefined
    }

    const map = new maplibregl.Map({
      container: containerRef.current,
      style: baseStyle,
      center: currentUser.coordinates,
      zoom: 11.8,
      pitch: 42,
      bearing: -18,
      attributionControl: true,
    })

    mapRef.current = map
    lastSavedCoordinatesRef.current = currentUser.coordinates

    map.addControl(
      new maplibregl.NavigationControl({
        showCompass: true,
        visualizePitch: true,
      }),
      'top-right',
    )

    map.on('load', () => {
      currentUserMarkerRef.current = new maplibregl.Marker({
        element: buildMarker(currentUser.initials, currentUser.avatar, avatarAlt, 'primary'),
      })
        .setLngLat(currentUser.coordinates)
        .addTo(map)

      placeMarkersRef.current = places.map((place) =>
        new maplibregl.Marker({ element: buildLabel(place.name), anchor: 'bottom-left' })
          .setLngLat(place.coordinates)
          .addTo(map),
      )
    })

    let watchId = null

    if (navigator.geolocation) {
      watchId = navigator.geolocation.watchPosition(
        ({ coords }) => {
          const nextCoordinates = [coords.longitude, coords.latitude]
          const lastSaved = lastSavedCoordinatesRef.current
          const hasChanged =
            !lastSaved ||
            lastSaved[0] !== nextCoordinates[0] ||
            lastSaved[1] !== nextCoordinates[1]

          currentUserMarkerRef.current?.setLngLat(nextCoordinates)

          if (!hasCenteredOnLiveLocationRef.current) {
            hasCenteredOnLiveLocationRef.current = true
            map.easeTo({
              center: nextCoordinates,
              duration: 1200,
            })
          }

          if (hasChanged) {
            lastSavedCoordinatesRef.current = nextCoordinates
            onLocationChangeRef.current?.(nextCoordinates)
          }
        },
        () => {
          // If geolocation is blocked or unavailable, keep the initial fallback coordinates.
        },
        {
          enableHighAccuracy: true,
          maximumAge: 15000,
          timeout: 10000,
        },
      )
    }

    return () => {
      if (watchId !== null && navigator.geolocation) {
        navigator.geolocation.clearWatch(watchId)
      }

      placeMarkersRef.current.forEach((marker) => marker.remove())
      placeMarkersRef.current = []
      currentUserMarkerRef.current = null
      lastSavedCoordinatesRef.current = null
      hasCenteredOnLiveLocationRef.current = false

      map.remove()
      mapRef.current = null
    }
  }, [])

  useEffect(() => {
    if (!currentUserMarkerRef.current) {
      return
    }

    currentUserMarkerRef.current.setLngLat(currentUser.coordinates)
  }, [currentUser.coordinates])

  return <div ref={containerRef} className="absolute inset-0" />
}
