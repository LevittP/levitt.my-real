// LevittWeb - open reverse proxy entry point.
// GET /api/proxy?url=<absolute URL> fetches that URL and streams it back,
// rewriting links/forms so continued browsing stays routed through the
// proxy. Access is gated by middleware.js (Basic Auth against
// PROXY_PASSWORD) - there's no domain whitelist here by design.
import { proxyRequest } from './_lib/core.js';

function resolveTargetUrl(query) {
  if (query.url) {
    const raw = Array.isArray(query.url) ? query.url[0] : query.url;
    try {
      return new URL(raw);
    } catch {
      return null;
    }
  }

  if (query.__lw_target) {
    const rawBase = Array.isArray(query.__lw_target)
      ? query.__lw_target[0]
      : query.__lw_target;
    let target;
    try {
      target = new URL(rawBase);
    } catch {
      return null;
    }
    for (const [key, value] of Object.entries(query)) {
      if (key === '__lw_target') continue;
      if (Array.isArray(value)) {
        value.forEach((v) => target.searchParams.append(key, v));
      } else {
        target.searchParams.append(key, value);
      }
    }
    return target;
  }

  return null;
}

export default async function handler(req, res) {
  const target = resolveTargetUrl(req.query);

  if (!target) {
    res
      .status(400)
      .send('Missing or invalid target. Use /api/proxy?url=https://example.com');
    return;
  }

  await proxyRequest(req, res, target);
}
