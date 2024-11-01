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

    // Fetch and Display Visitor Count
    async function fetchVisitorCount() {
        try {
            const response = await fetch('https://f9cnbiiy95.execute-api.us-east-1.amazonaws.com/prod/update'); // Update with your API endpoint this will change based on deployment
            if (!response.ok) throw new Error('Network response was not ok');
            const data = await response.json();
            document.getElementById('visitorCount').textContent = data.visits; // Ensure this matches your HTML
        } catch (error) {
            console.error('Error fetching visitor count:', error);
        }
    }

    fetchVisitorCount(); // Call the function to get visitor count on page load
});
