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
		You successfully logged in. Please enjoy this great view
    </div>
	<div class="check"> 
		<a href="${logout_url}">
            <button id="submit-btn">Logout</button>
        </a>
    </div>
    <image src="image.jpg" alt="Great view" class="center"></image>
	<script src="script.js"></script>
</body>
</html>
 
