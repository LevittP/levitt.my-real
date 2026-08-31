// Shared logic for fetching a target URL and streaming it back, with HTML
// link/form rewriting so browsing keeps flowing through the proxy.
// Files starting with "_" under /api are not treated as routes by Vercel,
// so this module is safe to import without becoming its own endpoint.

const HOP_BY_HOP_RESPONSE_HEADERS = new Set([
  'content-encoding',
  'content-length',
  'transfer-encoding',
  'connection',
  'x-frame-options',
  'content-security-policy',
  'content-security-policy-report-only',
  'set-cookie', // we set our own tracking cookie instead of forwarding upstream cookies
]);

function proxied(absoluteUrl) {
  return `/api/proxy?url=${encodeURIComponent(absoluteUrl)}`;
}

function absolutize(maybeRelative, base) {
  try {
    return new URL(maybeRelative, base).toString();
  } catch {
    return null;
  }
}

function rewriteAttrs(html, baseUrl) {
  return html.replace(
    /(href|src)\s*=\s*(["'])(.*?)\2/gi,
    (match, attr, quote, value) => {
      if (
        !value ||
        value.startsWith('data:') ||
        value.startsWith('javascript:') ||
        value.startsWith('#') ||
        value.startsWith('mailto:') ||
        value.startsWith('tel:')
      ) {
        return match;
      }
      const abs = absolutize(value, baseUrl);
      if (!abs) return match;
      return `${attr}=${quote}${proxied(abs)}${quote}`;
    }
  );
}

function rewriteForms(html, baseUrl) {
  return html.replace(
    /<form([^>]*?)\saction\s*=\s*(["'])(.*?)\2([^>]*)>/gi,
    (match, pre, quote, action, post) => {
      const abs = absolutize(action, baseUrl) || baseUrl;
      let targetBase;
      try {
        const u = new URL(abs);
        u.search = '';
        targetBase = u.toString();
      } catch {
        targetBase = abs;
      }
      const hidden = `<input type="hidden" name="__lw_target" value="${targetBase.replace(
        /"/g,
        '&quot;'
      )}">`;
      return `<form${pre} action="/api/proxy"${post}>${hidden}`;
    }
  );
}

function rewriteHtml(html, baseUrl) {
  return rewriteForms(rewriteAttrs(html, baseUrl), baseUrl);
}

// Fetches `target`, streams the response back through `res`, rewrites HTML,
// and records the site's origin in a cookie so that later same-origin
// relative requests (e.g. a SPA's client-side JS navigation, or an asset
// request that hits our domain directly) can be resolved by the fallback
// catch-all route.
export async function proxyRequest(req, res, target) {
  if (!['http:', 'https:'].includes(target.protocol)) {
    res.status(400).send('Only http:// and https:// URLs are allowed.');
    return;
  }

  try {
    const fetchOptions = {
      method: req.method,
      headers: {
        'user-agent': req.headers['user-agent'] || 'Mozilla/5.0 LevittWeb',
        accept: req.headers['accept'] || '*/*',
        'accept-language': req.headers['accept-language'] || 'en-US,en;q=0.9',
      },
      redirect: 'manual',
    };

    if (req.method === 'POST' && req.body && typeof req.body === 'object') {
      const params = new URLSearchParams();
      for (const [k, v] of Object.entries(req.body)) {
        if (k === '__lw_target') continue;
        params.append(k, v);
      }
      fetchOptions.body = params.toString();
      fetchOptions.headers['content-type'] = 'application/x-www-form-urlencoded';
    }

    const upstream = await fetch(target.toString(), fetchOptions);

    // Remember the current site's origin regardless of outcome, so the
    // fallback route has the best information available for follow-up
    // requests.
    res.setHeader(
      'Set-Cookie',
      `lw_origin=${encodeURIComponent(target.origin)}; Path=/; HttpOnly; SameSite=Lax`
    );

    if ([301, 302, 303, 307, 308].includes(upstream.status)) {
      const location = upstream.headers.get('location');
      if (location) {
        const abs = absolutize(location, target.toString());
        res.setHeader('Location', abs ? proxied(abs) : location);
        res.status(upstream.status).end();
        return;
      }
    }

    res.status(upstream.status);
    upstream.headers.forEach((value, key) => {
      if (!HOP_BY_HOP_RESPONSE_HEADERS.has(key.toLowerCase())) {
        res.setHeader(key, value);
      }
    });

    const contentType = upstream.headers.get('content-type') || '';

    if (contentType.includes('text/html')) {
      const body = rewriteHtml(await upstream.text(), target.toString());
      res.send(body);
    } else {
      const buffer = Buffer.from(await upstream.arrayBuffer());
      res.send(buffer);
    }
  } catch (err) {
    res.status(502).send(`LevittWeb proxy error: ${err.message}`);
  }
}
