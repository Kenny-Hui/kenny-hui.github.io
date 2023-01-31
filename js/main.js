"use strict"

runClock();

window.onload = function() {
    setTimeout(checkSpecialDay, 750)
}

function runClock() {
    var clockElement = document.getElementById("clock");
    var date = new Date();
    clockElement.innerHTML = padZero(date.getHours()) + ":" + padZero(date.getMinutes());
    setTimeout(runClock, 5000)
}

function checkSpecialDay() {
    var date = new Date();
    var month = date.getMonth() + 1;
    var day = date.getDate();

    if(month == 3 && day == 2) {
        // Cake day!
        var element = document.getElementById("cakeday");
        element.style.display = 'block';
    } else if (month == 12 && (day == 25 || day == 26 || day == 27)) {
        // Christmas
        var element = document.getElementById("christmas");
        element.style.display = 'block';
    }
}

function padZero(number) {
    if(number == 0) return "00";
    if(number <= 9) return "0" + number;
    return number;
}