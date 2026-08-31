// LevittWeb - password gate
// Runs on Vercel Edge Runtime for every request (see `matcher` below).
// Checks HTTP Basic Auth credentials against the PROXY_PASSWORD env var.
// Set PROXY_PASSWORD in your Vercel project's Environment Variables.

export const config = {
  // Protect everything except Vercel's own static internals.
  matcher: '/((?!_next/static|favicon.ico).*)',
};

function unauthorized() {
  return new Response('Authentication required', {
    status: 401,
    headers: {
      'WWW-Authenticate': 'Basic realm="LevittWeb", charset="UTF-8"',
    },
  });
}

export default function middleware(request) {
  const expected = process.env.PROXY_PASSWORD;

  if (!expected) {
    // Fail closed if the operator forgot to set the password.
    return new Response(
      'LevittWeb is not configured: set the PROXY_PASSWORD environment variable.',
      { status: 500 }
    );
  }

  const authHeader = request.headers.get('authorization');

  if (!authHeader || !authHeader.startsWith('Basic ')) {
    return unauthorized();
  }

  let decoded;
  try {
    decoded = atob(authHeader.slice('Basic '.length));
  } catch {
    return unauthorized();
  }

  // Username is ignored - only the password matters.
  const separatorIndex = decoded.indexOf(':');
  const password = separatorIndex === -1 ? decoded : decoded.slice(separatorIndex + 1);

  if (password !== expected) {
    return unauthorized();
  }

  // Authorized - let the request through.
}
