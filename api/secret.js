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

  <style>
    body {
      background: #111;
      color: white;
      font-family: Arial, sans-serif;
      padding: 40px;
    }
  </style>
</head>

<body>

  <h1>Welcome to the secret area 🔒</h1>

  <p>Your protected content goes here.</p>

</body>
</html>
  `);
}
