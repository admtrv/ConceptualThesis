#import "template/lib.typ": *

#show raw.where(block: true): set text(size: 9.5pt)
#show raw.where(block: false): set text(size: 11pt)

#import "@preview/zebraw:0.6.1": *
#show: zebraw.with(lang: false)

#set math.equation(numbering: "[1]")

#show: fiit-thesis.with(
  disable-cover: true,
  title: "Ballistics Simulation in Computer Games with Realistic Physics Modeling",
  thesis: "bp2",
  author: "Anton Dmitriev",
  supervisor: (
    sk: (
      ("Vedúci záverečnej práce", "doc. Ing. Katarína Sedlačková, PhD."),
      ("Konzultant", "Ing. Katarína Jelemenská, PhD."),
    ),
    en: (
      ("Thesis supervisor", "doc. Ing. Katarína Sedlačková, PhD."),
      ("Consultant", "Ing. Katarína Jelemenská, PhD."),
    ),
  ),
  abstract: (
    sk: [
      Balistická simulácia priamo ovplyvňuje konzistentnosť hrateľnosti a hráčsku imerziu, ale často je zredukovaná na zjednodušené aproximácie, ktoré neodrážajú reálne správanie projektilu, alebo je zabudovaná do implementácií viazaných na konkrétny engine, čo obmedzuje prenositeľnosť a znovupoužiteľnosť. Existujúce nástroje sú buď marketplace assety viazané na určitý engine, alebo balistické kalkulátory nekompatibilné s real-time integráciou snímok po snímke. Na riešenie týchto problémov je predstavený framework balistickej simulácie nezávislý od enginu vo forme knižnice v C/C++, založený na overených fyzikálnych zákonoch a implementujúci pohyb projektilu prostredníctvom postupnej numerickej integrácie. Framework pokrýva vonkajšiu balistiku: gravitáciu, aerodynamický odpor, vplyvy atmosféry, vietor, efekty rotácie Zeme a gyroskopický úlet spôsobený rotáciou projektilu, ako aj terminálnu balistiku zahŕňajúcu odraz, prieraz a zastavenie v materiáli. Každý fyzikálny jav je zapuzdrený ako nezávislý komponent, čo umožňuje vývojárom zostaviť len moduly, ktoré ich projekt vyžaduje, a prispôsobiť simuláciu od arkádových hier po vysoko vernú vojenskú simuláciu. Fyzikálne modelovanie je explicitne oddelené od vykresľovania a kolíznych subsystémov prostredníctvom minimálnych abstraktných rozhraní, čo umožňuje znovupoužitie na rôznych platformách. Vykonaná evaluácia potvrdzuje, že framework spĺňa stanovené návrhové ciele: integrácia bola overená vo vlastnom OpenGL engine aj v Godot Engine bez úpravy zdrojového kódu, numerické výsledky zodpovedajú overenej balistickej referenčnej kalkulačke a profilovanie behu preukazuje, že výkon v reálnom čase zostáva stabilný aj pri viac ako tisícke súčasne letiacich projektilov.

      *Oblasť problematiky:* Balistické modelovanie, Pohyb projektilu, Fyzikálna simulácia, Architektúra herného enginu, Strieľačky
    ],
    en: [
      Ballistic simulation directly affects gameplay consistency and player immersion, yet it is often reduced to simplified approximations that do not reflect real projectile behavior, or embedded within engine-specific implementations that limit portability and reuse. Existing tools are either marketplace assets tied to a concrete engine, or ballistic calculators incompatible with real-time frame-by-frame integration. To address these issues, an engine-independent ballistic simulation framework is introduced as a C/C++ library, grounded in established physical laws and implementing projectile motion through step-by-step numerical integration. The framework covers external ballistics: gravity, aerodynamic drag, atmospheric influences, wind, Earth rotation effects, and gyroscopic spin drift, as well as terminal ballistics including ricochet, penetration, and embedding. Each physical phenomenon is encapsulated as an independent component, letting developers assemble only the modules their project requires and tailor the simulation from arcade-style games to high-fidelity military simulators. Physical modeling is explicitly decoupled from rendering and collision subsystems via minimal abstract interfaces, enabling reuse across heterogeneous platforms. The conducted evaluation confirms that the framework satisfies the stated design objectives: integration was validated in both a custom OpenGL engine and Godot Engine without source modification, numerical results match an established ballistic reference calculator, and runtime profiling demonstrates real-time performance sustaining over a thousand simultaneous projectiles.


      *Keywords:* Ballistic modeling, Projectile motion, Physics simulation, Game engine architecture, Shooter games
    ],
  ),
  id: "FIIT-16768-127135",
  assignment: image("/zadanie.pdf"),
  lang: "en",
  
  month: datetime.today().month(),
  current-date: datetime.today(),

  acknowledgment: [I would like to thank my supervisor for all the help and guidance I have received. I would also like to thank my family and friends for supporting during this work.],

  abbreviations-outline: (
    ("ODE", "Ordinary Differential Equation"),
    ("RK2", "Second-Order Runge-Kutta"),
    ("RK4", "Fourth-Order Runge-Kutta"),
    ("ISA", "International Standart Atmosphere"),
    ("NASA", "The National Aeronautics and Space Administration"),
    ("WGS 84", "World Geodetic System 1984"),
    ("GPS","Global Positioning System"),
    ("DMA","The Defence Mapping Agency"),
    ("ECEF", "Earth-Centered, Earth-Fixed coordinate system"),
    ("ENU", "East-North-Up coordinate system"),
    ("3DOF", "Three Degrees of Freedom"),
    ("6DOF", "Six Degrees of Freedom"),
    ("4DOF", "Four Degrees of Freedom"),
    ("MPMM", "Modified Point Mass Model"),
    ("NATO", "North Atlantic Treaty Organization"),
    ("CP", "Center of Pressure"),
    ("CM", "Center of Mass"),
  ),

  // figures-outline: true,
  
  // tables-outline: true,
  
  style: "compact",
)

= Technical abstract

Ballistic simulation is a core element of many game genres, directly affecting gameplay consistency and player immersion. Although shooting mechanics are widespread in modern games, their physical basis is often reduced to simplified approximations: fixed parabolic arcs, constant drag coefficients, or purely directional force vectors that do not reflect real projectile behavior. Existing solutions are either marketplace assets tied to specific game engines, or standalone ballistic calculators that, while physically accurate, compute complete trajectories in a single pass and are incompatible with the frame-by-frame integration that interactive applications require. Moreover, no open-source library bridges this gap.

To address these issues, an engine-independent ballistic simulation framework is introduced as a C/C++ library, grounded in established physical laws and implementing projectile motion through step-by-step numerical integration. The framework models external ballistics progressively, from gravitational free flight through aerodynamic drag, atmospheric and environmental influences, Earth rotation effects, to gyroscopic spin drift following the Modified Point Mass Model. It also implements terminal ballistics covering ricochet, penetration, and embedding. Each physical phenomenon is encapsulated as an independent component, allowing developers to assemble only the required modules and tailor the simulation from arcade-style games to high-fidelity military simulators.

The evaluation confirms that the framework satisfies the stated design objectives. Integration with host engines is achieved through minimal abstract interfaces, validated by deploying the library into both a custom OpenGL engine and Godot Engine without source modification. Comparison with an established ballistic reference calculator showed comparable accuracy, and runtime profiling demonstrated an allocation-free simulation loop sustaining over a thousand simultaneous projectiles within real-time constraints.


= Lay summary

Many video games feature weapons that fire projectiles: bullets, shells, arrows. For these games to feel believable, a projectile cannot simply fly in a straight line and instantly hit the target. In reality, a bullet is affected by gravity, air resistance, wind, and even the rotation of the Earth over long distances. The spinning of the bullet itself keeps it stable but causes a slight sideways drift. These effects shape the trajectory in ways that players can feel, even if they cannot name the physics behind them. Tools that already exist either only work inside one specific game engine, or are designed for real-world marksmen and calculate the entire flight path at once rather than updating it frame by frame as games need. No freely available library solves this problem.

This thesis builds a software library that simulates these effects for game developers. Each physical effect is a separate building block. A developer making a simple mobile game might only use gravity, while a developer building a realistic military simulator can enable everything: atmospheric conditions, Earth rotation, and spin effects. When the projectile hits something, the library has feature to determine what happens next: whether it punches through, bounces off, or gets stuck, depending on the material and the angle of impact.

The library is written in C/C++ and is not tied to any particular game engine, meaning it can be plugged into different engines and custom game projects. Tests show that its results closely match professional ballistic calculators, and it runs fast enough to handle over a thousand projectiles simultaneously.


= Introduction



= Problem statement and solution

== Problem statement

== Technical literature review 

== Solution overview 

== Risk assessment

== Experimental reproducibility and integration

== Sustainability and environmental impact

== Employability

== Teamwork, diversity and inclusion



= Conclusion





// Bibliography
#bibliography("citations.bib")



// Resume
#resume[]



// Appendices
#show: section-appendices.with()

= Description of digital submission

=  Work schedule <plan-of-work>

== Winter semester

#table(
  columns: 3,
  stroke: 0.5pt,

  [*Study Week*], [*Planned*], [*Completed*],
  [1],  [Set up repository and document.], [Initialized repository. Drafted thesis sections. Implemented graphics core.],
  [2],  [Begin writing document.], [Wrote an introduction and outlined the problem.],
  [3],  [Research existing solutions.], [Analyzed major existing solutions. Highlighted key features and implementation gaps.],
  [4],  [Literature study.], [Reviewed literature.],
  [5],  [Literature study.], [Implemented movement through kinematics.],
  [6],  [Implement ballistic physics core.], [Considered implementation and chosen different path.],
  [7],  [Implement ballistic physics core.], [Implemented movement through dynamics. The gravity force has been created.],
  [8],  [Implement ballistic physics core.], [The drag force has been created. The influence of atmosphere and wind has been implemented.],
  [9],  [Implement ballistic physics core.], [The Coriolis force has been created.],
  [10], [Continue writing document.], [The lift force and Magnus force have been created.],
  [11], [Continue writing document.], [Refactored codebase and improved architecture.],
  [12], [Finalize winter checkpoint and prepare midterm report.], [Finalized report and prepared for submission.]
)

== Summer semester

#table(
  columns: 3,
  stroke: 0.5pt,

  [*Study Week*], [*Planned*], [*Completed*],
  [1],  [Develop penetration and ricochet mechanics.], [],
  [2],  [Develop penetration and ricochet mechanics.], [],
  [3],  [Develop penetration and ricochet mechanics.], [],
  [4],  [Study external engines.], [],
  [5],  [Set up comparison scenes in external engines.], [],
  [6],  [Set up testing by other people.], [],
  [7],  [Collect results.], [],
  [8],  [Write remaining document.], [],
  [9],  [Write remaining document.], [],
  [10], [Polish codebase and complete document.], [],
  [11], [Prepare final submission.], [],
  [12], [Prepare defense materials.], []
)

= Technical documentation

= Scientific part


// #pagebreak()