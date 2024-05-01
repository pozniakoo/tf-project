<!DOCTYPE html>
<html>
<head>
	<title>Serverless app</title>
	<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
	<header>
		<h1>Greeting App</h1>
        <div class="counter-number">Views</div>
	</header>
	<main>
		<form>
			<label for="name">Name:</label>
			<input type="text" id="name" name="name">
			<button id="submit-btn">Submit</button>
		</form>
		<p id="greeting"></p>
	</main>
	<hr>
	<div class="logowanie">
		You successfully logged out.
	</div>
	<div class="check">
		<a href="${login_url}">
			<button id="submit-btn">Login</button>
		</a>
	</div>
	<script src="script.js"></script>
</body>
</html>
 