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
  ),

  // figures-outline: true,
  
  // tables-outline: true,
  
  style: "compact",
)

#set text(size: 12pt)

= Technical abstract

Ballistic simulation is a core element of many game genres, directly affecting gameplay consistency and player immersion. Although shooting mechanics are widespread in modern games, their physical basis is often reduced to simplified approximations: fixed parabolic arcs, constant drag coefficients, or purely directional force vectors that do not reflect real projectile behavior. Existing solutions are either marketplace assets tied to specific game engines, or standalone ballistic calculators that, while physically accurate, compute complete trajectories in a single pass and are incompatible with the frame-by-frame integration that interactive applications require. Moreover, no open-source library bridges this gap.

To address these issues, an engine-independent ballistic simulation framework is introduced as a C/C++ library, grounded in established physical laws and implementing projectile motion through step-by-step numerical integration. The framework models external ballistics progressively, from gravitational free flight through aerodynamic drag, atmospheric and environmental influences, Earth rotation effects, to gyroscopic spin drift following the Modified Point Mass Model. It also implements terminal ballistics covering ricochet, penetration, and embedding. Each physical phenomenon is encapsulated as an independent component, allowing developers to assemble only the required modules and tailor the simulation to the desired level of realism: from arcade-style games to high-fidelity military simulators.

The evaluation confirms that the framework satisfies the stated design objectives. Integration with host engines is achieved through minimal abstract interfaces, validated by deploying the library into both a custom OpenGL engine and Godot Engine without source modification. Comparison with an established ballistic reference calculator showed comparable accuracy, and runtime profiling demonstrated an allocation-free simulation loop sustaining over a thousand simultaneous projectiles within real-time constraints.


= Lay summary

Many video games feature weapons that fire projectiles: bullets, shells, arrows. For these games to feel believable, a projectile cannot simply fly in a straight line and instantly hit the target. In reality, a bullet is affected by gravity, air resistance, wind, and even the rotation of the Earth over long distances. The spinning of the bullet itself keeps it stable but causes a slight sideways drift. These effects shape the trajectory in ways that players can feel, even if they cannot name the physics behind them. Tools that already exist either only work inside one specific game engine, or are designed for real-world marksmen and calculate the entire flight path at once rather than updating it frame by frame as games need. No freely available library solves this problem.

This thesis builds a software library that simulates these effects for game developers. Each physical effect is a separate building block. A developer making a simple mobile game might only use gravity, while a developer building a realistic military simulator can enable everything: atmospheric conditions, Earth rotation, and spin effects. When the projectile hits something, the library has feature to determine what happens next: whether it punches through, bounces off, or gets stuck, depending on the material and the angle of impact.

The library is written in C/C++ and is not tied to any particular game engine, meaning it can be plugged into different engines and custom game projects. Tests show that its results closely match professional ballistic calculators, and it runs fast enough to handle over a thousand projectiles simultaneously.


= Introduction

According to data published by the analytics firm Newzoo in 2025 @newzoo-report-2025, although the mobile segment dominates the global video game market with 83% of the total gaming audience, the PC platform still ranks second, accounting for 26% of all gamers. Within the PC segment, the shooter genre leads in revenue generation, comprising 23% of segment earnings, equivalent to approximately 9 billion USD @newzoo-report-2025. Shooting mechanics have also long transcended pure shooter games, becoming a standard gameplay element across diverse genres. As a consequence, the fidelity of projectile behavior becomes a critical factor in shaping player perception: inconsistencies in projectile motion or impact response are immediately noticeable and directly affect immersion.

The main problem domain of this work is ballistic simulation as a core technical component of shooter gameplay, which must remain numerically stable and internally consistent under discrete-time integration. Several challenges persist in this domain. While the governing equations of projectile motion are well known, their implementation is often simplified to an idealized parabolic model @unity-ballistics. Implementations aimed at higher physical realism are frequently tightly coupled to specific engine architectures @unreal-ballistics, limiting portability and reuse. A survey of publicly available tools shows primarily ballistic calculators that compute complete trajectories in a single pass for fixed parameters @gnu-ballistics, rather than providing the incremental state updates required in interactive systems.

To address these issues, the work focused on the development of a physically consistent ballistic simulation framework, situated at the intersection of physics and software development. The proposed solution is guided by three principles that shape the design of the framework. First, _physical consistency_ requires that the simulation is physically consistent and driven through numerical step-by-step integration. Second, _modularity_ dictates that individual physical effects are encapsulated as independent components, allowing developers to assemble the simulation pipeline that matches the required level of realism, from simple parabolic motion suited for arcade games, through moderate realism for shooters, to high-fidelity modeling required by simulation-oriented titles. Third, _engine independence_ demands that physical modeling is separated from rendering and other subsystems via a minimal and well-defined interface, enabling reuse across heterogeneous environments, including custom game projects, open-source game engines, and commercial platforms, without requiring significant modifications. The framework is also evaluated against the stated design objectives through a series of controlled simulation experiments.

= Problem statement and solution

== Problem statement

Ballistic modeling directly affects gameplay consistency and player immersion, yet it is often reduced to a simplified motion. Titles such as Arma 3 @ace3-advanced-ballistics demonstrate what realistic ballistics can do for gameplay, but reaching this level of fidelity currently requires building the simulation from scratch. Large studios can afford to develop dedicated in-house solutions, whereas an independent developer has to choose between reimplementing the physics themselves or accepting the oversimplified defaults provided by their environment. No general-purpose plug-and-use ballistic framework exists that would be applicable across projects regardless of their scale and target engine.

A second aspect of the problem is the monolithic nature of existing solutions. Game developers emphasize different aspects of physics simulation depending on the requirements of their projects. Some focus on long-range ballistics and effects that become noticeable during extended projectile flight, while others are constrained by smaller world scales and require only forces whose influence is immediately apparent. These design choices reflect fundamental game development constraints: developers must remove gameplay-irrelevant simulations in favor of those critical to the core mechanics to avoid unnecessary computational load. Current ballistic solutions primarily expose a fixed feature set chosen by their author and do not allow selective enablement of individual physical effects, forcing developers either to pay the cost of phenomena irrelevant to their genre or to strip them out manually.

The third aspect is ecosystem fragmentation. Most available ballistic solutions are distributed as marketplace assets tied to commercial game engines such as Unity or Unreal Engine and cannot be reused outside of their host runtime. Development, however, does not always happen within a single engine: a studio may prototype in one environment and ship in another, or maintain parallel projects on different platforms. There is no single ballistic framework that can be plugged into heterogeneous environments and provide consistent behavior across them. The open-source landscape does not close this gap either: the majority of available libraries are ballistic calculators that compute the full trajectory in a single pass for a fixed set of parameters, which is incompatible with real-time environments where the state has to be advanced iteratively once per frame.

The problem addressed in this thesis is therefore formulated as follows:

*Physical foundations.* Conduct an in-depth analysis of the physical models describing ballistics, so that each physical effects is derived from established physical theory.

*Modular model.* Express individual physical effects as independent modules that can be selectively enabled, and advance the projectile state by step-by-step numerical integration over the net force produced by the active modules. The integration layer is modular as well, exposing multiple schemes of different order, affects both accuracy and computational cost.

*Quality architecture.* Select a suitable implementation technology, design a clean internal architecture, and define a stable public interface. The interface is to be planned together with the integration workflow, so that embedding the framework remains straightforward.

*Conduct evaluation.* Validate the resulting framework against the stated design objectives through a series of controlled experiments, in order to demonstrate the applicability of the proposed solution.

== Technical literature review 

Several commercial titles demonstrate the gameplay value of physically-based ballistics. In the Sniper Elite series, the bullet is affected by gravity and deflected by wind, requiring the player to compensate for both effects when aiming at distant targets @sniper-elite-v2-2012. The internal implementation is not publicly documented, and players note that the effects appear exaggerated, likely due to the compressed in-game distances. World of Tanks places greater emphasis on terminal ballistics, with the ricochet and multi-layer armor penetration system serving as the foundational gameplay mechanic @wot-armor-penetration. Arma 3 with the ACE3 Advanced Ballistics module @ace3-advanced-ballistics represents a near-ideal reference: it simulates ballistic coefficients, atmosphere influence with wind, Earth rotation effects, and spin drift caused by projectile rotation. However, all these implementations are internal to their respective commercial implementation and unavailable for reuse.

Game engines represent comprehensive core systems that implement fundamental functionality including rendering pipelines, physics simulation, input processing, and asset management systems. These frameworks provide developers with the necessary tools to immediately start developing games. Along with the systems that were already implemented "out of box", their official marketplaces distribute community-created add-ons that extend engine functionality, and ballistic simulation is one such area where marketplace solutions exist. 

A comparative analysis of the most popular marketplace assets based on user ratings and download statistics for *Unity* @true-ballistics-unity @realistic-sniper-unity @bullet-ballistics-unity and *Unreal Engine* @weapon-ballistics-unreal @easy-ballistics-unreal @terminal-ballistics-unreal reveals significant variation in feature completeness. @table-marketplace summarizes the supported physical phenomena across both ecosystems. Only a few assets approach a solid feature set and serve as useful references, but still remain tightly bound to their host engine and cannot be reused outside of it. 

#set table(stroke: (x, y) => (
  left: if x > 0 { 0.8pt },
  top: if y > 0 { 0.8pt },
))

#figure(
text(size: 10pt)[
  #table(
    columns: 7,
    align: (left, center, center, center, center, center, center),
    table.header(
      [], table.cell(colspan: 3)[*Unity Asset Store*], table.cell(colspan: 3)[*Unreal Engine Fab*],
    ),
    table.hline(),
    [*Feature*],
    [True \ Ballistics], [Realistic \ Sniper], [Bullet \ Ballistics 2],
    [Weapon \ Ballistics Pro], [Easy \ Ballistics], [Terminal \ Ballistics],
    table.hline(),
    [Gravity], [+], [+], [+], [−], [+], [+],
    [Air resistance], [+], [+], [+], [−], [+], [+],
    [Atmosphere influence], [+], [+], [+], [−], [+], [+],
    [Drag curves], [+], [−], [−], [−], [+], [−],
    [Coriolis effect], [+], [−], [−], [−], [−], [−],
    [Gyroscopic influence], [+], [+], [−], [−], [−], [−],
    [Terminal impact], [+], [+], [+], [−], [−], [+],
  )],
  caption: [Comparison of ballistic features across Unity and Unreal Engine marketplace assets.]
) <table-marketplace>

The *Godot Asset Library* lacks comprehensive ballistic solutions entirely. The available assets provide simplified, non-physical shooting mechanics suited for arcade and casual genres. This absence further emphasizes the need for proposed solution.

*Standalone libraries* outside of engine ecosystems are primarily ballistic calculators designed for real-world marksmanship @gnu-ballistics that compute complete trajectories in a single pass, which is incompatible with frame-by-frame integration required by interactive applications. No discovered solution combines physical fidelity with a modular, engine-independent architecture.

The gap in sources about ballistics as a software artifact motivated a study of both the physical and the software engineering literature separately, in order to combine them into a unified solution. The primary physical reference is McCoy's _Modern Exterior Ballistics_ @mccoy-modern, the most comprehensive treatment of projectile flight dynamics available. This work has become foundational in the field and is widely cited across a large number of ballistic research. The remaining physical models are drawn from domain-specific sources: the International Standard Atmosphere model from a NASA technical report by Talay @talay-nasa, the WGS-84 geodetic model by The United States Defense Mapping Agency @wgs-84, NATO's Modified Point Mass Model @stanag-4355, and other relevant works referenced throughout the thesis. On the software engineering side, Gregory's _Game Engine Architecture_ @gregory-game-engine is one of the principal references for the design of game engine subsystems, and it directly informed the architectural decisions in this work.

== Solution overview

The proposed solution is a ballistic simulation framework implemented as a static #box[C/C++] library with no external dependencies. The framework covers two domains of ballistics: _external ballistics_, modeling projectile flight from muzzle exit to target, and _terminal ballistics_, modeling the interaction upon impact. The following subsections describe the key design decisions, justify the chosen techniques, and acknowledge their limitations.

=== Language choice

The library targets #box[C/C++] because this is the common denominator across all major game engine ecosystems. Unreal Engine is written in #box[C++] and treats it as the primary development language alongside Blueprint system @ue-cpp. Godot Engine is similarly relies on #box[C++] as its implementation language and exposes a stable GDExtension API with first-class #box[C/C++] bindings @godot-cpp. Unity, despite using #box[C\#] as its scripting language, supports native #box[C/C++] plugins via an external C interface @unity-cpp. Targeting #box[C/C++] therefore maximises compatibility across all major architectures. By contrast, a library implemented in a managed or scripting language would require separate bindings for each engine, increasing maintenance and potentially adding language-boundary overhead.

=== Simulation pipeline

The external ballistics module is organized using a composition-based architecture. The simulation is constructed from independent components rather than implemented as a monolithic solver. Each integration step proceeds in two phases. In the _first phase_, registered environment providers (`IEnvironment`) are evaluated in priority order: each provider reads the current body state and writes the corresponding environmental parameters into a shared context structure. For example, the atmosphere provider computes air density at the current altitude, and the humidity provider subsequently corrects that density. In the _second phase_, registered force models (`IForce`) read from the populated context and accumulate their contributions onto the body. The integrator then consumes the accumulated net force to advance position and velocity.

#figure(
  image("images/diagram.png", width: 65%),
  caption: [Execution flow within a single step.],
  placement: top
) <fig:sequence-diagram>

This two-phase design (@fig:sequence-diagram) decouples environments from forces: a force never queries an environment provider directly but reads whatever data is present in the context. The context carries default values, so forces operate correctly even when a particular provider is not registered. Developers compose the pipeline by registering only the providers and forces their project requires.

=== Physical model

_External ballistics_ covers gravitational acceleration, aerodynamic drag @mccoy-modern with drag curves varying by Mach number (G1–G8, GL) @applied-drag, atmospheric density effects driven by pressure, temperature, and humidity according to the International Standard Atmosphere @talay-nasa, wind @talay-nasa, the Coriolis effect computed in the ENU frame using the WGS-84 geodetic model @wgs-84, and gyroscopic spin drift following the Modified Point Mass Model @mccoy-modern @stanag-4355. Each of these phenomena is implemented as an independent force or environment module.

_Terminal ballistics_ implements three outcomes: ricochet, penetration with residual energy tracking, and embedding. The resolution is driven by material properties assigned to surfaces. The critical ricochet angle is computed via the Wijk model, penetration depth follows an energy-based formulation @energy-penetrarion, and the velocity after ricochet is decomposed into normal and tangential components with restitution and friction coefficients. The terminal subsystem is structured as a resolver-style component that consumes a compact input description and produces a structured outcome.

The external ballistics model is limited to the Modified Point Mass formulation and does not implement a full six-degree-of-freedom 6DOF simulation. However, McCoy notes that this is in practice is not required for routine work in exterior ballistics @mccoy-modern. Terminal ballistics presents a different kind of limitation: this is inherently material-dependent and condition-dependent, and the published research is largely empirical, derived from experimental firing data @koene-ricochet @steel-ricochet @sand-ricochet @concrete-ricochet. The formulas used in this work are therefore approximations rooted in classical physics.

=== Numerical integration

The projectile state is advanced by step-by-step numerical integration rather than analytical solutions. All integration schemes are implemented as interchangeable strategy-like components (`IIntegrator`). The Euler method with one force evaluation per step, the Midpoint method (RK2) with two evaluations, and the classical RK4 method with four evaluations. Higher-order methods reduce truncation error at the cost of additional computations per step. The choice of integrator is a runtime parameter, allowing the developer to trade accuracy for performance depending on the application requirements.

A limitation of fixed-step integration is that accuracy depends on the timestep chosen by the host application. Adaptive step-size control, which could dynamically adjust integration detail based on trajectory curvature, is not implemented in the current version.

=== Integration interface

The rigid body is one of the most fundamental components of every physics engine @gregory-game-engine. The framework defines a minimal abstract interface `IPhysicsBody` to avoid duplicating the engine logic. It specifies only what the simulation pipeline requires: mass, position, velocity, and force accumulation. A concrete engine integration then requires only a thin adapter bridging the host engine's rigid body to this interface. 

The collision subsystem follows a similar approach. Unlike the rigid body, which participates in every simulation step, collision geometry is relevant only at the moment of impact. The framework externalizes all impact-related information into a POD structure `ImpactInfo` that the host engine populates upon detecting a collision, then passes to the stateless resolver. The method returns a structured result `ImpactResult` containing the classified interaction outcome (`ImpactOutcome`: `Ricochet`, `Penetration`, or `Embed`) and the corresponding post-impact state. This avoids wrapping the host engine's collision system and keeps the integration surface minimal.

The library operates internally in the East-North-Up coordinate system, required for correct physical computations. A coordinate mapping, defined once at startup, allows the user to work entirely in their engine's native convention while the framework handles all conversions transparently.

=== Build and distribution

The library is built as a static library using CMake with no external dependencies beyond the #box[C++] standard library. Components amenable to isolated unit testing are covered by a Google Test suite. A GitHub Actions pipeline builds and tests on Linux, Windows, and macOS. When a version tag is pushed, the pipeline packages prebuilt binaries for all three platforms and publishes a GitHub Release.

=== Evaluation strategy

The framework is evaluated along four directions. First, _integration effort_ is measured by deploying the library into a custom OpenGL engine and Godot Engine without modifying the library's and engine's source code. Second, _numerical accuracy_ is assessed by comparing simulated trajectories against the established ballistic calculator @jbm. Third, _runtime performance_ is profiled to confirm that the simulation loop is allocation-free and sustains real-time throughput with over a thousand simultaneous projectiles. Fourth, _terminal ballistics outcomes_ are validated through controlled impact experiments covering ricochet, penetration, multi-layer traversal, and embedding.

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

#set table(stroke: (x, y) => (
  left: if x > 0 { 0.8pt },
  top: if y > 0 { 0.8pt },
))

#figure(
text(size: 9pt)[
  #table(
    columns: 3,
    align: (center, left, left),
    table.header(
      [*Study Week*], [*Planned*], [*Completed*],
    ),
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
  )]
)

== Summer semester

#figure(
text(size: 9pt)[
  #table(
    columns: 3,
    align: (center, left, left),
    table.header(
      [*Study Week*], [*Planned*], [*Completed*],
    ),
    [1],  [Develop penetration and ricochet mechanics.], [penetration],
    [2],  [Develop penetration and ricochet mechanics.], [penetration],
    [3],  [Develop penetration and ricochet mechanics.], [article],
    [4],  [Study external engines.], [article],
    [5],  [Set up comparison scenes in external engines.], [article],
    [6],  [Set up testing by other people.], [external engine, tests],
    [7],  [Collect results.], [sick],
    [8],  [Write remaining document.], [sick],
    [9],  [Write remaining document.], [],
    [10], [Polish codebase and complete document.], [],
    [11], [Prepare final submission.], [],
    [12], [Prepare defense materials.], []
  )]
)

= Technical documentation

== Setup

== Installation Manual

== Developer Manual

= Scientific part


// #pagebreak()