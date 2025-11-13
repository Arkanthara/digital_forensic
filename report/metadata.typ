// Main report file
#import "template.typ": create-report-template

// Configure your report
#let my-report = create-report-template(
  // Required information
  logo: "./img/unige.pdf",
  logosize: 6cm,
  university: "University Name",
  title: "Report Title",

  // Structured authors
  authors: (
    (
      name: "Theresa Tungsten",
      affiliation: "Artos Institute",
      email: "tung@artos.edu",
    ),
    (
      name: "Eugene Deklan",
      // affiliation: "Honduras State",
      email: "e.deklan@hstate.hn",
    ),
  ),

  // Optional information
  faculty: "Faculty of Science",
  // subtitle: "Report Subtitle",
  course-name: "Course Name",
  course-id: "CS101",
  illustrations: (
    (
      path: "./img/unige_informatic.png",
      width: 4cm,
    ),
  ),
  project-name: "Project Name",
  github: "project-repo",
  github-link: "https://github.com/username/project-repo",
  date: none,

  // Document options
  toc: true,
  numbering: true,
  bibliography: "./bibliography.bib",
  appendix: false,
)
