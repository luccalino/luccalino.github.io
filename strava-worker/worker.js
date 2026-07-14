/**
 * Strava OAuth token-exchange proxy for the Bike Ride Heatmap page.
 *
 * Why this exists: GitHub Pages is static, so the Strava CLIENT_SECRET
 * cannot live in the frontend. This Worker holds the secret, swaps the
 * one-time auth `code` for an access token, fetches the athlete's recent
 * rides, and returns ONLY the ride polylines. The access token never
 * touches the browser.
 *
 * Secrets / vars (set via wrangler — see README.md):
 *   CLIENT_ID       (var)    - Strava application Client ID
 *   CLIENT_SECRET   (secret) - Strava application Client Secret
 *   ALLOWED_ORIGIN  (var)    - e.g. https://luccalino.github.io
 */

const RIDE_TYPES = new Set(["Ride", "VirtualRide", "EBikeRide", "GravelRide", "MountainBikeRide"]);

export default {
  async fetch(request, env) {
    const origin = env.ALLOWED_ORIGIN || "*";
    const cors = {
      "Access-Control-Allow-Origin": origin,
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Vary": "Origin",
    };

    // CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: cors });
    }

    const url = new URL(request.url);
    if (request.method !== "POST" || url.pathname !== "/exchange") {
      return json({ error: "Not found" }, 404, cors);
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: "Invalid JSON body" }, 400, cors);
    }
    const { code, redirect_uri } = body || {};
    if (!code) return json({ error: "Missing code" }, 400, cors);

    // 1) Exchange the one-time code for an access token
    let token;
    try {
      const tokenRes = await fetch("https://www.strava.com/oauth/token", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          client_id: env.CLIENT_ID,
          client_secret: env.CLIENT_SECRET,
          code,
          grant_type: "authorization_code",
          redirect_uri,
        }),
      });
      if (!tokenRes.ok) {
        const t = await tokenRes.text();
        return json({ error: "Strava token exchange failed", detail: t }, 502, cors);
      }
      token = await tokenRes.json();
    } catch (e) {
      return json({ error: "Token exchange error", detail: String(e) }, 502, cors);
    }

    // 2) Fetch recent activities (max 200 per page)
    let activities = [];
    try {
      const actRes = await fetch(
        "https://www.strava.com/api/v3/athlete/activities?per_page=200",
        { headers: { Authorization: "Bearer " + token.access_token } }
      );
      if (!actRes.ok) {
        const t = await actRes.text();
        return json({ error: "Strava activities fetch failed", detail: t }, 502, cors);
      }
      activities = await actRes.json();
    } catch (e) {
      return json({ error: "Activities fetch error", detail: String(e) }, 502, cors);
    }

    // 3) Keep only rides with GPS, and strip to the minimum the page needs
    const rides = (Array.isArray(activities) ? activities : [])
      .filter((a) => RIDE_TYPES.has(a.type) && a.map && a.map.summary_polyline)
      .map((a) => ({
        name: a.name,
        distance: a.distance,
        total_elevation_gain: a.total_elevation_gain,
        start_date: a.start_date,
        polyline: a.map.summary_polyline,
      }));

    const athlete = token.athlete
      ? { firstname: token.athlete.firstname, lastname: token.athlete.lastname }
      : null;

    return json({ athlete, activities: rides }, 200, cors);
  },
};

function json(obj, status, cors) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "Content-Type": "application/json", ...cors },
  });
}
