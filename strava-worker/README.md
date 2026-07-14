# Strava Heatmap — setup

This is the backend for the **Bike Ride Heatmap** page (`/strava.html`).
It's a tiny Cloudflare Worker that holds your Strava **Client Secret** and
exchanges the OAuth code for a token (a static site can't do this safely on
its own). The access token never reaches the visitor's browser.

## 1. Create a Strava API application (~2 min)

1. Go to <https://www.strava.com/settings/api>
2. Create an application. Set:
   - **Authorization Callback Domain:** `luccalino.github.io`
     *(for local testing, create a second app with `localhost`)*
3. Note your **Client ID** and **Client Secret**.

## 2. Deploy the Cloudflare Worker

Install once: `npm install -g wrangler` then `wrangler login`.

From this folder:

```bash
# put your Client ID + allowed origin into wrangler.toml first, then:
wrangler secret put CLIENT_SECRET   # paste your Strava Client Secret when prompted
wrangler deploy
```

`wrangler deploy` prints your Worker URL, e.g.
`https://strava-heatmap.<your-subdomain>.workers.dev`.

## 3. Configure the frontend

Open `strava.html` and fill in the CONFIG block near the bottom:

```js
const STRAVA_CLIENT_ID = "12345";                                  // your Client ID
const WORKER_URL       = "https://strava-heatmap.xxx.workers.dev"; // from step 2
```

Also confirm `ALLOWED_ORIGIN` in `wrangler.toml` matches your site's origin
(`https://luccalino.github.io`), then re-run `wrangler deploy` if you changed it.

## 4. Test

Visit `https://luccalino.github.io/strava.html`, click **Connect with Strava**,
authorize, and your recent rides render as a heatmap.

## Notes

- **Scope:** the page requests `activity:read_all` so your own private rides
  are included. Change `SCOPE` in `strava.html` to `activity:read` for public
  activities only.
- **Rate limits:** Strava allows 100 requests / 15 min and 1000 / day per app.
  Each visitor uses ~2 requests, so this is fine for a personal site.
- **Data:** only ride polylines + distance/elevation are returned to the
  browser; nothing is stored server-side.
