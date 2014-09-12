# UMLIT: UML It

(or *UML* *i*n *T*ext)

Produces a few kinds of UML diagrams from textual descriptions of the UML diagrams.

Inspired by [http://www.graphviz.org/](Graphviz) and [http://www.websequencediagrams.com/](Websequence Diagrams)

## Installation

Install it:

    $ gem install umlit

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Design

To build the diagram, the parser builds up a data structure with the following info:

1. Actors
    a. Label
    b. Style: Box (default), Stick Figure, etc.
2. Rows
    a. Row
        1. Row Number
        2. Row Starting Top
        3. Row height
    b. 

| Row                                                              |
| Left | Lifeline1 | Between1 | ... | BetweenN | LifelineN | Right |


Separate Actors from Actor headings (except for minimum width)

Left Width = Max of (width of actor[0]/2) and (Max width of actor[0].left content)

lifeline is a constant

Middle column is a 
