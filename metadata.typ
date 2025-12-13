// Main report file
#import "template.typ": create-report-template

// Configure your report
#let my-report = create-report-template(
  // Required information
  logo: "./img/unige.pdf",
  logosize: 6cm,
  university: "University of Geneva",
  title: "CC2",

  // Structured authors
  authors: (
    (
      name: "Michel Jean Joseph Donnet",
    ),
  ),

  // Optional information
  faculty: "Faculty of Science",
  // subtitle: "Report Subtitle",
  course-name: "Digital Forensic",
  course-id: "14X065",
  // illustrations: (
  // (
  //   path: "./img/hist.png",
  //   width: 12cm,
  // ),
  // (
  //   path: "./img/full_hist_R.png",
  //   width: 10cm,
  // ),
  // ),
  project-name: "Digital Forensic",
  date: none,

  // Document options
  toc: true,
  numbering: true,
  bibliography: none,
  appendix: false,
)
