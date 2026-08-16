export default function handler(req, res) {
  const cookies = req.headers.cookie || "";

  if (!cookies.includes("secret_auth=true")) {
    return res.redirect(302, "/secret");
  }

  res.setHeader("Content-Type", "text/html");

  res.status(200).send(`
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Secret</title>
</head>

<body>
  <h1>Secret Area</h1>
  <p>You successfully unlocked the secret page.</p>
</body>
</html>
`);
}
