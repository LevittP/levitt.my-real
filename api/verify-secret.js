export default function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({
      success: false,
      error: "Method not allowed"
    });
  }

  const { code } = req.body || {};

  if (!process.env.SECRET_CODE) {
    return res.status(500).json({
      success: false,
      error: "SECRET_CODE is not configured"
    });
  }

  if (String(code) !== String(process.env.SECRET_CODE)) {
    return res.status(401).json({
      success: false,
      error: "Incorrect code"
    });
  }

  res.setHeader(
    "Set-Cookie",
    "secret_auth=true; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=3600"
  );

  return res.status(200).json({
    success: true
  });
}
