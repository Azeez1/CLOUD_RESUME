// Initialize AOS Library for Animations
document.addEventListener('DOMContentLoaded', () => {
    AOS.init({
        duration: 1000,
        once: true,
    });

    // Update Footer Year Dynamically
    const yearSpan = document.getElementById('year');
    if (yearSpan) {
        const currentYear = new Date().getFullYear();
        yearSpan.textContent = currentYear;
    }

    // Smooth Scrolling for Navigation Links
    const navLinks = document.querySelectorAll('nav ul li a');
    navLinks.forEach(link => {
        link.addEventListener('click', smoothScroll);
    });

    function smoothScroll(e) {
        e.preventDefault();
        const targetId = this.getAttribute('href').substring(1);
        const targetSection = document.getElementById(targetId);
        
        if (targetSection) {
            window.scrollTo({
                top: targetSection.offsetTop - 60, // Adjust for fixed nav if necessary
                behavior: 'smooth',
            });
        }
    }

    // Animate Skill Bars on Scroll
    const skillsSection = document.getElementById('skills');
    const skillBars = document.querySelectorAll('.skill-level');
    let skillsAnimated = false;

    window.addEventListener('scroll', () => {
        if (skillsSection && (window.pageYOffset + window.innerHeight) >= skillsSection.offsetTop && !skillsAnimated) {
            skillBars.forEach(bar => {
                const skillName = bar.parentElement.parentElement.querySelector('h3').textContent;
                if (skillName === 'Python') {
                    bar.style.width = '90%';
                } else if (skillName === 'AWS') {
                    bar.style.width = '80%';
                } else {
                    bar.style.width = '70%'; // Default for other skills
                }
            });
            skillsAnimated = true; // Prevent reanimation
        }
    });
});
