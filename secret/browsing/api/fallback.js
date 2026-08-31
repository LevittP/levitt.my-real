// LevittWeb - fallback catch-all.
// Reached when a request doesn't match a static file or another API route
// (see the "/:path*" -> "/api/fallback" rewrite in vercel.json - filesystem
// matches like "/", "/api/proxy", etc. always take precedence over that
// rewrite, so this only fires for genuinely unmatched paths).
//
// This happens when a proxied page's own JavaScript does client-side
// navigation, or requests a root-relative path (e.g. "/foryou",
// "/api/v2/whatever") directly - those hit our domain instead of going
// through the rewritten /api/proxy links. We resolve them against the
// origin of whichever site was last loaded (tracked via the lw_origin
// cookie set in _lib/core.js).
//
// The rewrite's named ":path*" segment arrives as req.query.path (an array
// of segments, or absent for the root). Any other original query string
// parameters are forwarded alongside it and get merged back onto the
// reconstructed target URL.
import { proxyRequest } from './_lib/core.js';

function getCookie(req, name) {
  const header = req.headers.cookie || '';
  const match = header.match(new RegExp(`(?:^|;\\s*)${name}=([^;]*)`));
  return match ? decodeURIComponent(match[1]) : null;
}

export default async function handler(req, res) {
  const origin = getCookie(req, 'lw_origin');

  if (!origin) {
    res
      .status(404)
      .send(
        'LevittWeb: nothing to resolve this request against yet. Go back and open a site first.'
      );
    return;
  }

  const { path, ...rest } = req.query;
  const pathStr = Array.isArray(path) ? path.join('/') : path || '';

  let target;
  try {
    target = new URL(`/${pathStr}`, origin);
  } catch {
    res.status(400).send('LevittWeb: could not resolve this request.');
    return;
  }

  for (const [key, value] of Object.entries(rest)) {
    if (Array.isArray(value)) {
      value.forEach((v) => target.searchParams.append(key, v));
    } else if (value !== undefined) {
      target.searchParams.append(key, value);
    }
  }

  await proxyRequest(req, res, target);
}
