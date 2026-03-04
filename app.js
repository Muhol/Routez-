function goTo(id) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  document.getElementById(id).classList.add('active');
}

setTimeout(() => goTo('login'), 2000);

function scrollToSearch() {
  document.getElementById('search').scrollIntoView({ behavior: 'smooth' });
}

function startTrip() {
  alert("You’re approaching your destination. Prepare to get off.");
}
