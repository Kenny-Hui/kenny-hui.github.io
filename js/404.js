window.onload = function() {
    var input = document.getElementById("input");
    var cursor = document.getElementById("cursor");
    var workDone = false;

    setInterval(function() {
        if(cursor.style.display == 'none') {
            cursor.style.display = ''
        } else {
            cursor.style.display = 'none'
        }
    }, 250);

    document.onkeypress = function(e) {
        if(workDone) return;
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
        workDone = true;
        var resultHTML = message + '<span id="cursor">_</span>';
        var resultElement = document.getElementById("result");
        input.innerHTML = key;
        cursor.parentNode.removeChild(cursor);
        resultElement.innerHTML = resultHTML;
        cursor = document.getElementById("cursor");

        if(key === "1") {
            window.location.href = "http://" + window.location.host + "/index.html";
        }

        if(key === "2") {
            window.location.href = "https://web.archive.org/web/*/" + window.location.href;
        }

        if(key == "3") {
            window.location.href = "mailto:lx86@lx862.com";
        }
    }
}