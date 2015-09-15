# Architecture

This document will explore how to take what I've learned so far and refactor components into something where I can leverage more shared code between rendering types, add styling, and more diagram types more easily.

Text Renderer
input text, options { layout: [:one_line, :line_count, :ratio, :circle, :diamond, :square], style: [font, size, weight, etc] }
output render rectangle

For a flow chart renderer

Inside out render
Select relevant part of drawing


## Generalized Pipeline

Input: Representation & Style Document
  |
  v
[Representation Parser]
  |
  v
Diagram Description Data & Style Document
  |
  v
[Diagram Layout Engine]
  |
  v
Layed out Diagram Data
  |
  v
[Diagram Serializer]
  |
  v
Diagram Document (SVG)
  |
  v
[Diagram Post Processor]
  |
  v
Post-Processed Diagram Document (SVG)
  |
  v
[Diagram Transformer]   <- (To produce alternate output formats, scaling, etc.)
  |
  v
Final Output Diagram Document (SVG, PNG, PDF, etc.)

## Grid Layout Algorithm

1. Assign all members to an XY grid based on input representation
2. Compute node sizes for each node (varies by type), requires access to:
    - node contents
    - diagram style
    - path to node? (maybe)
3. Compute node positions for each node, requires access to:
    - node size
    - diagram style
    - path to node(s)?
    - resize nodes?
4. Produce output representation

TODO: handle connector paths, avoid crossings, etc.

