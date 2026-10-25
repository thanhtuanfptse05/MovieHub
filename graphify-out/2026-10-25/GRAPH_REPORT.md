# Graph Report - MovieHub  (2026-10-25)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 56 nodes · 60 edges · 11 communities (5 shown, 6 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- plugin.json
- validate-package.py
- common.ps1
- marketplace.json
- create-new-feature.ps1
- Get-NormalizedPriority
- Format-SpecKitCommand

## God Nodes (most connected - your core abstractions)
1. `Get-FeaturePathsEnv()` - 4 edges
2. `Get-RepoRoot()` - 4 edges
3. `Get-NormalizedPriority()` - 4 edges
4. `Get-SortedExtensionIds()` - 4 edges
5. `Resolve-TemplateContent()` - 4 edges
6. `author` - 3 edges
7. `owner` - 3 edges
8. `Resolve-Template()` - 3 edges
9. `read_package_file()` - 2 edges
10. `require_match()` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (11 total, 6 thin omitted)

### Community 0 - "plugin.json"
Cohesion: 0.15
Nodes (12): author, name, url, description, homepage, keywords, license, name (+4 more)

### Community 1 - "validate-package.py"
Cohesion: 0.22
Nodes (8): Check Humanizer's package files without external dependencies., read_package_file(), require_match(), json, Match, Path, pathlib, re

### Community 2 - "common.ps1"
Cohesion: 0.36
Nodes (6): Find-SpecifyRoot(), Get-CurrentBranch(), Get-FeaturePathsEnv(), Get-RepoRoot(), Resolve-SpecifyInitDir(), Save-FeatureJson()

### Community 3 - "marketplace.json"
Cohesion: 0.25
Nodes (7): description, name, owner, name, url, plugins, $schema

### Community 5 - "Get-NormalizedPriority"
Cohesion: 0.60
Nodes (5): Get-NormalizedPriority(), Get-Python3Command(), Get-SortedExtensionIds(), Resolve-Template(), Resolve-TemplateContent()

## Knowledge Gaps
- **17 isolated node(s):** `name`, `url`, `description`, `homepage`, `keywords` (+12 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 32 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `name`, `url`, `description` to the rest of the system?**
  _17 weakly-connected nodes found - possible documentation gaps or missing edges._