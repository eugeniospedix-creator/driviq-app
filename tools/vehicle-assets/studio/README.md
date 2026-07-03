# Driviq Studio Pipeline

Every vehicle asset entering Driviq passes through this pipeline. **Source material is never shown in the app.**

Marketplace downloads, commissioned GLB files, and OEM-provided models are **inputs only**.  
The **outputs** are Driviq-branded studio renders in a single visual language.

## Visual identity (non-negotiable)

All studio outputs share the canonical profile: `assets/vehicles/registry/studio-profile.v1.json`

| Property | Value |
|----------|-------|
| Background | Void black `#05080C` |
| Key light | 42° azimuth, 28° elevation, cool white |
| Rim light | Cyan `#00D4FF` |
| Camera | 3/4 front, 85mm equivalent, 5.2m distance |
| Composition | 72% vehicle scale, cinematic wide |
| Reflections | Soft cinematic clearcoat, 18% floor reflectivity |

BMW, Tesla, Audi, and Toyota must be indistinguishable in **quality and ecosystem** — only silhouette differs.

## Pipeline stages

```
1. ACQUIRE   Legal source + receipt → vault/
2. NORMALIZE Import to Blender, clean mesh, export source GLB
3. STUDIO    Render in driviq_studio_v1 scene (locked lighting/camera)
4. OUTPUT    Export hero_home, hero_garage, hero_scan, hero_report, thumbnail
5. VALIDATE  Schema + visual QA against reference fallback
6. REGISTER  build_registry.dart updates catalog
7. SHIP      Bundle or CDN
```

## Presentation roles

| Role | Use in app |
|------|------------|
| `hero_home` | Home screen — primary emotional moment |
| `hero_garage` | Garage showroom cards |
| `hero_scan` | Scan identity + running |
| `hero_report` | Report + diagnosis |
| `thumbnail` | Catalog tiles, lists |

## Pack authoring

When studio pass completes:

1. Place WebP/PNG outputs in `packs/{make}/{model}/media/`
2. Populate `manifest.json` media array
3. Set `studio.processedAt` and remove `fallbackPackId`
4. Run validate + registry build

Until then, model packs use `fallbackPackId` — users always see premium body-type art.
