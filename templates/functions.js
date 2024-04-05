function refreshDatabase() {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "/refresh-database", true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            alert("Database refreshed successfully!")
            window.location.reload();
        }
    };
    xhr.send();
}


function selectTask(taskId) {
    selectedTaskId = taskId;
    document.getElementById('startTaskBtn').style.display = 'block';
}

function openModal() {
    var modal = document.getElementById("myModal");
    modal.style.display = "block";
}

function closeModal() {
    var modal = document.getElementById("myModal");
    modal.style.display = "none";
}

function selectStage(stage) {
    console.log('Etapa seleccionada:', stage);
}