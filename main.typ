#import "template/lib.typ": *

#show raw.where(block: true): set text(size: 8pt)
#show raw.where(block: false): set text(size: 10pt)

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
      Balistická simulácia priamo ovplyvňuje konzistentnosť hrateľnosti a hráčsku imerziu, ale často je zredukovaná na zjednodušené aproximácie, ktoré neodrážajú reálne správanie projektilu, alebo je zabudovaná do implementácií viazaných na konkrétny engine, čo obmedzuje prenositeľnosť a znovupoužiteľnosť. Existujúce nástroje sú buď komerčné assety viazané na určitý engine, alebo balistické kalkulátory nekompatibilné s krokovou integráciou v reálnom čase. Na riešenie týchto problémov je predstavený framework balistickej simulácie nezávislý od enginu vo forme knižnice v #box[C/C++], založený na overených fyzikálnych zákonoch a implementujúci pohyb projektilu prostredníctvom postupnej numerickej integrácie. Framework pokrýva vonkajšiu balistiku: gravitáciu, aerodynamický odpor, vplyvy atmosféry, vietor, efekty rotácie Zeme a gyroskopická derivácia spôsobená rotáciou projektilu, a čiastočne aj terminálnu balistiku zahŕňajúcu odraz, prieraz a zastavenie v materiáli. Každý fyzikálny jav je implementovaný ako samostatný modul, čo umožňuje vývojárom zostaviť len moduly, ktoré ich projekt vyžaduje, a prispôsobiť simuláciu od arkádových hier až po vysoko vernú vojenskú simuláciu. Fyzikálne modelovanie je explicitne oddelené od vykresľovania a kolíznych subsystémov prostredníctvom minimálnych abstraktných rozhraní, čo umožňuje znovupoužitie na rôznych platformách. Vykonaná evaluácia potvrdzuje, že framework spĺňa stanovené návrhové ciele: integrácia bola overená vo vlastnom OpenGL engine aj v Godot Engine bez úpravy zdrojového kódu, numerické výsledky zodpovedajú overenej balistickej referenčnej kalkulačke a profilovanie behu preukazuje, že výkon v reálnom čase zostáva stabilný aj pri viac ako tisícke súčasne letiacich projektilov.

      *Kľúčové slová:* balistické modelovanie, pohyb projektilu, fyzikálna simulácia, architektúra herného enginu, strieľačky
    ],
    en: [
      Ballistic simulation directly affects gameplay consistency and player immersion, yet it is often reduced to simplified approximations that do not reflect real projectile behavior, or embedded within engine-specific implementations that limit portability and reuse. Existing tools are either marketplace assets tied to a concrete engine, or ballistic calculators incompatible with real-time frame-by-frame integration. To address these issues, an engine-independent ballistic simulation framework is introduced as a #box[C/C++] library, grounded in established physical laws and implementing projectile motion through step-by-step numerical integration. The framework covers external ballistics: gravity, aerodynamic drag, atmospheric influences, wind, Earth rotation effects, and gyroscopic spin drift, as well as terminal ballistics including ricochet, penetration, and embedding. Each physical phenomenon is encapsulated as an independent component, letting developers assemble only the modules their project requires and tailor the simulation from arcade-style games to high-fidelity military simulators. Physical modeling is explicitly decoupled from rendering and collision subsystems via minimal abstract interfaces, enabling reuse across heterogeneous platforms. The conducted evaluation confirms that the framework satisfies the stated design objectives: integration was validated in both a custom OpenGL engine and Godot Engine without source modification, numerical results match an established ballistic reference calculator, and runtime profiling demonstrates real-time performance sustaining over a thousand simultaneous projectiles.


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
    ("PC", "Personal Computer"),
    ("CPU", "Central Processing Unit"),
    ("API", "Application Programming Interface"),
    ("CI", "Continuous Integration"),
    ("POD", "Plain Old Data"),
    ("ECS", "Entity Component System"),
    ("GCC", "GNU Compiler Collection"),
    ("MSVC", "Microsoft Visual C++"),
    ("RPG", "Role-Playing Game"),
    ("ISA", "International Standard Atmosphere"),
    ("WGS 84", "World Geodetic System 1984"),
    ("RK2", "Second-Order Runge-Kutta"),
    ("RK4", "Fourth-Order Runge-Kutta"),
    ("MPMM", "Modified Point Mass Model"),
    ("4DOF", "Four Degrees of Freedom"),
    ("6DOF", "Six Degrees of Freedom"),
    ("ENU", "East-North-Up"),
    ("ECEF", "Earth-Centered, Earth-Fixed"),
    ("DMA", "The Defence Mapping Agency"),
    ("NASA", "The National Aeronautics and Space Administration"),
    ("NATO", "North Atlantic Treaty Organization"),
    ("ISO", "International Organization for Standardization"),
  ),

  // figures-outline: true,

  // tables-outline: true,

  style: "compact",
)

#set text(size: 12pt)

#set table(stroke: (x, y) => (
  left: if x > 0 { 0.8pt },
  top: if y > 0 { 0.8pt },
))

#show figure.where(kind: table): set figure.caption(position: top)

= Technical abstract

Ballistic simulation is a core element of many game genres, directly affecting gameplay consistency and player immersion. Although shooting mechanics are widespread in modern games, their physical basis is often reduced to simplified approximations: fixed parabolic arcs, constant drag coefficients, or purely directional force vectors that do not reflect real projectile behavior. Existing solutions are either marketplace assets tied to specific game engines, or standalone ballistic calculators that, while physically accurate, compute complete trajectories in a single pass and are incompatible with the frame-by-frame integration that interactive applications require. Moreover, no open-source library bridges this gap.

To address these issues, an engine-independent ballistic simulation framework is introduced as a #box[C/C++] library, grounded in established physical laws and implementing projectile motion through step-by-step numerical integration. The framework models external ballistics progressively, from gravitational free flight through aerodynamic drag, atmospheric and environmental influences, Earth rotation effects, to gyroscopic spin drift following the Modified Point Mass Model (MPMM). It also implements terminal ballistics covering ricochet, penetration, and embedding. Each physical phenomenon is encapsulated as an independent component, allowing developers to assemble only the required modules and tailor the simulation to the desired level of realism: from arcade-style games to high-fidelity military simulators.

The evaluation confirms that the framework satisfies the stated design objectives. Integration with host engines is achieved through minimal abstract interfaces, validated by deploying the library into both a custom OpenGL engine and Godot Engine without source modification. Comparison with an established ballistic reference calculator showed comparable accuracy, and runtime profiling demonstrated an allocation-free simulation loop sustaining over a thousand simultaneous projectiles within real-time constraints.


= Lay summary

Many video games feature weapons that fire projectiles: bullets, shells, arrows. For these games to feel believable, a projectile cannot simply fly in a straight line and instantly hit the target. In reality, a bullet is affected by gravity, air resistance, wind, and even the rotation of the Earth over long distances. The spinning of the bullet itself keeps it stable but causes a slight sideways drift. These effects shape the trajectory in ways that players can feel, even if they cannot name the physics behind them. Tools that already exist either only work inside one specific game engine, or are designed for real-world marksmen and calculate the entire flight path at once rather than updating it frame by frame as games need. No freely available library solves this problem.

This thesis builds a software library that simulates these effects for game developers. Each physical effect is a separate building block. A developer making a simple mobile game might only use gravity, while a developer building a realistic military simulator can enable everything: atmospheric conditions, Earth rotation, and spin effects. When the projectile hits something, the library has feature to determine what happens next: whether it punches through, bounces off, or gets stuck, depending on the material and the angle of impact.

The library is written in #box[C/C++] and is not tied to any particular game engine, meaning it can be plugged into different engines and custom game projects. Tests show that its results closely match professional ballistic calculators, and it runs fast enough to handle over a thousand projectiles simultaneously.


= Introduction

According to data published by the analytics firm Newzoo in 2025 @newzoo-report-2025, although the mobile segment dominates the global video game market with 83% of the total gaming audience, the PC platform still ranks second, accounting for 26% of all gamers. Within the PC segment, the shooter genre leads in revenue generation, comprising 23% of segment earnings, equivalent to approximately 9 billion USD @newzoo-report-2025. Shooting mechanics have also long transcended pure shooter games, becoming a standard gameplay element across diverse genres, from survival horror to open-world action RPG. As a consequence, the fidelity of projectile behavior becomes a critical factor in shaping player perception: inconsistencies in projectile motion or impact response are immediately noticeable and directly affect perceived realism.

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

A comparative analysis of the most popular marketplace assets based on user ratings and download statistics for Unity @true-ballistics-unity @realistic-sniper-unity @bullet-ballistics-unity and Unreal Engine @weapon-ballistics-unreal @easy-ballistics-unreal @terminal-ballistics-unreal reveals significant variation in feature completeness. @table-marketplace summarizes the supported physical phenomena across both ecosystems. Only a few assets approach a solid feature set and serve as useful references, but still remain tightly bound to their host engine and cannot be reused outside of it.

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
  caption: [Comparison of features across Unity and Unreal Engine marketplace assets.]
) <table-marketplace>

The Godot Asset Library lacks comprehensive ballistic solutions entirely. The available assets provide simplified, non-physical shooting mechanics suited for arcade and casual genres. This absence further emphasizes the need for proposed solution.

Standalone libraries outside of engine ecosystems are primarily ballistic calculators designed for real-world marksmanship @gnu-ballistics that compute complete trajectories in a single pass, which is incompatible with frame-by-frame integration required by interactive applications. No discovered solution combines physical fidelity with a modular, engine-independent architecture.

The gap in sources about ballistics as a software artifact motivated a study of both the physical and the software engineering literature separately, in order to combine them into a unified solution. The primary physical reference is McCoy's _Modern Exterior Ballistics_ @mccoy-modern, the most comprehensive treatment of projectile flight dynamics available. This work has become foundational in the field and is widely cited across a large number of ballistic research @gupta-stability @1718-2022 @stanag-4355. The remaining physical models are drawn from domain-specific sources: the International Standard Atmosphere (ISA) model from the NASA technical report by Talay @talay-nasa, the World Geodetic System 1984 (WGS 84) model by The Defence Mapping Agency (DMA) @wgs-84, NATO's MPMM @stanag-4355, and other relevant works referenced throughout the thesis. On the software engineering side, Gregory's _Game Engine Architecture_ @gregory-game-engine is one of the principal references for the design of game engine subsystems, and it directly informed the architectural decisions in this work.

== Solution overview

The proposed solution is a ballistic simulation framework implemented as a static #box[C/C++] library with no external dependencies. The framework covers two domains of ballistics @carlucci-ballistics: _external ballistics_, modeling projectile flight from muzzle exit to target, and _terminal ballistics_, modeling the interaction upon impact with target. The following subsections describe the key design decisions, justify the chosen techniques, and acknowledge their limitations.

=== Language choice

The library targets #box[C/C++] due to its widespread adoption across major game engine ecosystems. Unreal Engine treats #box[C++] as its primary development language @ue-cpp, Godot Engine exposes a stable GDExtension API with first-class #box[C/C++] bindings @godot-cpp, and Unity supports native #box[C/C++] plugins via an external C interface @unity-cpp. By contrast, a library in a managed or scripting language would require separate bindings for each engine, increasing maintenance and adding language-boundary overhead.

=== Simulation pipeline

The external ballistics module is organized using a composition-based architecture. The simulation is constructed from independent components rather than implemented as a monolithic solver. Each integration step proceeds in two phases. In the _first phase_, registered environment providers (`IEnvironment`) reads the current body state and writes the corresponding environmental parameters into a shared context structure. In the _second phase_, registered force models (`IForce`) read from the populated context and accumulate their contributions onto the body. The integrator then consumes the accumulated net force to advance position and velocity.

#figure(
  image("images/diagram.png", width: 70%),
  caption: [Execution flow within a single step.]
) <fig:sequence-diagram>

This two-phase design (@fig:sequence-diagram) decouples environments from forces: a force never queries an environment provider directly but reads whatever data is present in the context. The context carries default values, so forces operate correctly even when a particular provider is not registered. Developers compose the pipeline by registering only the components their project requires.

=== Physical model

_External ballistics_ covers gravitational acceleration, aerodynamic drag @mccoy-modern with drag curves varying by Mach number (G1–G8, GL) @applied-drag, atmospheric density effects driven by pressure, temperature, and humidity according to the ISA @talay-nasa, wind, the Coriolis effect using the WGS 84 model @wgs-84, Geodetic through Earth-Centered, Earth-Fixed (ECEF) to East-North-Up (ENU) coordinates conversion @kuna-galileo, and gyroscopic spin drift following the MPMM, or a Four Degree of Freedom (4DOF) model @mccoy-modern @stanag-4355. Each of these phenomena is implemented as an independent force or environment module.

_Terminal ballistics_ implements three outcomes: ricochet, penetration with residual energy tracking, and embedding. The resolution is driven by material properties assigned to surfaces. The critical ricochet angle is computed via the Wijk model, penetration depth follows an energy-based formulation @energy-penetrarion, and the velocity after ricochet is decomposed into normal and tangential components with restitution and friction coefficients. The terminal subsystem is structured as a resolver-style component that consumes a compact input description and produces a structured outcome.

The external ballistics model is limited to the MPMM formulation and does not implement a full Six Degrees of Freedom (6DOF), which is in practice is not required for routine work in exterior ballistics @mccoy-modern. Terminal ballistics presents a different kind of limitation: this is inherently material-dependent and condition-dependent, and the published research is largely empirical, derived from experimental firing data @koene-ricochet @steel-ricochet @sand-ricochet @concrete-ricochet. The formulas used in this work are therefore approximations rooted in classical physics.

=== Numerical integration

The projectile state is advanced by step-by-step numerical integration rather than analytical solutions. All integration schemes are implemented as interchangeable strategy-like components (`IIntegrator`). The Euler method with one force evaluation per step, the Second-Order Runge-Kutta (RK2) or Midpoint method with two evaluations, and the classical Fourth-Order Runge-Kutta (RK4) method with four evaluations. Higher-order methods reduce truncation error at the cost of additional computations per step. The choice of integrator is a runtime parameter, allowing the developer to trade accuracy for performance depending on the application requirements.

A limitation of fixed-step integration is that accuracy depends on the timestep chosen by the host application. Adaptive step-size control, which could dynamically adjust integration detail based on trajectory curvature, is not implemented in the current version.

=== Integration interface

The rigid body is one of the most fundamental components of every physics engine @gregory-game-engine. The framework defines a minimal abstract interface `IPhysicsBody` to avoid duplicating the engine logic. It specifies only what the simulation pipeline requires: mass, position, velocity, and force accumulation. A concrete engine integration then requires only a thin adapter bridging the host engine's rigid body to this interface.

The collision subsystem follows a similar approach. Unlike the rigid body, which participates in every simulation step, collision geometry is relevant only at the moment of impact @gregory-game-engine. The framework externalizes impact-related information into a Plain Old Data (POD) structure `ImpactInfo` that the host engine populates upon detecting a collision and passes to the stateless resolver, which returns a classified outcome and post-impact state. This avoids excessive wrapping host engine's collision system.

The library operates internally in the ENU (X — East, Y — North, Z — Up) coordinate system, required for correct physical computations. A coordinate mapping, defined once at startup, allows the user to work entirely in their engine's native convention while the framework handles all conversions transparently.

=== Build and distribution

The library is built as a static library using CMake with no external dependencies beyond the #box[C++] standard library. Components amenable to isolated unit testing are covered by a Google Test suite. A GitHub Actions pipeline builds and tests on Linux, Windows, and macOS. When a version tag is pushed, the pipeline packages prebuilt binaries for all three platforms and publishes a GitHub Release.

=== Evaluation strategy

The framework is evaluated along four directions. First, _integration effort_ is measured by deploying the library into a custom OpenGL engine and Godot Engine without modifying the library's and engine's source code. Second, _numerical accuracy_ is assessed by comparing simulated trajectories against the established ballistic calculator @jbm. Third, _runtime performance_ is profiled to confirm that the simulation loop is allocation-free and sustains real-time throughput with over a thousand simultaneous projectiles. Fourth, _terminal ballistics outcomes_ are validated through controlled impact experiments covering ricochet, penetration, multi-layer traversal, and embedding.

== Risk assessment

The strengths of the framework include a solid theoretical foundation grounded in established physical references. The modular architecture allows selective enablement of individual effects, making the library applicable across a wide range of game genres. The #box[C/C++] implementation with no external dependencies ensures broad compatibility with major game projects. The library includes built-in rigid body and collision systems, so it can be used both as a supplement to an existing physics system and as a standalone solution. Cross-platform CI with automated testing reduces the risk of platform-specific regressions.

The weaknesses include the limitation of the external ballistics model to the MPMM formulation. The atmospheric model covers only the troposphere, which prevents simulation of transcontinental or high-altitude trajectories. Due to the inherently empirical nature of terminal ballistics and the absence of a universal analytical model, the terminal module goes beyond the primary scope of the thesis and was included to deliver a complete product. The implemented formulas are classical approximations, and this area has clear room for improvement through deeper study of material science models.

The following risks were identified along with their mitigation strategies:

+ _Integration complexity._ The number of possible host environments is large, and the integration path into each of them remains largely unexplored. Mitigation: the evaluation demonstrates successful integration into two fundamentally different environments, which confirms that the interface design is sound. Further integrations, at minimum into Unreal Engine and Unity, are a natural next step.

+ _Built-in preset quality._ The built-in presets for materials, projectiles, and coefficients are values sourced by the author from available literature and may not be sufficiently accurate for all scenarios. Mitigation: all presets are replaceable and extensible components. If the user possesses more precise firing data or tabular references, they can substitute their own values without modifying the library.

+ _Cross-platform compatibility._ Differences in compilers, standard library implementations, and build toolchains across Linux, Windows, and macOS can introduce subtle issues. Mitigation: the CI pipeline builds and tests on all three platforms with every commit, catching compatibility problems before release.

+ _Single-threaded execution._ The simulation runs in a single thread, which may not fully utilize multi-core systems under heavy projectile loads. Mitigation: parallelization is the responsibility of the user's integration layer, but the architecture provides good prerequisites for it: the simulation loop is allocation-free, and there is no shared mutable state between individual projectiles.

== Experimental reproducibility and integration

The project is organized as three public GitHub repositories, all released under the MIT license:

- `BulletPhysics` — the ballistic simulation library itself, which is the primary deliverable of this thesis. It contains the full source code, test suite, documentation, and CI pipeline. The library has no dependency on graphics or engine code.

- `BulletRender` — a lightweight OpenGL-based rendering engine built specifically to visualize ballistic simulations. It handles rendering and window management but also has no dependency on physics or engine code.

- `BulletEngine` — the game engine that connects `BulletPhysics` and `BulletRender` as independent modules, providing an Entity Component System (ECS) architecture that binds physics state to visual entities. It serves as the primary demonstration and validation platform: it is the environment in which the integration of `BulletPhysics` into a custom engine was validated, and all simulation samples were implemented and tested within this engine during development.

The physics and graphics modules are fully decoupled and are connected only at the game engine level. No part of the project is subject to a non-disclosure agreement or any other access restriction. The MIT license permits unrestricted use, modification, and redistribution, including commercial applications.

=== Build reproducibility

The library is built with CMake and depends only on the #box[C++] standard library, so it can be compiled on any system with a conforming #box[C++] compiler without external packages. Google Test is used only for the test suite, organized in a separate `tests/` subdirectory, and is not required to build or use the library itself.

Build reproduction requires only cloning the repository and compiling it with a standard compiler toolchain using the root `CMakeLists.txt`. The build definition is self-contained: it collects all source files from `src/` and exposes `src/` as a public include path. No additional setup scripts, environment variables, or configuration files are required.

=== Continuous integration

The library uses GitHub Actions for continuous integration. The pipeline is organized as four sequential stages, each implemented as a separate job:

+ _Build._ The library and test executable are compiled on three platforms (Linux with GCC, Windows with MSVC, macOS with AppleClang) in parallel using a matrix strategy. Each platform uploads its build artifacts for subsequent jobs.

+ _Test._ The compiled test binary is downloaded and executed on each platform. A non-zero exit code from Google Test fails the pipeline and prevents subsequent stages from running.

+ _Package._ Triggered only by version tags. Headers are extracted from the source tree (with implementation files removed), and the compiled static library is packaged into a platform-specific archive.

+ _Release._ Collects all platform archives and creates a GitHub Release. The release includes prebuilt binaries for all three platforms alongside the source code.

On every push to `main`, the build and test stages execute automatically. When a version tag is pushed (e.g., `git tag 1.0.0 && git push origin 1.0.0`), all four stages execute and produce a release with prebuilt binaries for all three platforms. Users who do not wish to compile from source can download a ready-to-link binary from the latest release.

=== Test reproducibility

The test suite uses Google Test and targets the components most likely to break silently during refactoring. Since the tests run automatically in the CI pipeline on every push, manual test execution is unnecessary: an unnoticed broken component fails the pipeline immediately. @tab:tests summarizes the coverage.

#figure(
text(size: 10pt)[
  #table(
    columns: 3,
    align: (left, left, left),
    table.header([*Domain*], [*Test*], [*Purpose*]),
    [Math], [TestVec3], [Vec3 operations ],
    [Math], [TestIntegrator], [Integrators accuracy],
    [Math], [TestAngles], [Degree/radian conversions],
    [Math], [TestAlgorithms], [Linear interpolation],
    [Geography], [TestCoordinates], [Geodetic $arrow.l.r$ ECEF $arrow.l.r$ ENU conversion],
    [Geography], [TestCoordinateMapping], [Mapping to/from internal representation],
    [External], [TestPhysicsWorld], [Construction correctness],
    [External], [TestDragModel], [Mach-based $C_d$ lookup],
    [External], [TestCoriolis], [Dependance on latitude],
    [External], [TestSpinDrift], [Dependance on rifling twist direction ],
    [Terminal], [TestImpact], [Impact outcomes],
  )],
  caption: [Test coverage summary.]
) <tab:tests>

The force models are direct transcriptions of established physical formulas and are not unit-tested separately. Runtime behavior and visual consistency were instead verified throughout development using simulation samples built within `BulletEngine`. This is a self-contained `main()` configuration that exercises a specific aspect of the framework and can be compiled and run without additional setup beyond cloning the repository and building with CMake. @tab:samples lists the available samples.

#figure(
text(size: 10pt)[
  #table(
    columns: 2,
    align: (left, left),
    table.header([*Sample*], [*Purpose*]),
    [basic-external], [Interactive external ballistics demo],
    [basic-terminal], [Interactive terminal ballistics demo],
    [comparison-configs], [Trajectory comparison across configurations],
    [comparison-integrators], [Integrator accuracy against analytical solution],
    [comparison-costs], [Per-step cost across configurations and integrators],
    [benchmark-performance], [Scalability with increasing projectile count],
    [test-allocations], [Heap activity during simulation loop],
    [test-convergence], [Timestep convergence evaluation],
  )],
  caption: [Simulation samples overview.]
) <tab:samples>

=== Integration reproducibility

The custom engine integration is the `BulletEngine` repository itself. It includes `BulletPhysics` and `BulletRender` as Git submodules, with the engine implementation in `src/` providing the ECS layer. All simulation samples are organized in `samples/`. A single `CMakeLists.txt` at the root builds the entire project, including both submodules as independent libraries and all samples, so that cloning the repository and running CMake is sufficient to reproduce the full set of evaluation scenarios.

The Godot Engine integration is maintained in a separate repository (`BulletPhysicsGodot`). It likewise includes `BulletPhysics` as a submodule along with `godot-cpp` for the GDExtension #box[C++] bindings. The integration source code in `src/` wraps the library's abstractions into Godot-native scene tree nodes. The repository also includes a demo project with an example scene in `project/`, allowing the integration to be verified directly within the Godot editor. A `CMakeLists.txt` builds the GDExtension shared library that Godot loads as a plugin, so that cloning the repository and running CMake is also sufficient to run sample verificational project.

=== Data reproducibility

The drag curve lookup tables (G1–G8, GL) used by the library are embedded in the source code as static arrays derived from published reference data @jbm-data. The other presets are likewise defined in the source. No external data files, databases, or runtime downloads are required, which guarantees full data reproducibility without reliance on external files that could become unavailable or differ across environments.

== Sustainability and environmental impact

The most common cause of long-term software decay is dependency rot: external libraries change their APIs, build systems evolve, and package repositories eventually retire older versions. The proposed framework depends only on the #box[C++] standard library, which is governed by an ISO standard and remains stable across compiler generations. No third-party runtime dependencies, package managers, or platform-specific APIs are required. Google Test is used exclusively for the test suite and is not required for building or using the library itself. The implementation targets #box[C++20], a modern revision of the language standard available across major compiler toolchains. No compiler-specific extensions or other non-standard language features are used. As a result, the library can be built on any conforming system using CMake, while remain compilable and functional for a long time.

Long-term maintainability is further supported by the modular architecture. Each physical effect is encapsulated as an independent component behind a stable interfaces: `IForce`, `IEnvironment`, and `IIntegrator`, which allows new effects to be added and existing implementations to be replaced without modifying the rest of the codebase.

The repository itself contains a `README.md` file with build and download instructions, and a `DOCUMENTATION.md` file providing an API overview and usage examples. The project is organized into a clear and conventional directory structure. The codebase is further structured through a consistent namespace hierarchy that reflects the conceptual decomposition of the framework and prevents collisions as the project grows. These measures improve readability and lower the cost of future maintenance. The project is hosted publicly on GitHub under the MIT license, allowing unrestricted forking, modification, and redistribution. This reduces dependence on a single maintainer and increases the likelihood that the framework will remain accessible and reusable in the long term.

From an environmental perspective, the project does not involve machine learning, large-scale data processing, or permanently running cloud services. The library is a lightweight #box[C++] static library with negligible build-time requirements. The CI pipeline runs on GitHub-hosted runners only on push events, avoiding continuous resource consumption. The simulation itself is designed to be computationally efficient, as the conducted evaluation confirmed minimal CPU and memory overhead even under heavy projectile loads. Furthermore, the computational cost can be directly controlled by the choice of integration method, trading simulation fidelity for performance depending on deployment constraints.

== Employability

The project was motivated by a personal interest in game engine programming. While the physics subsystem became the thesis subject, the rendering subsystem was developed out of necessity, and implementing both provided a broader understanding of how engine components interact.

On the physics side, the work progressed from foundational mechanics into specialized ballistic literature: reference books and research papers, that required independent reading, interpretation, and synthesis into a coherent model. This process developed the ability to navigate unfamiliar scientific domains, identify relevant sources, and extract the physical principles needed to implement them in software. This skill transfers directly to the high-quality AAA game industry, where studios set the standard for physical realism.

On the software side, the project resulted in a complete, publicly released #box[C++] product applicable across projects of different scale and requirements. #box[C++] remains the foundational language of the game industry, and writing a game engine from scratch is a valuable exercise for understanding how commercial engines are structured internally. The intention is to continue developing game engine beyond the thesis, progressively implementing the remaining core subsystems to arrive at a fully functional game engine.

== Teamwork, diversity and inclusion

The thesis was developed as an individual project. Supervision was primarily oriented towards the physics domain, so detailed guidance was provided on physical modeling, while the software architecture and design decisions had to be explained by the author. The work also benefited from informal knowledge sharing within the facilities of both FEI and FIIT STU, including a shared Google Classroom group. Task management followed the iterative approach, where the implementation was progressively extended from a minimal functional core towards a more complete system. Time management was followed as described in @plan-of-work. User testing was conducted with a small group of participants, and based on their feedback minor adjustments were made. The full testing protocol is documented in @testing-protocol.

From a diversity and inclusion perspective, the framework is designed to be accessible to developers with varying levels of expertise: it can be used immediately with built-in presets for those who need a quick plug-and-use solution, while also exposing the full set of parameters and extensible interfaces for those who want to configure the simulation in detail. This design approach increases the practical usability of the framework and lowers the barrier to entry for its adoption.

= Conclusion



// Bibliography
#bibliography("citations.bib")



// Resume
#resume[]



// Appendices
#show: section-appendices.with()

#set par(first-line-indent: 0em)

= Description of digital submission

*Thesis Evidence Number:* FIIT-16768-127135

*Name of the submitted archive:* `BP_AntonDmitriev.zip`

#import "@preview/dtree:0.1.0": dtree

#dtree(```
.zip/
 BulletPhysics/                Physics library (thesis subject)
  .github/                     GitHub Actions configuration
   workflows/
    ci.yml                     CI workflow
  src/                         Library source code
   ballistics/                 Ballistic physics
    external/                  External ballistics module
     forces/                   Force models
     environments/             Environment providers
     PhysicsContext.h          Shared simulation state
     PhysicsWorld.h            Simulation pipeline
    terminal/                  Terminal ballistics module
     Impact.h                  Impact resolver
     Material.h                Material definition
   math/                       Math utilities
    Vec3.h                     3D vector type
    Integrator.h               Numerical integrators
    ...
   geography/                  Geographic utilities
    CoordinateMapping.h        Coordinate mapping
    ...
   builtin/                    Built-in implementations
    bodies/                    Rigid bodies
    collision/                 Collision detection
   PhysicsBody.h               Core body interfaces
   Constants.h                 Defined physical constants
  tests/                       Unit test suite
   ballistics/                 Ballistics tests
    external/
    terminal/
   geography/                  Geography tests
   math/                       Math tests
   CMakeLists.txt              Tests build configuration
  CMakeLists.txt               Library build configuration
  DOCUMENTATION.md             Project documentation
  LICENSE.md                   MIT license
  README.md                    Repository overview
 BulletRender/                 Graphics engine
 BulletEngine/                 Game engine
  BulletPhysics/               BulletPhysics submodule
  BulletRender/                BulletRender submodule
  src/                         Engine source code
   ecs/                        ECS architecture
  samples/                     Demonstration samples
   common/
   basic-external/
   basic-terminal/
   comparison-configs/
   comparison-costs/
   comparison-integrators/
   test-allocations/
   test-convergence/
   benchmark-performance/
  CMakeLists.txt               Engine build configuration
  LICENSE.md                   MIT license
  README.md                    Repository overview
 BulletPhysicsGodot/           Godot engine integration
  BulletPhysics/               BulletPhysics submodule
  godot-cpp/                   Godot C++ bindings submodule
  src/                         Godot extension source code
  project/                     Demonstration project
  CMakeLists.txt               Extension build configuration
  LICENSE.md                   MIT license
  README.md                    Repository overview
```)

= Technical documentation


== Setup

The library requires a C++20 compatible compiler and CMake. Google Test is required for building and running the test suite but is not needed for the library itself. No other external dependencies are required.

1. On a Debian-based Linux system, all required tools can be installed with:
```bash
sudo apt install build-essential cmake libgtest-dev
```

2. Verify the installation:
```bash
gcc --version
cmake --version
dpkg -l | grep libgtest-dev
```

== Installation

Download the prebuilt static library and headers from the GitHub releases page (https://github.com/admtrv/BulletPhysics/releases).

Alternatively, the library can be compiled from source:

1. Clone the repository:
```bash
git clone https://github.com/admtrv/BulletPhysics.git
```

2. Generate the build files:
```bash
cmake -B build
```

3. Build the project:
```bash
cmake --build build
```

4. Optionally, run the test suite:
```bash
ctest --test-dir build
```

== Developer Manual

=== Body

The library operates on the `IPhysicsBody` interface. Integrate it with your own rigid body system, or use the builtin `RigidBody` / `ProjectileRigidBody`.

For basic simulation:

```cpp
#include "PhysicsBody.h"
#include "builtin/bodies/RigidBody.h"

RigidBody body;
body.setMass(1.0);
body.setPosition({0.0, 1.5, 0.0});
body.setVelocity({20.0, 10.0, 0.0});
```

For projectile simulation with ballistic properties, use the `ProjectileSpecs` builder and `ProjectileRigidBody`:

```cpp
#include "PhysicsBody.h"
#include "builtin/bodies/RigidBody.h"

// mass kg, diameter m
auto specs = ProjectileSpecs::create(0.01, 0.00762)
    .withDragModel(DragCurveModel::G7)
// muzzle velocity, rifling direction, twist rate
    .withMuzzle(838.0, Direction::RIGHT, 12.0);

ProjectileRigidBody body(specs);
```

Or use a preset:

```cpp
auto specs = presets::Sphere();     // idealized sphere
auto specs = presets::Nato762();    // 7.62 NATO bullet

ProjectileRigidBody body(specs);
```

Drag behavior is configured either by selecting a standard drag curve or by providing a constant drag coefficient:

```cpp
// standard drag curves
specs.withDragModel(DragCurveModel::G1);
specs.withDragModel(DragCurveModel::G2);
specs.withDragModel(DragCurveModel::G5);
specs.withDragModel(DragCurveModel::G6);
specs.withDragModel(DragCurveModel::G7);
specs.withDragModel(DragCurveModel::G8);
specs.withDragModel(DragCurveModel::GL);

// constant drag coefficient
specs.withCustomDragCoefficient(0.5);
```

=== Integrator

Choose a numerical integration method:

```cpp
#include "math/Integrator.h"

EulerIntegrator euler;          // fastest, least accurate
MidpointIntegrator midpoint;    // good balance
RK4Integrator rk4;              // slowest, most accurate
```

=== Physics World

`PhysicsWorld` manages forces and environments. Environments update the shared `PhysicsContext`, then Forces read it.

```cpp
#include "ballistics/external/PhysicsWorld.h"

PhysicsWorld world;

// environments

// sea-level temp K, sea-level pressure Pa
world.addEnvironment(std::make_unique<Atmosphere>(280.0, 100000.0));
// relative humidity correction %
world.addEnvironment(std::make_unique<Humidity>(60));
// wind velocity m/s
world.addEnvironment(std::make_unique<Wind>(Vec3{0.0, 0.0, 2.0}));
// latitude/longitude in radians
world.addEnvironment(std::make_unique<Geographic>(deg2rad(48.15), deg2rad(17.11)));

// forces
world.addForce(std::make_unique<Gravity>());
world.addForce(std::make_unique<Drag>());
world.addForce(std::make_unique<Coriolis>());
world.addForce(std::make_unique<Lift>());
world.addForce(std::make_unique<Magnus>());
```

=== Simulation Loop

```cpp
double dt = 0.001;
double t = 0.0;

while (true)
{
    integrator.step(body, &world, dt);
    t += dt;

    auto pos = body.getPosition();
    // use position...
}
```

=== Coordinate Mapping

The library uses the ENU (East-North-Up) coordinate system internally: x=East, y=North, z=Up. If your engine uses a different convention, set a coordinate mapping once at startup. The integrator converts body state at step boundaries automatically.

```cpp
#include "geography/CoordinateMapping.h"

// presets
CoordinateMapping::set(mappings::ENU());       // identity (default)
CoordinateMapping::set(mappings::OpenGL());    // x=East, y=Up, z=-North
CoordinateMapping::set(mappings::Godot());     // x=East, y=Up, z=-North
CoordinateMapping::set(mappings::Unreal());    // x=North, y=East, z=Up
CoordinateMapping::set(mappings::Unity());     // x=East, y=Up, z=North
CoordinateMapping::set(mappings::Vulkan());    // x=East, y=-Up, z=-North
```

For a custom system, specify which user axis corresponds to East, North, and Up:

```cpp
// your system: x=Up, y=North, z=-East
CoordinateMapping custom(Axis::NEG_Z, Axis::POS_Y, Axis::POS_X);
CoordinateMapping::set(custom);
```

With a mapping set, pass positions and velocities in your engine's coordinate system. The library handles internal conversion and returns results in the same user space.

=== Detail Levels

Configure based on required realism level:

*Minimum (Gravity only):*
```cpp
PhysicsWorld world;
world.addForce(std::make_unique<Gravity>());
```

*+ Aerodynamic drag:*
```cpp
// for standard isa atmosphere
world.addEnvironment(std::make_unique<Atmosphere>());
world.addForce(std::make_unique<Drag>());

// mass, diameter (area auto-calculated)
auto specs = ProjectileSpecs::create(0.01, 0.00762)
    .withDragModel(DragCurveModel::G7);
```

*+ Sea-level condition correction:*
```cpp
world.addEnvironment(std::make_unique<Atmosphere>(280.0, 100000.0));
```

*+ Humidity correction:*
```cpp
world.addEnvironment(std::make_unique<Humidity>(60));
```

*+ Wind vector:*
```cpp
world.addEnvironment(std::make_unique<Wind>(Vec3{0.0, 0.0, 2.0}));
```

*+ Coriolis effect:*
```cpp
// for geographic coordinates and position-dependent gravity
world.addEnvironment(std::make_unique<Geographic>(lat, lon));
world.addForce(std::make_unique<Coriolis>());
```

*+ Spin drift (Lift + Magnus):*
```cpp
world.addForce(std::make_unique<Lift>());
world.addForce(std::make_unique<Magnus>());
// or all at once via SpinDrift::addTo(world);

// muzzle velocity, rifling direction, twist rate
specs.withMuzzle(838.0, Direction::RIGHT, 12.0);
```

=== Terminal Ballistics

Material presets for assigning a material property to an object:

```cpp
#include "ballistics/terminal/Material.h"

Material m;
m = materials::Steel();
m = materials::Concrete();
m = materials::Wood();
m = materials::Soil();
```

The terminal system is resolver-style. Fill an `ImpactInfo` structure, pass it into `Impact::resolve`:

```cpp
struct ImpactInfo {
    Vec3 normal;            // surface normal at impact point
    Material material;      // material properties of target
    double thickness;       // m, effective thickness along velocity direction
};
```

Then receive an `ImpactResult` back with classified outcome (`Ricochet`, `Penetration`, `Embed`) and post-impact data:

```cpp
struct ImpactResult {
    ImpactOutcome outcome;          // Ricochet, Penetration, Embed

    Vec3 residualVelocity;          // m/s, post-impact velocity (zero for Embed)
    double energyAbsorbed;          // J, transferred to material
    double penetrationDepth;        // m, how far into material
};
```

The returned data is then consumed by the caller to drive the corresponding response:


```cpp
#include "ballistics/terminal/Impact.h"
#include "ballistics/terminal/Material.h"

void CollisionSystem::onCollision()
{
    ...

    ImpactInfo info;
    info.normal = manifold.info.normal;
    // Wood(), Steel(), ...
    info.material = collider.getMaterial();
    // effective thickness
    info.thickness = collider.computeThickness(body.getPosition(), body.getVelocity());

    auto result = Impact::resolve(projectileBody, info);

    switch (result.outcome)
    {
        case ImpactOutcome::Ricochet:
            // your logic...
        case ImpactOutcome::Penetration:
            // your logic...
        case ImpactOutcome::Embed:
            // your logic...
    }

    ...
```

=  Work schedule <plan-of-work>

== Winter semester

#figure(
  text(size: 9pt)[
    #table(
      columns: (0.7fr, 1.7fr, 3fr),
      align: (center, left, left),
      table.header(
        [*Week*], [*Plan*], [*Result*],
      ),
      [1. − 2.],   [Set up environment],            [Initialized repository, implemented renderer],
      [3. − 4.],   [Research existing solutions],   [Studied existing solutions, outlined report structure],
      [5. − 6.],   [Study literature],              [Reviewed literature, implemented basic movement],
      [7. − 8.],   [Implement external ballistics], [Implemented gravity, drag, atmosphere, wind, Coriolis effect],
      [9. − 10.],  [Write document],                [Implemented lift and Magnus forces, refactored architecture],
      [11. − 12.], [Prepare midterm report],        [Finalized and submitted report],
    )
  ]
)

*Self-Evaluation.* The work plan for the winter semester is considered satisfied and exceeded. The depth of the physical research led to a substantially more thorough treatment than originally anticipated, resulting in a comprehensive discussion of the physical foundations of external ballistics in the midterm report.


== Summer semester

#figure(
  text(size: 9pt)[
    #table(
      columns: (0.7fr, 1.7fr, 3fr),
      align: (center, left, left),
      table.header(
        [*Week*], [*Plan*], [*Result*],
      ),
      [1. − 2.],   [Implement terminal ballistics], [Reviewed literature, implemented impact interaction],
      [3. − 4.],   [Set up engine integration],     [Worked on conference paper, refactored architecture],
      [5. − 6.],   [Set up user testing],           [Integrated into engine, conducted user testing],
      [7. − 8.],   [Write document],                [],
      [9. − 10.],  [Finalize project],              [],
      [11. − 12.], [Prepare final submission],      [],
    )
  ]
)

*Self-Evaluation.*

= Usability testing protocol <testing-protocol>

== Task specification

*Deadline:* April 26, 2026

*Expected duration:* up to one hour

=== Subject of evaluation

A #box[C++] library that provides a ready-to-use toolkit for implementing ballistic simulations. It is being evaluated against the criteria of ease of integration, API clarity, and practical applicability.

_In plain terms:_ a library that takes care of all the physics for projectile flight simulation: trajectories, gravity, and collisions. Instead of writing all of that manually, you integrate the library and use the provided tools. The goal is to determine how convenient the library is and whether it saves time, effort, and code volume compared to implementing everything from scratch.

=== Main goal

Choose any scenario, mini-project, or task of interest and implement it in two ways:
+ A full implementation of the flight physics from scratch.
+ An implementation of the same task using the library.

For students of _FYZAKPH_B (Physical basics of computer games)_: you may use the graphical ballistic simulations that were covered in your lab sessions.

After that, compare both approaches and draw a conclusion on which one is more practical from a development perspective.

In addition to the main task, you are welcome to experiment with the library further if you wish. The level of complexity is up to you: from simple gravity to atmospheric effects, wind, Earth’s rotation, projectile spin, or even ricochet and penetration. Using OpenGL for graphical simulations is optional. Creativity is encouraged.

It is preferable to upload the finished project to GitHub for easier review and as proof of completion. The suggested structure for one completed task is:

#dtree(```
task/
  from-scratch/
  with-library/

```)

=== Resources

- *Library:* \
  #h(1em) #link("https://github.com/admtrv/BulletPhysics")
- *Documentation:* \
  #h(1em) #link("https://github.com/admtrv/BulletPhysics/blob/main/DOCUMENTATION.md")
- *Usage examples:* \
  #h(1em) #link("https://github.com/admtrv/BulletEngine/tree/main/samples")

#pagebreak()

== Post-testing questionnaire

#let radio = box(circle(radius: 4pt, stroke: 0.6pt))
#let check = box(rect(width: 9pt, height: 9pt, stroke: 0.6pt))
#let blank = rect(width: 100%, height: 2.5cm, stroke: 0.5pt)
#let question(body) = block(breakable: false, below: 2.5em, body)

=== Part 1: Integration and setup

#question[
  *1. How easy was it to integrate the library into your project?*

    #h(1em) #check a) Very easy, managed without documentation \
    #h(1em) #check b) Managed with the documentation \
    #h(1em) #check c) Encountered difficulties, had to investigate further \
    #h(1em) #check d) Could not integrate the library on my own
]

#question[
  *2. How long did the initial setup take, up to the first working result?*
  
    #h(1em) #check a) Less than 15 minutes \
    #h(1em) #check b) 15–30 minutes \
    #h(1em) #check c) 30–60 minutes \
    #h(1em) #check d) More than one hour
]

#question[
  *3. Was the documentation sufficient to get started?*

    #h(1em) #check a) Yes, everything was clear on first reading \
    #h(1em) #check b) Mostly yes, but some details had to be guessed \
    #h(1em) #check c) Documentation was insufficient, often referred to examples \
    #h(1em) #check d) Documentation did not help
]

=== Part 2: API and development experience

#question[
  *4. How intuitive is the library's API?*

    #h(1em) #check a) Very intuitive — names and behavior match expectations \
    #h(1em) #check b) Mostly intuitive, but some aspects are non-obvious \
    #h(1em) #check c) Often had to guess how a particular function works \
    #h(1em) #check d) API is unclear without studying the source code
]

#question[
  *5. Were there any moments in the API that surprised or confused you?* \
  _Free-form answer_

  #blank
]

#question[
  *6. What did you feel was missing in the library?* \
  _Free-form answer_

  #blank
]

=== Part 3: Comparing the two approaches

#question[
  *7. Did the library-based implementation take less time than the from-scratch version?*

    #h(1em) #check a) Significantly less \
    #h(1em) #check b) Slightly less \
    #h(1em) #check c) About the same \
    #h(1em) #check d) More — figuring out the library took longer than writing it myself
]

#question[
  *8. Was the library-based code more compact?*

    #h(1em) #check a) Yes, noticeably less code \
    #h(1em) #check b) Slightly less \
    #h(1em) #check c) About the same \
    #h(1em) #check d) No, there was even more code
]

#question[
  *9. Which approach produced more readable and understandable code?*

    #h(1em) #check a) With the library \
    #h(1em) #check b) From scratch \
    #h(1em) #check c) About the same
]

#question[
  *10. If you had to implement a similar task in a real project, what would you choose?*

    #h(1em) #check a) The library — faster and more convenient \
    #h(1em) #check b) Write it from scratch — more control \
    #h(1em) #check c) Depends on the task
]

=== Part 4: Overall evaluation

#question[
  *11. Rate the library on each criterion from 1 to 5:*

  #figure(
    text(size: 10pt)[
      #table(
        columns: (2fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        align: (left, center, center, center, center, center),
        table.header([*Criterion*], [*1*], [*2*], [*3*], [*4*], [*5*]),
        [Integration simplicity],  [], [], [], [], [],
        [API clarity],             [], [], [], [], [],
        [Documentation quality],   [], [], [], [], [],
        [Practical applicability], [], [], [], [], [],
        [Overall impression],      [], [], [], [], [],
      )
    ]
  )
]

#question[
  *12. Main strength of the library:* \
  _Free-form answer_

  #blank
]

#question[
  *13. Main weakness of the library:* \
  _Free-form answer_

  #blank
]

#question[
  *14. Any additional comments, wishes, or remarks:* \
  _Free-form answer_

  #blank
]

#v(2em)

_Thank you for participating in the testing!_

#pagebreak()

== Test Users

#figure(
  text(size: 10pt)[
    #table(
      columns: (auto, 1fr, 1fr, 1fr),
      align: (center, center, center, center),
      table.header(
        //             Alexej   Alyona   Andreii
        [*Test User*], [*TU1*], [*TU2*], [*TU3*],
      ),
      [*Age*],                              [22], [22], [18],
      [*Gender*],                           [Male], [Female], [Male],
      [*Education*],                        [Bachelor's], [Bachelor's], [Secondary school],
      [*Physics \ experience*],             [Basic], [Basic], [Basic],
      [*C/C++ \ Programming \ experience*], [Intermediate], [Basic], [Advanced],
      [*Game \ development \ experience*],  [Intermediate], [None], [Intermediate], // None / Basic / Intermediate / Advanced
    )
  ],
  caption: [Overview of the test users.]
)

#pagebreak()

== Results

=== Completed tasks

#figure(
  text(size: 9pt)[
    #table(
      columns: (auto, 1fr, 1fr, 1fr),
      align: (left, center, center, center),
      table.header(
        [*Test User*], [*TU1*], [*TU2*], [*TU3*],
      ),
      [*Completed tasks*],        [2D and 3D \ OpenGL simulations], [Simulation \ without graphics], [2D OpenGL simulation],
      [*Code review observation*], [Wrote manual \ coordinate translation at \ the integration boundary], [Did not use \ constant drag coefficient, \ although available], [No unexpected behavior],
    )
  ],
  caption: [Completed tasks and code review observations per test user.]
)


=== Questionnaire responses

#figure(
  text(size: 9pt)[
    #table(
      columns: (auto, 3fr, 2fr, 2fr, 2fr),
      align: (center, left, center, center, center),
      table.header(
        [*№*], [*Question*], [*TU1*], [*TU2*], [*TU3*],
      ),
      table.cell(colspan: 5, align: left)[_Part 1: Integration and setup_],
      [1], [Ease of integration],      [b], [a], [a],
      [2], [Initial setup time],       [b], [a], [a],
      [3], [Documentation sufficiency],[b], [a], [a],
      table.cell(colspan: 5, align: left)[_Part 2: API and development experience_],
      [4], [API intuitiveness],        [b], [a], [a],
      [5], [Surprising or confusing moments], [No], [No], [No],
      [6], [What was missing],         [Integration scenario \ for existing projects], [Nothing, meets \ all requirements], [Nothing],
      table.cell(colspan: 5, align: left)[_Part 3: Comparing the two approaches_],
      [7], [Time spent vs. from-scratch], [b], [a], [a],
      [8], [Code compactness],            [b], [b], [c],
      [9], [Code readability],            [a], [a], [a],
      [10],[Choice for a real project],   [a], [a], [a],
      table.cell(colspan: 5, align: left)[_Part 4: Overall evaluation_],
      [11a],[Integration simplicity], [4], [5], [5],
      [11b],[API clarity],            [4], [5], [5],
      [11c],[Documentation quality],  [5], [5], [5],
      [11d],[Practical applicability],[4], [5], [5],
      [11e],[Overall impression],     [5], [5], [5],
      [12], [Main strength], [Modular, \ engine-independent, \ ready-to-use], [Convenient \ preset \ system], [Simple integration, \ C++20, \ good docs],
      [13], [Main weakness], [Higher entry barrier \ for existing projects], [—], [—],
      [14], [Additional comments], [Better onboarding, \ integration examples \ for existing projects], [—], [—],
    )
  ],
  caption: [Questionnaire responses per test user.]
) <tab:results>

=== List of problems found

+ *Manual coordinate conversion.* TU1 wrote custom conversion functions to translate between the project's internal coordinate representation and the convention expected by the library. _Resolution:_ a `CoordinateMapping` was introduced, defined once at startup, so that the user works entirely in their project's native convention while the framework handles all conversions transparently.

+ *Undiscoverable constant drag coefficient.* TU2 did not realize that a constant drag coefficient model was available, although it was already implemented. _Resolution:_ this was a documentation gap. The `DOCUMENTATION.md` file was updated to mention the constant drag coefficient model alongside the drag curve models.


= Scientific part


// #pagebreak()