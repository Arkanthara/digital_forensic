// Main report file
#import "template.typ": create-report-template

// Configure your report
#let my-report = create-report-template(
  // Required information
  logo: "./img/unige.pdf",
  logosize: 6cm,
  university: "University of Geneva",
  title: "Video Compression and Modification Detection",

  // Structured authors
  authors: (
    (
      name: "Michel Jean Joseph Donnet",
    ),
  ),

  // Optional information
  faculty: "Faculty of Science",
  // subtitle: "Report Subtitle",
  course-name: "Digital Forensics",
  course-id: "14x065",
  illustrations: (
    (
      path: "./img/frame.jpg",
      width: 8cm,
    ),
    (
      path: "./img/diff_frame.jpg",
      width: 8cm,
    ),
  ),
  project-name: "Digital Forensics",
  date: none,

  // Document options
  toc: true,
  numbering: true,
  bibliography: "./Digital_Forensic.bib",
  appendix: false,
)
