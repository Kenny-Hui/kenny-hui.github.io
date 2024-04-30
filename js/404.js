const input = document.getElementById("input");
const d1 = document.getElementById("d1");

d1.removeAttribute("hidden");

document.onkeypress = function(e) {
    e = e || window.event;
    var keycode = e.keyCode || e.which;

    if(keycode == 49) {
        doWork("Redirecting to Home Page...", "1");
    }

    if(keycode == 50) {
        doWork("Redirecting to the Internet Archive...", "2")
    }

    if(keycode == 51) {
        doWork("Opening email, continue on your email client...", "3")
    }
};

function doWork(message, key) {
    input.innerHTML += key;
    input.innerHTML += "<br>" + message;

    if(key === "1") {
        window.location.href = "index.html";
    }

    if(key === "2") {
        window.location.href = "https://web.archive.org/web/*/" + window.location.href;
    }

    if(key == "3") {
        window.location.href = "mailto:lx86@lx862.com";
    }
}