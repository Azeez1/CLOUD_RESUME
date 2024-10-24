// Initialize AOS Library for Animations
document.addEventListener('DOMContentLoaded', () => {
    AOS.init({
        duration: 1000,
        once: true,
    });
});

// Update Footer Year Dynamically
const yearSpan = document.getElementById('year');
const currentYear = new Date().getFullYear();
yearSpan.textContent = currentYear;

// Smooth Scrolling for Navigation Links
const navLinks = document.querySelectorAll('nav ul li a');
for (let link of navLinks) {
    link.addEventListener('click', smoothScroll);
}

function smoothScroll(e) {
    e.preventDefault();
    const targetId = this.getAttribute('href').substring(1);
    const targetSection = document.getElementById(targetId);
    window.scrollTo({
        top: targetSection.offsetTop - 60,
        behavior: 'smooth',
    });
}

// Animate Skill Bars on Scroll
const skillsSection = document.getElementById('skills');
const skillBars = document.querySelectorAll('.skill-level');
let skillsAnimated = false;

window.addEventListener('scroll', () => {
    if (window.pageYOffset + window.innerHeight >= skillsSection.offsetTop && !skillsAnimated) {
        skillBars.forEach(bar => {
            bar.style.width = bar.parentElement.parentElement.querySelector('h3').textContent === 'Python' ? '90%' :
                              bar.parentElement.parentElement.querySelector('h3').textContent === 'AWS' ? '80%' :
                              '70%'; // Adjust percentages as needed
        });
        skillsAnimated = true;
    }
});
